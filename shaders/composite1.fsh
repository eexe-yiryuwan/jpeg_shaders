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
#define CPQ1 2 // [ 0 1 2 3 4 5 6 7 8 9 10 11 12 ]
#define CPQ2 4 // [ 0 1 2 3 4 5 6 7 8 9 10 11 12 ]
#define CPQ3 4 // [ 0 1 2 3 4 5 6 7 8 9 10 11 12 ]
#define CPQ4 0 // [ 0 1 2 3 4 5 6 7 8 9 10 11 12 ]
#if !(CPQ1 == 0 && CPQ2 == 0 && CPQ3 == 0 && CPQ4 == 0)
	const vec4 cpqf = vec4(
		#if CPQ1 == 0
			1024.0
		#elif CPQ1 == 1
			256.0
		#elif CPQ1 == 2
			64.0
		#elif CPQ1 == 3
			32.0
		#elif CPQ1 == 4
			24.0
		#elif CPQ1 == 5
			16.0
		#elif CPQ1 == 6
			12.0
		#elif CPQ1 == 7
			8.0
		#elif CPQ1 == 8
			6.0
		#elif CPQ1 == 9
			5.0
		#elif CPQ1 == 10
			4.0
		#elif CPQ1 == 11
			3.0
		#elif CPQ1 == 12
			2.0
		#endif
		,
		#if CPQ2 == 0
			1024.0
		#elif CPQ2 == 1
			256.0
		#elif CPQ2 == 2
			64.0
		#elif CPQ2 == 3
			32.0
		#elif CPQ2 == 4
			24.0
		#elif CPQ2 == 5
			16.0
		#elif CPQ2 == 6
			12.0
		#elif CPQ2 == 7
			8.0
		#elif CPQ2 == 8
			6.0
		#elif CPQ2 == 9
			5.0
		#elif CPQ2 == 10
			4.0
		#elif CPQ2 == 11
			3.0
		#elif CPQ2 == 12
			2.0
		#endif
		,
		#if CPQ3 == 0
			1024.0
		#elif CPQ3 == 1
			256.0
		#elif CPQ3 == 2
			64.0
		#elif CPQ3 == 3
			32.0
		#elif CPQ3 == 4
			24.0
		#elif CPQ3 == 5
			16.0
		#elif CPQ3 == 6
			12.0
		#elif CPQ3 == 7
			8.0
		#elif CPQ3 == 8
			6.0
		#elif CPQ3 == 9
			5.0
		#elif CPQ3 == 10
			4.0
		#elif CPQ3 == 11
			3.0
		#elif CPQ3 == 12
			2.0
		#endif
		,
		#if CPQ4 == 0
			1024.0
		#elif CPQ4 == 1
			256.0
		#elif CPQ4 == 2
			64.0
		#elif CPQ4 == 3
			32.0
		#elif CPQ4 == 4
			24.0
		#elif CPQ4 == 5
			16.0
		#elif CPQ4 == 6
			12.0
		#elif CPQ4 == 7
			8.0
		#elif CPQ4 == 8
			6.0
		#elif CPQ4 == 9
			5.0
		#elif CPQ4 == 10
			4.0
		#elif CPQ4 == 11
			3.0
		#elif CPQ4 == 12
			2.0
		#endif
	);
#endif
const vec4 cpqo = sign(vec4(CPQ1, CPQ2, CPQ3, CPQ4));

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
#define DS 4 // [ 0 1 2 3 4 5 6 7 8 9 ]
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

// supersampling
// 0 - off
// 1 - 2x2
// 2 - 3x3
// 3 - 4x4
// 4 - 5x5
#define SS 2 // [ 0 1 2 3 4 ]
#if SS == 1
	const float ssf1 = 2.0;
	const float ssf2 = 4.0;
#elif SS == 2
	const float ssf1 = 3.0;
	const float ssf2 = 9.0;
#elif SS == 3
	const float ssf1 = 4.0;
	const float ssf2 = 16.0;
#elif SS == 4
	const float ssf1 = 5.0;
	const float ssf2 = 25.0;
#endif
#if SS != 0
	const int ssi1 = int(ssf1);
	vec2 ss1x;
	vec2 ss1y;
	vec2 ssc;
	vec4 ssa;
	int ssii;
	int ssij;
#endif

// global variables
vec4 col1;
float val1;

void main() {
	// perform downsampling and supersampling if necessary
	#if DS == 0
		col1 = texture2D(gcolor, _xy); // We just need one regular color
	#else
		// initialize stuff that is nesessary regardless of next stuff
		//
		// find the coords of lower band of sup-pixel
		dsc = floor( _xy * _dims / dsd ); // round new <0;dims;dims> to nearest sup-pixel low bound
		#if SS == 0
			dsc = ( vec2(0.5) + dsc ) * dsd / _dims; // go back to <0;1>
			col1 = texture2D(gcolor, dsc); // sample the only necessary color
		#else
			// initialize subsampling stuff
			ss1x = vec2(dsf / ssf1 / _dims.x, 0.0); // vector to the next subsample column
			ss1y = vec2(0.0, dsf / ssf1 / _dims.y); // vec to the next sub-s row
			//
			// already have low-bound of sup-pixel in the [dsc] var
			ssc = dsc + vec2(0.5 / ssf1); // offset to the center of the first sub-sample
			ssc = ssc * dsd / _dims; // go back to the <0;1> range
			// do the sampling of sub-samples
			ssa = vec4(0.0);
			for(ssii = 0; ssii < ssi1; ssii++) {
				for(ssij = 0; ssij < ssi1; ssij++) {
					ssa += texture2D(gcolor, ssc);
					ssc += ss1x;
				}
				ssc += ss1y - ssf1 * ss1x;
			}
			col1 = ssa / ssf2;
		#endif
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
	#if !(CPQ1 == 0 && CPQ2 == 0 && CPQ3 == 0 && CPQ4 == 0)
		col1 = mix( col1, floor( vec4(0.5) + col1*cpqf ) / cpqf, cpqo );
	#endif
	// pass colors further
	gl_FragData[0] = 2.0 * col1 - vec4(1.0);
	gl_FragData[4] = texture2D(gaux1, _xy);
	gl_FragData[5] = texture2D(gaux2, _xy);
	gl_FragData[6] = texture2D(gaux3, _xy);
}