# Task 3 — CycleGAN: Monet ↔ Photo (member: manjot)

Everything was trained **from scratch**. No pretrained or foundation image model generates or touches the submitted
images; the only pretrained network involved is the frozen Inception/feature extractor *inside the evaluation metrics*.
Notebook: `src/task3.ipynb`; executed runs are in `src/task3_run1.ipynb` … `src/task3_run4A/4B/4C.ipynb`.
Hardware: **NVIDIA GeForce RTX 4090** (RunPod), PyTorch 2.8 / CUDA 12.8.
Data: Kaggle *I'm Something of a Painter Myself*. Domain **A = 300 Monet paintings**, domain **B = 7,038 photos**,
all 256 × 256 JPEG.
Outputs: `pred_B2A/` (7,038 photo → Monet) and `pred_A2B/` (300 Monet → photo). Full prediction folders are on Google
Drive (see the top-level README); `sample_preds/` and `training_milestones/` in the repo hold samples.

## 1. Final submission

| | Value |
|---|---|
| Official `Part3_Evaluation_Script` FID | **96.59658** |
| Official MiFID | **0.41111** |
| Kaggle score = −(FID + MiFID) / 2 | **−48.5038** |
| Team leaderboard rank at submission | 18 |
| Submitted file | `official_eval/submission.csv` (produced by the unmodified evaluation script; only the data paths were set) |

The reported FID/MiFID come **only** from the provided evaluation script, as the TA required. The numbers in
`full_metrics_report_*.csv` come from my own in-notebook evaluator. That evaluator agrees with the official script to
about 0.05 FID (96.649 vs 96.597 for run 4A), but it is used only for diagnostics.

## 2. Model

| Part | Design | Params |
|---|---|---|
| Generators G_AB (Monet→photo), G_BA (photo→Monet) | ResNet generator: reflection-padded 7×7 conv, 2 stride-2 downsampling convs, **9 residual blocks**, 2 transposed-conv upsampling layers, 7×7 conv + tanh; instance norm; ngf = 64 | 11,378,179 each |
| Discriminators D_A, D_B | 70 × 70 PatchGAN (instance norm, LeakyReLU 0.2) | 2,764,737 each |
| Total | | 28,285,832 |

**Losses.** Adversarial + λ_cyc · cycle-consistency L1 + λ_id · λ_cyc · identity L1, with λ_cyc = 10 and λ_id = 0.5
(the CycleGAN paper values).

**Training tricks.**
- **Image pool** of 50 past fakes for the discriminators.
- **DiffAugment** on every image the discriminators see, because there are only 300 Monet paintings.
- **EMA** of the generator weights (decay 0.999) in run 4.
- **Best-checkpoint selection** by a quick 300-image FID every 10 epochs.

**Optimisation.** Adam (lr 2e-4, β = 0.5, 0.999), batch size 1. One epoch is 300 steps, i.e. one pass over the Monet set.
The learning rate is constant for the first half of training, then decays linearly to 0.

## 3. Experiments

| Run | Change vs previous | Epochs (steps) | Best quick FID during training | Final FID (300 imgs) | Kaggle-style score | Outcome |
|---|---|---|---|---|---|---|
| 1 | Baseline: paper losses, DiffAugment, image pool | 300 (90k) | see `*_024149_fid_history.csv` | 105.56 | −52.99 | Submitted |
| 2 | Resize-conv upsampling, λ_id 0.1, 400 epochs | stopped at 150 | 124.88 | — | — | **Stopped early**: at epoch 150 it trailed run 1 (116.84) by 8 FID |
| 3 | Back to transposed conv, λ_id 0.5, 450 epochs | 450 (135k) | 104.76 | 102.15 | −51.29 | Submitted |
| 3 + q75 | **Same model**, outputs re-saved as JPEG q75 instead of q95 | — | — | 100.90 | −50.66 | Submitted (see §4) |
| **4A** | + EMA generator, 1000 epochs (decay from 500), fp32 inference, JPEG q75 | 1000 (300k) | 97.90 | **96.65** (official 96.597) | **−48.50** | **Final submission** |
| 4B | 4A with λ_cyc = 5 | 1000 (300k) | 98.49 | 97.53 | −48.97 | Not submitted |
| 4C | 4A with seed 7 | 1000 (300k) | 100.06 | 98.14 | −49.28 | Not submitted |

