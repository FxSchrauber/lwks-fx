// @Released 2019-01-06
// @Author schrauber
// @Created 2017-02-01
// @see https://www.lwks.com/media/kunena/attachments/348533/RC_Gamma.png

/**
This is a simple gamma control.
This effect can only be influenced by a remote control.
In the effect settings of this remotely controllable effect
the channel number should be adjusted, which should control this effect. 
Please note the description of the connected remote control effect
in order to determine the relevant remote control channel.
*/


//--------------------------------------------------------------//
// Lightworks user effect rc_Gamma.fx
//
// Updates:
//
// 06 January 2018 by LW user schrauber:
//    File renamed from "RC_rc_Gamma.fx"  to "rc_Gamma.fx"
//    Renamed effect from "RC Gamma" to "rc Gamma"
//    Category changed from "Colour" to "User"
//    Subcategory changed from "Requires remote control" to "Remote control"
//    Option for the future: Measurement option extended: fn_receiving05 (more channels, such as channel 100)
//
// 15 April 2018 by LW users schrauber:    Lightworks category and subcategory changed
// 19 February 2017 by LW users schrauber: If Channel 0 is set in the effect settings, the remote control is now disabled.
// 17 February 2017 by LW user jwrl:       The effect now preserves the alpha channel
// 
//
//--------------------------------------------------------------//
// Information for Effect Developer:
//
// This effect is based on the effect: "Lift, Gamma, Gain"
// Original file name: Sample 1 - Single input, Single pass.fx 
// And came from the Lightworks folder: "Effect Templates"
// Thanks!
// LW user "schrauber" has significantly reduced this effect 
//                     and equipped it with a remote control.
//
// 17 February 2017: modified by jwrl to preserve the alpha channel//
// 19 Febuary 2017; modified by user "schrauber": RcSampler settings, Clamp changed to Border
//
// 15 April 2018 modified by LW users schrauber:
//    Lightworks category and subcategory changed
//    GitHub-relevant: @Released, @Author, @Created, Effect description
//
//--------------------------------------------------------------//
int _LwksEffectInfo
<
   string EffectGroup = "GenericPixelShader";
   string Description = "rc Gamma";
   string Category    = "User";
   string SubCategory = "Remote control";
> = 0;

//--------------------------------------------------------------//
// Inputs
//--------------------------------------------------------------//


texture Input;
sampler FgSampler = sampler_state
{
   Texture = <Input>;
};



texture RC;
sampler RcSampler = sampler_state
{
   Texture = <RC>;
   AddressU = Border; 					// If a channel position is set outside the texture (e.g., channel 0), a black border turns off the remote control.
   AddressV = Border;					// If a channel position is set outside the texture (e.g., channel 0), a black border turns off the remote control.
   MinFilter = None;
   MagFilter = None;
   MipFilter = None;
};






////////////////////////////////////////////////////////////////////////////
//
// Parameters, which can be changed by the user in the effects settings.
//
/////////////////////////////////////////////////////////////////////////////


 
float Ch
<
   string Description =  "Channel";
   float MinVal = 1.0;
   float MaxVal = 5000.0;
> = 1.0;






//--------------------------------------------------------------//
// Functions
//--------------------------------------------------------------//
// The code is documented in the developer repository.
// The link to this repository can be found in the forum:
// https://www.lwks.com/index.php?option=com_kunena&func=view&catid=7&id=143678&Itemid=81#ftop


float fn_receiving05 (float Ch)    // Return value range: -1.0 to +1.0
{
   float  ch    = floor(Ch) - 1.0;
   float  posY  = floor(ch/100.0) / 50.0;
   float2 pos   = float2 ( frac(ch / 100.0) + 0.005  ,  posY + 0.01 );
  
   float4 sample = tex2D (RcSampler, pos );
   float status = sample.b;
   float ret = round (sample.r * 255.0) / 255.0
             + sample.g / 255.0;
   ret = status > 0.001 ? ret * 2.0 -1.0 : 0.0;

   return ret;
}






///////////////////////////////////////////////////////////////////////////////////////////////////
//               *****  Pixel Shader  *****
//
// This section defines the code which the GPU will
// execute for every pixel in an output image.
//
// These functions are used by "Technique"
////////////////////////////////////////////////////////////////////////////////////////////////////




float4 Gamma( float2 xy : TEXCOORD1 ) : COLOR
{
   float4 retval = tex2D (FgSampler, xy);

   return float4 (pow (retval.rgb, 1 / max (fn_receiving05 (Ch) + 1, 1E-6)), retval.a);
}








//--------------------------------------------------------------
// Technique
//
// Specifies the order of passes (we only have a single pass, so
// there's not much to do)
//--------------------------------------------------------------

technique SampleFxTechnique
{
   pass SinglePass
   {
      PixelShader = compile PROFILE Gamma();
   }
}

