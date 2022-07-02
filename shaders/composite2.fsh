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
vec2 dctccx;
vec2 dctccy;
vec2 dctci1x;
vec2 dctci1y;
const vec2 dctcc1u = vec2(0.125, 0.0); // vec to the next value of cosine  aka width of a pixel in the map
int dctii;
int dctij;

// dct coef quantization
// 0 - off
// 1 - og jpeg quants
// 2 - constant treshold
// 3 - linear treshold
#define DCQ 1 // [ 0 1 2 3 ]

// dct coef quantization quality factor for  og jpeg quants
// 0 - 100
// 1 - 96
// 2 - 92
// 3 - 86
// 4 - 78
// 5 - 68
// 6 - 52
// 7 - 42
// 8 - 34
// 9 - 27
// 10 - 21
// 11 - 17
// 12 - 12
// 13 - 9
// 14 - 7
// 15 - 5
#define DCQQ 4 // [ 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ]
#if DCQ == 1
	// dcqs = (Q<50)? 5000/Q : 200-2*Q;
	#if DCQQ == 0
		const vec4 dcqs = vec4(0.0);
	#elif DCQQ == 1
		const vec4 dcqs = vec4(8.0);
	#elif DCQQ == 2
		const vec4 dcqs = vec4(16.0);
	#elif DCQQ == 3
		const vec4 dcqs = vec4(28.0);
	#elif DCQQ == 4
		const vec4 dcqs = vec4(44.0);
	#elif DCQQ == 5
		const vec4 dcqs = vec4(64.0);
	#elif DCQQ == 6
		const vec4 dcqs = vec4(96.0);
	#elif DCQQ == 7
		const vec4 dcqs = vec4(119.04761904761905);
	#elif DCQQ == 8
		const vec4 dcqs = vec4(147.05882352941177);
	#elif DCQQ == 9
		const vec4 dcqs = vec4(185.1851851851852);
	#elif DCQQ == 10
		const vec4 dcqs = vec4(238.0952380952381);
	#elif DCQQ == 11
		const vec4 dcqs = vec4(294.11764705882354);
	#elif DCQQ == 12
		const vec4 dcqs = vec4(416.6666666666667);
	#elif DCQQ == 13
		const vec4 dcqs = vec4(555.5555555555555);
	#elif DCQQ == 14
		const vec4 dcqs = vec4(714.2857142857143);
	#elif DCQQ == 15
		const vec4 dcqs = vec4(1000.0);
	#endif
	vec4 dcqq;
#endif

// DCT Coeficients constant tReshold
// 1 - 1.0
// 2 - 10.0
// 3 - 15.0
// 4 - 20.0
// 5 - 25.0
// 6 - 30.0
// 7 - 40.0
// 8 - 50.0
#define DCR 5 // [1 2 3 4 5 6 7 8]
#if DCQ == 2
	#if DCR == 1
		const vec4 dcr = vec4(1.0);
	#elif DCR == 2
		const vec4 dcr = vec4(10.0);
	#elif DCR == 3
		const vec4 dcr = vec4(15.0);
	#elif DCR == 4
		const vec4 dcr = vec4(20.0);
	#elif DCR == 5
		const vec4 dcr = vec4(25.0);
	#elif DCR == 6
		const vec4 dcr = vec4(30.0);
	#elif DCR == 7
		const vec4 dcr = vec4(40.0);
	#elif DCR == 8
		const vec4 dcr = vec4(50.0);
	#endif
#endif

// DCT Coeficients linear tReshold slope
// 1 - 1.0
// 2 - 10.0
// 3 - 15.0
// 4 - 20.0
// 5 - 25.0
// 6 - 30.0
// 7 - 40.0
// 8 - 50.0
#define DCLA 5 // [1 2 3 4 5 6 7 8]
#if DCQ == 3
	#if DCLA == 1
		const vec4 dcla = vec4(1.0);
	#elif DCLA == 2
		const vec4 dcla = vec4(10.0);
	#elif DCLA == 3
		const vec4 dcla = vec4(15.0);
	#elif DCLA == 4
		const vec4 dcla = vec4(20.0);
	#elif DCLA == 5
		const vec4 dcla = vec4(25.0);
	#elif DCLA == 6
		const vec4 dcla = vec4(30.0);
	#elif DCLA == 7
		const vec4 dcla = vec4(40.0);
	#elif DCLA == 8
		const vec4 dcla = vec4(50.0);
	#endif
#endif

