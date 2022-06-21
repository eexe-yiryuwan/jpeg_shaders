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

// color space transformation
// 0 - RGB
// 1 - YCbCr
// 2 - CMYK
#define CST 1 // [ 0 1 2 ]

// color pre-quantization
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
#define CPQ1 1 // [ 0 1 2 3 4 5 6 7 8 9 ]
#define CPQ2 1 // [ 0 1 2 3 4 5 6 7 8 9 ]
#define CPQ3 1 // [ 0 1 2 3 4 5 6 7 8 9 ]
#define CPQ4 1 // [ 0 1 2 3 4 5 6 7 8 9 ]
const float cpqf1 = exp2(9 - CPQ1);
const float cpqo1 = sign(CPQ1);
const float cpqf2 = exp2(9 - CPQ2);
const float cpqo2 = sign(CPQ2);
const float cpqf3 = exp2(9 - CPQ3);
const float cpqo3 = sign(CPQ3);
const float cpqf4 = exp2(9 - CPQ4);
const float cpqo4 = sign(CPQ4);
const vec4 cpqf = vec4(cpqf1, cpqf2, cpqf3, cpqf4);
const vec4 cpqo = vec4(cpqo1, cpqo2, cpqo3, cpqo4);

// local variables
vec4 col1;
float val1;

void main() {
	// sample OG color
	col1 = texture2D(gcolor, _xy);
	// transform the color if requested
	#if CST == 0
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
		col1 = (  vec4( 1.0 ) - col1  )/ ( 1.0 - val1 );
		col1.a = val1;
	#endif
	// apply color pre-quantization if necessary
	#if (CPQ1 == 0 && CPQ2 == 0 && CPQ3 == 0 && CPQ4 == 0)
	#else
		col1 = mix( col1, floor( vec4(0.5) + col1*cpqf ) / cpqf, cpqo );
	#endif
	// pass colors further
	gl_FragData[0] = 2.0 * col1 + vec4(-1.0);
	gl_FragData[4] = texture2D(gaux1, _xy);
	gl_FragData[5] = texture2D(gaux2, _xy);
}