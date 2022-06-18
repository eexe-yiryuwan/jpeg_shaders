#include <iostream>
#include <iomanip>
#include <math.h>
#include <ostream>
#include <fstream>
#include <cstdlib>



int main() {
	std::ofstream alfafile;
	std::ofstream cosfile;
	float x, u, i;
	char buffer [255];
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
	return 0;
}