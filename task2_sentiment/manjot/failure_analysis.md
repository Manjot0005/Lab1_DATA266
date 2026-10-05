# Task 2 — Failure / Error Analysis (member: manjot)

Model reviewed: **exp1_bigru_attention** (best test macro-F1 0.9595). 20 test errors were selected automatically
(5 most-confident false positives, 5 most-confident false negatives, 5 errors closest to the 0.5 threshold, and
5 most-confident errors from the weakest slice, *short reviews < 50 words*) and then **read and labelled by hand**
(`error_review_candidates.csv`: `manual_error_type`, `testable_fix`). Label 1 = positive (4–5★), 0 = negative (1–2★).

## Summary of error types

| Error type | Count | Cases |
|---|---|---|
| Label noise — text contradicts the star label | 4 | #1, #4, #16, #18 |
| Mixed sentiment / aspect conflict (verdict buried among pros and cons) | 4 | #3, #5, #11, #15 |
| Review update / edit changes the verdict | 2 | #2, #7 |
| Sarcasm / irony | 2 | #13, #19 |
| Negation scope (incl. negated low rating) | 2 | #9, #14 |
| Temporal or sequential contrast ('first visit amazing, second not so much', 'old owners bad, new owners good') | 2 | #10, #12 |
| Rating driven by one aspect the text barely covers | 1 | #6 |
| Target confusion (negativity about other customers, not the business) | 1 | #8 |
| No opinion / off-topic review | 1 | #17 |
| Lexical ambiguity / idiom ('vacuums can REALLY suck' = good) | 1 | #20 |

