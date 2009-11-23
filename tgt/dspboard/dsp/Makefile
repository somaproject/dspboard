
BFROOT = /home/jonas/blackfin/opt/uClinux/bfin-elf

CCSRCS   = main.cc
ASMSRCS = crt0.asm
SRCDIR= ../../../src/
HWDIR = $(SRCDIR)/bf533/
CPUDEFINES = -D__ADSPBF561__ -D__ADSPLPBLACKFIN__
INCLUDES = -I$(HWDIR) -I. -I$(SRCDIR) 
ASMFLAGS = -x assembler-with-cpp $(CPUDEFINES) $(INCLUDES)
ASMFLAGS += -DBOARD_$(BOARD)
CXXFLAGS = -mcpu=bf533 $(INCLUDES) -O3  -g -DBOARD_$(BOARD) -save-temps
CXXFLAGS += $(CPUDEFINES) -fno-rtti --no-exceptions -ffast-math -mfast-fp -funsafe-math-optimizations
BOARD=SOMA_DSPBOARD4X


BFROOTVER = 4.1.2
LDFLAGS =  -g -T bftiny.x  -L$(BFROOT)lib/ -L$(BFROOT)/lib/gcc/bfin-elf/$(BFROOTVER)/ \
	 -lsupc++ -lc -lgcc -lnosys


OBJS = $(ASMSRCS:%.asm=%.o) eventtx.o eventrx.o \
	eventdispatch.o memory.o dspuartconfig.o  acqserial.o audiomon.o \
	uarttx.o acqstatecontrol.o systemtimer.o datasport.o acqboardif.o\
	fakesource.o rawsink.o  tspikesink.o availablefirs.o filterlinkcontroller.o\
	 rawmainloop.o somamainloop.o noopmainloop.o echoproc.o benchmark.o memtestproc.o\
	filter.o delta.o fir.o acqdatasourcecontrol.o acqdatasource.o wavesink.o \
	fakerawmainloop.o


AS = bfin-elf-as
CC = bfin-elf-gcc-$(BFROOTVER)
CXX = bfin-elf-g++

LD = bfin-elf-ld

all: $(OBJS) dspboard_noop.dxe dspboard_noop.ldr \
	 dspboard_soma.dxe dspboard_soma.ldr \
	dspboard_raw.dxe dspboard_raw.ldr

main_noop.o: main.cc
	$(CXX) $(CXXFLAGS) -DMAINLOOP=1 -c -o main_noop.o main.cc

main_soma.o: main.cc
	$(CXX) $(CXXFLAGS) -DMAINLOOP=2 -c -o main_soma.o main.cc

main_raw.o: main.cc
	$(CXX) $(CXXFLAGS) -DMAINLOOP=3 -c -o main_raw.o main.cc

memory.o: $(HWDIR)hw/memory.cc
	$(CXX) $(CXXFLAGS)  -c  $(HWDIR)hw/memory.cc


eventtx.o: $(HWDIR)hw/eventtx.cc
	$(CXX) $(CXXFLAGS) -c $(HWDIR)hw/eventtx.cc -o eventtx.o


eventrx.o: $(HWDIR)hw/eventrx.cc	
	$(CXX) $(CXXFLAGS)  -c  $(HWDIR)hw/eventrx.cc


datasport.o: $(HWDIR)hw/datasport.cc	
	$(CXX) $(CXXFLAGS)  -c  $(HWDIR)hw/datasport.cc

filter.o: $(HWDIR)filter.cc
	$(CXX) $(CXXFLAGS)  -c  $(HWDIR)filter.cc

eventdispatch.o: $(SRCDIR)/eventdispatch.cc	
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/eventdispatch.cc

echoproc.o: $(SRCDIR)/echoproc.cc	
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/echoproc.cc

benchmark.o: $(SRCDIR)/benchmark.cc	
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/benchmark.cc

memtestproc.o: $(SRCDIR)/memtestproc.cc	
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/memtestproc.cc

acqboardif.o: $(SRCDIR)/acqboardif.cc	
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/acqboardif.cc

