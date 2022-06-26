#include <iostream>
#include <iomanip>
#include <math.h>
#include <ostream>
#include <fstream>
#include <cstdlib>



int main() {
	std::ofstream alfafile;
	std::ofstream cosfile;
	std::ofstream dctfile;
	float coefs [] = {
		16.0, 11.0, 10.0, 16.0, 24.0, 40.0, 51.0, 61.0,
		12.0, 12.0, 14.0, 19.0, 26.0, 58.0, 60.0, 55.0,
		14.0, 13.0, 16.0, 24.0, 40.0, 57.0, 69.0, 56.0,
		14.0, 17.0, 22.0, 29.0, 51.0, 87.0, 80.0, 62.0,
		18.0, 22.0, 37.0, 56.0, 68.0, 109.0, 103.0, 77.0,
		24.0, 35.0, 55.0, 64.0, 81.0, 104.0, 113.0, 92.0,
		49.0, 64.0, 78.0, 87.0, 103.0, 121.0, 120.0, 101.0,
		72.0, 92.0, 95.0, 98.0, 112.0, 100.0, 103.0, 99.0
	};
	float x, u;
	int i;
	float val;
	char * reader;
	alfafile.open("./alfa.dat");
	cosfile.open("./cos.dat");
	reader = (char *)(&val);
	for(u=0.0;u<8.0;u++) for(x=0.0;x<8.0;x++) {
		// for alfa
		val = 1.0/std::sqrt(16.0 * (u<0.5?2.0:1.0) * (x<0.5?2.0:1.0));
		alfafile.write(reader, 4);
		// for cos
		val = std::cos((2.0*x+1.0)*u*0.0625*3.14159265358979323846);
		cosfile.write(reader, 4);
	}
	alfafile.close();
	cosfile.close();
	// for dct quants
	dctfile.open("./dct.dat");
	dctfile.write((char*)&coefs, 64*4);
	dctfile.close();
	return 0;
}