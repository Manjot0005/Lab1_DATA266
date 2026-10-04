# Part 3 Results

## Architecture
- CycleGAN with two ResNet-style generators and two PatchGAN discriminators
- Residual blocks per generator: 6
- Image size: 256×256
- Parameters: G_A2B 7,837,699 · G_B2A 7,837,699 · D_A 2,764,737 · D_B 2,764,737 · total 21,204,872
- Adversarial loss: least-squares (MSE); cycle and identity losses: L1
- Replay buffer of 50 generated images for discriminator updates
- Domain naming in this notebook: **A = Photo, B = Monet**

## Training Parameters
- Epochs: 30
- Batch size: 1
- Learning rate: 0.0002
- Adam beta1: 0.5
- Cycle-consistency weight (λ_cycle): 10.0
- Identity weight (λ_id): 5.0
- Archived checkpoint interval: every 5 epochs plus the final epoch
- Device: NVIDIA GeForce RTX 4090 (RunPod cloud instance)

## Design Justification
<!-- WRITE THIS SECTION YOURSELF. For each choice, give your reason and, where possible,
     point to evidence from your own results (loss curves, metrics, sample images). -->

- **6 residual blocks:** [Why 6 rather than 9 for 256×256 images? What did you trade off?]
- **λ_cycle = 10, λ_id = 5:** [What does each loss enforce? What would happen if λ_cycle were much lower?]
- **Learning rate 2e-4, β1 = 0.5:** [Why these values for GAN training? Avoid claiming you tested alternatives unless you did.]
- **LSGAN (MSE) adversarial loss:** [Why least-squares instead of the original cross-entropy GAN loss?]
- **Batch size 1:** [Why is batch size 1 common for CycleGAN / instance normalization?]
- **30 epochs:** [Why this budget? Time per epoch was about 10 minutes on the RTX 4090.]
- **Replay buffer:** [What problem does it address in discriminator training?]

## How This Model Differs From My Teammate's
<!-- WRITE THIS YOURSELF after comparing settings with your partner. -->
[Which settings differ (residual blocks, λ values, learning rate, epochs, image size), and what did the comparison show?]

## Training Behaviour and Stability
Measured values:
- NaN count: 0
- Peak generator gradient norm (before clipping): 498.97
- Final losses (epoch 30): G_total 3.109 · G_gan 1.267 · cycle 1.331 · identity 0.512 · D_A 0.156 · D_B 0.065
- Loss curves: `metrics/loss_curves.png`; per-epoch values: `metrics/training_history.csv`

Analysis:
<!-- WRITE THIS YOURSELF using the loss curves. Questions to address: -->
[How did the cycle and identity losses behave over training? Why does D_B end much lower than D_A,
and what does the rising G_gan loss suggest about the Monet-side discriminator vs. the generator?
When did the gradient-norm spike occur, and did training stay stable?]

## Local Evaluation

### Photo → Monet
- Local FID (TorchMetrics, max 200 images): 109.370598
- Local KID: 0.008050
- Generative precision: 0.520000
- Generative recall: 0.585000
- Cycle L1: 0.081459
- LPIPS (input vs. cycle reconstruction): 0.167825
- Content cosine similarity (input vs. translation): 0.791598

### Monet → Photo
- Local FID (TorchMetrics, max 200 images): 112.764648
- Local KID: 0.019937
- Generative precision: 0.720000
- Generative recall: 0.395000
- Cycle L1: 0.066821
- LPIPS (input vs. cycle reconstruction): 0.221538
- Content cosine similarity (input vs. translation): 0.840300

### Interpretation
<!-- WRITE THIS YOURSELF. -->
[What do the precision/recall differences between directions mean? Is the cycle constraint working,
based on cycle L1 and LPIPS? How do the metrics relate to what you see in the images?]

## Official Kaggle Evaluation
Computed with the course-provided evaluator (`evaluate_local.ipynb`, executed outputs saved),
using the first 300 sorted images per folder.

