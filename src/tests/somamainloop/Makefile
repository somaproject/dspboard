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

availablefirs.o: $(SRCDIR)/filterlinks/availablefirs.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/filterlinks/availablefirs.cc -o availablefirs.o

fir.o: $(SRCDIR)/filterlinks/fir.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/filterlinks/fir.cc -o fir.o

tspikesink.o: $(SRCDIR)/sinks/tspikesink.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/sinks/tspikesink.cc -o tspikesink.o

hostdataout.o: $(HWDIR)/hostdataout.o
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hostdataout.cc -o hostdataout.o

acqserial.o: $(HWDIR)/hw/acqserial.o
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hw/acqserial.cc -o acqserial.o

filter.o: $(HWDIR)/filter.o
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/filter.cc -o filter.o

eventtx.o: $(HWDIR)/hw/eventtx.o
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hw/eventtx.cc -o eventtx.o

acqdatasource.o: $(SRCDIR)/acqdatasource.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqdatasource.cc -o acqdatasource.o

filterlinkcontroller.o: $(SRCDIR)/filterlinkcontroller.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/filterlinkcontroller.cc -o filterlinkcontroller.o

acqboardif.o: $(SRCDIR)/acqboardif.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqboardif.cc -o acqboardif.o

acqdatasourcecontrol.o: $(SRCDIR)/acqdatasourcecontrol.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqdatasourcecontrol.cc -o acqdatasourcecontrol.o

acqstatecontrol.o: $(SRCDIR)/acqstatecontrol.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqstatecontrol.cc -o acqstatecontrol.o

echoproc.o: $(SRCDIR)/echoproc.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/echoproc.cc -o echoproc.o

somamainloop.o: $(SRCDIR)/mainloops/somamainloop.o
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/mainloops/somamainloop.cc -o somamainloop.o


runner.o: runner.cc

runner: runner.o 

clean: 
	rm *.o runner


runner: runner.o somamainloop.o somamainlooptest.o  systemtimer.o eventdispatch.o fakesource.o \
	eventtx.o acqserial.o hostdataout.o \
	availablefirs.o fir.o filter.o\
	rawsink.o tspikesink.o \
	 acqdatasource.o filterlinkcontroller.o echoproc.o \
	acqboardif.o acqstatecontrol.o acqdatasourcecontrol.o




