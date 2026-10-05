# Part 2 Results

## Models and Architecture Choices

### Baseline — Mean Embedding + MLP
- Embedding dimension: 128
- Hidden size: 128
- Dropout: 0.30
- Architecture: learned token embeddings are mean pooled and passed through an MLP.
- Reason: this is a simple, fast baseline that shows how far bag-of-embedding information can go without explicit sequence modeling.

### Experimental 1 — TextCNN
- Embedding dimension: 128
- Filters per kernel: 128
- Kernel sizes: 3, 4, 5
- Dropout: 0.40
- Architecture: learned embeddings followed by 1D convolution and max pooling.
- Reason: the convolution filters can capture short local sentiment phrases such as negation and adjective patterns while remaining highly parallel.

### Experimental 2 — BiLSTM
- Embedding dimension: 128
- Hidden size: 128
- Layers: 1
- Bidirectional: yes
- Dropout: 0.35
- Architecture: learned embeddings followed by a bidirectional LSTM and masked mean pooling.
- Reason: the BiLSTM can use left and right context and preserve more word-order information than the baseline.

All embeddings were learned from scratch. No pretrained embeddings or pretrained language models were used.

## Preprocessing
- Final mode: **stop_stem**
- The ablation gave about **84.75%** accuracy for `stop_stem` versus **82.35%** for `basic`.
- Sentiment-bearing stopwords such as negation and contrast words are preserved.
- Literal escaped newline/tab, Unicode, and hex sequences are cleaned before tokenization.
- Preprocessing artifacts are stored in `data_processed/`.

## Shared Training Settings
- Maximum vocabulary: 50,000
- Maximum review length: 256
- Batch size: 256
- Epochs: 5
- Learning rate: 0.002
- Hardware: NVIDIA GeForce RTX 4090

## Comparative Results
- **Baseline Mean MLP:** train accuracy 0.9494, test accuracy 0.9222, train-test gap 0.0272, macro-F1 0.9222, ECE 0.0211.
- **TextCNN:** train accuracy 0.9513, test accuracy 0.9320, train-test gap 0.0193, macro-F1 0.9320, ECE 0.0214.
- **BiLSTM:** train accuracy 0.9835, test accuracy 0.9376, train-test gap 0.0459, macro-F1 0.9375, ECE 0.0331.

The **BiLSTM** produced the highest test accuracy and macro-F1. Its larger train-test gap (0.0459) also shows more overfitting than the other two models. The **TextCNN** had the smallest train-test gap (0.0193) of the three.

## Calibration
The BiLSTM was the least calibrated model by ECE (0.0331), even though it had the highest classification accuracy. The baseline had the lowest ECE (0.0211). This shows that better classification accuracy does not automatically mean better probability calibration.

## Strengths and Weaknesses
- **Mean Embedding + MLP:** simple and efficient, but averaging removes word order and makes mixed or contrastive reviews difficult.
- **TextCNN:** captures local phrase patterns and generalized well in this run, but fixed convolution windows can miss long-range dependencies.
- **BiLSTM:** best overall predictive performance and stronger sequential context modeling, but it showed the largest train-test gap and the worst ECE.

## Error Analysis
The 20 manually reviewed errors show recurring problems with mixed sentiment, sarcasm, label/text conflicts, long reviews whose final conclusion differs from earlier wording, and reviews where negative words describe other people rather than the business itself. The completed cases are documented in `failure_analysis.md` and `error_review_candidates.csv`.

## Throughput
All three models were near roughly 1,000 examples/sec in the recorded runs. This is an end-to-end training-loop measurement, so CPU-side tokenization/stemming, batching, and data transfer can reduce the apparent difference between model architectures.

## Limitations
- Reviews are truncated to 256 tokens.
- Vocabulary is capped at 50,000 tokens.
- Results use one seed and one primary hyperparameter configuration.
- Learned embeddings do not provide semantic information beyond what is learned from this training set.
- Long mixed-sentiment reviews remain challenging.

## Future Work
- Add validation-based early stopping.
- Tune dropout, hidden sizes, kernel sizes, and learning rate.
- Cache processed token IDs to reduce repeated CPU preprocessing cost.
- Test longer sequence lengths and hierarchical sentence pooling.
- Try calibration methods such as temperature scaling.
- Run multiple random seeds to measure stability.

## Files
- Checkpoints: `checkpoints/full/`
- Processed artifacts: `data_processed/`
- Metrics: `metrics_report.csv`
- McNemar tests: `mcnemar_tests.csv`
- Error candidates: `error_review_candidates.csv`
- Failure analysis: `failure_analysis.md`
- Outputs: `outputs/`
