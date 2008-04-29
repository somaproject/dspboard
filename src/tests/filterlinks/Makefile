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


runner.o: runner.cc

runner: runner.o 

clean: 
	rm *.o


runner: runner.o filterlinktests.o systemtimer.o eventdispatch.o fakesource.o \
	hostdataout.o rawsink.o 



