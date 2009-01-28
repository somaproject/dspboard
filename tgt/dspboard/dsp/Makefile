
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

BFROOT = /home/jonas/blackfin/out-elf/
BFROOTVER = 4.1.2
LDFLAGS =  -g -T bftiny.x  -L$(BFROOT)lib/ -L$(BFROOT)/lib/gcc/bfin-elf/$(BFROOTVER)/ \
	 -lsupc++ -lc -lgcc -lnosys


OBJS = $(ASMSRCS:%.asm=%.o) $(CCSRCS:%.cc=%.o) eventtx.o eventrx.o \
	eventdispatch.o memory.o dspuartconfig.o  acqserial.o \
	uarttx.o acqstatecontrol.o systemtimer.o datasport.o acqboardif.o\
	fakesource.o rawsink.o  tspikesink.o availablefirs.o filterlinkcontroller.o\
	 rawmainloop.o somamainloop.o echoproc.o memtestproc.o\
	filter.o delta.o fir.o acqdatasourcecontrol.o acqdatasource.o


AS = bfin-elf-as
CC = bfin-elf-gcc-$(BFROOTVER)
CXX = bfin-elf-g++

LD = bfin-elf-ld

all: $(OBJS) dspboard.dxe dspboard.ldr

main.o: main.cc
	$(CXX) $(CXXFLAGS)  -c -o main.o main.cc

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

somamainloop.o: $(SRCDIR)/mainloops/somamainloop.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/mainloops/somamainloop.cc

systemtimer.o: $(SRCDIR)/systemtimer.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/systemtimer.cc

rawsink.o: $(SRCDIR)/sinks/rawsink.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/sinks/rawsink.cc

tspikesink.o: $(SRCDIR)/sinks/tspikesink.cc
	$(CXX) $(CXXFLAGS)  -c  $(SRCDIR)/sinks/tspikesink.cc

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


dspboard.dxe: $(OBJS)
	$(LD) $(OBJS)  $(LDFLAGS) -o dspboard.dxe

clean:
	rm -f *.o


ldr: simpletest.ldr

dspboard.dump: dspboard.dxe
	bfin-elf-objdump -s --disassemble --line-numbers dspboard.dxe > dspboard.dump

dspboard.ldr: dspboard.dxe
	rm -f dspboard.ldr
	bfin-elf-ldr -T BF533 -c -p f --gpio=1  dspboard.ldr dspboard.dxe
