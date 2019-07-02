//--------------------------------------------------------------//
// Lightworks user effect
//
// Created [ July 2019]


/**    ---    Prototype  --- 
*/





//--------------------------------------------------------------//

int _LwksEffectInfo
<
   string EffectGroup = "GenericPixelShader";
   string Description = "Random asymmetric flicker";
   string Category    = "User";
   string SubCategory = "Switches";
   string Notes       = "Prototype 1.2. ; see: https://fxschrauber.github.io/lwks-fx/";
> = 0;





//--------------------------------------------------------------//
// Inputs und Samplers
//--------------------------------------------------------------//


texture In1;
sampler s_1 = sampler_state { Texture = <In1>; };

texture In2;
sampler s_2 = sampler_state { Texture = <In2>; };





//--------------------------------------------------------------//
// Parameters
//--------------------------------------------------------------//



float TimeRatio
<
   string Description = "Time ratio";
   float MinVal = -1.0;
   float MaxVal = 1.0;
> = 0.8;






//-----------------------------------------------------------------------------------------//
// Definitions and declarations
//-----------------------------------------------------------------------------------------//


float _Progress;

#define RATIOtime ( 0.5 + TimeRatio / 2.0)


//--------------------------------------------------------------//
// Functions
//--------------------------------------------------------------//


float fn_noise (float progress)
{
   return frac (sin (progress * 478523.3 + 1.0) * (progress + 854.5421));
}



//--------------------------------------------------------------//
// Shader
//--------------------------------------------------------------//


float4 ps_main (float2 uv : TEXCOORD1) : COLOR 
{ 
   float4 ret1 = tex2D (s_1 , uv);
   float4 ret2 = tex2D (s_2 , uv);
   
   float noise1 = fn_noise(_Progress);
   float noise2 = fn_noise(noise1 * 0.7 + 2.6);

   return (noise2 > RATIOtime) ? ret2 : ret1;

} 




//--------------------------------------------------------------//
// Techniques
//--------------------------------------------------------------//


technique tech_main
{
   pass P_1  { PixelShader = compile PROFILE ps_main(); }
}