| Direction (evaluator naming) | Official FID | Official MiFID |
|---|---|---|
| Photo → Monet (evaluator "B2A") | 96.616 | 0.4026 |
| Monet → Photo (evaluator "A2B") | 100.858 | 0.4166 |
| **Submitted average** | **98.736938** | **0.409615** |

- Kaggle score file: `submission.csv` (`ID,FID,MiFID`, one result row), uploaded unchanged
- Team name: PairProgramming_Team_[NN]
- Leaderboard rank: [record after submission — public/private]
- Lower FID and MiFID are better.

Notes on the official evaluation:
- **Direction naming:** the official evaluator uses A = Monet, B = Photo, the reverse of this notebook.
  Its `pred_B2A` folder contains this model's Photo → Monet outputs (`G_A2B`), and its `pred_A2B` folder
  contains this model's Monet → Photo outputs (`G_B2A`).
- **Evaluator change:** the only change besides `BASE` was removing the `disp=False` argument from
  `scipy.linalg.sqrtm`, which the installed SciPy version does not accept. The computation is unchanged.
- **"MiFID" definition:** in the course evaluator, MiFID is the mean cosine distance between
  index-paired Inception features of real and generated images, not the standard memorization-penalized FID.
- **Local vs. official FID:** the local TorchMetrics FID uses up to 200 images and a different implementation
  and real-image set, so the two values are not directly comparable.

## Visual Quality
<!-- WRITE THIS YOURSELF after reviewing outputs/pred_A2B/ and outputs/pred_B2A/.
     See failure_analysis.md for the three concrete failure cases. -->
[What works well in the translations? What typical artifacts or failures appear?]

## Human Audit
<!-- Fill after both raters complete human_audit_30.csv and the audit cell is rerun. -->
- Mean scores (style / content / artifacts): [from audit cell]
- Percent agreement and quadratic-weighted Cohen's kappa: [from audit cell]
- Blinding procedure: [describe how outputs were anonymized between raters]

The 1–5 ratings are ordinal, so quadratic-weighted Cohen's kappa is reported in addition to exact
percent agreement.

## Runtime
- Total parameters: 21,204,872
- Training time: 18,249 s (about 5.1 hours)
- Images/sec: 23.14
- Peak GPU memory: 2,046.5 MB

## Limitations and Future Work
- Local FID/KID use at most 200 samples per direction and should not be compared directly with the official values.
- LPIPS here measures input vs. cycle reconstruction, not input vs. translation.
- Scalar metrics do not capture every artifact, so visual review and the two-rater audit remain important.
- Evaluation feature extractors (Inception, ResNet, AlexNet for LPIPS) use pretrained weights for
  evaluation only; the submitted images are produced solely by the trained CycleGAN generators.
- [Your own limitations and what you would try next.]

## Reproducibility and Evidence
- Raw training log (all 30 epochs): `reproducibility/raw_logs/Kavya_task3_full.log`
- Environment manifest: `reproducibility/manifests/Kavya_task3_manifest.txt`
- Final generator weights (used for all reported results): `checkpoints/full/generators_final.pt`
- Full resume checkpoint and epoch snapshots (~250 MB each) exceed GitHub's 100 MB limit:
  [Google Drive link]

## Files
- Training notebook: `src/Part3_CycleGAN_VSCode.ipynb`
- Official evaluator (executed): `evaluate_local.ipynb`
- Official evaluation images (300 per direction): `outputs/official_photo2monet/`, `outputs/official_monet2photo/`
- Evaluator folder links: `official_eval_data/`
- Local evaluation images (200 per direction): `outputs/pred_A2B/`, `outputs/pred_B2A/`
- Metrics: `metrics_report.csv`, `full_metrics_report.csv`, `metrics/loss_curves.png`, `metrics/training_history.csv`
- Human audit: `human_audit_30.csv`
- Kaggle score file: `submission.csv`
- Failure analysis: `failure_analysis.md`
