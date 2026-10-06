#!/usr/bin/env bash
# One-command smoke test: Manjot's Task 2 notebook on a small subset.
# Uses whichever python is active (e.g. the .venv from the README).
set -euo pipefail
PY="${PYTHON:-python}"
"$PY" -m ipykernel install --user --name lab1-smoke --display-name "lab1 smoke" >/dev/null
cd "$(dirname "$0")/task2_sentiment/manjot/src"
T2_MODE=smoke "$PY" -m jupyter nbconvert --to notebook --execute --output task2_smoke.ipynb \
  --ExecutePreprocessor.timeout=-1 --ExecutePreprocessor.kernel_name=lab1-smoke task2.ipynb
echo "== smoke metrics"; cut -d, -f1-4 ../metrics_report_smoke.csv
