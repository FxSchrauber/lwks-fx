*[[Return to parent page]](../README.md)*  

# Camera shake & crop & reflections

### Filename: <a href="Camera_shake_crop.fx" download>Camera_shake_crop.fx</a> 
[Download as zip-file](Camera_shake_crop.zip)

*Category*: **Stylize**  
*Subcategory:* **Video artefacts**  
*Status:* **Prototype** ,  June 2019  

### *Issues and limitations:*
  - **Only for Windows**  
  - **Lightworks 14.5 or better**
  - Maybe the effect doesn't work with all GPUs?
  - The effect was **not tested** with the "Letterbox" **project setting** enabled.


--------------------------------------------------------------------------

### Effect description:
Horizontal and vertical shifts based on a random generator.  

#### Features:
- Several automatic zoom modes to avoid the visibility of the frame edges.  
- Different reflection modes of the edges to allow a low zoom at strong shifts.  
- Cropping for adaptation to letterbox material.  
  *(This refers to material that has already been imported with black bars, or previous effects have created these bars. This **does not** refer to letterboxing created using the "Letterbox" project settings.)*  
  By default, the original material is reflected at the set crop edges before cropping is applied. 
  This prevents the black edges of letterbox material from becoming visible when shaking.  
  ![](IMG/img.jpg)  
  
  
  ### [More details](Details.md) 