acqdatasource.o: $(SRCDIR)/acqdatasource.cc	
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/acqdatasource.cc

filterlinkcontroller.o: $(SRCDIR)/filterlinkcontroller.cc	
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/filterlinkcontroller.cc

availablefirs.o: $(SRCDIR)/filterlinks/availablefirs.cc	
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/filterlinks/availablefirs.cc -o availablefirs.o

acqdatasourcecontrol.o: $(SRCDIR)/acqdatasourcecontrol.cc	
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/acqdatasourcecontrol.cc

dspuartconfig.o: $(HWDIR)hw/dspuartconfig.cc	
	$(CXX) $(CXXFLAGS)  -c  $(HWDIR)hw/dspuartconfig.cc

acqstatecontrol.o: $(SRCDIR)/acqstatecontrol.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/acqstatecontrol.cc

rawmainloop.o: $(SRCDIR)/mainloops/rawmainloop.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/mainloops/rawmainloop.cc

fakerawmainloop.o: $(SRCDIR)/mainloops/fakerawmainloop.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/mainloops/fakerawmainloop.cc

noopmainloop.o: $(SRCDIR)/mainloops/noopmainloop.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/mainloops/noopmainloop.cc

somamainloop.o: $(SRCDIR)/mainloops/somamainloop.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/mainloops/somamainloop.cc

systemtimer.o: $(SRCDIR)/systemtimer.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/systemtimer.cc

audiomon.o: $(SRCDIR)/audiomon.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/audiomon.cc

rawsink.o: $(SRCDIR)/sinks/rawsink.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/sinks/rawsink.cc

tspikesink.o: $(SRCDIR)/sinks/tspikesink.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/sinks/tspikesink.cc

wavesink.o: $(SRCDIR)/sinks/wavesink.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/sinks/wavesink.cc

delta.o: $(SRCDIR)/filterlinks/delta.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/filterlinks/delta.cc

fir.o: $(SRCDIR)/filterlinks/fir.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/filterlinks/fir.cc

fakesource.o: $(SRCDIR)/fakesource.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/fakesource.cc


acqserial.o: $(HWDIR)hw/acqserial.cc
	$(CXX) $(CXXFLAGS) -c $(HWDIR)hw/acqserial.cc -o acqserial.o

uarttx.o: $(HWDIR)hw/uarttx.cc
	$(CXX) $(CXXFLAGS) -c $(HWDIR)hw/uarttx.cc -o uarttx.o


%.o: %.asm
	$(CC) $(ASMFLAGS) -c -o $@ $<


dspboard_noop.dxe: $(OBJS) main_noop.o
	$(LD) $(OBJS) main_noop.o  $(LDFLAGS) -o dspboard_noop.dxe


dspboard_soma.dxe: $(OBJS) main_soma.o
	$(LD) $(OBJS) main_soma.o  $(LDFLAGS) -o dspboard_soma.dxe


dspboard_raw.dxe: $(OBJS) main_raw.o
	$(LD) $(OBJS) main_raw.o  $(LDFLAGS) -o dspboard_raw.dxe

clean:
	rm -f *.o


ldr: simpletest.ldr

dspboard.dump: dspboard.dxe
	bfin-elf-objdump -s --disassemble --line-numbers dspboard.dxe > dspboard.dump

dspboard_soma.ldr: dspboard_soma.dxe
	rm -f dspboard_soma.ldr
	bfin-elf-ldr -T BF533 -c -p f --gpio=1  dspboard_soma.ldr dspboard_soma.dxe

dspboard_noop.ldr: dspboard_noop.dxe
	rm -f dspboard_noop.ldr
	bfin-elf-ldr -T BF533 -c -p f --gpio=1  dspboard_noop.ldr dspboard_noop.dxe

dspboard_raw.ldr: dspboard_raw.dxe
	rm -f dspboard_raw.ldr
	bfin-elf-ldr -T BF533 -c -p f --gpio=1  dspboard_raw.ldr dspboard_raw.dxe
