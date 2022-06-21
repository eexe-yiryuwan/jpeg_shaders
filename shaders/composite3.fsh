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

// ccolor space transformation
// 0 - RGB
// 1 - YCbCr
// 2 - CMYK
#define CST 1 // [ 0 1 2 ]

// color post-quantization
// 0 - off
// 1 - 256 levels
// 2 - 128 levels
// 3 - 64 levels
// 4 - 32 levels
// 5 - 16 levels
// 6 - 8 levels
// 7 - 4 levels
// 8 - 2 levels
// 9 - 1 level
#define CRQ1 1 // [ 0 1 2 3 4 5 6 7 8 9 ]
#define CRQ2 1 // [ 0 1 2 3 4 5 6 7 8 9 ]
#define CRQ3 1 // [ 0 1 2 3 4 5 6 7 8 9 ]
#define CRQ4 1 // [ 0 1 2 3 4 5 6 7 8 9 ]
const float crqf1 = exp2(9 - CRQ1);
const float crqo1 = sign(CRQ1);
const float crqf2 = exp2(9 - CRQ2);
const float crqo2 = sign(CRQ2);
const float crqf3 = exp2(9 - CRQ3);
const float crqo3 = sign(CRQ3);
const float crqf4 = exp2(9 - CRQ4);
const float crqo4 = sign(CRQ4);
const vec4 crqf = vec4(crqf1, crqf2, crqf3, crqf4);
const vec4 crqo = vec4(crqo1, crqo2, crqo3, crqo4);

// local variables
vec4 col1;
float val1;

void main() {
	// get the color
	col1 = 0.5 * texture2D(gcolor, _xy) + vec4(0.5);
	// apply color pre-quantization if necessary
	#if (CRQ1 == 0 && CRQ2 == 0 && CRQ3 == 0 && CRQ4 == 0)
	#else
		col1 = mix( col1, floor( vec4(0.5) + col1*crqf ) / crqf, crqo );
	#endif
	// transform the color if requested
	#if CST == 0
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
		col1 = vec4( 1.0 ) - col1;
		val1 = col1.a;
		col1 = col1 * vec4( val1 );
		col1.a = 1.0;
	#endif
	// pass colors further
	gl_FragData[0] = col1;
	gl_FragData[4] = texture2D(gaux1, _xy);
	gl_FragData[5] = texture2D(gaux2, _xy);
}