// DCT Coeficients linear tReshold base
// 1 - 1.0
// 2 - 10.0
// 3 - 15.0
// 4 - 20.0
// 5 - 25.0
// 6 - 30.0
// 7 - 40.0
// 8 - 50.0
#define DCLB 2 // [1 2 3 4 5 6 7 8]
#if DCQ == 3
	#if DCLB == 1
		const vec4 dclb = vec4(1.0);
	#elif DCLB == 2
		const vec4 dclb = vec4(10.0);
	#elif DCLB == 3
		const vec4 dclb = vec4(15.0);
	#elif DCLB == 4
		const vec4 dclb = vec4(20.0);
	#elif DCLB == 5
		const vec4 dclb = vec4(25.0);
	#elif DCLB == 6
		const vec4 dclb = vec4(30.0);
	#elif DCLB == 7
		const vec4 dclb = vec4(40.0);
	#elif DCLB == 8
		const vec4 dclb = vec4(50.0);
	#endif
#endif

// local variables
vec4 col1;

void main() {
	// find dct stuff
	#if DS == 0
		dctci = floor(_xy * _dims); // <0;lb-px;dims/px>  quantize to full pixel beggining (lobo)
	#else
		dctci = floor(_xy * _dims / dsd); // <0;lb-px;dims/spx>  quantize to full super-pixel beginning (lobo)
	#endif
	dctcj = 8.0 * floor( dctci / 8.0 ); // <0;lb-dct;dims/spx>  transform to dct square beggining (lobo)
	dctci = dctci - dctcj; // pixels - dct-lobo = dct-index   <0;7>   calc index in the dct-square (lobo)
	dctccx = vec2(0.0625, 0.0625 + 0.125 * dctci.x); // setup initial coords for getting cosine values for x (mid)
	dctccy = vec2(0.0625, 0.0625 + 0.125 * dctci.y); // setup initial coords for getting cosine values for y (mid)
	dctci = 0.125 * dctci; // setup coords for getting alpha value.. and possibly quantization coef (mid)
	dctcj = dctcj + vec2(0.5); // offset to the center of the first pixel of the dct square (mid)
	#if DS == 0
		dctcj = dctcj / _dims; // <0;mid;1> transform back to og texture coords (mid)
		dctci1x = vec2(1.0 / _dims.x, 0.0); // vec to the next pixel in x dir  aka the width of a pixel
		dctci1y = vec2(0.0, 1.0 / _dims.y); // vec to the next row of pixels in y dir  aka the height of a pixel
	#else
		dctcj = dctcj * dsd / _dims; // <0;mid;1> transform back to og texture coords (mid)
		dctci1x = vec2(dsd.x / _dims.x, 0.0); // vec to the next pixel in x dir  aka the width of a pixel
		dctci1y = vec2(0.0, dsd.y / _dims.y); // vec to the next row of pixels in y dir  aka the height of a pixel
	#endif
	// now We should probably just dct
	dcta = vec4(0.0);
	for(dctii=0;dctii<8;dctii++){
		for(dctij=0;dctij<8;dctij++){
			// accumulate next value
			dcta += texture2D(gcolor, dctcj) * texture2D(gaux1, dctccx).rrrr * texture2D(gaux1, dctccy).rrrr;
			dctcj += dctci1x; // go to the next pixel, to the right
			dctccx += dctcc1u; // so should the cosine coef coord go right
		}
		dctcj += dctci1y - 8.0 * dctci1x; // go back to the first pixel left, and one up
		dctccx -= 8.0 * dctcc1u; // new line = reset x cosine coef
		dctccy += dctcc1u; // new line requires y coef to change to the next
	}
	col1 = texture2D(gaux2, vec2(0.0625) + dctci).rrrr * dcta;
	// perform coef quantization as necessary
	#if DCQ == 1
		#if DCQQ == 0
			dcqq = vec4(1.0);
		#else
			dcqq = floor((dcqs * texture2D(gaux3, vec2(0.0625) + dctci).rrrr + vec4(50.0)) / 100.0);
		#endif
		col1 = col1 * 128.0 / dcqq;
		col1 = 0.5 * ceil(col1 + 0.5) + 0.5 * floor(col1 - 0.5);
		col1 = col1 * dcqq / 128.0;
	#elif DCQ == 2
		col1 = mix(vec4(0.0), col1, step(dcr, abs(256.0*col1)));
	#elif DCQ == 3
		col1 = mix(vec4(0.0), col1, step(dclb + dcla * length(dctci), abs(256.0*col1)));
	#endif
	gl_FragData[0] = col1;
	gl_FragData[4] = texture2D(gaux1, _xy);
	gl_FragData[5] = texture2D(gaux2, _xy);
	gl_FragData[6] = texture2D(gaux3, _xy);
}