
include_directories(${Boost_INCLUDE_DIRS})
include_directories(${SIGC++_INCLUDE_DIRS})
include_directories(${SOMADEPS_INCLUDE_DIRS})

set(DSPSRCDIR ../../src)

include_directories(${DSPSRCDIR})


add_executable(test_simple
  test_simple.cc
  runner.cc
)

add_executable(test_acqdatasource
  test_acqdatasource.cc
  runner.cc)

set(DSPSRCHWDIR
  ${DSPSRCDIR}/host)

include_directories(${DSPSRCHWDIR})
include_directories(${DSPSRCHWDIR})

add_library(mockdsp
  mockdspboard.cc
  ${DSPSRCDIR}/systemtimer.cc 
  ${DSPSRCDIR}/benchmark.cc 
  ${DSPSRCDIR}/echoproc.cc 
  ${DSPSRCHWDIR}/hostdataout.cc 
  ${DSPSRCDIR}/eventdispatch.cc 
  ${DSPSRCHWDIR}/hw/eventtx.cc 
  ${DSPSRCHWDIR}/hw/acqserial.cc 
  ${DSPSRCDIR}/sinks/tspikesink.cc 
  ${DSPSRCHWDIR}/filter.cc 
  ${DSPSRCDIR}/filterlinks/availablefirs.cc 
  ${DSPSRCDIR}/mainloops/rawmainloop.cc 
  ${DSPSRCDIR}/filterlinkcontroller.cc 
  ${DSPSRCDIR}/filterlinks/fir.cc 
  ${DSPSRCDIR}/acqstatecontrol.cc 
  ${DSPSRCDIR}/acqdatasourcecontrol.cc 
  ${DSPSRCDIR}/acqdatasource.cc 
  ${DSPSRCDIR}/eventutil.cc 
  ${DSPSRCDIR}/acqboardif.cc 
  ${DSPSRCDIR}/sinks/rawsink.cc 
  ${DSPSRCDIR}/mainloops/somamainloop.cc)


set(testlist
  test_simple
  test_acqdatasource)

foreach(testname ${testlist})
    target_link_libraries(${testname}
      mockdsp
      ${PROJECT_NAME}_test
      somanetwork)
  
  ADD_TEST(${testname} ${testname})

endforeach(testname)


