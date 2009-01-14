SRCDIR = ../
HWDIR = $(SRCDIR)/host
CXXFLAGS=-I$(SRCDIR) -I$(HWDIR) -g `pkg-config somanetwork-1.0 sigc++-2.0 --cflags`

LDFLAGS=-lboost_unit_test_framework `pkg-config somanetwork-1.0 sigc++-2.0 --libs` -lboost_thread

BUILDDIR=build

all: runner

builddir: $(BUILDDIR)
	mkdir -p $(BUILDDIR)

runner.o: runner.cc

$(BUILDDIR)/systemtimer.o: $(SRCDIR)/systemtimer.cc builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/systemtimer.cc -o $(BUILDDIR)/systemtimer.o

$(BUILDDIR)/filterlinkcontroller.o: $(SRCDIR)/filterlinkcontroller.cc builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/filterlinkcontroller.cc -o $(BUILDDIR)/filterlinkcontroller.o

$(BUILDDIR)/acqboardif.o: $(SRCDIR)/acqboardif.cc builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqboardif.cc -o $(BUILDDIR)/acqboardif.o

$(BUILDDIR)/acqserial.o: $(HWDIR)/hw/acqserial.cc builddir
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hw/acqserial.cc -o $(BUILDDIR)/acqserial.o

$(BUILDDIR)/eventtx.o: $(HWDIR)/hw/eventtx.cc builddir
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hw/eventtx.cc -o $(BUILDDIR)/eventtx.o

$(BUILDDIR)/eventdispatch.o: $(SRCDIR)/eventdispatch.cc builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/eventdispatch.cc -o $(BUILDDIR)/eventdispatch.o

$(BUILDDIR)/echoproc.o: $(SRCDIR)/echoproc.cc builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/echoproc.cc -o $(BUILDDIR)/echoproc.o

$(BUILDDIR)/fakesource.o: $(SRCDIR)/fakesource.cc builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/fakesource.cc -o $(BUILDDIR)/fakesource.o

$(BUILDDIR)/rawmainloop.o: $(SRCDIR)/mainloops/rawmainloop.cc builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/mainloops/rawmainloop.cc -o $(BUILDDIR)/rawmainloop.o

$(BUILDDIR)/rawsink.o: $(SRCDIR)/sinks/rawsink.cc builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/sinks/rawsink.cc -o $(BUILDDIR)/rawsink.o

$(BUILDDIR)/delta.o: $(SRCDIR)/filterlinks/delta.o builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/filterlinks/delta.cc -o $(BUILDDIR)/delta.o

$(BUILDDIR)/tspikesink.o: $(SRCDIR)/sinks/tspikesink.cc builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/sinks/tspikesink.cc -o $(BUILDDIR)/tspikesink.o

$(BUILDDIR)/hostdataout.o: $(HWDIR)/hostdataout.o builddir
	$(CXX) $(CXXFLAGS) -c $(HWDIR)/hostdataout.cc -o $(BUILDDIR)/hostdataout.o

$(BUILDDIR)/acqdatasource.o: $(SRCDIR)/acqdatasource.o builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqdatasource.cc -o $(BUILDDIR)/acqdatasource.o

$(BUILDDIR)/acqdatasourcecontrol.o: $(SRCDIR)/acqdatasourcecontrol.o builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqdatasourcecontrol.cc -o $(BUILDDIR)/acqdatasourcecontrol.o

$(BUILDDIR)/acqstatecontrol.o: $(SRCDIR)/acqstatecontrol.o builddir
	$(CXX) $(CXXFLAGS) -c $(SRCDIR)/acqstatecontrol.cc -o $(BUILDDIR)/acqstatecontrol.o

COREOBJS = $(BUILDDIR)/systemtimer.o $(BUILDDIR)/filterlinkcontroller.o $(BUILDDIR)/delta.o\
	$(BUILDDIR)/eventdispatch.o $(BUILDDIR)/echoproc.o $(BUILDDIR)/fakesource.o $(BUILDDIR)/hostdataout.o \
	 $(BUILDDIR)/rawsink.o $(BUILDDIR)/rawmainloop.o  \
	$(BUILDDIR)/tspikesink.o $(BUILDDIR)/acqdatasource.o $(BUILDDIR)/acqdatasourcecontrol.o \
	 $(BUILDDIR)/acqboardif.o \
	$(BUILDDIR)/acqstatecontrol.o $(BUILDDIR)/acqserial.o $(BUILDDIR)/eventtx.o

# Actual tests

ACQDATASOURCE_OBJS = acqdatasource/acqdatasourcetest.o
ACQSTATECONTROL_OBJS = acqstatecontrol/acqstatecontroltest.o acqstatecontrol/mock_receiver.o
CALLBACK_OBJS = 
DATAOUTFIFO_OBJS = 
EVENTDISPATCH_OBJS = 
FILTERIO_OBJS = filterio/filteriotest.o
FILTERLINKS_OBJS = filterlinks/filterlinktests.o filterlinks/deltatest.o
RAWMAINLOOP_OBJS = rawmainloop/rawmainlooptest.o 
SAMPLEBUFFERS_OBJ = 
TSPIKESINK_OBJS = tspikesink/tspikesinktest.o

runner: runner.o $(COREOBJS)  \
	$(ACQDATASOURCE_OBJS) \
	$(ACQSTATECONTROL_OBJS) \
	$(CALLBACK_OBJS) \
	$(DATAOUTFIFO_OBJS) \
	$(EVENTDISPATCH_OBJS) \
	$(FILTERIO_OBJS) \
	$(FILTERLINKS_OBJS) \
	$(RAWMAINLOOP_OBJS) \
	$(SAMPLEBUFFERS_OBJ) \
	$(TSPIKESINK_OBJS) 


clean: 
	rm -Rf *.o $(BUILDDIR)/*.o
