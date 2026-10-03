# Part 1 Results

## Architecture
- Character-level GPT-style language model built from scratch
- Transformer blocks: 4
- Hidden size: 256
- Attention heads: 8
- Context length: 128
- Dropout: 0.1
- Parameters: 3,270,815

## Design choices
- **4 Transformer layers:** This gives the model enough depth to learn useful language patterns while keeping training practical on the available GPU.
- **d_model = 256:** A hidden size of 256 provides enough representation capacity for a character-level TinyStories model without making the model unnecessarily large.
- **8 attention heads:** With d_model 256, 8 heads gives 32 dimensions per head, which allows the model to learn different attention patterns while keeping the dimensions balanced.
- **Context length = 128:** A 128-character context is long enough to capture short story structure and local dependencies while keeping memory usage and training time manageable.
- **Learning rate = 3e-4:** This is a commonly stable learning rate for AdamW with Transformer models and gave a good balance between learning speed and training stability.
- **500 warm-up steps:** Warm-up gradually increases the learning rate at the beginning of training, which helps avoid unstable updates before the model parameters settle.
- **Dropout = 0.1:** A small amount of dropout provides regularization and helps reduce overfitting without removing too much information during training.

## Training
- Epochs: 10
- Batch size: 64
- Steps per epoch: 10936
- Validation steps per epoch: 1097
- Optimizer: AdamW
- Initial learning rate: 0.0003
- Warm-up steps: 500
- Device: NVIDIA GeForce RTX 4090
- Total training time (s): 3911.65

## Final Metrics
- Training loss: 0.695788
- Validation loss: 0.663736
- Perplexity: 1.942035
- Bits/character: 0.957569
- Generalization gap: -0.032051
- Top-1 next-character accuracy: 0.787781
- Distinct-1: 0.035484
- Distinct-2: 0.221953
- Distinct-3: 0.466074
- Repeated 4-gram rate: 0.553759
- Peak gradient norm: 7.064823
- NaN count: 0
- Training tokens/sec: 243356.89
- Generation tokens/sec: 467.92
- Peak GPU memory (MB): 940.81

## Files
- Checkpoint: `checkpoints/full/model.pt`
- Metrics: `metrics_report.csv`
- Failure analysis: `failure_analysis.md`
- Outputs: `outputs/`
