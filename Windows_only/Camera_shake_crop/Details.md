*[[Return to parent page]](../README.md)*  

## More details (Camera shake & crop & reflections)
![](IMG/img2.jpg)  

---------------------------------------------

### Strength:
![](IMG/Strength.jpg)
  - **Move**  
    Average strength of semi-random shaking movements. 
  - **Automatic**  
  Self-adjusting zoom, depending on the "Move" setting and automatic mode.
  ![](IMG/Automatic.jpg)  
    - **Mirrored edges (no zoom)**  
      The edges are reflected to avoid trembling black edges. 
    - **Zoom; mirrored edges visible**  
      Self-adjusting low zoom to minimize reflections at the edges.
    - **Zoom; mirrored edges maybe visible**  
      Self-adjusting zoom to largely avoid reflections at the edges.
    - **Secure zoom; edges never visible**  
       Self-adjusting zoom, which can be strong depending on the "Move" setting.  
  - **XY Shake ratio**  
    - 0% = Statistically identical average intensity of horizontal and vertical movements.
    - -100% = Horizontal movements only.
    - +100% = Vertical movements only.

---------------------------------------------

#### Speed
  - Details in progress

---------------------------------------------

### Crop & mirror edges
![](IMG/Crop.jpg)  
  - **Crop and mirror behavior:**  
  ![](IMG/Reflection.jpg)  
    - **Reflection on set edges acting on incoming frames**  
      Details in progress  
    - **Reflection on the edges of the incoming frame**  
      Details in progress  
    - **NO cropping ; Reflection on the set edges**  
      Details in progress  
  - **Top & Bottom**
    Details in progress
  - **Left & Right**
     Details in progress
  - **Crop color**
    Details in progress  
    
--------------------------------------------
    
#### Random values
They are not real random values.  
From this ramp, the effect creates seemingly random values to produce the shaking.
![](IMG/Random.jpg)  
The values of this ramp itself are **not** the random values, but merely the basis for selecting an internal random value.
If you want to start the effect with other shaking behaviors then you can change the starting value of the keyframing (ramp). 
Note that the angle of the ramp also affects the speed. If you just want to change the speed then use the "Speed" slider.
