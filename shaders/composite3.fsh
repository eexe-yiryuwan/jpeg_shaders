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

uniform vec2 _one;
uniform vec2 _half;
uniform vec2 _dims;

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

// discrete cosine transform stuff
vec4 dcta;
vec2 dctci;
vec2 dctcj;
vec2 dctccx;
vec2 dctccy;
vec2 dctcca;
vec2 dctci1x;
vec2 dctci1y;
vec2 dctcca1x;
vec2 dctcca1y;
const vec2 dctcc1v = vec2(0.0, 0.125);
int dctii;
int dctij;

// local variables
vec4 col1;
float val1;

void main() {
	// init dct stuff
	#if DS == 0
		dctci1x = vec2(1.0 / _dims.x, 0.0);
		dctci1y = vec2(0.0, 1.0 / _dims.y);
	#else
		dctci1x = vec2(dsd.x / _dims.x, 0.0);
		dctci1y = vec2(0.0, dsd.y / _dims.y);
	#endif
	dctcca = vec2(0.0625, 0.0625); // set init position on the alpha texture
	dctcca1x = vec2(0.125, 0.0);
	dctcca1y = vec2(0.0, 0.125);
	// find the starting points to tha textures for dct stuff
	#if DS != 0
		dctcj = floor(_xy * _dims / dsd); // transform to low bound of full super-pixels
	#else
		dctcj = floor(_xy * _dims); // transform to low bound of full pixels
	#endif
	dctci = dctcj;
	dctcj = 8.0 * floor( dctcj / 8.0 ); // get the lower bound of a dct square
	dctci = dctci - dctcj; // get where in the square the pixel is
	dctccx = vec2(0.0625 + dctci.x / 8.0, 0.0625); // set init position on the cosine texture for x-axis
	dctccy = vec2(0.0625 + dctci.y / 8.0, 0.0625); // set init position on the cosine texture for y-axis
	#if DS != 0
		dctcj = ( vec2(0.5) + dctcj ) * dsd / _dims; // transform back to <0;1> range
	#else
		dctcj = ( vec2(0.5) + dctcj ) / _dims; // transform back to <0;1> range
	#endif
	// now We should probably just dct
	dcta = vec4(0.0);
	for(dctii = 0; dctii < 8; dctii++) {
		for(dctij = 0; dctij < 8; dctij++) {
			dcta += texture2D(gaux2, dctcca).rrrr * texture2D(gcolor, dctcj) * texture2D(gaux1, dctccx).rrrr * texture2D(gaux1, dctccy).rrrr;
			dctccx += dctcc1v;
			dctcj += dctci1x;
			dctcca += dctcca1x;
		}
		dctccx -= 8.0 * dctcc1v;
		dctccy += dctcc1v;
		dctcj += dctci1y - 8.0 * dctci1x;
		dctcca += dctcca1y - 8.0 * dctcca1x;
	}
	col1 = 0.5 * dcta + vec4(0.5);
	// col1 = 0.5 * texture2D(gcolor, _xy) + vec4(0.5);
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