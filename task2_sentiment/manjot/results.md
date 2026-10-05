# Task 2 — Yelp Polarity Sentiment Classification (member: manjot)

All three models are trained **from scratch** (no pretrained embeddings or language models).
Notebook: `src/task2.ipynb` (executed full run: `src/task2_full.ipynb`). Hardware: **1× NVIDIA GeForce RTX 4090** (RunPod),
PyTorch, bf16 autocast for the baseline and Transformer, fp32 for the GRU.
Data: Hugging Face `fancyzhx/yelp_polarity` — 560,000 train / 38,000 test reviews, balanced (50 % positive).
A stratified 5 % of train (28,000) is held out as **validation** for epoch selection; the **test set was used once**.

## 1. Data preprocessing (2.1)

| Step | What was done | Why |
|---|---|---|
| Analysis | Class balance, length distribution by class, missing/empty rows, exact duplicates, train–test overlap, malformed escapes (`\n`, `\"`, HTML entities, non-ASCII) — table + `outputs/eda_length_class.png` | Required by 2.1.1; decides max length and cleaning |
| Missing / malformed | No missing or empty texts, **0** exact duplicates and **0** train–test leaks found (checks kept in the pipeline); literal `\n`/`\"` escapes and HTML entities repaired | Yelp text stores line breaks as literal `\n`; left alone they become junk tokens such as `n` |
| Lowercasing, punctuation / special-character removal | regex tokeniser `[a-z0-9]+` | Required |
| **Negation-aware contractions** | `don't → do not`, `can't → can not`, `won't → will not` | Keeps the negation as its own token |
| **`!` → `xxexcl` token** | runs of `!` become one token before punctuation removal | Exclamations carry sentiment |
| Stop-word removal | scikit-learn English list **minus** sentiment-bearing words (no, not, never, but, however, very, too, only, …) | Required; plain lists delete "not" and "but" |
| **Lemmatisation** | WordNet (verb, then noun) | Required (stemming *or* lemmatisation); keeps real words, unlike the stemming used by teammate Kavya |
| Tokenisation & vocabulary | top 60,000 words with count ≥ 3 (`<pad>`=0, `<unk>`=1); 180,141 distinct tokens in train; test OOV rate **0.50 %** | |
| Sequence length | 256 tokens, **head + tail truncation** (first 128 + last 128) | Median review is 49 tokens after cleaning (p95 = 184, p99 = 299), so only **1.7 %** are truncated, and those keep their ending, where the verdict usually is |
| Embeddings | learned from scratch inside every model (100-d baseline, 128-d GRU / Transformer) | Required: no pretrained vectors |

**Preprocessing ablation** (same fastText baseline, 60k-review subset, 1 epoch — `preprocessing_ablation.csv`):

| Variant | Vocab | Accuracy | Macro-F1 |
|---|---|---|---|
| basic (lowercase + punctuation only) | 30,002 | 0.8998 | 0.8972 |
| + negation-aware stop-word removal | 30,002 | **0.9005** | **0.8976** |
| + Porter stemming | 22,077 | 0.8975 | 0.8946 |
| + WordNet lemmatisation (final) | 24,412 | 0.8952 | 0.8921 |

Honest reading: on this small one-epoch probe, negation-aware stop-word removal is neutral-to-helpful, while **both
stemming and lemmatisation cost ~0.3–0.5 points** for the bag-of-n-grams model — merging word forms removes signal
("loved" vs "love") that 532k reviews are enough to learn separately. The gap is small (≈ 1.5–2 standard errors on 12k
validation reviews). Lemmatisation was kept because the brief requires a normalisation step and it is the
higher-quality variant for the sequence models; a full-data ablation is listed as future work.

## 2. Models (2.2.1–2.2.2)