**Main finding.** About a quarter of the most-confident errors (#1, #4, #16, #18, plus the opinion-free #17) are
not model mistakes in a useful sense: the text genuinely disagrees with, or says nothing about, the star rating.
This suggests a label-noise ceiling a little below 100 % on Yelp Polarity. The remaining errors need understanding
*beyond word order*: which part of a review is the final verdict (updates, contrast, temporal change), who the
sentiment is aimed at, and non-literal language (sarcasm, idioms). These match the slice results — the weakest slices
for every model are reviews with contrast words and negations.

## The 20 cases

### #1 — confident false positive
- True: **negative** · Predicted: **positive** · p(positive) = 0.9999 · 23 words
- Excerpt: “Wow love the place and everything is very clean and new!  Great place to come and relax worth a try!  Cheers,  Eric Van Nguyen Visited April 2012”
- **Error type:** label_noise (text-rating mismatch)
- **Testable fix:** Text is purely positive yet labelled negative. Run confident-learning style cleaning: drop train reviews whose out-of-fold p(label) < 0.05, retrain, compare test macro-F1 and error count on this slice.

### #2 — confident false positive
- True: **negative** · Predicted: **positive** · p(positive) = 0.9998 · 411 words
- Excerpt: “NOTE:  This was a 4-star review, but the food quality and ESPECIALLY customer service have gone down the tubes.  See update below. Complaining I can't find a good meatball sub in Phoenix, I was referred to Santisi Brothers.  I was told that the meatballs are still made by the brothers' mother, so I was intrigued.  Santisi Brothers did not disappoin …”
- **Error type:** review_update / temporal shift
- **Testable fix:** Verdict lives in an 'UPDATE/EDIT/NOTE' line while the body is the old positive review. Add an xxupdate token for update/edit markers and up-weight that segment; measure accuracy on test reviews containing 'update|edit'.

### #3 — confident false positive
- True: **negative** · Predicted: **positive** · p(positive) = 0.9997 · 422 words
- Excerpt: “Saturday / Sunday AYCE brunch  In true las vegas fashion, you get a flat rate to eat your heart out.   For Strip food, main menu items seem reasonably priced and the brunch is cheap at $29.99. There are a few different flavors to choose from for the All-You-Can-Drink Bottomless mimosas. They're $5 per person; but on multiple occasions, the $5 was c …”
- **Error type:** mixed_sentiment (aspect conflict)
- **Testable fix:** Negatives (cold food, 'blah') sit mid-review between positive intro/outro. Try max_len 512 or sentence-level pooling (hierarchical GRU); compare macro-F1 on the has_contrast and len_long slices.

### #4 — confident false positive
- True: **negative** · Predicted: **positive** · p(positive) = 0.9996 · 193 words
- Excerpt: “This is the neighborhood Foodland that has the bare necessities needed to sustain a pantry or for when the next snowstorm of the century is a day away and you only have minutes to get TP, bread and milk.   The bakery here is tops, small selection, but really well made specialities. Huge brownies, iced and moist. They are easily 5 inch squares,  top …”
- **Error type:** label_noise (text-rating mismatch)
- **Testable fix:** Body praises the bakery with one mild complaint; text reads 3-4 stars. Same label-noise cleaning experiment as #1; also report what share of confident errors are mismatches (estimate of noise ceiling).

### #5 — confident false positive
- True: **negative** · Predicted: **positive** · p(positive) = 0.9996 · 272 words
- Excerpt: “This hotel was very beautiful, and if you are use to being pampered and have a bit of money to throw around then this is totally the place for you!  My room was beautiful and spacious, as was my bathroom.  The staff around the hotel were also wonderful and helpful.  I did find it a little annoying that despite the lovely decor and all, I didn't hav …”
- **Error type:** mixed_sentiment + ironic conclusion
- **Testable fix:** 'Would stay again if someone else was paying' is a hedged negative verdict. Add a final-sentence auxiliary head (predict label from last sentence only) and ensemble; measure on reviews whose last sentence contains 'if|unless'.

### #6 — confident false negative
- True: **positive** · Predicted: **negative** · p(positive) = 0.0002 · 215 words
- Excerpt: “The food is crap.  I'm not trying to be mean, but it really is horrible.  I'd rather eat one of those Tornado things from Circle K for dinner.  Also, I don't appreciate the waitress telling me everything is great when everything is absolutely not great.  What kind of disgusting excuse for food must she live off of if the nachos get her stamp of app …”
- **Error type:** aspect conflict / rating driven by one aspect
- **Testable fix:** Text trashes the food but the 4-star rating is for Thursday drinks ('gets to keep the four star rating'). Add an explicit star-mention feature (regex '[1-5] star' -> xxstarN token); test on the explicit-star-mention slice.

### #7 — confident false negative
- True: **positive** · Predicted: **negative** · p(positive) = 0.0004 · 96 words
- Excerpt: “EDIT: They really did change the service up since I last posted this.  Horrible service.  Used to be my favorite pizza in the city (at a reasonable price), but I'm rethinking that. We just had an altercation with a server who refused to split a check when we were paying with cash. He then proceeded to disrespect the party at the table, telling us t …”
- **Error type:** review_update / stale rating
- **Testable fix:** 'EDIT: Horrible service' but the old positive rating was kept. Same xxupdate-marker experiment as #2; also flag such reviews as noisy in the training set and re-measure.

### #8 — confident false negative
- True: **positive** · Predicted: **negative** · p(positive) = 0.0004 · 187 words
- Excerpt: “Last night several parents came in with over 15 children to celebrate their 9 year olds 4th grade graduation at 9:15 pm. The bartender expressed that it was not a place to have children running around as it is against the law and a liability issue if anything were to happen to them on their premise. The children were running in and out of the bar w …”
- **Error type:** target confusion (sentiment about other customers)
- **Testable fix:** Negativity is aimed at other patrons; the business (bartender) is praised. Test target awareness: augment training with third-party-complaint narratives, or mask person nouns, and measure accuracy on reviews mentioning 'customers|parents|people'.

### #9 — confident false negative
- True: **positive** · Predicted: **negative** · p(positive) = 0.0007 · 27 words
- Excerpt: “I've just been forced to concede that, despite still not digging their ordering process, their food is just too good to disrespect with a 2 star review.”
- **Error type:** negated low rating ('too good to ... 2 star')
- **Testable fix:** Model keys on 'not digging' and '2 star'. Add negation-scope marking (prefix NEG_ to tokens after not/never until punctuation) and the xxstarN token; re-test this case and the has_negation slice.

### #10 — confident false negative
- True: **positive** · Predicted: **negative** · p(positive) = 0.0007 · 98 words
- Excerpt: “This place is so much better since they changed owners.  My wife and I went when it was the old owners, it was terrible.  We waited forever and the food never came before we walked out.  People were served before us that walked in after and my wife actually got her soup before me and I sat and waited while they \""made more\"".  It was horrible.  N …”
- **Error type:** temporal contrast (old owners bad, new owners good)
- **Testable fix:** Most text describes the past bad experience. Add tense/temporal cue tokens ('used to', 'now', 'new owners') or weight the tail more; measure on test reviews matching 'used to|now|new owner|changed'.

### #11 — near threshold
- True: **positive** · Predicted: **negative** · p(positive) = 0.4999 · 77 words
- Excerpt: “Great BBQ.  I lived in one of the BBQ Meccas for 10 years, Kansas city and this is good. Had ribs, fall off bone delish good flavoring. Also had pulled pork, mine is better but this is very good. Liked the beans and the sauces.  The only draw back the slaw. No flavor, no hints of vinegar seasonings or even cream, like Corky's famous slaw from Memph …”
- **Error type:** mixed_sentiment (minor complaint at the end)
- **Testable fix:** Positive review whose last lines criticise one side dish; tail-heavy features tip it. Tune the decision threshold on validation (instead of 0.5) and compare near-threshold error count.

### #12 — near threshold
- True: **negative** · Predicted: **positive** · p(positive) = 0.5005 · 34 words
- Excerpt: “First visit, amazing! Second visit, not so much. They are really skimpy on their servings. We said something to them about it, and they responded back with a snarky remark. They just lost customers.”
- **Error type:** contrast ('first visit amazing, second not so much')
- **Testable fix:** Early strong positive outweighs the later negative. Test a recency weight on attention (bias towards later sentences) and measure on has_contrast slice.

### #13 — near threshold
- True: **negative** · Predicted: **positive** · p(positive) = 0.5008 · 166 words
- Excerpt: “I cant believe I ever went here, but my girlfriend did the models hair that were doing a fashion show for the ugliest homemade garbage. So I came for support.   Anyway, every dude in there looks the same. Low rise seven jeans with a sparkley belt with shirt tucked behind the questionably femenine buckle, sunglasses inside, orange tan, waxed eyebrow …”
- **Error type:** sarcasm + slang / misspellings (OOV)
- **Testable fix:** Insulting slang and misspellings (cant, spoted, freek) are mostly <unk>. Add character n-gram or subword (BPE trained from scratch) tokens; measure OOV rate and accuracy on reviews with >10% OOV tokens.

### #14 — near threshold
- True: **positive** · Predicted: **negative** · p(positive) = 0.4985 · 109 words
- Excerpt: “I don't know what it is we East Coast-ers did, exactly, but it must have been pretty bad for us to miss out on a burger joint like In-N-Out!  I blew into Scottsdale with my mother recently, and she insisted that the first thing in my mouth absolutely HAD to be an In-N-Out burger.  She wasn't wrong.  I'm a little sad, thinking that I'll have to say  …”
- **Error type:** negation scope / double negation
- **Testable fix:** 'She wasn't wrong', 'aren't that great', 'WISHES' - negated and emotive phrases confuse the model. Negation-scope marking experiment (NEG_ prefix); compare has_negation slice F1.

### #15 — near threshold
- True: **positive** · Predicted: **negative** · p(positive) = 0.4984 · 38 words
- Excerpt: “The security guard from April 3rd at noon is a complete jerk.  The women on staff are all extremely nice and make you feel comfortable.   I got my appt the next day and the wait time wasn't awful.”
- **Error type:** mixed_sentiment (one bad staff member, rest good)
- **Testable fix:** Strong insult ('complete jerk') vs milder praise. Sentence-level pooling / aspect aggregation; measure on reviews containing both strong negative and positive lexicon hits.

### #16 — slice failure:len short(<50w)
- True: **negative** · Predicted: **positive** · p(positive) = 0.9992 · 28 words
- Excerpt: “my husband had an omelette that was good. i had a blt, a little on the small side for $10, but bacon was great. Our server was awesome!”
- **Error type:** label_noise / understated 2-star
- **Testable fix:** Short, mostly positive text labelled negative ('a little small for $10'). Label-noise cleaning experiment; also report short-slice F1 before and after cleaning.

### #17 — slice failure:len short(<50w)
- True: **positive** · Predicted: **negative** · p(positive) = 0.0019 · 37 words
- Excerpt: “It appears that this is not the business. The business is David Wilson's Toyota of Las Vegas.  When you call a regular person answers. Not the dealership. This is very confusing and perhaps Yelp should clarify it.”
- **Error type:** off-topic / no opinion about the business
- **Testable fix:** Review only says the listing is wrong; there is no sentiment, so the label is arbitrary. Add a subjectivity filter (drop train reviews with no opinion words) and evaluate abstention: refuse to predict when no sentiment lexicon is present.

### #18 — slice failure:len short(<50w)
- True: **negative** · Predicted: **positive** · p(positive) = 0.9980 · 35 words
- Excerpt: “Standard take out and it's cheap. Service is fast and friendly. I go here when I'm too lazy to walk to Zaw's or pressed for time (I've never had to wait longer than 15 minutes).”
- **Error type:** label_noise / neutral text, negative label
- **Testable fix:** 'Standard take out... fast and friendly' reads neutral-positive. Label-noise cleaning experiment; add a 'neutral' analysis bucket in the slice table to quantify how many short neutral reviews fail.

