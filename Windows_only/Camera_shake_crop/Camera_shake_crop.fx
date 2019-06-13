//--------------------------------------------------------------//
// Lightworks user effect
//
// Created [June 2019]


/**    ---    Prototype  --- 
   Known issues and limitations:
   Only for Windows
   Maybe the effect doesn't work with all GPUs?
   Cause of incompatibility: The used random number generator

  More limitations: Lightworks 14.5 or better

  Effect description see: https://fxschrauber.github.io/lwks-fx/Windows_only/Camera_shake_crop/
*/





//--------------------------------------------------------------//

int _LwksEffectInfo
<
   string EffectGroup = "GenericPixelShader";
   string Description = "Camera shake & crop & reflections";
   string Category    = "Stylize";
   string SubCategory = "Video artefacts";
   string Notes       = "Prototype, Windows only, >= Lightworks 14.5";
> = 0;





//--------------------------------------------------------------//
// Inputs und Samplers
//--------------------------------------------------------------//


texture Input;
sampler s_input = sampler_state
{
   Texture = <Input>;
   AddressU = Mirror;
   AddressV = Mirror;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;
};


texture RenderPass1 : RenderColorTarget;
sampler s_render = sampler_state
{
   Texture = <RenderPass1>;
};


//--------------------------------------------------------------//
// Parameters
//--------------------------------------------------------------//



float Move
<
   string Group = "Strength";
   string Description = "Move";
   float MinVal = 0.0;
   float MaxVal = 1.0;
> = 0.1;


int AutoZoom
<
   string Group = "Strength";
   string Description = "Automatic";
   string Enum = "Mirrored edges (no zoom),"
                 "Zoom; mirrored edges visible,"
                 "Zoom; mirrored edges maybe visible,"
                 "Secure zoom; edges never visible";
> = 2;


float XYratio
<
   string Group = "Strength";
   string Description = "XY Shake ratio";
   float MinVal = -1.0;
   float MaxVal = 1.0;
> = 0.0;



float Speed
<
   string Description = "Speed";
   float MinVal = 0.0;
   float MaxVal = 1.0;
> = 0.2;


int MirrorMode
<
   string Group = "Crop & mirror edges (Adaptation to original at Move = 0)";
   string Description = " ";
   string Enum = "Reflection on set edges acting on incoming frames,"
                 "Reflection on the edges of the incoming frame,"
                 "NO cropping ; Reflection on the set edges";
> = 0;



float CropY
<
   string Group = "Crop & mirror edges (Adaptation to original at Move = 0)";
   string Description = "Top & Bottom";
   float MinVal = 0.0;
   float MaxVal = 0.5;
> = 0.0;



float CropX
<
   string Group = "Crop & mirror edges (Adaptation to original at Move = 0)";
   string Description = "Left & Right";
   float MinVal = 0.0;
   float MaxVal = 0.5;
> = 0.0;


float4 CropColor
<   
   string Group = "Crop & mirror edges (Adaptation to original at Move = 0)";
   string Description = "Crop color ";
   bool SupportsAlpha = true;
> = { 0.0, 0.0, 0.0, 1.0};





float Progress
<
   string Description = "Random values";
   float MinVal = 0.0;
   float MaxVal = 1.0;
   float KF0    = 0.0;
   float KF1    = 1.0;
> = 0.0;




//-----------------------------------------------------------------------------------------//
// Definitions and declarations
//-----------------------------------------------------------------------------------------//

float _OutputAspectRatio;
float _Length;


#define FRAMECENTER  0.5
#define OFFSETnoise  2.2 
#define PROGRESS  ((Progress * 20.0) * _Length)

#define EDGEleft    CropX
#define EDGEright   (1.0 - CropX)
#define EDGEtop     CropY
#define EDGEbottom  (1.0 - CropY)




//--------------------------------------------------------------//
// Shader
//--------------------------------------------------------------//


float4 ps_main (float2 uv : TEXCOORD1) : COLOR 
{ 
   float2 multiplier1 = saturate (float2 (1.0 - XYratio,
                                         1.0 - (XYratio * -1.0)));                      // Two multipliers of X and Y motion strength (range from 0 to 1)
   float2 move = float2 (Move * multiplier1);                                           // Motion strength, Without correction based on media aspect ratio

   float2 multiplier = float2 (multiplier1.x / _OutputAspectRatio, multiplier1.y);


   if (AutoZoom == 1) multiplier *= _OutputAspectRatio * 2.0;
   if (AutoZoom == 2) multiplier *= _OutputAspectRatio;

   float deltaX = multiplier.x * (noise(PROGRESS * Speed + OFFSETnoise));  // !! Windows only !!  X Sampler-position shift of the semi-randomly determined effect center
   float deltaY = multiplier.y * (noise(PROGRESS * Speed));                // !! Windows only !!  Y Sampler-position shift of the semi-randomly determined effect center
   float2 delta = float2 (deltaX, deltaY) / 2.0;                           //  Sampler-position shift
   float2 delta2 = move * delta;                                           //  Sampler-position shift without zoom

     
 
  // ...... Zoom at the semi-randomly changing effect center  ....
   float zoom = max(move.x , move.y);
   if (AutoZoom == 1) zoom /= _OutputAspectRatio * 2.0;
   if (AutoZoom == 2) zoom /= _OutputAspectRatio;

   delta = delta + FRAMECENTER - uv;
   delta = zoom * delta;   
   delta = (AutoZoom == 0) ? delta2 : delta;
   


   // ... Reflection at the set edges (Corrected sample position)
   float2 xy2 = delta + uv;    
   if (xy2.x < EDGEleft)    xy2.x = xy2.x + 2.0 * (EDGEleft - xy2.x);
   if (xy2.x > EDGEright )  xy2.x = xy2.x + 2.0 * (EDGEright - xy2.x);
   if (xy2.y < EDGEtop)     xy2.y = xy2.y + 2.0 * (EDGEtop - xy2.y);
   if (xy2.y > EDGEbottom ) xy2.y = xy2.y + 2.0 * (EDGEbottom - xy2.y);



   // ... Reflection at the edges of the incoming frame (sampler settings)
   xy2 =  (MirrorMode == 1) ? delta + uv : xy2;      
   float4 retval = tex2D (s_input, xy2);                          


   // ... Crop
   float y = 1.0 - uv.y;
   if (   ( MirrorMode == 2)
      ||
         (
         (uv.x > EDGEleft) 
      && (uv.x < EDGEright) 
      && (y > EDGEtop) 
      && (y < EDGEbottom)
         )
      )
      return retval;

   return CropColor;  
} 




//--------------------------------------------------------------//
// Techniques
//--------------------------------------------------------------//


technique tech_main
{
   pass P_1  { PixelShader = compile PROFILE ps_main(); }
}
