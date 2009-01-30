SRCDIR = ../../
HWDIR = $(SRCDIR)/host
CXXFLAGS=-I$(SRCDIR) -I$(HWDIR) -g
LDFLAGS=-lboost_unit_test_framework


all: runner


systemtimer.o: $(SRCDIR)/systemtimer.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/systemtimer.cc -o systemtimer.o

eventdispatch.o: $(SRCDIR)/eventdispatch.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/eventdispatch.cc -o eventdispatch.o


fakesource.o: $(SRCDIR)/fakesource.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/fakesource.cc -o fakesource.o

rawsink.o: $(SRCDIR)/sinks/rawsink.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/sinks/rawsink.cc -o rawsink.o

hostdataout.o: $(HWDIR)/hostdataout.o
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hostdataout.cc -o hostdataout.o

acqserial.o: $(HWDIR)/hw/acqserial.o
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hw/acqserial.cc -o acqserial.o

eventtx.o: $(HWDIR)/hw/eventtx.o
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hw/eventtx.cc -o eventtx.o

acqdatasource.o: $(SRCDIR)/acqdatasource.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqdatasource.cc -o acqdatasource.o

acqboardif.o: $(SRCDIR)/acqboardif.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqboardif.cc -o acqboardif.o

acqdatasourcecontrol.o: $(SRCDIR)/acqdatasourcecontrol.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqdatasourcecontrol.cc -o acqdatasourcecontrol.o

acqstatecontrol.o: $(SRCDIR)/acqstatecontrol.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqstatecontrol.cc -o acqstatecontrol.o

echoproc.o: $(SRCDIR)/echoproc.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/echoproc.cc -o echoproc.o

benchmark.o: $(SRCDIR)/benchmark.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/benchmark.cc -o benchmark.o

rawmainloop.o: $(SRCDIR)/mainloops/rawmainloop.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/mainloops/rawmainloop.cc -o rawmainloop.o


runner.o: runner.cc

runner: runner.o 

clean: 
	rm *.o


runner: runner.o rawmainloop.o rawmainlooptest.o  systemtimer.o eventdispatch.o fakesource.o \
	eventtx.o acqserial.o hostdataout.o rawsink.o  acqdatasource.o echoproc.o \
	benchmark.o acqboardif.o acqstatecontrol.o acqdatasourcecontrol.o




