

CXXFLAGS=-I../../ -g
LDFLAGS=-lboost_unit_test_framework -g

main: main.o acqserial.o acqboarddatasrc.o

main.o: main.cc

acqserial.o: ../../nohw/acqserial.cc	
	g++ $(CXXFLAGS) -c  ../../nohw/acqserial.cc -o acqserial.o

acqboarddatasrc.o: ../../acqboarddatasrc.cc	
	g++ $(CXXFLAGS) -c  ../../acqboarddatasrc.cc -o acqboarddatasrc.o

clean: 
	rm *.o main
