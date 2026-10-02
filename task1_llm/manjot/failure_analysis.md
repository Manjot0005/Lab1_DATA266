# Task 1 – Failure Analysis (Manjot)

- **Model:** character-level GPT (4 layers, 4 heads, d_model 256, 3.28M parameters)
- **Checkpoint:** `checkpoints/20261002_045745_epoch10.pt`
- **Samples analysed:** `outputs/samples_20261002_045745.txt` (25 samples: 5 greedy, 10 at temperature 0.7, 10 at temperature 1.0)

## Overall pattern

| Decoding | What it looks like |
|---|---|
| Greedy | Fluent first sentences, then gets stuck in loops. Different prompts collapse onto the same story. |
| Temperature 0.7 | Best balance: mostly grammatical, but loses track of characters. |
| Temperature 1.0 | Most varied, but more contradictions, nonsense word pairs and broken grammar. |

This matches the diversity metrics in `metrics_report.csv`:

| Decoding | Distinct-2 | Distinct-3 | Repeated 4-gram rate |
|---|---|---|---|
| Greedy | 0.437 | 0.530 | **0.308** |
| Temperature 0.7 | 0.714 | 0.882 | 0.021 |
| Temperature 1.0 | 0.817 | 0.947 | 0.000 |

---

## Failure 1 – Repetition loop (greedy decoding)

**Snippet (greedy, prompt "Once upon a time"):**
> "One day, she saw a big box of colorful colorful colors on the ground. She wanted to open it, but it was too heavy. She tried to open it, but it was too heavy. She tried to open it, but it was too heavy. She tried to open it, but it was too heavy. She tried to open it, but it was too heavy."

**Failure type:** repetition / degenerate loop.

**Observation:** The model repeats the same sentence until the 400-character limit. A smaller repetition already appears earlier ("colorful colorful colors"). The prompt "In a small house," produced *exactly the same* continuation, so greedy decoding collapses different prompts onto the single most likely story.

**Why it happens:** Greedy decoding always picks the most probable next character, so there is no randomness to escape a pattern. Once a sentence has been written, it is in the context window, which makes the same sentence even more likely to come next. This self-reinforcing feedback produces a loop.

**Evidence:** greedy has a repeated 4-gram rate of 0.308 (about 31% of word 4-grams are repeats), compared with 0.021 at temperature 0.7.

**Possible fix:** Use temperature or top-k / top-p sampling, or add a repetition penalty that lowers the probability of recently generated n-grams.

---

## Failure 2 – Loss of coherence: entity confusion and name drift

**Snippet (greedy, prompt "The cat was sad because"):**
> "The cat was sad because he wanted to help the cat. The cat wanted to help the cat, so he said, "I will help you find your cat." … The cat went back to the cat and they both found the cat."

**Related examples:**
> "there was a little girl named Lucy … The boy saw Lily" (temperature 1.0)
> "Tom smiled and thanked the dog … Tom and Lily thought for a moment." (temperature 0.7; Lily was never introduced)

**Failure type:** loss of coherence (the model cannot track who is who).

**Observation:** Each sentence is grammatical on its own, but the story stops making sense because the model mixes up the characters. "The cat" refers to several different characters, and names change mid-story, often to "Lily".

**Why it happens:** The model has no explicit memory of characters. It only learns which words are likely in a given position. "Lily", "Tom" and "the cat" are very frequent in TinyStories, so they are always strong candidates. A 256-character context holds only about 2–3 sentences, so the original name can fall out of view. At character level, one name takes 4–5 prediction steps, which makes it easier to drift.

**Possible fix:** A longer context (block size 512), a larger model, or subword tokenisation so that a name is a single token.

---

## Failure 3 – Semantic nonsense, contradiction and broken grammar (temperature 1.0)

**Snippets (temperature 1.0):**
> "She loved the car because it had broken into pieces."
> "he found a big box of black carrots in the grass … he was very careful with the block on it. He got some black black black sailors"
> "The dog wanted to never eat available again."
> "The boy looked at the cookie and tried to make it it."

**Failure type:** hallucination / logical contradiction, plus broken grammar.

**Observation:** The text keeps the *style* of a children's story, but the meaning breaks down. Some reasons contradict themselves (loving a car *because* it is broken), some objects are strange (black carrots), the topic drifts (box → block), and some words are misplaced ("available", "make it it").

**Why it happens:** Temperature 1.0 samples lower-probability characters more often than 0.7. Each word is locally plausible after the previous few characters, but the model has no understanding of meaning or cause and effect, so nothing stops contradictory or odd combinations. Once one unusual word is sampled, later predictions build on it, so errors compound.

**Possible fix:** A lower temperature (0.7–0.8), top-k / top-p sampling, or a larger model trained for longer.
