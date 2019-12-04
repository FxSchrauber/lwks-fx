
// @Released 
// @Author 
// @Created 
//-----------------------------------------------------------------------------------------//
// Lightworks user effect 
//
//-----------------------------------------------------------------------------------------//


// Test-effect




int _LwksEffectInfo
<
   string EffectGroup = "GenericPixelShader";
   string Description = "Diffusion_Test02b";
   string Category    = "Mix";
   string SubCategory = "Prototypes";
   string Notes       = "Prototype, effect development is not finished yet";
> = 0;



//-----------------------------------------------------------------------------------------//
// Inputs & Samplers
//-----------------------------------------------------------------------------------------//



texture Fg;
sampler s_Fg = sampler_state
{
   Texture   = <Fg>;
   AddressU  = Mirror;
   AddressV  = Mirror;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;
};


texture Bg;
sampler s_Bg = sampler_state
{
   Texture   = <Bg>;
   AddressU  = Mirror;
   AddressV  = Mirror;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;
};







//-----------------------------------------------------------------------------------------//
// Parameters
//-----------------------------------------------------------------------------------------//


float Amount
<
   string Description = "Amount";
   float MinVal = 0.0;
   float MaxVal = 1.0;
   float KF0    = 0.0;
   float KF1    = 1.0;
> = 0.0;



float Radius
<
   string Description = "Diffusion radius";
   float MinVal       = 0.0;
   float MaxVal       = 1.0;
> = 0.3;



int Mode
<
  string Description = "Diffusion random generator";
  string Enum = "Static,Renew per frame";
> = 1;


//-----------------------------------------------------------------------------------------//
// Definitions and declarations
//-----------------------------------------------------------------------------------------//

float _OutputAspectRatio;

#define PI      3.1415926536
#define TWO_PI  6.2831853072



//--------------------------------------------------------------//
// Functions
//--------------------------------------------------------------//


float2 fn_noiseTex (float2 progress, float2 xy)      // float2 texture noise (two different values per pixel and frame)
{
   float2 noise1 = frac (sin ( 1.0 + progress + (xy.x * 82.3)) * ( xy.x + 854.5421));
   return          frac (sin ((1.0 + noise1 + xy.y)   * 92.7 ) * (noise1   + xy.y + 928.4837));
}



//-----------------------------------------------------------------------------------------//
// Shaders
//-----------------------------------------------------------------------------------------//

float4 ps_main (float2 uv1 : TEXCOORD1, float2 uv2 : TEXCOORD2) : COLOR
{

   
   float progressCos0_1_0 = cos(Amount * TWO_PI) *-0.5 + 0.5;       // Generates a cos-project-progress of 0 over 1 to 0 

   float2 radius = float2 (1.0, _OutputAspectRatio) * progressCos0_1_0.xx * Radius.xx;


   float progressNoise = (Mode == 1) ? Amount : 1.0;

   float2 noise = fn_noiseTex (float2(progressNoise, progressNoise + 0.3) , uv1 + uv2 ); 
   noise -= 0.5;


   float maxNoise = max( abs(noise.x), abs(noise.y));
   float correction = length(maxNoise) / max( length(noise), 1.0E-9); 
   radius = radius * noise * correction;                                        // Creates a statistically round diffusion radius   

   float4 sampleFg = tex2D (s_Fg, uv1 + radius);
   float4 sampleBg = tex2D (s_Bg, uv2 + radius);

   float progress_S = cos(Amount * PI) *-0.5 + 0.5;
   float S_Curve    = cos(progress_S * PI) *-0.5 + 0.5;

   return lerp ( sampleFg, sampleBg, S_Curve )  ;
}


//-----------------------------------------------------------------------------------------//
// Techniques
//-----------------------------------------------------------------------------------------//




technique main_technipue
{

    pass P_1 { PixelShader = compile PROFILE  ps_main (); }
}


