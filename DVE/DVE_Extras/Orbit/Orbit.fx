// Prototype of a multiple rotation effect
// 
// Ideas and Suggestions for improvement:
//
// * [quote="khaver"]... Something you might add is an enumeration list box to pin the frame at it’s center or one of it’s corners to the circle.[/quote]
// * Crop: In case of asymmetrical cropping a re-centering of the spin is required.
// * Aspect Ratio of Orbit: - Symmetric Slider Scaling
//                          - Maybe rotatable aspect ratio?
// * Interference filter option at minimization (scaling-dependent pre-blurring)
// * Sampler configuration "Border" maybe replaced by the function "fn_tex2D_4"?
//       - This also allows edge softness
//       see https://www.lwks.com/index.php?option=com_kunena&func=view&catid=7&id=143678&limit=15&limitstart=315&Itemid=81#179823





// Setting characteristics of the zoom slider
//    The dimensions will be doubled or halved in setting steps of 10%:
//    -40% Dimensions / 16
//    -30% Dimensions / 8
//    -20% Dimensions / 4
//    -10% Half dimensions
//      0% No change
//     10% Double dimensions
//     20% Dimensions * 4
//     30% Dimensions * 8
//     40% Dimensions * 16
//
// Center of rotation:
// Switch between automatic centering, and manually adjustable position of the axis of rotation.
//    Automaic:
//        Zoom >= 0: rotation center = center of the output texture
//        Zoom <  0: rotation center = center of the input textur
//        For this purpose, the program sections ZOOM and ROTATION are run through in different order.
//        Zoom >= 0: first ZOOM, then ROTATION
//        Zoom <  0: first ROTATION, then ZOOM
//
//--------------------------------------------------------------//

int _LwksEffectInfo
<
   string EffectGroup = "GenericPixelShader";
   string Description = "Orbit";
   string Category    = "DVE";
   string SubCategory = "DVE Extras";
   string Notes       = "Prototype 20190619, see: https://fxschrauber.github.io/lwks-fx/";
> = 0;





//--------------------------------------------------------------//
// Inputs und Samplers
//--------------------------------------------------------------//


texture Fg;
sampler FgSampler = sampler_state
{
   Texture   = <Fg>;
   AddressU  = Border;
   AddressV  = Border;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;
};


texture Bg;
sampler BgSampler = sampler_state
{
   Texture   = <Bg>;
   AddressU  = Border;
   AddressV  = Border;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;
};


texture RenderPass1 : RenderColorTarget;
sampler Render1Sampler = sampler_state
{
   Texture   = <RenderPass1>;
   AddressU  = Border;
   AddressV  = Border;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;
};


texture RenderPass2 : RenderColorTarget;
sampler Render2Sampler = sampler_state
{
   Texture   = <RenderPass2>;
   AddressU  = Border;
   AddressV  = Border;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;
};


//--------------------------------------------------------------//
// Parameters
//--------------------------------------------------------------//


float Rounds
<
   string Group = "Orbit";
   string Description = "Rounds";
   float MinVal = -10.0;
   float MaxVal = 10.0;
> = 0.0;


float OrbitRadius
<
   string Group = "Orbit";
   string Description = "Orbit radius";
   float MinVal = 0.0;
   float MaxVal = 2.0;
> = 0.5;

float OrbitAspectRatio
<
   string Group = "Orbit";
   string Description = "Aspect ratio";
   float MinVal = 0.3;
   float MaxVal = 4.0;
> = 1.0;



float Spin
<
   string Description = "Spin";
   float MinVal = -10.0;
   float MaxVal = 10.0;
> = 0.0;


float Zoom
<
   string Description = "Zoom";
   float MinVal = -1.0;
   float MaxVal = 1.0;
> = - 0.2;


float Xcenter
<
   string Description = "Effect center";
   string Flags = "SpecifiesPointX";
   float MinVal = 0.0;
   float MaxVal = 1.0;
> = 0.5;

float Ycenter
<
   string Description = "Effect center";
   string Flags = "SpecifiesPointY";
   float MinVal = 0.0;
   float MaxVal = 1.0;
> = 0.5;



float CropLeft
<
   string Group = "Simple Crop";
   string Description = "Top left";
   float MinVal = 0.00;
   float MaxVal = 1.00;
> = 0.0;

float CropTop
<
   string Group = "Simple Crop";
   string Description = "Top left";
   float MinVal = 0.00;
   float MaxVal = 1.00;
> = 1.0;

float CropRight
<
   string Group = "Simple Crop";
   string Description = "Bottom right";
   float MinVal = 0.00;
   float MaxVal = 1.00;
> = 1.0;

float CropBottom
<
   string Group = "Simple Crop";
   string Description = "Bottom right";
   float MinVal = 0.00;
   float MaxVal = 1.00;
> = 0.0;


