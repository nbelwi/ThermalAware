# Thermal-Aware Construction-Stage Embodied Carbon: Reproducibility Package

**All project-level data in this package are simulated.** No field records from real construction
projects are included or used. Project labels P01 to P12 and their city/climate attributes are
simulation scenarios defined in `data/raw/MENA_Project_Dataset.xlsx`.

## Contents

| Path | Purpose |
|---|---|
| `data/raw/MENA_Project_Dataset.xlsx` | Authors' simulated scenario tables (project overview, material quantities, 60 activity thermal records) |
| `data/raw/EPD_Material_Database.xlsx` | Material emission factor reference table (ICE v3.0 based values); see `data/DATA_NOTE.md` |
| `src/calibrate.py` | Fits WBGT, phi(dT), psi(WBGT) and penalty ratio coefficients to the 60 activity records → `data/processed/calibration.json` |
| `src/generate_dataset.py` | Generates 1,440 simulated activity-day records (12 x 120, seed 42, 4.2% MCAR missingness) → `data/processed/activity_day_records.csv` |
| `src/thermal_models.py` | Thermal sub-models and Arrhenius hydration kinetics |
| `src/data_utils.py` | Fold-specific KNNImputer (k = 5) and scaler, fitted on training records only; target never imputed |
| `src/pinn.py` | Physics-informed network (TensorFlow): penalty head + hydration head with Arrhenius residual (lambda1) and dT monotonicity penalty (lambda2) |
| `src/validation.py` | 12-fold leave-one-project-out CV with independent Bayesian hyperparameter search inside every outer fold |
| `src/scheduler.py` | Stochastic time-indexed MILP (PuLP/CBC, SAA with S = 200 scenarios); exact formulation in the module docstring |
| `src/make_figures.py` | Results figures built only from `outputs/` |
| `run_all.sh` | Runs the full pipeline |

## Run

```bash
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
bash run_all.sh                 # search budget 15 per fold (setting used for shipped outputs)
N_CALLS=200 bash run_all.sh     # full search budget
```

Seeds: numpy and TensorFlow 42; fold k uses seed 42 + k. Fold order P01 to P12.

## Outputs shipped in this package

Produced by the run recorded in `outputs/*.log` (Python 3.12, TensorFlow 2.21.0 CPU,
scikit-optimize 0.10.2, PuLP 2.7.0 with bundled CBC 2.10.3, single CPU core).

| File | Content |
|---|---|
| `outputs/fold_k/hparam_log.json` | Every Bayesian search iteration of fold k, selected configuration, calibration split, imputer fit size |
| `outputs/fold_k/predictions.csv` | Held-out predictions for fold k |
| `outputs/lopo_folds.csv` | Per-fold RMSE, MAE, MAPE, R2, selected hyperparameters |
| `outputs/lopo_summary.json` | Mean metrics and project-level bootstrap 95% CI of MAPE (1,000 resamples) |
| `outputs/scheduling/Pxx_cbc.log` | Raw CBC solver log per project |
| `outputs/scheduling/scheduling_results.csv` | Per-project solver status, relative gap, size, solve time, baseline vs optimised EC |
| `outputs/scheduling/schedules.csv` | Baseline and optimised start periods per activity |
| `figures/` | PNG (600 dpi) and PDF figures |

`outputs/validation_run.log` records the run as executed: folds 9 to 12 were resumed with
`--folds` after the process was interrupted, and an interrupted partial attempt of fold 12 appears
before the completed one. Each fold is independent, so resuming does not change any fold's result.

Exact numerical agreement across machines is not guaranteed for TensorFlow training
(floating point ordering, oneDNN); CBC results are deterministic for a given version.

## Important

The sheets `PINN LOPO-CV` and `Scheduling Optimisation` inside `MENA_Project_Dataset.xlsx`
are earlier tabulated values and are **not** produced by this code. All results reported from
this package must be taken from `outputs/`.
