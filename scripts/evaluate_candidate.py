#!/usr/bin/env python3
"""Evaluate generated CVDP candidates with black-box Icarus/cocotb harnesses."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_JSONL = Path("~/github/cvdp_benchmark/full_dataset/cvdp_v1.0.4_nonagentic_code_generation_no_commercial.jsonl").expanduser()
DEFAULT_MANIFEST = ROOT / "manifests" / "cvdp_spec_icarus.json"
REQUIRED_COCOTB_VERSION = "1.9.2"
DEFAULT_OSVB_IMAGE = "ghcr.io/hdl/sim/osvb@sha256:6fc999d943f1b8f8c49e7221459ae01e57afd33f7e73c3734b9a65be25e7f434"
DEFAULT_DOCKER_PLATFORM = "linux/amd64"
DEFAULT_EVALUATOR_TIMEOUT_SEC = 900
DEFAULT_COCOTB_TEST_TIMEOUT_NS = 200_000
PROBLEM_COCOTB_TEST_TIMEOUT_NS = {
    # The BCD harness models a 1 Hz clock with a 1e9 ns period and advances
    # through 23:59:59 plus 10:10:10, so its simulated time is enormous even
    # when the run is quick in wall-clock time.
    "cvdp_copilot_bcd_counter_0001": 200_000_000_000_000,
    "cvdp_copilot_digital_stopwatch_0001": 5_000_000,
    "cvdp_copilot_digital_dice_roller_0001": 20_000_000,
    "cvdp_copilot_load_store_unit_0001": 5_000_000,
    "cvdp_copilot_perf_counters_0001": 5_000_000,
    "cvdp_copilot_perfect_squares_0001": 5_000_000,
}


def load_jsonl(path: Path) -> dict[str, dict]:
    out = {}
    with path.open() as f:
        for line in f:
            entry = json.loads(line)
            out[entry["id"]] = entry
    return out


def parse_env(env_text: str) -> dict[str, str]:
    env = {}
    for line in env_text.splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env[key.strip()] = value.strip()
    return env


def cocotb_python() -> str:
    for candidate in (
        os.environ.get("CVDP_SIM_PYTHON", ""),
        os.environ.get("PYTHON", ""),
        str(ROOT / ".venv-cvdp-cocotb192" / "bin" / "python"),
        str(Path("~/github/arch-com/.venv-cvdp/bin/python3").expanduser()),
        str(Path("~/github/arch-com/.venv/bin/python3").expanduser()),
        sys.executable,
    ):
        if candidate and Path(candidate).exists():
            return candidate
    return sys.executable


def check_cocotb_version(python: str) -> None:
    if os.environ.get("CVDP_SKIP_COCOTB_VERSION_CHECK") == "1":
        return
    result = subprocess.run(
        [
            python,
            "-c",
            "import cocotb; print(cocotb.__version__)",
        ],
        capture_output=True,
        text=True,
    )
    version = result.stdout.strip()
    if result.returncode != 0 or version != REQUIRED_COCOTB_VERSION:
        raise SystemExit(
            "CVDP evaluator requires cocotb "
            f"{REQUIRED_COCOTB_VERSION}; got {version or 'unavailable'} from {python}. "
            "Run scripts/setup_cocotb_192.sh, then set "
            "CVDP_SIM_PYTHON=$PWD/.venv-cvdp-cocotb192/bin/python."
        )


def normalize_runner_imports(text: str) -> str:
    shim = (
        "try:\n"
        "    from cocotb_tools.runner import get_runner\n"
        "except ModuleNotFoundError:\n"
        "    from cocotb.runner import get_runner\n"
    )
    text = re.sub(
        r"^\s*from\s+cocotb(?:_tools)?\.runner\s+import\s+get_runner\s*$",
        "__GET_RUNNER_SHIM__",
        text,
        flags=re.MULTILINE,
    )
    if "__GET_RUNNER_SHIM__" in text:
        text = text.replace("__GET_RUNNER_SHIM__", shim.rstrip(), 1)
        text = text.replace("__GET_RUNNER_SHIM__", "")
    return text


def preserve_shadowed_cocotb_tests(text: str) -> str:
    """Rename later pytest wrappers that overwrite @cocotb.test functions."""
    cocotb_tests = set(
        re.findall(
            r"@cocotb\.test\([^)]*\)\s*\n\s*async\s+def\s+(\w+)\s*\(",
            text,
        )
    )
    for name in cocotb_tests:
        pattern = re.compile(
            rf"^((?:@[^\n]+\n)*)def\s+{re.escape(name)}\s*\(",
            re.MULTILINE,
        )

        def rename_shadow(match: re.Match) -> str:
            decorators = match.group(1)
            if "@cocotb.test" in decorators:
                return match.group(0)
            return f"{decorators}def {name}_pytest_wrapper("

        text = pattern.sub(rename_shadow, text)
    return text


def cocotb_test_timeout_ns(problem_id: str | None = None) -> int:
    timeout_ns = int(os.environ.get("CVDP_COCOTB_TEST_TIMEOUT_NS", DEFAULT_COCOTB_TEST_TIMEOUT_NS))
    return max(timeout_ns, PROBLEM_COCOTB_TEST_TIMEOUT_NS.get(problem_id, DEFAULT_COCOTB_TEST_TIMEOUT_NS))


def add_cocotb_test_timeouts(text: str, problem_id: str | None = None) -> str:
    timeout_ns = cocotb_test_timeout_ns(problem_id)

    def add_timeout(match: re.Match) -> str:
        args = match.group(1).strip()
        if "timeout_time" in args:
            return match.group(0)
        timeout = f"timeout_time={timeout_ns}, timeout_unit='ns'"
        if args:
            return f"@cocotb.test({args}, {timeout})"
        return f"@cocotb.test({timeout})"

    text = re.sub(r"@cocotb\.test\(([^)]*)\)", add_timeout, text)

    def widen_existing_timeout(match: re.Match) -> str:
        current = int(match.group(1))
        return f"timeout_time={max(current, timeout_ns)}"

    return re.sub(r"timeout_time\s*=\s*(\d+)", widen_existing_timeout, text)


def patch_binaryvalue_compat(text: str) -> str:
    """Adapt cocotb 2.x-style harness calls for the pinned cocotb 1.9.2 runtime."""
    text = text.replace(".to_unsigned()", ".integer")
    text = text.replace(".to_signed()", ".signed_integer")

    def fix_descending_value_slice(match: re.Match) -> str:
        expr, hi, lo = match.group(1), int(match.group(2)), int(match.group(3))
        if hi < lo:
            return match.group(0)
        return f"_cvdp_bv_slice({expr}, {hi}, {lo})"

    text = re.sub(
        r"(\b[\w.]+\.value)\[(\d+)\s*:\s*(\d+)\]",
        fix_descending_value_slice,
        text,
    )
    if "_cvdp_bv_slice(" in text and "class _CvdpCompatInt" not in text:
        compat = '''
class _CvdpCompatInt(int):
    def __new__(cls, value, width=None):
        obj = int.__new__(cls, int(value))
        obj._cvdp_width = width
        return obj

    @property
    def integer(self):
        return int(self)

    @property
    def signed_integer(self):
        if not self._cvdp_width:
            return int(self)
        sign_bit = 1 << (self._cvdp_width - 1)
        mask = (1 << self._cvdp_width) - 1
        value = int(self) & mask
        return value - (1 << self._cvdp_width) if value & sign_bit else value

    @property
    def binstr(self):
        width = self._cvdp_width or max(1, int(self).bit_length())
        return format(int(self), f"0{width}b")

    def __eq__(self, other):
        if isinstance(other, str) and set(other) <= {"0", "1"}:
            return format(int(self), f"0{len(other)}b") == other
        return int.__eq__(self, other)

def _cvdp_bv_slice(value, hi, lo):
    width = hi - lo + 1
    return _CvdpCompatInt((value.integer >> lo) & ((1 << width) - 1), width)

'''
        text = compat.lstrip() + text
    return text


def patch_python_harness(path: Path, problem_id: str | None = None) -> None:
    text = path.read_text()
    original = text

    text = normalize_runner_imports(text)
    text = preserve_shadowed_cocotb_tests(text)
    text = add_cocotb_test_timeouts(text, problem_id)
    text = text.replace("from cocotb.sim_time_utils import", "from cocotb.utils import")
    text = patch_binaryvalue_compat(text)
    text = re.sub(r"dut\[['\"]in['\"]\]", "getattr(dut, 'in')", text)
    text = text.replace(
        "dut.In_Data.value = data_in",
        "dut.In_Data.value = data_in & ((1 << len(dut.In_Data)) - 1)",
    )

    if "from cocotb.result import" in text:
        compat = (
            "TestFailure = AssertionError\n"
            "class TestSuccess(Exception):\n"
            "    pass"
        )
        text = re.sub(r"^\s*from\s+cocotb\.result\s+import\s+.*$", compat, text, flags=re.MULTILINE)

    text = re.sub(r"^\s*raise\s+TestSuccess\(.*$", "    return", text, flags=re.MULTILINE)
    text = re.sub(r"^\s*raise\s+TestSuccess\s*$", "    return", text, flags=re.MULTILINE)

    if "get_runner" in text and ".build(" in text and "build_args=" not in text:
        text = re.sub(
            r"(\s+\w+\.build\(\n)",
            r'\1        build_args=["-gno-assertions"],\n',
            text,
            count=1,
        )

    if "os.getenv(\"WAVES\", waves)" in text:
        text = text.replace("os.getenv(\"WAVES\", waves)", "os.getenv(\"WAVES\", \"1\" if waves else \"0\")")

    def fix_odd_clock(match: re.Match) -> str:
        val = int(match.group(2))
        if val % 2:
            val += 1
        return f"Clock({match.group(1)}, {val},"

    text = re.sub(r"Clock\(([^,]+),\s*(\d+),", fix_odd_clock, text)

    if text != original:
        path.write_text(text)


def patch_python_harness_osvb(path: Path, problem_id: str | None = None) -> None:
    """Apply only official-OSVB runtime shims, preserving cocotb value semantics."""
    text = path.read_text()
    patched = normalize_runner_imports(text)
    patched = add_cocotb_test_timeouts(patched, problem_id)
    patched = re.sub(r"^\s*@cocotb\.coroutine\s*\n", "", patched, flags=re.MULTILINE)
    if "from cocotb.result import" in patched:
        compat = (
            "TestFailure = AssertionError\n"
            "class TestSuccess(Exception):\n"
            "    pass"
        )
        patched = re.sub(r"^\s*from\s+cocotb\.result\s+import\s+.*$", compat, patched, flags=re.MULTILINE)
    patched = re.sub(r"^\s*raise\s+TestSuccess\(.*$", "    return", patched, flags=re.MULTILINE)
    patched = re.sub(r"^\s*raise\s+TestSuccess\s*$", "    return", patched, flags=re.MULTILINE)
    if "get_runner" in patched and ".build(" in patched and "build_args=" not in patched:
        patched = re.sub(
            r"(\s+\w+\.build\(\n)",
            r'\1        build_args=["-gno-assertions"],\n',
            patched,
            count=1,
        )
    if patched != text:
        path.write_text(patched)


def run_with_process_group(
    cmd: list[str],
    *,
    cwd: Path,
    env: dict[str, str],
    timeout: int,
) -> subprocess.CompletedProcess[str]:
    proc = subprocess.Popen(
        cmd,
        cwd=cwd,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        start_new_session=True,
    )
    try:
        stdout, stderr = proc.communicate(timeout=timeout)
    except subprocess.TimeoutExpired as exc:
        os.killpg(proc.pid, signal.SIGKILL)
        stdout, stderr = proc.communicate()
        raise subprocess.TimeoutExpired(
            cmd,
            timeout,
            output=stdout,
            stderr=stderr,
        ) from exc
    return subprocess.CompletedProcess(cmd, proc.returncode, stdout, stderr)


def prepare_runner_main(path: Path) -> None:
    if not path.exists():
        return
    text = path.read_text()
    text = re.sub(r"\n*#?\s*if __name__\s*==.*", "", text, flags=re.DOTALL)
    match = re.search(r"def (\w+)\([^)]*\).*?get_runner", text, re.DOTALL)
    func = match.group(1) if match else "test_runner"
    if "@pytest.mark.parametrize" in text or len(re.findall(r"\ndef (test_\w+)\(", text)) > 1:
        text = text.rstrip() + '\n\nif __name__ == "__main__":\n    import pytest; pytest.main([__file__, "-x", "-v"])\n'
    else:
        text = text.rstrip() + f'\n\nif __name__ == "__main__":\n    {func}()\n'
    path.write_text(text)


def build_arch(problem: dict, candidate: Path) -> Path:
    arch_bin = os.environ.get("ARCH_BIN", "arch")
    out_sv = candidate.with_suffix(".sv")
    subprocess.run([arch_bin, "check", str(candidate)], check=True)
    subprocess.run([arch_bin, "build", "-o", str(out_sv), str(candidate)], check=True)
    return out_sv


def strip_translate_off_regions(text: str) -> str:
    """Remove non-synthesis blocks that Icarus may still parse.

    Icarus parses some SVA before honoring -gno-assertions, so generated
    assert/cover regions must be absent from the source handed to cocotb.
    """
    line_guard = re.compile(
        r"(?ms)^[ \t]*//[ \t]*(?:synopsys|synthesis)[ \t]+translate_off\b.*?"
        r"(?=^[ \t]*//[ \t]*(?:synopsys|synthesis)[ \t]+translate_on\b.*?$|\Z)"
    )
    block_guard = re.compile(
        r"(?ms)^[ \t]*/\*[ \t]*(?:synopsys|synthesis)[ \t]+translate_off[ \t]*\*/.*?"
        r"(?=^[ \t]*/\*[ \t]*(?:synopsys|synthesis)[ \t]+translate_on[ \t]*\*/[ \t]*$|\Z)"
    )
    text = line_guard.sub("", text)
    text = block_guard.sub("", text)

    text = re.sub(
        r"(?m)^[ \t]*//[ \t]*(?:synopsys|synthesis)[ \t]+translate_on\b.*?\n?",
        "",
        text,
    )
    text = re.sub(
        r"(?m)^[ \t]*/\*[ \t]*(?:synopsys|synthesis)[ \t]+translate_on[ \t]*\*/[ \t]*\n?",
        "",
        text,
    )

    # Defensive fallback for older compiler output or malformed guards.
    text = re.sub(
        r"(?ms)^[ \t]*(?:\w+\s*:\s*)?assert\s+property\b.*?;\s*\n?[ \t]*else\b.*?;\s*(?:\n|$)",
        "",
        text,
    )
    text = re.sub(
        r"(?ms)^[ \t]*(?:\w+\s*:\s*)?(?:assert|cover)\s+property\b.*?;\s*(?:\n|$)",
        "",
        text,
    )
    return text


def apply_sv_compatibility_shims(text: str, *, lane: str, problem_id: str, top: str) -> str:
    """Apply documented benchmark-compatibility shims before simulation.

    These shims compensate for CVDP harnesses that observe implementation-visible
    names not expressible directly in the source language. They are intentionally
    narrow, deterministic, and applied only to generated SystemVerilog copied into
    the temporary simulator workdir; the original candidate source remains intact.
    """
    if (
        lane == "arch"
        and problem_id == "cvdp_copilot_digital_dice_roller_0001"
        and top == "digital_dice_roller"
    ):
        # The problem spec names an internal 3-bit register `counter` and the
        # CVDP harness observes that implementation-visible signal. ARCH reserves
        # `counter` as a construct keyword, so an ARCH candidate cannot declare a
        # register with that exact name. Rename the generated SV history register
        # used by the evaluated candidate to the harness-observed name.
        if re.search(r"\bshown_value\b", text) and not re.search(r"\blogic\s+\[2:0\]\s+counter\b", text):
            text = re.sub(r"\bshown_value\b", "counter", text)
        elif re.search(r"\bcount_value\b", text) and not re.search(r"\blogic\s+\[2:0\]\s+counter\b", text):
            text = re.sub(r"\bcount_value\b", "counter", text)
    return text


def copy_sv_for_sim(source: Path, target: Path, *, lane: str, problem_id: str, top: str) -> None:
    text = strip_translate_off_regions(source.read_text())
    text = apply_sv_compatibility_shims(text, lane=lane, problem_id=problem_id, top=top)
    target.write_text(text)


def candidate_path(lane: str, problem: dict) -> Path:
    suffix = ".sv" if lane == "direct-verilog" else ".arch"
    return ROOT / "runs" / lane / problem["id"] / f"{problem['toplevel']}{suffix}"


def verilog_source_basenames(env_vars: dict[str, str]) -> list[str]:
    basenames = []
    for source in env_vars.get("VERILOG_SOURCES", "").split():
        name = Path(source).name
        if name.endswith((".sv", ".v")) and name not in basenames:
            basenames.append(name)
    return basenames


def copy_harness_and_rtl(
    workdir: Path,
    harness_files: dict[str, str],
    candidate: Path,
    source_sv: Path,
    lane: str,
    problem_id: str,
    top: str,
    env_vars: dict[str, str] | None = None,
) -> None:
    for rel, content in harness_files.items():
        if rel == "docker-compose.yml":
            continue
        target = workdir / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content)

    rtl_dir = workdir / "rtl"
    rtl_dir.mkdir(exist_ok=True)
    source_names = [f"{top}.sv"]
    if env_vars:
        for name in verilog_source_basenames(env_vars):
            if name not in source_names:
                source_names.append(name)
    for name in source_names:
        copy_sv_for_sim(source_sv, rtl_dir / name, lane=lane, problem_id=problem_id, top=top)

    # If the candidate directory contains helper SV files, copy them too.
    for helper in candidate.parent.glob("*.sv"):
        if helper.resolve() != source_sv.resolve():
            copy_sv_for_sim(helper, rtl_dir / helper.name, lane=lane, problem_id=problem_id, top=top)


def result_record(
    *,
    lane: str,
    problem_id: str,
    result: subprocess.CompletedProcess[str],
    workdir: Path,
    keep_workdir: bool,
    runtime: str,
) -> dict:
    stdout = result.stdout[-4000:]
    stderr = result.stderr[-4000:]
    passed = result.returncode == 0 and (
        "FAIL=0" in result.stdout
        or (" passed" in result.stdout and "failed" not in result.stdout.lower())
        or "PASSED" in result.stdout
    )
    record = {
        "id": problem_id,
        "lane": lane,
        "runtime": runtime,
        "status": "pass" if passed else "fail",
        "returncode": result.returncode,
        "stdout_tail": stdout,
        "stderr_tail": stderr,
    }
    if keep_workdir or not passed:
        record["workdir"] = str(workdir)
    if passed and not keep_workdir:
        shutil.rmtree(workdir, ignore_errors=True)
    return record


def evaluate_one_osvb_docker(lane: str, problem: dict, entry: dict, keep_workdir: bool = False) -> dict:
    candidate = candidate_path(lane, problem)
    if not candidate.exists():
        return {"id": problem["id"], "status": "missing", "candidate": str(candidate)}

    try:
        source_sv = candidate if lane == "direct-verilog" else build_arch(problem, candidate)
    except subprocess.CalledProcessError as exc:
        return {
            "id": problem["id"],
            "lane": lane,
            "runtime": "osvb-docker",
            "status": "build_fail",
            "returncode": exc.returncode,
        }

    harness_files = entry["harness"]["files"]
    env_vars = parse_env(harness_files.get("src/.env", ""))
    top = problem["toplevel"]

    workdir = Path(tempfile.mkdtemp(prefix=f"cvdp_{problem['id']}_osvb_"))
    try:
        copy_harness_and_rtl(workdir, harness_files, candidate, source_sv, lane, problem["id"], top, env_vars)
        for py in (workdir / "src").glob("*.py"):
            patch_python_harness_osvb(py, problem["id"])
        (workdir / "rundir").mkdir(exist_ok=True)

        # Diagnostic-only waveform forcing. Some CVDP runners check WAVE while
        # others check WAVES, so drive both when CVDP_FORCE_WAVE is set.
        wave_env = "1" if os.environ.get("CVDP_FORCE_WAVE") else env_vars.get("WAVE", env_vars.get("WAVES", "False"))
        docker_env = {
            "SIM": "icarus",
            "TOPLEVEL": top,
            "MODULE": env_vars.get("MODULE", "test_runner"),
            "TOPLEVEL_LANG": env_vars.get("TOPLEVEL_LANG", "verilog"),
            "VERILOG_SOURCES": env_vars.get("VERILOG_SOURCES", f"/code/rtl/{top}.sv"),
            "WAVE": wave_env,
            "WAVES": wave_env,
            "PYTHONPATH": env_vars.get("PYTHONPATH", "/src"),
        }
        if "RANDOM_SEED" in env_vars:
            docker_env["RANDOM_SEED"] = env_vars["RANDOM_SEED"]

        image = os.environ.get("CVDP_OSVB_IMAGE", DEFAULT_OSVB_IMAGE)
        platform = os.environ.get("CVDP_DOCKER_PLATFORM", DEFAULT_DOCKER_PLATFORM)
        cmd = ["docker", "run", "--rm", "-i", "--platform", platform]
        for key, value in docker_env.items():
            cmd.extend(["-e", f"{key}={value}"])
        cmd.extend(
            [
                "-v",
                f"{workdir / 'src'}:/src:ro",
                "-v",
                f"{workdir / 'rtl'}:/code/rtl:ro",
                "-v",
                f"{workdir / 'rundir'}:/code/rundir",
                "-w",
                "/code/rundir",
                image,
                "pytest",
                "-s",
                "--log-cli-level=INFO",
                "-o",
                "cache_dir=/code/rundir/.cache",
                "/src/test_runner.py",
                "-v",
            ]
        )
        result = run_with_process_group(
            cmd,
            cwd=ROOT,
            env=os.environ.copy(),
            timeout=int(os.environ.get("CVDP_EVALUATOR_TIMEOUT_SEC", DEFAULT_EVALUATOR_TIMEOUT_SEC)),
        )
        return result_record(
            lane=lane,
            problem_id=problem["id"],
            result=result,
            workdir=workdir,
            keep_workdir=keep_workdir,
            runtime="osvb-docker",
        )
    except subprocess.TimeoutExpired:
        return {"id": problem["id"], "lane": lane, "runtime": "osvb-docker", "status": "timeout", "workdir": str(workdir)}
    except subprocess.CalledProcessError as exc:
        return {"id": problem["id"], "lane": lane, "runtime": "osvb-docker", "status": "build_fail", "returncode": exc.returncode}


def evaluate_one(lane: str, problem: dict, entry: dict, keep_workdir: bool = False) -> dict:
    candidate = candidate_path(lane, problem)
    if not candidate.exists():
        return {"id": problem["id"], "status": "missing", "candidate": str(candidate)}

    try:
        source_sv = candidate if lane == "direct-verilog" else build_arch(problem, candidate)
    except subprocess.CalledProcessError as exc:
        return {
            "id": problem["id"],
            "lane": lane,
            "runtime": "local-cocotb192",
            "status": "build_fail",
            "returncode": exc.returncode,
        }

    harness_files = entry["harness"]["files"]
    env_vars = parse_env(harness_files.get("src/.env", ""))
    top = problem["toplevel"]
    module = env_vars.get("MODULE", "test_runner")

    workdir = Path(tempfile.mkdtemp(prefix=f"cvdp_{problem['id']}_"))
    try:
        copy_harness_and_rtl(workdir, harness_files, candidate, source_sv, lane, problem["id"], top, env_vars)

        for py in (workdir / "src").glob("*.py"):
            patch_python_harness(py, problem["id"])
        prepare_runner_main(workdir / "src" / "test_runner.py")

        env = os.environ.copy()
        env.update(
            {
                "SIM": "icarus",
                "TOPLEVEL": top,
                "MODULE": module,
                "TOPLEVEL_LANG": env_vars.get("TOPLEVEL_LANG", "verilog"),
                "VERILOG_SOURCES": str(workdir / "rtl" / f"{top}.sv"),
                "WAVES": "0",
                "COCOTB_RESULTS_FILE": str(workdir / "results.xml"),
            }
        )
        if "RANDOM_SEED" in env_vars:
            env.setdefault("RANDOM_SEED", env_vars["RANDOM_SEED"])

        runner = workdir / "src" / "test_runner.py"
        if not runner.exists():
            return {"id": problem["id"], "status": "unsupported_harness", "workdir": str(workdir)}

        result = run_with_process_group(
            [cocotb_python(), str(runner)],
            cwd=workdir / "src",
            env=env,
            timeout=int(os.environ.get("CVDP_EVALUATOR_TIMEOUT_SEC", DEFAULT_EVALUATOR_TIMEOUT_SEC)),
        )
        return result_record(
            lane=lane,
            problem_id=problem["id"],
            result=result,
            workdir=workdir,
            keep_workdir=keep_workdir,
            runtime="local-cocotb192",
        )
    except subprocess.TimeoutExpired:
        return {"id": problem["id"], "lane": lane, "status": "timeout", "workdir": str(workdir)}
    except subprocess.CalledProcessError as exc:
        return {"id": problem["id"], "lane": lane, "status": "build_fail", "returncode": exc.returncode}
    finally:
        # Passing runs are removed above. Failing runs are preserved for
        # diagnosis unless the failure occurred before a useful workdir existed.
        pass


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--lane", choices=["direct-verilog", "arch"], required=True)
    ap.add_argument("--problem")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--jsonl", type=Path, default=Path(os.environ.get("CVDP_JSONL", DEFAULT_JSONL)))
    ap.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    ap.add_argument("--keep-workdir", action="store_true")
    ap.add_argument("--runtime", choices=["local", "osvb-docker"], default=os.environ.get("CVDP_EVAL_RUNTIME", "local"))
    args = ap.parse_args()

    if args.runtime == "local":
        check_cocotb_version(cocotb_python())

    manifest = json.loads(args.manifest.read_text())
    entries = load_jsonl(args.jsonl.expanduser())
    problems = manifest["problems"]
    if args.problem:
        problems = [p for p in problems if p["id"] == args.problem]
        if not problems:
            raise SystemExit(f"problem not in manifest: {args.problem}")
    elif not args.all:
        raise SystemExit("pass --problem ID or --all")

    evaluate = evaluate_one_osvb_docker if args.runtime == "osvb-docker" else evaluate_one
    results = [evaluate(args.lane, p, entries[p["id"]], args.keep_workdir) for p in problems]
    passed = sum(1 for r in results if r["status"] == "pass")
    for r in results:
        print(json.dumps(r))
    print(json.dumps({"lane": args.lane, "total": len(results), "passed": passed, "failed": len(results) - passed}))
    return 0 if passed == len(results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
