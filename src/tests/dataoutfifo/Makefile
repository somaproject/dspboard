
HWDIR=../../host/
CXXFLAGS=-I../../ -g -I$(HWDIR)
LDFLAGS=-lboost_unit_test_framework -g

main: main.o dataout.o dspdataout.o

main.o: main.cc 

dataout.o: ../../dataout.cc ../../dataout.h
	g++ $(CXXFLAGS) -c  ../../dataout.cc -o dataout.o

dspdataout.o: $(HWDIR)hw/dspdataout.cc $(HWDIR)hw/dspdataout.h
	g++ $(CXXFLAGS) -c  $(HWDIR)hw/dspdataout.cc -o dspdataout.o

clean: 
	rm *.o main
