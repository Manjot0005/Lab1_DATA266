# Part 3 Results

## Architecture
- CycleGAN with two generators and two PatchGAN-style discriminators
- Residual blocks per generator: 6
- Image size: 256x256
- This configuration must differ from teammates' CycleGAN settings.

## Training Parameters
- Epochs: 30
- Batch size: 1
- Learning rate: 0.0002
- Adam beta1: 0.5
- Cycle-consistency weight: 10.0
- Identity weight: 5.0
- Archived checkpoint interval: every 5 epochs plus the final epoch
- Device: NVIDIA GeForce RTX 4090

## Checkpoints
- `checkpoints/full/latest_checkpoint.pt`: full resume state including optimizers
- `checkpoints/full/generators_final.pt`: compact generator-only inference/demo checkpoint

## Local Evaluation

### Photo → Monet
- Local FID (TorchMetrics, max 200 images): 109.370598
- Local KID: 0.008050
- Generative precision: 0.520000
- Generative recall: 0.585000
- Cycle L1: 0.081459
- LPIPS (input vs. cycle reconstruction): 0.167825
- Content cosine similarity: 0.791598

### Monet → Photo
- Local FID (TorchMetrics, max 200 images): 112.764648
- Local KID: 0.019937
- Generative precision: 0.720000
- Generative recall: 0.395000
- Cycle L1: 0.066821
- LPIPS (input vs. cycle reconstruction): 0.221538
- Content cosine similarity: 0.840300

## Official Kaggle Evaluation
- Official FID: 98.736938
- Official MiFID: 0.409615

- Kaggle CSV format: `ID,FID,MiFID` with exactly one result row
- Team name: PairProgramming_Team_##
- Leaderboard rank: Not recorded yet
- Lower FID and MiFID are better.
- Official score evidence: `outputs/official_evaluation.txt`
- Kaggle score file: `submission.csv`

The local TorchMetrics FID above is **not the same metric run** as the official competition FID.
The official FID/MiFID values in `submission.csv` must come directly from the provided competition
evaluation script.

## Human Audit
- Human audit not yet completed. Fill both rater columns in `human_audit_30.csv`, then rerun the audit, metrics, and results cells.

The 1–5 ratings are ordinal, so quadratic-weighted Cohen's kappa is reported in addition to exact
percent agreement.

## Runtime
- Total parameters: 21,204,872
- Training time (s): 18249.07
- Images/sec: 23.1398
- Peak GPU memory (MB): 2046.54

## Limitations
- Local FID/KID use at most 200 samples per direction and should not be compared directly with official Kaggle MiFID/FID.
- LPIPS measures input vs. cycle reconstruction.
- Reviews of visual failures and the two-rater audit remain important because scalar metrics do not capture every artifact.
- Evaluation feature extractors may use pretrained weights, but the submitted images are produced only by the trained CycleGAN generators.

## Files
- Checkpoints: `checkpoints/full/`
- Local evaluation images: `outputs/pred_A2B/`, `outputs/pred_B2A/`
- Full Photo → Monet images: `outputs/kaggle_pred_A2B/`
- Official evaluator stdout: `outputs/official_evaluation.txt`
- Local metrics: `metrics_report.csv`, `full_metrics_report.csv`
- Human audit: `human_audit_30.csv`
- Kaggle score file: `submission.csv`
- Generated image backup: `generated_A2B_images.zip`
- Failure analysis: `failure_analysis.md`
