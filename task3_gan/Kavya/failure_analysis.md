# Part 3 Failure / Limitation Analysis

## Training Stability
- NaN count: 0
- Peak generator gradient norm: 498.967590
- Final generator loss: 3.109084
- Final cycle loss: 1.330507
- Final identity loss: 0.512053
- Final discriminator A loss: 0.156174
- Final discriminator B loss: 0.064673

## Visual Failure Cases

I randomly reviewed images from both `pred_A2B` and `pred_B2A`. These were some noticeable failure cases.

### A2B — Photo to Monet

- **Picture 1: `photo_to_monet_00075.jpg`**
  - The Monet style is visible, but the sky has a very strong bright streak that looks unnatural.
  - Some areas around the trees and sky look blended together.
  - The model seems to add painterly texture too strongly in the bright parts of the image.

- **Picture 2: `photo_to_monet_00019.jpg`**
  - The image has the right painted look, but many small details are lost.
  - The trees and buildings look mixed together and a little messy.
  - The model captures the colors well, but the scene structure becomes less clear.

- **Picture 3: `photo_to_monet_00124.jpg`**
  - The snowy scene is recognizable, but some rocks and dark areas look like sharp black smears.
  - Fine details in the snow are replaced by rough brush-like patches.
  - This may happen because the model focuses more on texture than keeping exact object shapes.

### B2A — Monet to Photo

- **Picture 1: `monet_to_photo_00159.jpg`**
  - The scene looks more realistic, but the grass is very yellow and oversaturated.
  - Some painted texture is still visible instead of looking fully photographic.
  - The model improves realism, but the color balance is not always natural.

- **Picture 2: `monet_to_photo_00027.jpg`**
  - The path and landscape are recognizable, but parts of the trees and hillside look blurry.
  - The center of the image has a soft, stretched look.
  - The model has trouble turning painted edges into clean photographic details.

- **Picture 3: `monet_to_photo_00128.jpg`**
  - This is the clearest failure among the samples I checked.
  - The trees and water have strong white smears and repeated blurry patterns.
  - The reflections do not look natural and some object boundaries are hard to identify.
  - The model seems to struggle when the painting has many overlapping trees, reflections, and bright highlights.

## Overall Limitations

- A2B usually produces a convincing painted style, but it can remove too much detail from the original photo.
- B2A has a harder task because it has to invent realistic details that may not exist in the painting.
- Some outputs have color shifts, blur, smearing, or repeated textures.
- Object shapes are mostly preserved, but complex scenes can lose clear boundaries.
- More training, better tuning, and a larger variety of training images could help reduce these failures.
