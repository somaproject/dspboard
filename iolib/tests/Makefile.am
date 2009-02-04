
DSPSRC = ../../src
DSPSRCHW = $(DSPSRC)/host
AM_CXXFLAGS = -I$(DSPSRC) -I$(DSPSRCHW) -I../src $(SOMADEPS_CFLAGS) $(BOOST_THREAD_CPPFLAGS) $(BOOST_UNIT_TEST_FRAMEWORK_CPPFLAGS)
AM_LDFLAGS = $(SOMADEPS_LIBS)   $(BOOST_THREAD_LIBS)  	$(BOOST_UNIT_TEST_FRAMEWORK_LDFLAGS) $(BOOST_UNIT_TEST_FRAMEWORK_LIBS) 

LIBS = $(top_builddir)/src/libsomadspio-1.0.la

check_PROGRAMS = test_simple main test_acqdatasource

test_simple_SOURCES = $(MOCKSRC) test_simple.cc  runner.cc
test_acqdatasource_SOURCES = $(MOCKSRC) test_acqdatasource.cc runner.cc
main_SOURCES = $(MOCKSRC) main.cc

MOCKSRC =	$(DSPSRC)/systemtimer.cc \
	$(DSPSRC)/benchmark.cc \
	$(DSPSRC)/echoproc.cc \
	$(DSPSRCHW)/hostdataout.cc \
	$(DSPSRC)/eventdispatch.cc \
	$(DSPSRCHW)/hw/eventtx.cc \
	$(DSPSRCHW)/hw/acqserial.cc \
	$(DSPSRC)/sinks/tspikesink.cc \
	$(DSPSRCHW)/filter.cc \
	$(DSPSRC)/filterlinks/availablefirs.cc \
	$(DSPSRC)/mainloops/rawmainloop.cc \
	$(DSPSRC)/filterlinkcontroller.cc \
	$(DSPSRC)/filterlinks/fir.cc \
	$(DSPSRC)/acqstatecontrol.cc \
	$(DSPSRC)/acqdatasourcecontrol.cc \
	$(DSPSRC)/acqdatasource.cc \
	$(DSPSRC)/eventutil.cc \
	$(DSPSRC)/acqboardif.cc \
	$(DSPSRC)/sinks/rawsink.cc \
	$(DSPSRC)/mainloops/somamainloop.cc \
	mockdspboard.cc 
