DIR=../..
HWDIR=$(DIR)/host/
CXXFLAGS=-I../../ -g -I$(HWDIR)
LDFLAGS=-lboost_unit_test_framework -g

main: main.o dataout.o dspdataout.o systemtimer.o rawsink.o filterlinkmanager.o delta.o fakedatasrc.o


main.o: main.cc

rawsink.o: $(DIR)/sinks/rawsink.cc $(DIR)/sinks/rawsink.h
	g++ $(CXXFLAGS) -c $(DIR)/sinks/rawsink.cc

fakedatasrc.o: fakedatasrc.cc fakedatasrc.h
	g++ $(CXXFLAGS) -c fakedatasrc.cc fakedatasrc.h


delta.o: $(DIR)/filterlinks/delta.h $(DIR)/filterlinks/delta.h
	g++ $(CXXFLAGS) -c $(DIR)/filterlinks/delta.cc

systemtimer.o: $(DIR)/systemtimer.cc $(DIR)/systemtimer.h
	g++ $(CXXFLAGS) -c $(DIR)/systemtimer.cc

filterlinkmanager.o: $(DIR)/filterlinkmanager.cc $(DIR)/filterlinkmanager.h
	g++ $(CXXFLAGS) -c $(DIR)/filterlinkmanager.cc

dataout.o: $(DIR)/dataout.cc $(DIR)/dataout.h
	g++ $(CXXFLAGS) -c $(DIR)/dataout.cc

dspdataout.o: $(HWDIR)hw/dspdataout.cc $(HWDIR)hw/dspdataout.h
	g++ $(CXXFLAGS) -c  $(HWDIR)hw/dspdataout.cc -o dspdataout.o


clean: 
	rm *.o main
