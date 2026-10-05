# Part 2 Failure / Error Analysis

Model reviewed: **experimental_bilstm**

The 20 cases contain 5 confident false positives, 5 confident false negatives, 5 near-threshold errors, and 5 slice-specific failures.

Manual review completed: **20/20**

## Error 1: confident_false_positive
- True label: 0
- Predicted label: 1
- Positive probability: 1.000000
- Slice: short
- Manual error type: Sarcasm or ambiguous wording
- Testable fix: Test character/subword features and sentence-level context to improve handling of sarcastic expressions.

**Review text:**

Wow love the place and everything is very clean and new!\n\nGreat place to come and relax worth a try!\n\nCheers,\n\nEric Van Nguyen\nVisited April 2012

---

## Error 2: confident_false_positive
- True label: 0
- Predicted label: 1
- Positive probability: 0.999999
- Slice: short
- Manual error type: Positive keywords dominate negative context
- Testable fix: Use stronger context and word-order modeling so isolated positive words do not dominate the overall review sentiment.

**Review text:**

This place is only awesome if you are one of three things: 1. an Ohio State fan, 2. a metrosexual, or 3. someone trying to hook up with an Ohio State fan or metrosexual...Everyone else, do yourself a favor and go to any one of the many hundreds of awesome bars in old town that will happily accommodate the general public.

---

## Error 3: confident_false_positive
- True label: 0
- Predicted label: 1
- Positive probability: 0.999998
- Slice: short
- Manual error type: Mixed sentiment / contrastive clauses
- Testable fix: Give more importance to contrast words and later clauses using sentence-level or attention-style pooling trained from scratch.

**Review text:**

my husband had an omelette that was good. i had a blt, a little on the small side for $10, but bacon was great. Our server was awesome!

---

## Error 4: confident_false_positive
- True label: 0
- Predicted label: 1
- Positive probability: 0.999997
- Slice: short
- Manual error type: Positive keywords dominate negative context
- Testable fix: Use stronger context and word-order modeling so isolated positive words do not dominate the overall review sentiment.

**Review text:**

One to two stars, got the Jambalaya:\n\nMarinated chicken, white rice, andouille sausage, sweet peppers and roasted green onions in a spicy traditional jambalaya sauce\n\nWasn't:\nSpicy\nEvenly Heated\n\nHad:\nDelicious sauce\nA lot of Rice\n\n*Even BJs has a better Jambalaya with more stuff.\n\nWaiter was nice, split all the checks for us, she asked. (A party of 12)

---

## Error 5: confident_false_positive
- True label: 0
- Predicted label: 1
- Positive probability: 0.999997
- Slice: short
- Manual error type: Mixed sentiment / contrastive clauses
- Testable fix: Give more importance to contrast words and later clauses using sentence-level or attention-style pooling trained from scratch.

**Review text:**

Like Clay P who posted before me, I too love pancakes. Though I love chocolate chip pancakes. But like Clay I did not love the ones that I got a the Original Pancake House. Typically, restaurants just don't do it the way I like them and I have come to expect that. Grading OPH on those terms, they did a respectable job. It is definitely a worthwhile destination for a pancake lover.

---

## Error 6: confident_false_negative
- True label: 1
- Predicted label: 0
- Positive probability: 0.000000
- Slice: medium
- Manual error type: Updated or mixed sentiment review
- Testable fix: Preserve temporal markers such as update/edit and test sentence-level or position-aware pooling.

**Review text:**

EDIT: They really did change the service up since I last posted this.\n\nHorrible service.\n\nUsed to be my favorite pizza in the city (at a reasonable price), but I'm rethinking that. We just had an altercation with a server who refused to split a check when we were paying with cash. He then proceeded to disrespect the party at the table, telling us to 'not give him attitude about it.'\n\nSorry Bella Notte, but we're not children. I don't care if you're working hard - it doesn't give you any excuse to disrespect your paying customers like that.

---

## Error 7: confident_false_negative
- True label: 1
- Predicted label: 0
- Positive probability: 0.000000
- Slice: short
- Manual error type: Negative keywords dominate positive context
- Testable fix: Improve contextual modeling so isolated negative words do not override the overall positive sentiment.

