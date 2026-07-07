#!/usr/bin/env python3
"""Write per-problem full prompt files into the lane run directories."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PROMPTS = {
    "direct-verilog": ROOT / "prompts" / "direct-verilog.jsonl",
    "arch": ROOT / "prompts" / "arch.jsonl",
}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--lane", choices=["direct-verilog", "arch"], required=True)
    ap.add_argument("--prompts", type=Path)
    args = ap.parse_args()

    prompt_file = args.prompts or DEFAULT_PROMPTS[args.lane]
    suffix = ".sv" if args.lane == "direct-verilog" else ".arch"

    count = 0
    with prompt_file.open() as f:
        for line in f:
            rec = json.loads(line)
            problem_id = rec["id"]
            top = rec["toplevel"]
            outdir = ROOT / "runs" / args.lane / problem_id
            outdir.mkdir(parents=True, exist_ok=True)
            (outdir / f"{problem_id}_fullprompt.txt").write_text(rec["prompt"])
            (outdir / f"{problem_id}_systemprompt.txt").write_text(
                "You are an expert RTL generation agent. Follow the benchmark rules exactly.\n"
            )
            count += 1

    print(f"materialized {count} full prompts under runs/{args.lane}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
