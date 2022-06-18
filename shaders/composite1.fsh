#version 120

varying vec2 _xy;

uniform sampler2D gcolor;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
uniform sampler2D gaux3;
uniform sampler2D gaux4;
/*
const int colortex0Format = RGBA32F;
const int colortex4Format = R32F;
const int colortex5Format = R32F;
const int colortex6Format = R32F;
const int colortex7Format = R32F;
*/

// color settings
#define CST 0 // [ 0 1 2 ]

// local variables
vec4 col1;
float val1;

void main() {
	// sample OG color
	col1 = texture2D(gcolor, _xy);
	// transform the color if requested
	#if CST == 0
		col1 = col1;
	#elif CST == 1
		col1 =
				mat4(
						0.299 , -0.168736 ,  0.5      , 0.0 ,
						0.587 , -0.331264 , -0.418688 , 0.0 ,
						0.114 ,  0.5      , -0.081312 , 0.0 ,
						0.0   ,  0.0      ,  0.0      , 1.0
				)
				*
				col1;
		col1 = col1 + vec4( 0.0 , 0.5 , 0.5 , 0.0 );
	#elif CST == 2
		val1 = 1.0 - max( max(col1.r , col1.g) , col1.b );
		col1.a = val1;
		col1 =
				mat4(
						1.0 , 0.0 , 0.0 , 0.0 ,
						0.0 , 1.0 , 0.0 , 0.0 ,
						0.0 , 0.0 , 1.0 , 0.0 ,
						1.0 , 1.0 , 1.0 , 0.0
				)
				*
				col1;
		col1 = 2.0 * (  vec4( 1.0 ) - col1  )/ ( 1.0 - val1 ) - vec4( 1.0 );
		col1.a = val1;
	#endif
	// pass colors further
	gl_FragData[0] = col1;
	gl_FragData[4] = texture2D(gaux1, _xy);
	gl_FragData[5] = texture2D(gaux2, _xy);
}