"Final FID" is the Kaggle-style average of FID(photo→Monet vs real Monet) and FID(Monet→photo vs real photos) on the
first 300 sorted images of each folder. Fid histories for every run are in `reproducibility/raw_logs/*_fid_history.csv`.

## 4. Full metrics (`full_metrics_report_run*.csv`)

| Metric | Run 1 | **Run 4A** | Run 4B (λ_cyc 5) | Run 4C (seed 7) |
|---|---|---|---|---|
| FID photo→Monet (B2A) ↓ | 104.87 | 95.64 | **95.10** | 95.49 |
| FID Monet→photo (A2B) ↓ | 106.26 | **97.66** | 99.96 | 100.78 |
| FID Kaggle avg ↓ | 105.56 | **96.65** | 97.53 | 98.14 |
| MiFID avg | 0.4175 | **0.4112** | 0.4116 | 0.4143 |
| KID B2A ↓ (± std) | 0.0104 ± 0.0019 | **0.0058 ± 0.0016** | 0.0066 ± 0.0015 | 0.0062 ± 0.0018 |
| KID A2B ↓ | 0.0204 | **0.0147** | 0.0173 | 0.0166 |
| Precision / recall B2A | 0.36 / 0.63 | 0.45 / **0.68** | **0.47** / 0.62 | 0.46 / 0.64 |
| Precision / recall A2B | 0.60 / **0.35** | 0.68 / 0.33 | **0.69** / 0.31 | 0.67 / 0.33 |
| Cycle L1 Monet / photo ↓ | 0.073 / 0.087 | 0.058 / 0.070 | 0.065 / 0.089 | **0.056 / 0.073** |
| LPIPS input↔output B2A / A2B | 0.343 / 0.251 | 0.328 / 0.266 | **0.371 / 0.295** | 0.337 / 0.259 |
| SSIM content B2A / A2B ↑ | 0.690 / 0.804 | **0.727** / 0.822 | 0.685 / 0.803 | 0.706 / **0.828** |
| Grad-norm G mean / max | 25.4 / 143.6 | 23.8 / 143.6 | 14.8 / 127.3 | 21.7 / 161.8 |
| NaN steps | 0 | 0 | 0 | 0 |
| Training time | 2.4 h | 10.9 h | 12.2 h | 12.1 h |
| Train throughput (img/s, median) | 14.2 | 8.7 | 7.8 | 7.9 |
| Inference (img/s, B2A) | 129 | 158 | 150 | 148 |
| Peak GPU memory | 1.77 GB | 1.86 GB | 1.86 GB | 1.86 GB |

Run 1 used one GPU per pod. Runs 4B and 4C shared one 2-GPU pod, which explains their lower throughput.

## 5. Analysis

1. **Longer training plus EMA gave most of the gain.** Going from run 1 to run 4A cut the Kaggle-style FID by 8.9
   points. Both directions improved, KID B2A almost halved (0.0104 → 0.0058), and B2A precision rose from 0.36 to 0.45.
   The photo→Monet outputs are therefore closer to real Monet statistics *and* more often realistic, while recall
   (0.63 → 0.68) shows they are not collapsing onto one style. Content preservation also improved (SSIM B2A
   0.69 → 0.73; cycle L1 down about 20 %), so the gain is not bought by ignoring the input photo.
