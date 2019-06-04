*[[Return to parent page](../README.md)]*  

# Rhythmic pulsation

### Filename: <a href="Rhythmic_pulsation_20180405.fx" download>Rhythmic_pulsation_20180405.fx</a> 
[Download as zip-file](Rhythmic_pulsation_20180405.zip)

### Effect description:  The effect creates a cyclically repeating zoom. 
In addition to the frames per cycle, the zoom behavior within the cycles can also be set. For this purpose, the effect itself generates a curve graphic in order to be able to adjust the behavior more precisely. 
A prerequisite for the internal effect calculations is that you correctly set the effect runtime in frames in the effect.   
This video shows how the timing of the effect can be adjusted exactly with the help of Cue in the Timeline: **[youtube.com/watch?v=YYAMn6vOAbo](https://www.youtube.com/watch?v=YYAMn6vOAbo)**  

The effect also gives some feedback on the effect status and does some plausibility checks. The meaning of the warnings and confirmations is described in this PDF document:  
**[Meaning of displayed warning symbols](Documentation/warning_symbols.pdf)**  
Because the effect was developed for an older Lightworks version, it cannot be excluded that individual warnings react differently than documented.

--------------------------------------------------------------------------

### Known issues and limitations: Only for Windows 
Cause of incompatibility with other platforms: unknown

--------------------------------------------------------------------------

### Adjustment note: 
LWKS-Kyframing should not be used with some parameters.  
E.g. A sliding change of the frames per cycle ("Main Interval") always shifts the position in the cycle, which can counteract the internally calculated positional change, which in the interplay will give a different cycle time than the Kyframe value.

### General note:
For cycle frames with decimal places, the cycle progress (and the marker) will occasionally pause for 2 frames at a position to remain synchronized with the set value.

--------------------------------------------------------------------------

#### More recent alternative effects:
Since Lightworks 14.5 it is possible for an effect to automatically determine the effect runtime. This is implemented in the Cyclic [Remote Control](https://www.lwks.com/index.php?option=com_kunena&func=view&catid=7&id=188603&Itemid=81#ftop). If you control a suitable zoom effect with this remote control, you can achieve the same result (and control even more effects if necessary).

---------------------------------------------------------------------------

[Previous_versions "Rhythmic_pulsation_20170519.fx"](Previous_versions/Rhythmic_pulsation_20170519.fx?raw=true)  
[Similar versions "Heartbeat"](https://www.lwks.com/index.php?option=com_kunena&func=view&catid=7&id=121275&Itemid=81#121626)  
[Intermediate versions were created during the effect development:](https://www.lwks.com/index.php?option=com_kunena&func=view&catid=7&id=9259&limit=15&limitstart=840&Itemid=81#122190) (and the pages following the link)

*[[Return to parent page]](../README.md)*  
