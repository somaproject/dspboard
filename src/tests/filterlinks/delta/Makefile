

CXXFLAGS=-I../../../
LDFLAGS=-lboost_unit_test_framework


all: main

delta.o: ../../../filterlinks/delta.cc
	$(CC) $(CXXFLAGS) -c ../../../filterlinks/delta.cc -o delta.o
main.o: main.cc

main: main.o delta.o

clean: 
	rm *.o
