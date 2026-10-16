#!/usr/bin/env bash
# Full pipeline. N_CALLS defaults to 15 (the setting used for the outputs shipped here).
# Use N_CALLS=200 for the full search budget (about 8x longer).
set -euo pipefail
N_CALLS="${N_CALLS:-15}"
export TF_CPP_MIN_LOG_LEVEL=3
cd "$(dirname "$0")/src"
python calibrate.py        > ../outputs/calibrate.log
python generate_dataset.py > ../outputs/generate_dataset.log
python validation.py --n-calls "$N_CALLS" --verbose 2>&1 | tee ../outputs/validation_run.log
python scheduler.py --scenarios 200 2>&1 | tee ../outputs/scheduler_run.log
python make_figures.py
