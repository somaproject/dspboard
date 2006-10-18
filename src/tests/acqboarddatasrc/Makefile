
HWDIR=../../host/
CXXFLAGS=-I../../ -g -I$(HWDIR)
LDFLAGS=-lboost_unit_test_framework -g

main: main.o acqserial.o acqboarddatasrc.o

main.o: main.cc

acqserial.o: $(HWDIR)hw/acqserial.cc	
	g++ $(CXXFLAGS) -c  $(HWDIR)hw/acqserial.cc -o acqserial.o

acqboarddatasrc.o: ../../acqboarddatasrc.cc	
	g++ $(CXXFLAGS) -c  ../../acqboarddatasrc.cc -o acqboarddatasrc.o

clean: 
	rm *.o main