**Review text:**

I've just been forced to concede that, despite still not digging their ordering process, their food is just too good to disrespect with a 2 star review.

---

## Error 8: confident_false_negative
- True label: 1
- Predicted label: 0
- Positive probability: 0.000000
- Slice: short
- Manual error type: Negative keywords dominate positive context
- Testable fix: Improve contextual modeling so isolated negative words do not override the overall positive sentiment.

**Review text:**

For being a DUMP, should expect much more.\n\nFlys, stink, garbage, dirt, and everything that comes with.\n\nSalt River... Keepin it real dumpy!

---

## Error 9: confident_false_negative
- True label: 1
- Predicted label: 0
- Positive probability: 0.000001
- Slice: short
- Manual error type: Negative keywords dominate positive context
- Testable fix: Improve contextual modeling so isolated negative words do not override the overall positive sentiment.

**Review text:**

Um... left speechless. I'll head back to Montreal for the sole purpose of returning here. I can't really write much else.

---

## Error 10: confident_false_negative
- True label: 1
- Predicted label: 0
- Positive probability: 0.000002
- Slice: medium
- Manual error type: Mixed sentiment / contrastive clauses
- Testable fix: Give more importance to contrast words and later clauses using sentence-level or attention-style pooling trained from scratch.

**Review text:**

