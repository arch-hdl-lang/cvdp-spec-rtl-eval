#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

./scripts/select_subset.py >/tmp/cvdp_select_subset.log

python3 - <<'PY'
import json
from pathlib import Path

m = json.loads(Path("manifests/cvdp_spec_icarus.json").read_text())
assert m["selected_count"] == 50, m["selected_count"]
assert m["selected_by_category"] == {"cid002": 2, "cid003": 48}, m["selected_by_category"]
for p in m["problems"]:
    assert p["sim"].lower() == "icarus", p
    for forbidden in ("prompt", "response", "output", "context"):
        assert forbidden not in p, (forbidden, p)
print("CVDP setup check OK")
PY