int AlphaMode
<
   string Group = "Alpha-output management";
   string Description = " ";
   string Enum = "Use alpha from the Fg input,Use alpha from the Bg input,Alpha-mix,Always Alpha 0,Always Alpha 1";
> = 2;


//--------------------------------------------------------------//
// Common definitions, declarations, macros
//--------------------------------------------------------------//

float _OutputAspectRatio;

#define PI           3.1415926536
#define TWO_PI       6.2831853072
#define ZOOM         (Zoom * 10.0)
#define ROUNDS       (Rounds + 0.25)
#define FRAMECENTER  0.5
     


//--------------------------------------------------------------//
// Shaders
//--------------------------------------------------------------//

float4 ps_Fg_crop (float2 uv : TEXCOORD1) : COLOR
{ 
   float y = 1.0 - uv.y;
   if ((uv.x > CropLeft) && (uv.x < CropRight) && (y < CropTop) && (y > CropBottom)) {
      return tex2D (FgSampler, uv);
   }
   return float4 (0.0.xxxx);          
}





float4 ps_Fg (float2 uv : TEXCOORD1) : COLOR
{ 
 
   // ----Shader definitions and declarations ----

   float Tsin, Tcos;    // Sine and cosine of the set angle.
   float angle;

   // Position vectors
   float2 centreSpin = FRAMECENTER;  
   float2 centreZoom = float2 (Xcenter, 1.0 - Ycenter);
   float2 posZoom, posSpin, posFlip, posOut;

   // Direction vectors
   float2 vCrT;              // Vector between Center(rotation) and Texel
   float2 vCzT;              // Vector between Center(zoom) and Texel




   // ------ Orbit ------------
   centreZoom -= OrbitRadius 
               * (float2 (
                    ( cos(ROUNDS * TWO_PI) / _OutputAspectRatio) / OrbitAspectRatio,
                    sin(ROUNDS * TWO_PI) * OrbitAspectRatio

                    )
                 );

  
   // ------ negative ZOOM -------
   // Used only for negative zoom settings

   vCzT = centreZoom - uv;
   posZoom = ( (1- (exp2( (ZOOM) * -1))) * vCzT ) + uv;              // The set value Zoom has been replaced by the formula  (1- (exp2( ZOOM * -1)))   to get the setting characteristic described in the header.



   // ------ ROTATION --------
  
   angle = radians(Spin * 360) * -1.0;
   vCrT = uv - centreSpin;
   if (ZOOM < 0.0 ) vCrT = posZoom - centreSpin;
   vCrT = float2(vCrT.x * _OutputAspectRatio, vCrT.y );

   sincos (angle, Tsin , Tcos);
   posSpin = float2 ((vCrT.x * Tcos - vCrT.y * Tsin), (vCrT.x * Tsin + vCrT.y * Tcos)); 
   posSpin = float2(posSpin.x / _OutputAspectRatio, posSpin.y ) + centreSpin;



   // ------ positive ZOOM -------
   // Used only for positive zoom settings.

   vCzT = centreZoom - posSpin;
   posOut = ( (1- (exp2( ZOOM * -1))) * vCzT ) + posSpin;            // The set value Zoom has been replaced by the formula  (1- (exp2( ZOOM * -1)))   to get the setting characteristic described in the header. 


 
   // ------ Automatic switching of positioning method -------
   if(ZOOM < 0.0) posOut = posSpin;                                   // If true: Ignored the program section "positive ZOOM"
   return tex2D (Render1Sampler, posOut);
   float y = 1.0 - uv.y;

}






float4 ps_mix (float2 uv1 : TEXCOORD1, float2 uv2 : TEXCOORD2 ) : COLOR
{

   float4 fg = tex2D (Render2Sampler, uv1);
   float4 bg = tex2D (BgSampler, uv2);
   if (AlphaMode == 0) return lerp( float4(bg.rgb, fg.a),  fg,  fg.a );
   if (AlphaMode == 1) return lerp( float4(bg.rgb, bg.a), float4(fg.rgb, bg.a),  fg.a );
   if (AlphaMode == 2) return lerp( bg, fg, fg.a );
   if (AlphaMode == 3) return lerp( float4(bg.rgb, 0.0), float4(fg.rgb, 0.0),  fg.a );
                       return lerp( float4(bg.rgb, 1.0), float4(fg.rgb, 1.0),  fg.a );
}



//--------------------------------------------------------------
// Technique
//--------------------------------------------------------------


technique tech_main
{
   pass P_1 < string Script = "RenderColorTarget0 = RenderPass1;"; >  { PixelShader = compile PROFILE ps_Fg_crop(); }
   pass P_2 < string Script = "RenderColorTarget0 = RenderPass2;"; >  { PixelShader = compile PROFILE ps_Fg(); }
   pass P_3 { PixelShader = compile PROFILE ps_mix(); }
}
