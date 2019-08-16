// @Maintainer hugly
// @Released 2019-08-15
// @Author hugly, schrauber
// @Created 2019-08-09
// @see

/**
'EasyOverlay' is a luminance keyer for overlays which show luminance for transparency, i.e. full transparency appears as solid black in the overlay. The keyer works also on overlays with alpha channel. It reveals transparency using a black&white mask created from the foreground.
The presets should work for most material of that kind with good looking results. If adjustments should be necessary, start with 'MaskGain'. 'Fg Lift' influences overall brightness of the overly while preserving the highlights. 'Fg Opacity' is e.g. useful to dissolve from/to the overerlay using keyframes.
*/

//--------------------------------------------------------------//
// EasyOverlay.fx
//
// Version history:
// next2 
//		static background patterns and alpha export
// next3
// 		dynamic background: jwrl's FractalMatte3fx
//--------------------------------------------------------------//

int _LwksEffectInfo
<  string EffectGroup = "GenericPixelShader";
   string Description = "EasyOverlayNext3-mod";
   string Category    = "Key";
   string SubCategory = "Key Extras";
   string Notes       = "For overlays where luminance represents transparancy";
> = 0;

//--------------------------------------------------------------//
// Globals Definitions and declarations
//--------------------------------------------------------------//

float _OutputAspectRatio;
float _Progress;
float _Length;

#define PI       3.141592654
#define PI_2     6.283185

#define INVSQRT3 0.57735

#define R_WEIGHT 0.2989
#define G_WEIGHT 0.5866
#define B_WEIGHT 0.1145

//--------------------------------------------------------------//
// Parameters
//--------------------------------------------------------------//

float MaskGain
<  string Description = "Mask Gain";
   float MinVal = 0.0;
   float MaxVal = 6.0;
> = 3;

float FgLift
<  string Description = "Fg Lift";
   float MinVal =  -1.0;
   float MaxVal =   1.0;
> = 0;

float FgOpacity
<  string Description = "Fg Opacity";
   float MinVal = 0.0;
   float MaxVal = 1.0;
> = 1;

int SelectBg
<
   string Description = "Select Bg";
   string Enum = "Bg Input,"
                 "50% Diamond Pattern,"
                 "90% Luminance,"
                 "10% Luminance,"
                 "Alpha Channel,"
                 "FractalMatte";
> = 0;

/** bool EnableBgPattern
<	
	string Description = "Enable Bg Pattern";
> = false;
**/


/**
float Opacity
<
   string Description = "Opacity";   
   string Group = "Matte"; 
   float MinVal = 0.0;
   float MaxVal = 1.0;
> = 1.0;
**/

float Pulse
<
   string Description = "Pulse";   
   string Group = "Matte"; 
   float MinVal = 1;
   float MaxVal = 16;
> = 8.0;

float FracOffs
<
   string Description = "Fractal offset";   
   string Group = "Matte"; 
   float MinVal = 0.00;
   float MaxVal = 1.00;
> = 0.0;


/**
float FracRate = 0.5
<
   string Description = "Fractal rate";   
   string Group = "Matte"; 
   float MinVal = 0.00;
   float MaxVal = 1.00;
> = 0.5;
**/


float4 Colour
<
   string Description = "Mix colour";
   string Group = "Matte"; 
   bool SupportsAlpha = true;
> = { 1.0, 0.77, 0.19, 1.0 };

float ColourMix
<
   string Description = "Mix level";
   string Group = "Matte"; 
   float MinVal = 0.0;
   float MaxVal = 1.0;
> = 0.0;

float HueParam
<
   string Description = "Hue";
   string Group = "Matte"; 
   float MinVal = -1.0;
   float MaxVal = 1.0;
> = 0.0;

float SatParam
<
   string Description = "Saturation";
   string Group = "Matte"; 
   float MinVal = -1.0;
   float MaxVal = 1.0;
> = 0.0;

/**
float Gain
<
   string Description = "Gain";
   string Group = "Matte"; 
   float MinVal = 0.00;
   float MaxVal = 4.00;
> = 1.0;
float Gamma
<
   string Description = "Gamma";
   string Group = "Matte"; 
   float MinVal = 0.0;
   float MaxVal = 4.00;
> = 1.00;
float Brightness
<
   string Description = "Brightness";
   string Group = "Matte"; 
   float MinVal = -1.00;
   float MaxVal = 1.00;
> = 0.0;
float Contrast
<
   string Description = "Contrast";
   string Group = "Matte"; 
   float MinVal = 0.00;
   float MaxVal = 4.00;
> = 1.0;
**/

//--------------------------------------------------------------//
// Inputs
//--------------------------------------------------------------//

texture fg;
texture bg;
texture Fractal : RenderColorTarget;
texture Matte   : RenderColorTarget;

//--------------------------------------------------------------//
// Samplers
//--------------------------------------------------------------//

sampler FgSampler   = sampler_state { Texture = <fg>; };
sampler BgSampler   = sampler_state { Texture = <bg>; };
sampler s_Fractal   = sampler_state { Texture = <Fractal>; };
sampler s_Matte     = sampler_state { Texture = <Matte>; };

//--------------------------------------------------------------//
// Functions called by shaders 
//--------------------------------------------------------------//

float4 fn_setFgLift (float4 x, float lift)
{  lift *= 0.55;
   float3 gamma1 = 1.0 - pow ( 1.0 - x.rgb, 1.0 / max ((1.0 - lift), 1E-6));
   float3 gamma2 =       pow ( x.rgb , 1.0      / max (lift + 1.0, 1E-6));
   float3 gamma = (lift > 0) ? gamma1 : gamma2;
   gamma =  saturate (lerp ( gamma , (gamma1 + gamma2) / 2.0, 0.8));
   return float4 (gamma.rgb, x.a);
}

