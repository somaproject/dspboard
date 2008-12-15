SRCDIR = ../../
HWDIR = $(SRCDIR)/host
CXXFLAGS=-I$(SRCDIR) -I$(HWDIR) -g
LDFLAGS=-lboost_unit_test_framework


all: runner


runner.o: runner.cc

runner: runner.o 

clean: 
	rm *.o


runner: runner.o filteriotest.o


