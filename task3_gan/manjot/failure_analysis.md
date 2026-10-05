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

## Part B — Visual failure cases (from `sample_preds/`)

> Fill this table from your own inspection of `sample_preds/` and `training_milestones/`. Pick 5–6 clear examples and
> include file names so a grader can open them. The categories below are the usual CycleGAN failures to look for.

| # | File | Direction | What goes wrong | Failure type | Likely cause | Fix to test |
|---|---|---|---|---|---|---|
| 1 | _TODO_ | B2A | e.g. sky/water area left almost unchanged, only colour-shifted | weak stylisation on flat regions | little texture for the generator to "paint"; the cycle loss rewards copying | lower λ_id; patch-level texture loss |
| 2 | _TODO_ | B2A | e.g. people/faces/text smeared or distorted | geometry change on fine structures | CycleGAN only changes texture; Monet set has few people | — (known limitation) |
| 3 | _TODO_ | B2A | e.g. night or indoor photo turned into a washed-out daytime palette | colour/illumination hallucination | Monet set is mostly daylight landscapes | colour-histogram loss; identity loss |
| 4 | _TODO_ | A2B | e.g. "photo" still shows brush strokes or looks blurry | incomplete translation | 300 Monet inputs; A1 above | see A1 |
| 5 | _TODO_ | either | e.g. checkerboard or grid pattern | upsampling artefact | transposed convolutions | resize-conv (tried in run 2, hurt FID) |
| 6 | _TODO_ | B2A | e.g. very good result, for contrast | success case | — | — |

## Human audit (30 samples, 2 raters)

> _TODO_: 30 random photo→Monet pairs, each rated by both team members (1 = fails, 2 = partly Monet, 3 = convincing
> Monet with content kept). Report the mean score per rater and Cohen's κ for agreement.

| Rater | Mean score | % rated 3 |
|---|---|---|
| manjot | | |
| Kavya | | |
| Cohen's κ | | |

## Summary
The main measurable weaknesses are (1) low coverage in the Monet→photo direction, (2) a style-versus-content trade-off
controlled by λ_cyc, and (3) seed variance as large as the hyper-parameter effects. Evaluation choices (file format,
300-image FID) can move the score by several points with no change in the model, so the leaderboard number should be
read alongside KID, precision/recall and the visual review.