float3 fn_diamondPattern (float2 uv, float3 color1, float3 color2, float numberH, float edgeSharpness)
{  
   float2 mix = float2 (uv.x + (uv.y / _OutputAspectRatio) , 0.0);
   mix.y = uv.x - (uv.y / _OutputAspectRatio);
   mix = sin (mix * PI * numberH ) * edgeSharpness / numberH;
   mix =  clamp( mix, -0.5, 0.5) + 0.5;
   return (lerp (color1, color2, lerp( mix.y , 1.0 - mix.y, mix.x)));
}

//-----------------------------------------------------------------------------------------//
// Shaders
//-----------------------------------------------------------------------------------------//

float4 ps_fractal (float2 xy : TEXCOORD) : COLOR
{  
   float speed = 0.25 * ((cos(_Length/Pulse  * _Progress) + 1) /2);

   float4 retval = 1.0.xxxx;
   float3 f = float3 (xy, FracOffs);
   for (int i = 0; i < 75; i++) {
      f.xzy = float3 (1.3, 0.999, 0.7) * (abs ((abs (f) / dot (f, f) - float3 (1.0, 1.0, speed))));
   }
   retval.rgb = f;
   return retval;
}

float4 ps_FractalMatte (float2 uv : TEXCOORD) : COLOR 
{
   //float4 Fgd    = tex2D (s_Input, xy);
   float4 retval = tex2D (s_Fractal, uv);

   float luma   = dot (retval.rgb, float3 (R_WEIGHT, G_WEIGHT, B_WEIGHT));
   float buffer = dot (Colour.rgb, float3 (R_WEIGHT, G_WEIGHT, B_WEIGHT));

   buffer = saturate (buffer - 0.5);
   buffer = 1 / (buffer + 0.5);

   float4 temp = Colour * luma * buffer;

   retval = lerp (retval, temp, ColourMix);
   luma = (retval.r + retval.g + retval.b) / 3.0;

   float RminusG = retval.r - retval.g;
   float RminusB = retval.r - retval.b;
   // float GammVal = (Gamma > 1.0) ? Gamma : Gamma * 0.9 + 0.1;
   float Hue_Val = acos ((RminusG + RminusB) / (2.0 * sqrt (RminusG * RminusG + RminusB * (retval.g - retval.b)))) / PI_2;
   float Sat_Val = 1.0 - min (min (retval.r, retval.g), retval.b) / luma;

   if (retval.b > retval.g) Hue_Val = 1.0 - Hue_Val;

   Hue_Val = frac (Hue_Val + (HueParam * 0.5));
   Sat_Val = saturate (Sat_Val * (SatParam + 1.0));

   float Hrange = Hue_Val * 3.0;
   float Hoffst = (2.0 * floor (Hrange) + 1.0) / 6.0;

   buffer = INVSQRT3 * tan ((Hue_Val - Hoffst) * PI_2);
   temp.x = (1.0 - Sat_Val) * luma;
   temp.y = ((3.0 * (buffer + 1.0)) * luma - (3.0 * buffer + 1.0) * temp.x) / 2.0;
   temp.z = 3.0 * luma - temp.y - temp.x;

   retval = (Hrange < 1.0) ? temp.zyxw : (Hrange < 2.0) ? temp.xzyw : temp.yxzw;
   // temp   = (((pow (retval, 1.0 / GammVal) * Gain) + Brightness.xxxx - 0.5.xxxx) * Contrast) + 0.5.xxxx;
   // retval = lerp (Fgd, temp, Opacity);
   retval.a = 1.0;
   return retval;
}



float4 ps_oa( float2 xy0 : TEXCOORD0, float2 xy1 : TEXCOORD1, float2 xy2 : TEXCOORD2 ) : COLOR 
{  
   float4 fg    = tex2D( FgSampler, xy1 );
   float4 bg    = tex2D( BgSampler, xy2 );
   float4 matte = tex2D( s_Matte  , xy2 );
   float4 mask  = fg; 

   fg = fn_setFgLift (fg, FgLift);
   float alpha = mask.a * min ((( mask.r + mask.g + mask.b ) / 3.0) * MaskGain, 1.0);		

   if (SelectBg == 1) bg = float4 (fn_diamondPattern (xy0, 0.4, 0.6, 120, 1000.0), 1.0);
   if (SelectBg == 2) bg = float4 (0.90.xxx, 1.0);
   if (SelectBg == 3) bg = float4 (0.10.xxx, 1.0);
   if (SelectBg == 5) bg = matte;
  
   float4 ret = lerp( bg, fg, alpha * FgOpacity);

   if (SelectBg == 4)
      ret = float4 (fg.rgb, alpha * FgOpacity);
   else
		ret.a = 1.0;
   return ret;
}

//-----------------------------------------------------------------------------------------//
// Techniques
//-----------------------------------------------------------------------------------------//

technique test01
{
   pass P_1  < string Script = "RenderColorTarget0 = Fractal;"; > { PixelShader = compile PROFILE ps_fractal (); }
   pass P_2  < string Script = "RenderColorTarget0 = Matte;"  ; > { PixelShader = compile PROFILE ps_FractalMatte (); }
   pass P_3                                                       { PixelShader = compile PROFILE ps_oa(); } 
}
