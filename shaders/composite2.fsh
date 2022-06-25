#version 120

varying vec2 _xy;

uniform sampler2D gcolor;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
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
vec2 dctci1x;
vec2 dctci1y;
const vec2 dctcc1u = vec2(0.125, 0.0);
int dctii;
int dctij;

// local variables
vec4 col1;

void main() {
	// init dct stuff
	#if DS == 0
		dctci1x = vec2(1.0 / _dims.x, 0.0);
		dctci1y = vec2(0.0, 1.0 / _dims.y);
	#else
		dctci1x = vec2(dsd.x / _dims.x, 0.0);
		dctci1y = vec2(0.0, dsd.y / _dims.y);
	#endif
	// find the starting points to tha textures for dct stuff
	#if DS != 0
		dctcj = floor(_xy * _dims / dsd); // transform to low bound of full super-pixels
	#else
		dctcj = floor(_xy * _dims); // transform to low bound of full pixels
	#endif
	dctci = dctcj;
	dctcj = 8.0 * floor( dctcj / 8.0 ); // get the lower bound of a dct square
	dctci = dctci - dctcj; // get where in the square the pixel is
	dctccx = vec2(0.0625, 0.0625 + dctci.x / 8.0); // set init position on the cosine texture for x-axis
	dctccy = vec2(0.0625, 0.0625 + dctci.y / 8.0); // set init position on the cosine texture for y-axis
	dctci = vec2(0.0625) + dctci / 8.0; // generate coords for alfa texture
	#if DS != 0
		dctcj = ( vec2(0.5) + dctcj ) * dsd / _dims; // transform back to <0;1> range
	#else
		dctcj = ( vec2(0.5) + dctcj ) / _dims; // transform back to <0;1> range
	#endif
	// now We should probably just dct
	dcta = vec4(0.0);
	for(dctii = 0; dctii < 8; dctii++) {
		for(dctij = 0; dctij < 8; dctij++) {
			dcta += texture2D(gcolor, dctcj) * texture2D(gaux1, dctccx).rrrr * texture2D(gaux1, dctccy).rrrr;
			dctccx += dctcc1u;
			dctcj += dctci1x;
		}
		dctccx -= 8.0 * dctcc1u;
		dctccy += dctcc1u;
		dctcj += dctci1y - 8.0 * dctci1x;
	}
	col1 = texture2D(gaux2, dctci).rrrr * dcta;
	// col1 = texture2D(gcolor, dctcj);
	gl_FragData[0] = col1;
	// gl_FragData[0] = texture2D(gcolor, _xy);
	gl_FragData[4] = texture2D(gaux1, _xy);
	gl_FragData[5] = texture2D(gaux2, _xy);
}