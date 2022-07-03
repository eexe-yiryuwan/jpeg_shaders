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

// discrete cosine transform stuff
vec4 dcta;
vec2 dctci;
vec2 dctcj;
vec2 dctcci;
vec2 dctci1i;
vec2 dctca;
const vec2 dctca1i = vec2(0.125, 0.0);
const vec2 dctcc1i = vec2(0.0, 0.125); // vec to the next value of cosine  aka width of a pixel in the map
int dctii;

void main() {
	// prepare dct stuff
	#if DS == 0
		dctcj = floor(_xy * _dims); // <0;lb-px;dims/px>  quantize to full pixel beggining (lobo)
	#else
		dctcj = floor(_xy * _dims / dsd); // <0;lb-px;dims/spx>  quantize to full super-pixel beginning (lobo)
	#endif
	dctci = floor(dctcj / 8.0) * 8.0;
	dctcci = vec2(0.0625 + 0.125 * (dctcj.x - dctci.x), 0.0625); // setup initial coords for getting cosine values for x (mid)
	dctca = vec2(0.0625, 0.0625 + 0.125 * (dctcj.y - dctci.y));
	dctci = vec2(dctci.x + 0.5, dctcj.y + 0.5);
	#if DS == 0
		dctci = dctci / _dims; // <0;mid;1> transform back to og texture coords (mid)
		dctci1i = vec2(1.0 / _dims.x, 0.0); // vec to the next pixel in x dir  aka the width of a pixel
	#else
		dctci = dctci * dsd / _dims; // <0;mid;1> transform back to og texture coords (mid)
		dctci1i = vec2(dsd.x / _dims.x, 0.0); // vec to the next pixel in x dir  aka the width of a pixel
	#endif
	// do tha IDCT on x axis
	dcta = vec4(0.0);
	for(dctii=0;dctii<8;dctii++) {
		dcta += texture2D(gaux2, dctca).rrrr * texture2D(gcolor, dctci) * texture2D(gaux1, dctcci).rrrr;
		dctci += dctci1i;
		dctcci += dctcc1i;
		dctca += dctca1i;
	}
	// pass the colors further
	gl_FragData[0] = dcta;
	// gl_FragData[0] = texture2D(gcolor, _xy);
	gl_FragData[4] = texture2D(gaux1, _xy);
	gl_FragData[5] = texture2D(gaux2, _xy);
	gl_FragData[6] = texture2D(gaux3, _xy);
}