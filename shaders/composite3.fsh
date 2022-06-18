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
	// pass through the OG color
	col1 = texture2D(gcolor, _xy);
	#if CST == 0
		col1 = col1;
	#elif CST == 1
		col1 = vec4( 0.0 , -0.5 , -0.5 , 0.0 ) + col1;
		col1 =
				mat4(
						1.0   ,  1.0      , 1.0   , 0.0 ,
						0.0   , -0.344136 , 1.772 , 0.0 ,
						1.402 , -0.714136 , 0.0   , 0.0 ,
						0.0   ,  0.0      , 0.0   , 1.0
				)
				*
				col1;
	#elif CST == 2
		col1 = vec4( 0.5 ) - 0.5 * col1;
		val1 = col1.a;
		col1 = col1 * vec4( val1 );
		col1.a = 1.0;
	#endif
	gl_FragData[0] = col1;
	gl_FragData[4] = texture2D(gaux1, _xy);
	gl_FragData[5] = texture2D(gaux2, _xy);
}