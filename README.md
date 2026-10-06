# DATA 266 Lab 1 — Team 48 (Manjot Kaur, Kavya Ayyappan)

combined report -> under the name "Lab 1 - Team 48.pdf"  : https://drive.google.com/drive/folders/1FfUAhd_4UzgtnglmbtfXi8mLuMJyVtMU

Three deep-learning systems built from scratch, each implemented independently by both members:

| Part | Task | Best result |
|---|---|---|
| 1 | Character-level GPT on TinyStories | Manjot: perplexity 1.843, 80.6% next-character accuracy |
| 2 | Yelp Polarity sentiment classification (6 models) | Manjot's BiGRU + attention: 95.95% test accuracy |
| 3 | CycleGAN photo ↔ Monet (Kaggle "I'm Something of a Painter Myself") | Manjot's run 4A: official FID 96.597, MiFID 0.411, Kaggle −48.50 |

Full write-up: `report/DATA266_Lab1_Report_Team_48.pdf`.

## Repository layout

```
task1_llm/
  manjot/   src/task1.ipynb, results.md, failure_analysis.md, metrics_report.csv
  kavya/    src/task1.ipynb, results.md, failure_analysis.md, metrics_report.csv
task2_sentiment/
  manjot/   src/task2.ipynb (source), src/task2_full.ipynb (executed full run), results.md,
            failure_analysis.md, metrics_report.csv, mcnemar_tests.csv, slice_metrics.csv
  Kavya/    src/task2.ipynb, results.md, failure_analysis.md, metrics_report.csv, mcnemar_tests.csv
task3_gan/
  manjot/   src/task3.ipynb (training), src/task3_run1 … run4C.ipynb (executed runs),
            official_eval/Part3_Evaluation_Script.ipynb, submission.csv, full_metrics_report*.csv,
            results.md, failure_analysis.md, human_audit/
  Kavya/    src/Task3.ipynb, evaluate_local.ipynb, submission.csv, full_metrics_report.csv,
            results.md, failure_analysis.md, human_audits*.csv
reproducibility/
  manifests/   environment and hardware manifests per member and task
  raw_logs/    training logs, configs and FID histories
report/        team report (PDF)
run_smoke.sh   one-command smoke test
```

Each member folder has its own `results.md` (architecture, parameters, results, analysis) and
`failure_analysis.md`.

## Setup

Python 3.11 or 3.12. A GPU is needed for full training runs; the smoke test runs on CPU or Apple Silicon.

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

Final runs used PyTorch 2.8.0 + CUDA 12.8 on an NVIDIA GeForce RTX 4090 (RunPod). Exact package versions
for each run are in `reproducibility/manifests/`.

## One-command smoke test

```bash
source .venv/bin/activate && bash run_smoke.sh
```

This runs Manjot's Task 2 notebook in smoke mode (small subset, about 2 minutes) and prints the metrics
table. Expected accuracy is about 0.72 / 0.78 / 0.73 for the three models.

## Re-running the full experiments

| Part | Command (from the member's `src/` folder) |
|---|---|
| 1 (Manjot) | set `SMOKE = False` in `task1.ipynb`, then `jupyter nbconvert --to notebook --execute --inplace task1.ipynb` |
| 2 (Manjot) | `T2_MODE=full jupyter nbconvert --to notebook --execute --output task2_full.ipynb task2.ipynb` |
| 3 (Manjot) | `SMOKE=0 T3_EPOCHS=1000 T3_TAG=r4A jupyter nbconvert --to notebook --execute --output task3_run4A.ipynb task3.ipynb`, then run `official_eval/Part3_Evaluation_Script.ipynb` |
| Kavya | open the notebook in each `Kavya/src/` folder and run all cells (run mode is set in the first cells) |

Task 3 needs the Kaggle data in `task3_gan/data/` (see below).

## Large files (Google Drive)

GitHub rejected pushes of the large binaries, so they are in this Drive folder (view access for anyone
with the link):

**https://drive.google.com/drive/folders/1FfUAhd_4UzgtnglmbtfXi8mLuMJyVtMU?usp=share_link**

| File | Contents | Put it at |
|---|---|---|
| `lab1_task3_data.zip` (131 MB) | Kaggle Monet/photo data + `real_stats.npz` | unzip at repo root → `task3_gan/data/` |
| `lab1_task3_predictions_manjot.zip` (98 MB) | `pred_B2A/` (7,038 images), `pred_A2B/` (300), `submission.csv` | unzip at repo root → `task3_gan/manjot/outputs/` |
| `lab1_checkpoints_manjot.zip` (319 MB) | Task 1 epoch-10, Task 2 three models, Task 3 run-4A generators | unzip at repo root → each `task*/manjot/checkpoints/` |
| `checkpoints_task1.zip` (48 MB, Kavya) | Kavya's Task 1 final checkpoint | `task1_llm/kavya/checkpoints/full/` |
| `checkpoints_task2.zip` (74 MB, Kavya) | Kavya's Task 2 MLP, TextCNN, BiLSTM weights | `task2_sentiment/Kavya/checkpoints/` |

Manjot's zips keep the repo-relative paths, so `unzip <file>.zip` from the repo root puts everything in place.
Kavya's final Task 3 generator is in the repo: `task3_gan/Kavya/checkpoints/full/generators_final.pt`.

## Notes

- All models are trained from scratch. No pretrained weights generate or classify anything; pretrained
  Inception / LPIPS networks are used only inside the Task 3 evaluation metrics.
- Task 3 FID and MiFID are taken only from the course's official evaluation script.
- No credentials are stored in this repository (Kaggle access uses `~/.kaggle/`).
