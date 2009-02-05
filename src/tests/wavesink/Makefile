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

wavesink.o: $(SRCDIR)/sinks/wavesink.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/sinks/wavesink.cc -o wavesink.o

availablefirs.o: $(SRCDIR)/filterlinks/availablefirs.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/filterlinks/availablefirs.cc -o availablefirs.o

eventtx.o: $(HWDIR)/hw/eventtx.cc
	$(CXX) $(CXXFLAGS) -c  $(HWDIR)/hw/eventtx.cc -o eventtx.o


fakesource.o: $(SRCDIR)/fakesource.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/fakesource.cc -o fakesource.o

rawsink.o: $(SRCDIR)/sinks/rawsink.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/sinks/rawsink.cc -o rawsink.o

hostdataout.o: $(HWDIR)/hostdataout.o
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hostdataout.cc -o hostdataout.o

util.o: $(SRCDIR)/tests/utils/util.cc
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/tests/utils/util.cc -o util.o

runner.o: runner.cc

runner: runner.o 

clean: 
	rm *.o


runner: runner.o wavesinktest.o systemtimer.o availablefirs.o \
	eventdispatch.o fakesource.o hostdataout.o wavesink.o eventtx.o \
	filterlinkcontroller.o util.o




