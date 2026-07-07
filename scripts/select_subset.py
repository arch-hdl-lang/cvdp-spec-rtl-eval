#!/usr/bin/env python3
"""Select the CVDP pure spec-to-RTL, Icarus-supported subset.

This script reads CVDP metadata and prompts, but it never writes solution text
or reference RTL from `output.response` / `output.context`.
"""

from __future__ import annotations

import argparse
import json
import os
import re
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_JSONL = Path("~/github/cvdp_benchmark/full_dataset/cvdp_v1.0.4_nonagentic_code_generation_no_commercial.jsonl").expanduser()
DEFAULT_OUT = ROOT / "manifests" / "cvdp_spec_icarus.json"

COMPLETION_OR_FIX_RE = re.compile(
    r"\b("
    r"complete|fix|debug|modify|repair|correct|"
    r"given\s+partial|"
    r"partial\s+(?:systemverilog|verilog|rtl|code|module)|"
    r"existing\s+(?:systemverilog|verilog|rtl|code|module)|"
    r"provided\s+(?:partial\s+)?(?:systemverilog|verilog|rtl|code|module)"
    r")\b",
    re.IGNORECASE,
)

SPEC_VERB_RE = re.compile(r"\b(create|design|write|implement|develop)\b", re.IGNORECASE)

# This prompt is a pure module specification written descriptively rather than
# imperatively, so it has no "design/write/create" verb.
PURE_SPEC_ALLOWLIST = {
    "cvdp_copilot_morse_code_0001",
}


def parse_env(env_text: str) -> dict[str, str]:
    env = {}
    for line in env_text.splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env[key.strip()] = value.strip()
    return env


def category(entry: dict) -> str:
    return next(c for c in entry["categories"] if c.startswith("cid"))


def load_entries(path: Path) -> list[dict]:
    with path.open() as f:
        return [json.loads(line) for line in f]


def classify(entry: dict) -> tuple[bool, list[str]]:
    reasons = []
    env = parse_env(entry.get("harness", {}).get("files", {}).get("src/.env", ""))
    sim = env.get("SIM", "icarus").lower()
    prompt = entry.get("input", {}).get("prompt", "")

    if sim != "icarus":
        reasons.append("sim_not_icarus")
    if entry.get("input", {}).get("context"):
        reasons.append("has_input_context")
    if COMPLETION_OR_FIX_RE.search(prompt):
        reasons.append("completion_or_fix_wording")
    if not SPEC_VERB_RE.search(prompt) and entry["id"] not in PURE_SPEC_ALLOWLIST:
        reasons.append("no_spec_verb")

    return not reasons, reasons


def manifest_record(entry: dict) -> dict:
    env = parse_env(entry.get("harness", {}).get("files", {}).get("src/.env", ""))
    return {
        "id": entry["id"],
        "category": category(entry),
        "difficulty": next(c for c in entry["categories"] if c in {"easy", "medium"}),
        "toplevel": env.get("TOPLEVEL"),
        "module": env.get("MODULE"),
        "sim": env.get("SIM", "icarus"),
        "toplevel_lang": env.get("TOPLEVEL_LANG", "verilog"),
        "verilog_sources": env.get("VERILOG_SOURCES", ""),
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--jsonl", type=Path, default=Path(os.environ.get("CVDP_JSONL", DEFAULT_JSONL)))
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT)
    args = ap.parse_args()

    entries = load_entries(args.jsonl.expanduser())
    selected = []
    excluded_reasons = Counter()
    selected_by_category = Counter()

    for entry in entries:
        include, reasons = classify(entry)
        if include:
            rec = manifest_record(entry)
            selected.append(rec)
            selected_by_category[rec["category"]] += 1
        else:
            for reason in reasons:
                excluded_reasons[reason] += 1

    selected.sort(key=lambda r: r["id"])
    manifest = {
        "name": "cvdp-v1.0.4-pure-spec-to-rtl-icarus",
        "source_dataset": str(args.jsonl.expanduser()),
        "selection_rules": [
            "SIM is icarus according to harness src/.env",
            "input.context is empty",
            "prompt does not request completion, repair, modification, bug fixing, or partial-code filling",
            "prompt is an imperative pure spec-to-RTL request, plus explicit pure-spec allowlist entries",
            "manifest excludes output.response and output.context solution data",
        ],
        "total_source_records": len(entries),
        "selected_count": len(selected),
        "selected_by_category": dict(sorted(selected_by_category.items())),
        "excluded_reason_counts": dict(sorted(excluded_reasons.items())),
        "pure_spec_allowlist": sorted(PURE_SPEC_ALLOWLIST),
        "problems": selected,
    }

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"selected {len(selected)} / {len(entries)} problems")
    print(f"by category: {dict(sorted(selected_by_category.items()))}")
    print(f"wrote {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

