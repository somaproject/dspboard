CXXFLAGS = -O2 -D_REENTRANT -I../../ -I../../host/

LDFLAGS = -lboost_unit_test_framework

main: main.o eventdispatchtest.o eventdispatch.o

eventdispatch.o: ../../eventdispatch.cc
	$(CXX) $(CXXFLAGS) -c ../../eventdispatch.cc



