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
// 2 - 64 levels
// 3 - 32 levels
// 4 - 24 levels
// 5 - 16 levels
// 6 - 12 levels
// 7 - 8 levels
// 8 - 6 levels
// 9 - 5 levels
// 10 - 4 level
// 11 - 3 levels
// 12 - 2 levels
#define CRQ1 1 // [ 0 1 2 3 4 5 6 7 8 9 ]
#define CRQ2 1 // [ 0 1 2 3 4 5 6 7 8 9 ]
#define CRQ3 1 // [ 0 1 2 3 4 5 6 7 8 9 ]
#define CRQ4 1 // [ 0 1 2 3 4 5 6 7 8 9 ]
#if !(CRQ1 == 0 && CRQ2 == 0 && CRQ3 == 0 && CRQ4 == 0)
	const vec4 crqf = vec4(
		#if CRQ1 == 1
			256.0
		#elif CRQ1 == 2
			64.0
		#elif CRQ1 == 3
			32.0
		#elif CRQ1 == 4
			24.0
		#elif CRQ1 == 5
			16.0
		#elif CRQ1 == 6
			12.0
		#elif CRQ1 == 7
			8.0
		#elif CRQ1 == 8
			6.0
		#elif CRQ1 == 9
			5.0
		#elif CRQ1 == 10
			4.0
		#elif CRQ1 == 11
			3.0
		#elif CRQ1 == 12
			2.0
		#endif
		,
		#if CRQ1 == 1
			256.0
		#elif CRQ1 == 2
			64.0
		#elif CRQ1 == 3
			32.0
		#elif CRQ1 == 4
			24.0
		#elif CRQ1 == 5
			16.0
		#elif CRQ1 == 6
			12.0
		#elif CRQ1 == 7
			8.0
		#elif CRQ1 == 8
			6.0
		#elif CRQ1 == 9
			5.0
		#elif CRQ1 == 10
			4.0
		#elif CRQ1 == 11
			3.0
		#elif CRQ1 == 12
			2.0
		#endif
		,
		#if CRQ1 == 1
			256.0
		#elif CRQ1 == 2
			64.0
		#elif CRQ1 == 3
			32.0
		#elif CRQ1 == 4
			24.0
		#elif CRQ1 == 5
			16.0
		#elif CRQ1 == 6
			12.0
		#elif CRQ1 == 7
			8.0
		#elif CRQ1 == 8
			6.0
		#elif CRQ1 == 9
			5.0
		#elif CRQ1 == 10
			4.0
		#elif CRQ1 == 11
			3.0
		#elif CRQ1 == 12
			2.0
		#endif
		,
		#if CRQ1 == 1
			256.0
		#elif CRQ1 == 2
			64.0
		#elif CRQ1 == 3
			32.0
		#elif CRQ1 == 4
			24.0
		#elif CRQ1 == 5
			16.0
		#elif CRQ1 == 6
			12.0
		#elif CRQ1 == 7
			8.0
		#elif CRQ1 == 8
			6.0
		#elif CRQ1 == 9
			5.0
		#elif CRQ1 == 10
			4.0
		#elif CRQ1 == 11
			3.0
		#elif CRQ1 == 12
			2.0
		#endif
	);
#endif
const vec4 crqo = sign(vec4(CRQ1, CRQ2, CRQ3, CRQ4));

// downsampling
// 0 - off 1:1
// 1 - 2:1
// 2 - 3:1
// 3 - 4:1
// 4 - 5:1
// 5 - 8:1
// 6 - 12:1
// 7 - 16:1
// 8 - 24:1
// 9 - 32:1
#define DS 0 // [ 0 1 2 3 4 5 6 7 8 9 ]
#if DS == 1
	const float dsf = 2.0;
#elif DS == 2
	const float dsf = 3.0;
#elif DS == 3
	const float dsf = 4.0;
#elif DS == 4
	const float dsf = 5.0;
#elif DS == 5
	const float dsf = 8.0;
#elif DS == 6
	const float dsf = 12.0;
#elif DS == 7
	const float dsf = 16.0;
#elif DS == 8
	const float dsf = 24.0;
#elif DS == 9
	const float dsf = 32.0;
#endif
#if DS != 0
	const vec2 dsd = vec2(dsf);
	vec2 dsc;
#endif

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