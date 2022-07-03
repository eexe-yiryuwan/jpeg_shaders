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
const vec2 dctcc1i = vec2(0.125, 0.0); // vec to the next value of cosine  aka width of a pixel in the map
int dctii;

// local variables
vec4 col1;

void main() {
	// prepare dct stuff
	#if DS == 0
		dctcj = floor(_xy * _dims); // <0;lb-px;dims/px>  quantize to full pixel beggining (lobo)
	#else
		dctcj = floor(_xy * _dims / dsd); // <0;lb-px;dims/spx>  quantize to full super-pixel beginning (lobo)
	#endif
	dctci = floor(dctcj / 8.0) * 8.0;
	dctcci = vec2(0.0625, 0.0625 + 0.125 * (dctcj.x - dctci.x)); // setup initial coords for getting cosine values for x (mid)
	dctci = vec2(dctci.x + 0.5, dctcj.y + 0.5); // offset to the center of the first pixel of the dct square (mid)
	#if DS == 0
		dctci = dctci / _dims; // <0;mid;1> transform back to og texture coords (mid)
		dctci1i = vec2(1.0 / _dims.x, 0.0); // vec to the next pixel in x dir  aka the width of a pixel
	#else
		dctci = dctci * dsd / _dims; // <0;mid;1> transform back to og texture coords (mid)
		dctci1i = vec2(dsd.x / _dims.x, 0.0); // vec to the next pixel in x dir  aka the width of a pixel
	#endif
	// do tha DCT on x axis
	dcta = vec4(0.0);
	for(dctii=0;dctii<8;dctii++) {
		dcta += texture2D(gcolor, dctci) * texture2D(gaux1, dctcci).rrrr;
		dctci += dctci1i;
		dctcci += dctcc1i;
	}
	gl_FragData[0] = dcta;
	gl_FragData[4] = texture2D(gaux1, _xy);
	gl_FragData[5] = texture2D(gaux2, _xy);
	gl_FragData[6] = texture2D(gaux3, _xy);
}

// // find dct stuff
// 	#if DS == 0
// 		dctci = floor(_xy * _dims); // <0;lb-px;dims/px>  quantize to full pixel beggining (lobo)
// 	#else
// 		dctci = floor(_xy * _dims / dsd); // <0;lb-px;dims/spx>  quantize to full super-pixel beginning (lobo)
// 	#endif
// 	dctcj = 8.0 * floor( dctci / 8.0 ); // <0;lb-dct;dims/spx>  transform to dct square beggining (lobo)
// 	dctci = dctci - dctcj; // pixels - dct-lobo = dct-index   <0;7>   calc index in the dct-square (lobo)
// 	dctccx = vec2(0.0625, 0.0625 + 0.125 * dctci.x); // setup initial coords for getting cosine values for x (mid)
// 	dctccy = vec2(0.0625, 0.0625 + 0.125 * dctci.y); // setup initial coords for getting cosine values for y (mid)
// 	dctci = 0.125 * dctci; // setup coords for getting alpha value.. and possibly quantization coef (mid)
// 	dctcj = dctcj + vec2(0.5); // offset to the center of the first pixel of the dct square (mid)
// 	#if DS == 0
// 		dctcj = dctcj / _dims; // <0;mid;1> transform back to og texture coords (mid)
// 		dctci1x = vec2(1.0 / _dims.x, 0.0); // vec to the next pixel in x dir  aka the width of a pixel
// 		dctci1y = vec2(0.0, 1.0 / _dims.y); // vec to the next row of pixels in y dir  aka the height of a pixel
// 	#else
// 		dctcj = dctcj * dsd / _dims; // <0;mid;1> transform back to og texture coords (mid)
// 		dctci1x = vec2(dsd.x / _dims.x, 0.0); // vec to the next pixel in x dir  aka the width of a pixel
// 		dctci1y = vec2(0.0, dsd.y / _dims.y); // vec to the next row of pixels in y dir  aka the height of a pixel
// 	#endif
// 	// now We should probably just dct
// 	dcta = vec4(0.0);
// 	for(dctii=0;dctii<8;dctii++){
// 		for(dctij=0;dctij<8;dctij++){
// 			// accumulate next value
// 			dcta += texture2D(gcolor, dctcj) * texture2D(gaux1, dctccx).rrrr * texture2D(gaux1, dctccy).rrrr;
// 			dctcj += dctci1x; // go to the next pixel, to the right
// 			dctccx += dctcc1u; // so should the cosine coef coord go right
// 		}
// 		dctcj += dctci1y - 8.0 * dctci1x; // go back to the first pixel left, and one up
// 		dctccx -= 8.0 * dctcc1u; // new line = reset x cosine coef
// 		dctccy += dctcc1u; // new line requires y coef to change to the next
// 	}
// 	col1 = texture2D(gaux2, vec2(0.0625) + dctci).rrrr * dcta;
// 	// perform coef quantization as necessary
// 	#if DCQ == 1
// 		#if DCQQ == 0
// 			dcqq = vec4(1.0);
// 		#else
// 			dcqq = floor((dcqs * texture2D(gaux3, vec2(0.0625) + dctci).rrrr + vec4(50.0)) / 100.0);
// 		#endif
// 		col1 = col1 * 128.0 / dcqq;
// 		col1 = 0.5 * ceil(col1 + 0.5) + 0.5 * floor(col1 - 0.5);
// 		col1 = col1 * dcqq / 128.0;
// 	#elif DCQ == 2
// 		col1 = mix(vec4(0.0), col1, step(dcr, abs(256.0*col1)));
// 	#elif DCQ == 3
// 		col1 = mix(vec4(0.0), col1, step(dclb + dcla * length(dctci), abs(256.0*col1)));
// 	#endif