| Model | Architecture | Params | Justification |
|---|---|---|---|
| **Baseline — fastText-style n-grams** | averaged 100-d embeddings of unigrams + hashed bigrams (200k buckets) → linear | 26.0 M (mostly the bigram table) | Classic strong, fast baseline for review polarity; bigrams capture local negation ("not good") |
| **Exp 1 — BiGRU + attention** | 128-d embeddings → 2-layer bidirectional GRU (128/direction) → attention pooling ⊕ max pooling → linear | 8.18 M | Adds word order and long-range context; attention focuses on the verdict sentence |
| **Exp 2 — Transformer (from scratch)** | 128-d tokens + learned positions, [CLS], 4 pre-norm encoder layers, 4 heads, FFN 512 → linear | 8.51 M | Self-attention relates any two words directly; tests whether it beats recurrence without pretraining |

All: AdamW, one-cycle LR, gradient clipping 1.0, batch 256, best epoch chosen on validation macro-F1.
Differs from teammate Kavya's set (Mean-Embedding MLP, TextCNN, BiLSTM) in all three architectures, data size
(532k vs 200k train), normalisation (lemmatisation vs stemming) and truncation strategy.

## 3. Results on the 38,000-review test set (2.2.3)

| Metric | fastText baseline | **BiGRU + attention** | Transformer |
|---|---|---|---|
| Accuracy | 0.9325 | **0.9595** | 0.9327 |
| Accuracy 95 % CI | [0.9299, 0.9348] | **[0.9574, 0.9614]** | [0.9304, 0.9349] |
| Macro-F1 (= micro ≈ weighted, balanced classes) | 0.9325 | **0.9595** | 0.9327 |
| Macro-F1 95 % CI | [0.9299, 0.9348] | **[0.9574, 0.9614]** | [0.9304, 0.9349] |
| ROC-AUC | 0.9788 | **0.9926** | 0.9828 |
| PR-AUC | 0.9783 | **0.9928** | 0.9836 |
| MCC | 0.8650 | **0.9190** | 0.8653 |
| MCC 95 % CI | [0.8598, 0.8697] | **[0.9148, 0.9228]** | [0.8607, 0.8699] |
| Brier score ↓ | 0.0514 | **0.0315** | 0.0501 |
| Expected calibration error ↓ | **0.0073** | 0.0123 | 0.0166 |
| False negatives / true positives | 1,349 / 17,651 | **731 / 18,269** | 1,310 / 17,690 |
| Best epoch (of trained) | 2 / 5 | 4 / 4 | 4 / 5 |
| Training time | **45 s** | 662 s | 273 s |
| Training throughput | **59,302 ex/s** | 3,228 ex/s | 9,872 ex/s |
| Inference throughput | **1,005,492 ex/s** | 43,214 ex/s | 43,401 ex/s |
| Peak GPU memory | **517 MB** | 1,100 MB | 1,977 MB |

Bootstrap CIs use 1,000 resamples. Precision/recall per averaging scheme, confusion matrices, ROC / PR / reliability
curves: `metrics_report.csv`, `outputs/confusion_*.csv`, `outputs/eval_curves_all_models.png`, `outputs/training_curves.png`.

**Paired McNemar tests vs. the baseline** (`mcnemar_tests.csv`):

| Comparison | b (baseline right, other wrong) | c (baseline wrong, other right) | χ² (cc) | p-value | Significant |
|---|---|---|---|---|---|
| baseline vs BiGRU | 521 | 1,548 | 508.8 | 1.2 × 10⁻¹¹² | **yes** |
| baseline vs Transformer | 885 | 892 | 0.02 | 0.887 | no |

**Robustness — macro-F1 per slice** (`slice_metrics.csv`):

| Slice | n | fastText | BiGRU | Transformer |
|---|---|---|---|---|
| short (< 50 words) | 9,122 | 0.9291 | 0.9548 | 0.9278 |
| medium (50–150) | 17,196 | 0.9327 | **0.9615** | 0.9344 |
| long (> 150) | 11,682 | 0.9299 | 0.9573 | 0.9295 |
| contains negation | 28,246 | 0.9263 | 0.9581 | 0.9259 |
| contains contrast word (but / however / although) | 22,365 | **0.9239** (worst) | 0.9550 | **0.9238** (worst) |
| ≥ 3 exclamation marks | 6,944 | 0.9500 | 0.9722 | 0.9499 |
| all | 38,000 | 0.9325 | 0.9595 | 0.9327 |

