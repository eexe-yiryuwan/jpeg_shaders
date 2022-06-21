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
const vec4 cpqi = vec4(CPQ1, CPQ2, CPQ3, CPQ4);
const vec4 cpqf = exp2(ivec4(9) - cpqi);
const vec4 cpqo = sign(cpqi);

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
	const float dsf2 = 4.0;
#elif DS == 2
	const float dsf = 3.0;
	const float dsf2 = 9.0;
#elif DS == 3
	const float dsf = 4.0;
	const float dsf2 = 16.0;
#elif DS == 4
	const float dsf = 5.0;
	const float dsf2 = 25.0;
#elif DS == 5
	const float dsf = 8.0;
	const float dsf2 = 64.0;
#elif DS == 6
	const float dsf = 12.0;
	const float dsf2 = 144.0;
#elif DS == 7
	const float dsf = 16.0;
	const float dsf2 = 256.0;
#elif DS == 8
	const float dsf = 24.0;
	const float dsf2 = 576.0;
#elif DS == 9
	const float dsf = 32.0;
	const float dsf2 = 1024.0;
#endif
#if DS == 0
#else
	const int dsff = int(dsf);
	vec2 ds1x;
	vec2 ds1y;
	vec2 dsu;
	vec4 dsacc;
	vec2 dscrd;
	int dsii;
	int dsij;
#endif

// global variables
vec4 col1;
float val1;

void main() {
	// perform downsampling if necessary
	#if DS == 0
		col1 = texture2D(gcolor, _xy);
	#else
		// init "constants"
		ds1x = vec2(dsf / _dims.x, 0.0);
		ds1y = vec2(0.0, dsf / _dims.y);
		dsu = vec2(dsf, dsf);
		//
		dscrd = vec2(0.5)+0.5*_xy; // map cords to <0;1>
		dscrd = floor( dscrd * _dims / dsu ); // get to the low bound of the sup-pixel {c*k}in<0;dim>
		dscrd = (vec2(0.5)/dsu) + dscrd; // offset to the center of first sub-pixel in the sup-pixel
		dscrd = dscrd * dsu / _dims; // scale back to the <0;1> range
		dscrd = 2.0 * dscrd - vec2(1.0); // map back the coords to <-1;1> range
		// now accumulate all the sub-pixels
		dsacc = vec4(0.0);
		for(dsii = 0; dsii < dsff; dsii++){
			for(dsij = 0; dsij < dsff; dsij++){
				dsacc += texture2D(gcolor ,dscrd);
				dscrd += ds1x;
			}
			dscrd += ds1y - dsf * ds1x;
		}
		col1 = dsacc / dsf2;
	#endif
	//
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
	//
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