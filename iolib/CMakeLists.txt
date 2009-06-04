
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(somadspio)

SET(LIBRARY_VERSION "1.0")
SET(LIBRARY_SOVERSION "0")


# boost requirements
find_package(Boost 1.37.0 COMPONENTS unit_test_framework system REQUIRED)
find_package(PkgConfig)

pkg_check_modules(SIGC++ REQUIRED sigc++-2.0>=2.0)
pkg_check_modules(SOMADEPS REQUIRED 
  somanetwork-1.0>=1.0)


ENABLE_TESTING()

include_directories(src)

add_subdirectory(src)
add_subdirectory(tests)

set(PKG_FILE_NAME somadspio-1.0.pc)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${PKG_FILE_NAME}.in 
  ${CMAKE_CURRENT_BINARY_DIR}/${PKG_FILE_NAME})

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG_FILE_NAME} 
  DESTINATION lib/pkgconfig)

