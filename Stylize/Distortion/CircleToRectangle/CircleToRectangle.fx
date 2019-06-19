// Lightworks user effect
// prototype


// Created [June 2019]


/**    ---    Prototype  --- 
 Effect description see: https://fxschrauber.github.io/lwks-fx/
*/

//--------------------------------------------------------------//


int _LwksEffectInfo
<
   string EffectGroup = "GenericPixelShader";
   string Description = "From circle to rectangle";  
   string Category    = "Stylize";
   string SubCategory = "Distortion";
   string Notes       = "Prototype 20190617, see: https://fxschrauber.github.io/lwks-fx/";
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






//--------------------------------------------------------------//
// Parameters
//--------------------------------------------------------------//


float Distortion
<
   string Description = "Distortion";
   float MinVal = 0.0;
   float MaxVal = 1.0;
> = 0.0;

float PosDistortion
<
   string Description = "Pos-Distortion";
   float MinVal = -0.5;
   float MaxVal = 0.5;
> = 0.0;


float ReflectX
<
   string Description = "Reflect X position";
   float MinVal = 0.0;
   float MaxVal = 0.3;
> = 0.0;


float StretchX
<
   string Description = "Stretch X";
   float MinVal = 1.0;
   float MaxVal = 1.3;
> = 1.0;


float Xpos
<
   string Description = "Frame Position";
   string Flags = "SpecifiesPointX";
   float MinVal = 0.0;
   float MaxVal = 1.0;
> = 0.5;

float Ypos
<
   string Description = "Frame Position";
   string Flags = "SpecifiesPointY";
   float MinVal = 0.0;
   float MaxVal = 1.0;
> = 0.5;







//-----------------------------------------------------------------------------------------//
// Definitions and declarations
//-----------------------------------------------------------------------------------------//

#define PI            3.1415926536
#define FRAMECENTER   0.5
#define BLACK0        float4 (0.0.xxxx)    
#define EDGEleft    ReflectX
#define EDGEright   (1.0 - ReflectX)   

//--------------------------------------------------------------
// Shader
//--------------------------------------------------------------




float4 ps_zoom (float2 uv : TEXCOORD1) : COLOR 
{ 
   // --- Shader definitions and declarations

      // Position vectors: 
         float2 deltaPos;                     // Shifting, sampler position

      // Direction vectors:
         float2 vCenterT = FRAMECENTER - uv;  // Direction  between the frame center and the respective texel.



   // ... Pos
      deltaPos = float2 (1.0 - Xpos, Ypos) - FRAMECENTER;


   // ... X Distortion depending on the vertical distance of frame center

      float2 zoom = float2 (Distortion * 2.0 * abs(vCenterT.y + PosDistortion) , 0.0);
      zoom = cos(zoom * PI) * -0.5 + 0.5;
      deltaPos = deltaPos + (zoom * vCenterT) ; 


   // ... Reflection at the set x-edges (Corrected sample position)
   float2 xy = uv;    
   if (xy.x < EDGEleft)   xy.x = xy.x + 2.0 * (EDGEleft - xy.x);
   if (xy.x > EDGEright)  xy.x = xy.x + 2.0 * (EDGEright - xy.x);


   // ... StretchX
      xy.x = xy.x / max(StretchX, 1E-9);

   // ... Samper & Out
      return tex2D (s_input, deltaPos + xy); 
 

} 





//--------------------------------------------------------------
// Technique
//--------------------------------------------------------------

technique tech
{
   pass P_1  { PixelShader = compile PROFILE  ps_zoom (); }
}