After some nightmares with Chase, who inexplicably closed the checking account of the non-profit organization for students in which I am involved, I decided to try to take the account to Wells Fargo. This branch is closest to my school, and the banker I worked with made the process of opening up a new non-profit account very easy, and I did not have to file all kinds of awful paperwork that Chase would have made me do. I have not had good experiences at every branch (7th St, just past Camelback, I'm looking at you), but this one let me keep the organization running, financially speaking, with a minimum of red tape. Much appreciated!

---

## Error 11: near_threshold_error
- True label: 0
- Predicted label: 1
- Positive probability: 0.500130
- Slice: short
- Manual error type: Ambiguous near-threshold prediction
- Testable fix: Tune the classification threshold on a validation set and evaluate probability calibration.

**Review text:**

We don't have Cracker Barrell in CA so we always stop in for some country cookin' while visiting AZ.  Today we learned they changed the menu and removed some of our favorite items.  They added a few menu items that do not compliment their \""country comfort food\"" theme.  I guess their executives don't know who their customers are or why people choose their restaurants.

---

## Error 12: near_threshold_error
- True label: 1
- Predicted label: 0
- Positive probability: 0.499769
- Slice: medium
- Manual error type: Mixed sentiment / contrastive clauses
- Testable fix: Give more importance to contrast words and later clauses using sentence-level or attention-style pooling trained from scratch.

**Review text:**

Always stop here for a bag each of candy-shelled chocolate-covered peanuts and chocolate-covered almonds from the bulk section.  Love the organic Mountain Fresh and Brown Cow yogurts.  As for the produce I buy here, I must first say that I triple-, sometimes quadruple-inspect my options before I purchase at any grocery I shop at, and I've only had to complain about the strawberries here at Sunflower.  All other fruits and the veggies were fine.  Wish I could say the same about the other farmer's market whose name rhymes with snouts...\n\nDon't know if this place still sells Berto's gelato and Laloo's goat milk ice cream as it's been close to a year since I last purchased, but you must check these items out as they taste out-of-this-world!  The prices are also very wallet-friendly compared to AJ's, but really, that goes without saying, doesn't it?

---

## Error 13: near_threshold_error
- True label: 1
- Predicted label: 0
- Positive probability: 0.499305
- Slice: medium
- Manual error type: Updated or mixed sentiment review
- Testable fix: Preserve temporal markers such as update/edit and test sentence-level or position-aware pooling.

**Review text:**

I've had a Navy Federal account since I was 2 years old. I've lived all over the USA and even spent a few years in Germany and haven't found a better bank to do business at.\n\nIn reading the reviews and seeing the low scores I have to try and balance them out by providing a positive perspective. \n\nFirst off the lines...for the longest time this was the only location in the state and all the Military personnel who get paid on the same day rushing out to bank caused those lines. I avoided the lines by not going on popular days like Friday-Monday. Try going mid week or off hours and you can practically walk to the head of the line.\n\nThe complaints on the staff seem out of place as well. I've always been greeted at the door by a hello and a smile. At the counter the tellers are equally as approachable and willing to go the extra mile for you. \n\nThe ATM out front is well lit and easy to use. It does almost everything you will need once you are inside so if you see there is a line go back outside and complete your business.\n\nI haven't been to the new location yet but that should help elevate some of the line concerns. Even if it doesn't I think the most time I've spent on line has been ten minutes.\n\nAlmost forgot, it is a credit union and their rates on loans and mortgages are phenomenal.  If you qualify for one you will have a hard time beating them.

---

## Error 14: near_threshold_error
- True label: 0
- Predicted label: 1
- Positive probability: 0.500707
- Slice: short
- Manual error type: Ambiguous near-threshold prediction
- Testable fix: Tune the classification threshold on a validation set and evaluate probability calibration.

**Review text:**

This is made of cinderblock and cement. If that is your aesthetic taste, go for it.  My room flooded twice, my patio flooded, the hallway ceiling was caving in, and it took 3 days to fix it.  And to be frank, no one at the hotel seemed to care. There are too many other nice hotels and resorts in the Scottsdale area to stay at this one.

---

## Error 15: near_threshold_error
- True label: 1
- Predicted label: 0
- Positive probability: 0.498945
- Slice: short
- Manual error type: Updated or mixed sentiment review
- Testable fix: Preserve temporal markers such as update/edit and test sentence-level or position-aware pooling.

**Review text:**

I have to update again, sorry. But I just ordered delivery from here. A plate (Greek salad, fries, rice) with two chicken souvlakis, and a tatziki. Granted, I live just 5 blocks down the road, the food was ON my plate at home 14min from the time that I called, and it cost $23. Fastest delivery to date by far. I love this place even more now.

---

## Error 16: slice_specific_failure
- True label: 1
- Predicted label: 0
- Positive probability: 0.000031
- Slice: long
- Manual error type: Updated or mixed sentiment review
- Testable fix: Preserve temporal markers such as update/edit and test sentence-level or position-aware pooling.

**Review text:**

Look, we all know Cox sucks. In fact they are a terrible business and their practices are laughable. However they are a necessary evil if you want Internet that isn't garbage that can handle streaming/gaming. The way they handle issues over the phone is worse than Comcast, and for all my east coast brothers/sisters you know what a serious accusation that is. It all started with shitty TV Service. My household went through 4 dvr boxes. 4. That all broke. All of them. 100's of hours of TV. Lost. Every. Single. Time. Their solution? Downgrade from contour. That's their genius solution. So my solution? Upgrade to Dish for TV. PROBLEM SOLVED. However they charged us $200 to disconnect claiming we were on a contract. Nope, disputed that. However to dispute it you have to literally mail a letter to corporate. In the mean time, they cut off my Internet service for pay bills AND THEN DOUBLE CHARGED ME FOR THE INTERNET. WHAT? EXCUSE ME? How does that even make sense? So, an angry phone call and 2 hours on hold, I get the Internet back on because I work from home and to refund the double charged service they have to send a check, via the mail, to a local store. Okay, cool. A week later, let's drive from San tan valley to Gilbert. Once we arrive , turns out the check wasn't mailed. In fact the person helping us via the phone wrote that checks can't be sent to the store, and put a future apology in the notes to us. Thanks Cox cock. So, if you made it this far, why do I give this store 5 stars? The Manager, Mario. That's why. The savior of my people. Stepped in. Saw the crap we went through and listened to my tale. With about 5 minutes of effort , he credited our account for $300. $200 for the bs fee , $50 for the double charge and another $50 just because he was sorry. That's customer service. That's being a great human. He's the man, and my opinion of Cox has changed. ALWAYS GO TO A COX STORE. ALWAYS! They know their stuff and actually care. They are not the call center idiots. They are true experts and will always get the job done. Thank you Mario at the Gilbert Cox Store. Thank you so much

---

## Error 17: slice_specific_failure
- True label: 1
- Predicted label: 0
- Positive probability: 0.000049
- Slice: long
- Manual error type: Updated or mixed sentiment review
- Testable fix: Preserve temporal markers such as update/edit and test sentence-level or position-aware pooling.

**Review text:**

UPDATED. \n\nMy initial very frustrated and dramatic review read as follows:\n\nBililng practices are at best negligent and at worst fraudulent.  \n\nI started going to the studio per a groupon.  I enjoyed the experience so much that I purchased a discounted 20 pack of classes.  When I purchased the classes, my credit card was charged.  However, the purchase didn't show up in my online account so I couldn't schedule classes.  I called The Studio and they told me that they'd credited the classes to another student but they did remedy the situation. \n\nFast forward about 6 months and I am reviewing my credit card statement.  Lo and behold a mysterious charge from the Studio shows up for $130.  I have not even been back there in months and certainly have not authorized any transactions to this business.  I am now disputing the charge via my credit card. \n\nThe yoga is great but all these terrible billing practices make it not worth your time in the long run.\n\nUpdates:\n\nAfter reading this, the studio owner went out of her way to contact me to try and correct the error.  She contacted me several times over a month and offered to resolve the issue in minutes if I called her.  I couldn't manage to find time to call her, but she refused to give up and tracked down my information and resolved the situation in a way that goes above and beyond what can be expected from a business owner.  I can certainly say that although I was frustrated by the two billing mixups, this business went out of its way to accomodate and help me, even when I couldn't go out of my way to try and correct the error.  I am thus updating my review to 4 stars- not quite 5 due to the initial errors- but they certainly get 5 for the way they managed this.  \n\nAlso, as previously mentioned, the yoga is great.

---

## Error 18: slice_specific_failure
- True label: 0
- Predicted label: 1
- Positive probability: 0.999695
- Slice: long
- Manual error type: Updated or mixed sentiment review
- Testable fix: Preserve temporal markers such as update/edit and test sentence-level or position-aware pooling.

**Review text:**

NOTE:  This was a 4-star review, but the food quality and ESPECIALLY customer service have gone down the tubes.  See update below.\nComplaining I can't find a good meatball sub in Phoenix, I was referred to Santisi Brothers.  I was told that the meatballs are still made by the brothers' mother, so I was intrigued. \nSantisi Brothers did not disappoint.  That sub was so freaking good!!!  I got the 1/2 sandwich, which included two meatballs smothered under mozzarella and marinara on a toasted baguette-type roll.  Amazing.  The bread was soft inside with just the right crust, the meatballs were sizable (that's what she said!), and they did not scrimp on the mozzarella.  Since this is their only location in the valley, we will be sure to be back.  (It's right off I-17, close to the 101, so that's not hard.)\nIf you like sports, go!  This place has each wall covered in TVs - huge to 13\"", they don't spare a bit of viewing area.  The only reason I gave 4 stars instead of 5 is because the seating leaves a bit to be desired.  We sat at a hightop table with stools.  Next are a row of tables with nicer chairs (with backs), and the row closest to the TVs - who wants to sit there?  Music - we could hear each other, but agreed a table of four might have to shout.  Our server, Ariel, was very enjoyable, nice, and attentive.\nBig beer and bar selection.  Husband's Kiltlifter was in a huge beer mug and he was happy to see a few IPAs.  I had a John Daly that was verrry tasty.  It's one of those sneaky super-yummy drinks...  Sweet iced tea, lemonade, and vodka - I'll be stealing that recipe this summer!\nHusband had the turkey club, which was large enough to be funny to watch him eat, but he said it was unremarkable.  Side of fries were also really, really good.  Perfect amount of potato, crispiness, and salt.  We also had garlic knots, which are served with marinara and pretty tasty, but left me wishing there was a little ball of mozzarella in the middle.  House salads were... house salads.  Nothing special there.\nTo review: great for sports (I'm sure they can spare a TV for your game), may want to go early for good seats, good bar, and some great food.  EAT/DRINK:  Meatball sub, french fries, and a John Daly.  All wonderful.\nPS - Kitchen is open till 11pm Sun-Thu, midnight Fri-Sat.

---

## Error 19: slice_specific_failure
- True label: 1
- Predicted label: 0
- Positive probability: 0.000434
- Slice: long
- Manual error type: Sarcasm or ambiguous wording
- Testable fix: Test character/subword features and sentence-level context to improve handling of sarcastic expressions.

**Review text:**

Came here back in June for the Britney Spears concert with my daughter. Not the best accoustics, but still a fairly nice venue. This was the most bizarre concert I've ever attended. It's not the venue's fault, but it was a weird experience. We sat in the unfixed seats in the back, just above the first level. An older couple sat next to us because the wife used a cane. First of all, I thought I would have been the oldest person there, I'm 41, but this couple was in their mid to late sixties. I heard the man tell his wife to sit the f*ck down...nice guy, right? During the opening act & the Nicki Minaj portion of the concert, he kept looking through his binoculars at them...EW. Then Britney came out. He danced as well as he could being old, white & sitting down. Again, he ogled Britney & her dancers through his binocs. Some poor girl had the misfortune of walking past then stopping in front of them on the walkway just above the top row of seats in the lower section. They yelled at her and told her to, \""Get the f*ck out of the way!!\"". She left, quite bewildered at being verbally assulted by a couple of old geezers at a Britney Spears concert. The part of Britney's show came in which she asks a male member of the audience to come on stage and dance with her. The fool old man was waving his hand wildly in the air, like a the kiss-ass smart kid in your elementary school class kind of hand raising! Fortunately for everyone in that arena, she picked a younger, better looking man....phew! About 10 minutes later, a group of 4 girls decided they wanted to dance where the first girl had earlier got her ass verbally handed to her by Mr. & Mrs. Hemorrhoid.  Again, they yelled obscenities at the girls, he pushed one of them and the wife was pushing them with her cane! The girls asked my daughter & I if we minded if they moved in front of us. We told them it was fine, we could still see just fine. Then one of the girls told the man that it was not OK to hit a woman. He says, \""I didn't hit you, I pushed you!\""...wow. Sorry girls, he's taken!

---

## Error 20: slice_specific_failure
- True label: 1
- Predicted label: 0
- Positive probability: 0.000626
- Slice: long
- Manual error type: Mixed sentiment / contrastive clauses
- Testable fix: Give more importance to contrast words and later clauses using sentence-level or attention-style pooling trained from scratch.

**Review text:**

The name \""smalls\"" refers to the restaurant's interior space, not the size of dreams or expectations you'll find once inside the doors.  A local vibe permeates the environment: the chef is a Johnson & Wales graduate and the bar serves NC craft beers.  The menu is interesting and accessible, with a few varieties of down home sliders accompanying other worldly options like chicken & waffles and handmade pasta.  Once your order gets to the table, watch out; the food is rich, developed, and flavorful.  BUT... a month after opening, there are still some service-type kinks that they haven't yet worked out.  \n\nFriday night, I called to see if a party of 3 could be seated and was told that they were filling up, but if we got there in the next 10 minutes we should be fine.  7 minutes later, we walked in the door and were told there would be a 15 minute wait.  Not that big of a deal, we went to the bar for a drink.  The bartender was very nice, but sadly couldn't transfer our drinks to the table once we were ready to be seated, so we had to close out - again, not that big of a deal.  Our waitress (unenthusiastically) told us the day's specials and then took our order... which is right about when everything fell apart.  They brought only two of our three dishes to the table, of which only one was correct.  So they then took the pimento sliders away but not-so-sneakily tried to pawn them off on the table behind us - alas, the pimento sliders were not what they'd ordered either.  Apparently, our third order had never gotten put into the system, so they scrambled to make that and finally brought out a plain burger, having prepared it so quickly that they left off all the burger toppings (cheese, bacon, lettuce, and tomato) that were supposed to come with it.  So, now we send a second plate back to the kitchen.  Ultimately, we finally got the right sliders and burger with all the proper fixins, but it shouldn't have to be that difficult.\n\nHowever, the food was good enough to assuage those problems (it didn't hurt that they comped us the burger on our final bill too).  Assuming they work out the kinks, this place may need to be renamed Bigs, as I can see it being huge in the Charlotte restaurant scene.

---
