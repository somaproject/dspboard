SRCDIR = ../../
HWDIR = $(SRCDIR)/host
CXXFLAGS=-I$(SRCDIR) -I$(HWDIR) -g `pkg-config somanetwork-1.0 sigc++-2.0 --cflags`

LDFLAGS=-lboost_unit_test_framework `pkg-config somanetwork-1.0 sigc++-2.0 --libs` -lboost_thread


all: runner

systemtimer.o: $(SRCDIR)/systemtimer.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/systemtimer.cc -o systemtimer.o

eventdispatch.o: $(SRCDIR)/eventdispatch.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/eventdispatch.cc -o eventdispatch.o

filterlinkcontroller.o: $(SRCDIR)/filterlinkcontroller.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/filterlinkcontroller.cc -o filterlinkcontroller.o

tspikesink.o: $(SRCDIR)/sinks/tspikesink.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/sinks/tspikesink.cc -o tspikesink.o

eventtx.o: $(HWDIR)/hw/eventtx.cc
	$(CXX) $(CXXFLAGS) -c  $(HWDIR)/hw/eventtx.cc -o eventtx.o


fakesource.o: $(SRCDIR)/fakesource.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/fakesource.cc -o fakesource.o

rawsink.o: $(SRCDIR)/sinks/rawsink.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/sinks/rawsink.cc -o rawsink.o

hostdataout.o: $(HWDIR)/hostdataout.o
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hostdataout.cc -o hostdataout.o


runner.o: runner.cc

runner: runner.o 

clean: 
	rm *.o


runner: runner.o tspikesinktest.o systemtimer.o \
	eventdispatch.o fakesource.o hostdataout.o tspikesink.o eventtx.o \
	filterlinkcontroller.o




