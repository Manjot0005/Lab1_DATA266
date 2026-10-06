# Task 3 — Failure Analysis (manjot)

- **Model analysed:** run 4A, `checkpoints/20261004_132142_r4A_generators_best.pt` (official FID 96.597, MiFID 0.411)
- **Evidence:** `full_metrics_report_run*.csv`, `output_format_study.csv`, `reproducibility/raw_logs/*fid_history.csv`,
  `sample_preds/`, `training_milestones/`

Part A uses the measured metrics. Part B is a visual review of individual outputs.

## Part A — Failures visible in the metrics

### A1. Monet → photo is the weak direction (low coverage)
| | B2A (photo→Monet) | A2B (Monet→photo) |
|---|---|---|
| FID | 95.64 | 97.66 |
| KID | 0.0058 | 0.0147 (2.5× worse) |
| Recall | 0.68 | **0.33** |

**Failure type:** limited diversity / coverage. Most generated photos look plausible (precision 0.68), but together
they cover only about a third of the variety of real photos.
**Cause:** G_AB learns from only 300 Monet inputs. Paintings also lack the information a photo needs: fine texture,
sharp edges, sensor noise and depth of field all have to be invented.
**Fix to test:** stronger augmentation on the Monet side (crops, flips, colour jitter on the G_AB input); a multi-scale
discriminator for D_B; a higher identity-loss weight only for G_AB.

### A2. Trade-off between style strength and content (λ_cyc)
Lowering λ_cyc to 5 (run 4B) produced more painterly outputs: LPIPS input↔output 0.37 vs 0.33, and the best B2A FID
(95.10). But content preservation dropped (SSIM 0.685 vs 0.727), photo cycle L1 rose (0.089 vs 0.070) and A2B FID got
worse by 2.3.
**Failure type:** under-constrained translation. With a weaker cycle term the generator is freer to change scene content.
**Fix to test:** a separate λ_cyc per direction (5 for photo→Monet, 10 for Monet→photo).

### A3. Results depend on the seed
The same configuration with seed 7 (run 4C) scored 98.14 vs 96.65: a 1.5-FID spread, larger than the λ_cyc effect.
**Failure type:** high run-to-run variance, which makes any single-run comparison unreliable.
**Fix to test:** three seeds per configuration; average EMA weights across seeds, or keep the best seed by validation FID.

### A4. Metric sensitivity to file format
The same run-3 generator scored PNG 104.74 → JPEG q95 102.10 → JPEG q75 100.90 (`output_format_study.csv`).
**Failure type:** an evaluation artefact, not a model failure. Inception features react to JPEG compression, and the
real Kaggle images are JPEG at about q75, so lossless outputs look "different" to the metric.
**What was done:** outputs are saved at q75 to match the reference data, and this is documented openly. It shows that
an FID gap of about 1–4 points can come from post-processing alone, so small FID differences between submissions
should be read with care.

### A5. Negative experiment: resize-conv upsampling with λ_id 0.1 (run 2)
At epoch 150, run 2 had FID 124.88 vs 116.84 for run 1.
**Failure type:** a design change that hurt. A lower identity weight removes the constraint that keeps colours stable,
and the resize-conv decoder learned more slowly.
**What was done:** stopped early; both changes reverted for run 3.

### A6. Noisy FID during training
The quick FID moved by ±2–5 between checks 10 epochs apart, for example run 1: 113.9 → 115.5 → 113.3 at epochs 170–190.
Picking the final epoch would therefore be partly luck.
**What was done:** best-checkpoint selection on the quick FID, plus EMA weights (run 4). EMA smooths this oscillation
and gave the lowest FIDs.

## Part B — Visual failure cases (from my 30-pair human audit)

From `human_audit/ratings_manjot.csv` (run 4A, seed 266). Images: `human_audit/img/<id>_photo.jpg` and `<id>_monet.jpg`.

| # | Audit id (file) | Score | What goes wrong (my note) | Failure type |
|---|---|---|---|---|
| 1 | 01 (`7c384a7ede.jpg`) | 1 | green-olive stain over night sky; darkness lost | colour/illumination shift |
| 2 | 06 (`6d75effae7.jpg`) | 1 | snow turned yellow-beige; sky teal | colour/illumination shift |
| 3 | 26 (`36bafe2801.jpg`) | 1 | black background turned olive green | colour/illumination shift |
| 4 | 08 (`e8a6213a64.jpg`) | 1 | red blotches on face and arm; skin texture smeared | fine-structure distortion |
| 5 | 11 (`cfbca208c3.jpg`) | 2 | purple tint on hills; patterned artifact top centre | texture artefact |
| 6 | 03 (`25eba9fa76.jpg`) | 2 | washed out; blue sky gone | washed-out palette |

Similar: washed out on 04 and 09; blocky sky on 10; colour casts on 16, 19, 30. The 18 images rated 3 had no note.

## Human audit (30 samples)

| Rater | Mean (1–3) | % rated 3 | % rated 1 |
|---|---|---|---|
| manjot | 2.47 | 60.0 % (18/30) | 13.3 % (4/30) |
| Kavya | not done (single-rater audit) | — | — |
| Cohen's κ | not computed (one rater) | | |

## Summary
The main measurable weaknesses are (1) low coverage in the Monet→photo direction, (2) a style-versus-content trade-off
controlled by λ_cyc, and (3) seed variance as large as the hyper-parameter effects. Evaluation choices (file format,
300-image FID) can move the score by several points with no change in the model, so the leaderboard number should be
read alongside KID, precision/recall and the visual review.