2. **Output format is part of the model's evaluation.** The run-3 generator, unchanged, scored 104.74 when saved as
   PNG, 102.10 as JPEG q95 and 100.90 as JPEG q75 (`output_format_study.csv`). The real Kaggle images are JPEG at
   about q75. Matching that compression makes the generated images' Inception statistics match the real ones, so FID
   drops by about 1.2 points with no change to the model. This is a property of the metric, not of image quality,
   and it is reported as such. Every submitted image is still a direct output of my CycleGAN.
3. **λ_cyc = 5 (4B) versus 10 (4A).** The weaker cycle constraint let the photo→Monet generator move further from the
   input (LPIPS B2A 0.37 vs 0.33, SSIM 0.685 vs 0.727). That gives the best B2A FID (95.10), but Monet→photo got worse
   (99.96 vs 97.66) and cycle L1 for photos rose. The net result is +0.9 FID worse than 4A.
4. **Seed variance is as large as the hyper-parameter effect.** With the same configuration, seed 7 (4C) landed
   1.49 FID above 4A. The 4A-vs-4B difference (0.88) is smaller than this seed spread, so **λ_cyc 10 vs 5 is not
   conclusively different**. Any ranking of these configurations needs several seeds. 4A was submitted because it was
   the best measured model, not because its configuration is proven best.
5. **Monet→photo is the harder direction.** A2B FID is above B2A in every run, and A2B recall stays around 0.33:
   the generated photos cover only a third of the variety of real photos. With only 300 Monet inputs, G_AB sees far
   less variety, and many photo features (sharp edges, sensor noise, depth of field) cannot be recovered from a painting.
6. **Where the floor is.** Two disjoint 300-image sets of *real* photos already give FID 80.5, and two halves of the real
   Monet set give 105.1 (only 150 vs 150 images). Raw photos scored as "Monet" give 126.6. At 300 images, FID has a large
   small-sample bias, so 96.6 sits much closer to the real-vs-real floor than to the do-nothing baseline. Reaching the
   −30s on the leaderboard would need an average FID near 60–70, which is **below the real-vs-real floor**. That is why
   I did not chase it.
7. **Stability.** No NaN losses and no mode collapse in any run. Gradient-norm spikes (max 127–162) were isolated and
   recovered. The quick FID was noisy from one check to the next (±2–5), so best-checkpoint selection and EMA both
   mattered.
8. **Run 2 was a negative result.** Switching to resize-convolution upsampling (meant to remove checkerboard artefacts)
   and lowering λ_id to 0.1 made learning slower: FID 124.9 vs 116.8 at the same epoch. It was stopped
   early, and run 3 reverted both changes.

## 6. Reproduce

```
cd task3_gan/manjot/src
SMOKE=1 jupyter nbconvert --to notebook --execute --output smoke.ipynb task3.ipynb          # 2-epoch check
SMOKE=0 T3_EPOCHS=1000 T3_TAG=r4A jupyter nbconvert --to notebook --execute --output task3_run4A.ipynb task3.ipynb
#  4B: add T3_LAMBDA_CYC=5 T3_TAG=r4B_cyc5      4C: add T3_SEED=7 T3_TAG=r4C_seed7
```
Then run `official_eval/Part3_Evaluation_Script.ipynb` with `GEN_A2B` / `GEN_B2A` pointing at `outputs/pred_*`.
Configs, per-step logs and FID histories: `reproducibility/raw_logs/manjot_task3_*`.
Final generator checkpoint: `checkpoints/20261004_132142_r4A_generators_best.pt`.

## 7. Limitations and future work

* Only one seed per configuration. Three or more seeds for 4A and 4B would settle the λ_cyc question.
* FID on 300 images is biased and noisy. KID (unbiased) and precision/recall are reported alongside it for that reason.
* Monet→photo realism is limited by the 300-image Monet domain. Stronger augmentation for G_AB, or a two-scale
  discriminator, are the next experiments.
* No human perceptual study beyond the audit in `failure_analysis.md`.
