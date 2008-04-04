SRCDIR = ../../
HWDIR = $(SRCDIR)/host
CXXFLAGS=-I$(SRCDIR) -I$(HWDIR) -g
LDFLAGS=-lboost_unit_test_framework


all: runner

acqserial.o: $(HWDIR)/hw/acqserial.cc
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hw/acqserial.cc -o acqserial.o

acqstatecontrol.o: $(SRCDIR)/acqstatecontrol.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqstatecontrol.cc -o acqstatecontrol.o

runner.o: runner.cc

runner: runner.o 

clean: 
	rm *.o


runner: runner.o acqstatecontroltest.o acqserial.o acqstatecontrol.o