### #19 — slice failure:len short(<50w)
- True: **negative** · Predicted: **positive** · p(positive) = 0.9976 · 45 words
- Excerpt: “good: it's cheap, loud, every now and then a good band will play, good drink selection.  bad: the parking and the crowd.  it's fun to watch the young kids marvel in this new bar they've just discovered and is totally the coolest place, like, ever.  funny stuff.”
- **Error type:** sarcasm ('totally the coolest place, like, ever. funny stuff')
- **Testable fix:** Sarcastic tail flips a mixed good/bad list. Add sarcasm cue features (intensifier + 'like, ever', scare quotes) and test on a hand-labelled sarcasm sample of 100 reviews.

### #20 — slice failure:len short(<50w)
- True: **positive** · Predicted: **negative** · p(positive) = 0.0027 · 27 words
- Excerpt: “I won't say what spilled on my floor carpets, but their vacuums can REALLY suck!  Thank goodness because I thought my carpet in my truck was ruined.”
- **Error type:** lexical ambiguity / idiom ('vacuums can REALLY suck')
- **Testable fix:** 'suck' is literal praise here. Bigram/context features: check if the fastText bigram 'vacuum suck' fixes it; augment with literal-use sentences and re-test this pattern.

## Prioritised experiments

1. **Label-noise cleaning** (cases #1, #4, #16, #18): out-of-fold confident-learning filter on the training set; retrain; compare test macro-F1 and the count of confident errors.
2. **Update / verdict markers** (#2, #7): add an `xxupdate` token for 'UPDATE/EDIT/NOTE' and evaluate on test reviews containing those words.
3. **Negation-scope marking** (#9, #14): prefix `NEG_` to tokens after a negator until punctuation; compare the has_negation slice.
4. **Sentence-level (hierarchical) pooling** (#3, #5, #10–#12, #15): model sentences first, then the review; compare the has_contrast slice.
5. **Subword / character n-grams** (#13, #20): reduce OOV and capture slang and idioms; compare on reviews with high OOV rate.
6. **Explicit star-mention feature** (#6, #9): map '[1-5] star' phrases to tokens; evaluate on the explicit-star slice.