## 4. Comparative analysis and observations (2.3)

1. **Recurrence wins clearly and significantly.** The BiGRU fixes 1,548 reviews the baseline gets wrong while breaking
   only 521 (p ≈ 10⁻¹¹²), +2.7 accuracy points, with the best ROC-AUC, MCC and Brier score. Its advantage is largest
   exactly where order matters: on the *negation* slice it loses only 0.1 points versus its overall score, while the
   order-free baseline and the Transformer lose ~0.6–0.7, and on *contrast* reviews the gap to the baseline is 3.1 points.
2. **A Transformer trained from scratch does not beat a bag of n-grams here.** Same accuracy as the baseline
   (885 vs 892 discordant reviews, p = 0.89) despite 6× the training time. Self-attention without pretraining has weak
   inductive bias for local word order and needs far more data or pretraining; at 532k short reviews the GRU's built-in
   sequential bias is the better trade-off. Its validation F1 was still rising slowly (0.9265 → 0.9282 → 0.9280), so it is
   data/compute-limited rather than broken.
3. **The baseline is the efficiency champion.** 45 s training, ~1 M reviews/s inference, best calibration (ECE 0.007),
   and 93.2 % accuracy — it peaked at epoch 2 and then over-fitted (train loss 0.17 → 0.11 while validation F1 dipped),
   which the validation-based epoch selection caught.
4. **Calibration vs. accuracy.** The more accurate BiGRU is slightly over-confident (ECE 0.012), the Transformer most
   (0.017); the BiGRU still has the lowest Brier score because it is right far more often. Temperature scaling on the
   validation split would close most of the ECE gap at no accuracy cost.
5. **Training stability.** No NaN losses observed; gradient-norm clipping held. The BiGRU showed one transient loss spike
   (epoch 3: 0.28 → 0.34) that recovered to 0.14 in epoch 4 — characteristic of high one-cycle learning rates on RNNs.
6. **Hardest inputs for every model:** reviews with contrast words and negations; easiest: exclamation-heavy reviews
   (sentiment is explicit). Review length matters little because head + tail truncation keeps both ends.

**Team comparison.** Teammate Kavya trained Mean-Embedding MLP, TextCNN and BiLSTM on a 200k subset with Porter
stemming (Tesla T4). The notebook builds `task2_sentiment/team_comparison.csv` automatically when
`task2_sentiment/Kavya/metrics_report.csv` is present; fill this table from it:

| Member | Model | Test accuracy | Macro-F1 | ROC-AUC | Train time | Hardware |
|---|---|---|---|---|---|---|
| manjot | fastText bigram | 0.9325 | 0.9325 | 0.9788 | 45 s | RTX 4090 |
| manjot | BiGRU + attention | 0.9595 | 0.9595 | 0.9926 | 662 s | RTX 4090 |
| manjot | Transformer | 0.9327 | 0.9327 | 0.9828 | 273 s | RTX 4090 |
| Kavya | Mean-Embedding MLP | _TODO_ | | | | Tesla T4 |
| Kavya | TextCNN | _TODO_ | | | | Tesla T4 |
| Kavya | BiLSTM | _TODO_ | | | | Tesla T4 |

## 5. Limitations and future work

* **Label noise caps accuracy:** at least 5 of the 20 reviewed errors have text that contradicts the star label (see
  `failure_analysis.md`). Confident-learning style cleaning of the training set is the first experiment to run.
* Lemmatisation slightly hurt the bag-of-n-grams baseline in the small ablation; a full-data ablation per model
  (with and without normalisation) would settle it.
* Sarcasm, review updates ("EDIT: …") and target confusion need discourse-level modelling — e.g. sentence-level
  hierarchical attention or an explicit update-marker token.
* Temperature scaling for calibration; subword (BPE-from-scratch) or character n-grams for slang and misspellings;
  a longer/larger Transformer budget or masked-LM pre-training on Yelp itself (still "from scratch") to test whether the
  Transformer gap is data or architecture.
