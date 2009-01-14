SRCDIR = ../../
HWDIR = $(SRCDIR)/host
CXXFLAGS=-I$(SRCDIR) -I$(HWDIR) -g
LDFLAGS=-lboost_unit_test_framework


all: runner


acqserial.o: $(HWDIR)/hw/acqserial.cc
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hw/acqserial.cc -o acqserial.o

acqstatecontrol.o: $(SRCDIR)/acqstatecontrol.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqstatecontrol.cc -o acqstatecontrol.o

acqboardif.o: $(SRCDIR)/acqboardif.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqboardif.cc -o acqboardif.o

mock_receiver.o: mock_receiver.cc
	$(CXX) $(CXXFLAGS) -c mock_receiver.cc -o mock_receiver.o

runner.o: runner.cc

runner: runner.o 

clean: 
	rm *.o


runner: runner.o acqstatecontroltest.o acqserial.o acqboardif.o \
	 acqstatecontrol.o mock_receiver.o


