
set(dspiolib_SRCS
  dspcontrol.cc
  eventcodec.cc)

set(somadspio_HEADERS
  dspcontrol.h eventcodec.h const.h
)

include_directories(${Boost_INCLUDE_DIRS})
include_directories(${SIGC++_INCLUDE_DIRS})
include_directories(${SOMADEPS_INCLUDE_DIRS})

ADD_LIBRARY(${PROJECT_NAME} SHARED
  ${dspiolib_SRCS})

target_link_libraries(${PROJECT_NAME} 
  ${Boost_LIBRARIES} 
  ${SIGC++_LIBRARIES})


ADD_LIBRARY(${PROJECT_NAME}_test
  ${dspiolib_SRCS})

target_link_libraries(${PROJECT_NAME}_test
  ${Boost_LIBRARIES} 
  ${SIGC++_LIBRARIES})

SET_TARGET_PROPERTIES(${PROJECT_NAME}
  PROPERTIES VERSION ${LIBRARY_VERSION}
  SOVERSION ${LIBRARY_SOVERSION})

install( TARGETS ${PROJECT_NAME} LIBRARY
  DESTINATION lib)

install(FILES ${somadspio_HEADERS}
  DESTINATION
  include/${PROJECT_NAME}-${LIBRARY_VERSION}/${PROJECT_NAME})
