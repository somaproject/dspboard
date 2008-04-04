
CCSRCS   = main.cc
ASMSRCS = crt0.asm
SRCDIR= ../../../src/
CPUDEFINES = -D__ADSPBF561__ -D__ADSPLPBLACKFIN__
INCLUDES = -I$(SRCDIR)/bf533 -I. -I$(SRCDIR)
ASMFLAGS = -x assembler-with-cpp $(CPUDEFINES) $(INCLUDES)
ASMFLAGS += -DBOARD_$(BOARD)
CFLAGS = -mcpu=bf533 $(INCLUDES)  -g -DBOARD_$(BOARD) 
CFLAGS += $(CPUDEFINES) -fno-rtti --no-exceptions -ffast-math -mfast-fp
BOARD=SOMA_DSPBOARD4X

BFROOT = /home/jonas/blackfin/out-elf/
BFROOTVER = 4.1.2
LDFLAGS =  -g -T bftiny.x  -L$(BFROOT)lib/ -L$(BFROOT)/lib/gcc/bfin-elf/$(BFROOTVER)/ \
	 -lsupc++ -lc -lgcc -lnosys


OBJS = $(ASMSRCS:%.asm=%.o) $(CCSRCS:%.cc=%.o) eventtx.o eventrx.o eventdispatch.o memory.o 


AS = bfin-elf-as
CC = bfin-elf-gcc-$(BFROOTVER)
CXX = bfin-elf-g++

LD = bfin-elf-ld

all: $(OBJS) dspboard.dxe dspboard.ldr

main.o: main.cc
	$(CXX) $(CFLAGS)  -c -o main.o main.cc

memory.o: $(SRCDIR)/bf533/hw/memory.cc
	$(CXX) $(CFLAGS)  -c  $(SRCDIR)/bf533/hw/memory.cc


eventtx.o: $(SRCDIR)bf533/hw/eventtx.cc
	$(CXX) $(CFLAGS) -c $(SRCDIR)bf533/hw/eventtx.cc -o eventtx.o

eventrx.o: $(SRCDIR)/bf533/hw/eventrx.cc	
	$(CXX) $(CFLAGS)  -c  $(SRCDIR)/bf533/hw/eventrx.cc

eventdispatch.o: $(SRCDIR)/eventdispatch.cc	
	$(CXX) $(CFLAGS)  -c  $(SRCDIR)/eventdispatch.cc

%.o: %.asm
	$(CC) $(ASMFLAGS) -c -o $@ $<


dspboard.dxe: $(OBJS)
	$(LD) $(OBJS)  $(LDFLAGS) -o dspboard.dxe

clean:
	rm -f *.o


ldr: simpletest.ldr

dspboard.ldr: dspboard.dxe
	rm -f dspboard.ldr
	bfin-elf-ldr -T BF533 -c -p f --gpio=1  dspboard.ldr dspboard.dxe
