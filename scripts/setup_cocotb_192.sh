#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$ROOT/.venv-cvdp-cocotb192"

python3 -m venv "$VENV"
"$VENV/bin/python" -m pip install --upgrade pip
"$VENV/bin/python" -m pip install -r "$ROOT/requirements-cvdp-sim.txt"

"$VENV/bin/python" - <<'PY'
import cocotb
assert cocotb.__version__ == "1.9.2", cocotb.__version__
print("CVDP cocotb runtime ready:", cocotb.__version__)
PY

echo
echo "Use this runtime with:"
echo "export CVDP_SIM_PYTHON=\"$VENV/bin/python\""
