# Makefile for SPI test. 
#
# based off of Blink example via:
# 11/2004 Martin Strubel <hackfin@section5.ch>


ASMSRCS = crt0.asm 
CCSRCS   = main.cc
SRCDIR= ../../../src/
CPUDEFINES = -D__ADSPBF561__ -D__ADSPLPBLACKFIN__
INCLUDES = -I$(SRCDIR)/bf533 -I. -I$(SRCDIR)
ASMFLAGS = -x assembler-with-cpp $(CPUDEFINES) $(INCLUDES)
ASMFLAGS += -DBOARD_$(BOARD)
CFLAGS = -mcpu=bf533 $(INCLUDES)  -g -DBOARD_$(BOARD) 
CFLAGS += $(CPUDEFINES) -fno-rtti --no-exceptions
BOARD=STAMP_BF533

BFROOT = /home/jonas/blackfin/out-elf/
BFROOTVER = 4.1.2
LDFLAGS =  -g -T bftiny.x  -L$(BFROOT)lib/ -L$(BFROOT)/lib/gcc/bfin-elf/$(BFROOTVER)/ \
	 -lsupc++ -lc -lgcc -lnosys


OBJS = $(ASMSRCS:%.asm=%.o)  $(CCSRCS:%.cc=%.o) eventtx.o datasport.o memory.o


AS = bfin-elf-as
CC = bfin-elf-gcc-$(BFROOTVER)
CXX = bfin-elf-g++

LD = bfin-elf-ld

all: $(OBJS) periodictxtest.dxe periodictxtest.ldr

main.o: main.cc
	$(CXX) $(CFLAGS)  -c -o main.o main.cc

memory.o: $(SRCDIR)/bf533/hw/memory.cc
	$(CXX) $(CFLAGS)  -c  $(SRCDIR)/bf533/hw/memory.cc


eventtx.o: $(SRCDIR)bf533/hw/eventtx.cc
	$(CXX) $(CFLAGS) -c $(SRCDIR)bf533/hw/eventtx.cc -o eventtx.o

datasport.o: $(SRCDIR)bf533/hw/datasport.cc
	$(CXX) $(CFLAGS) -c $(SRCDIR)bf533/hw/datasport.cc -o datasport.o

%.o: %.asm
	$(CC) $(ASMFLAGS) -c -o $@ $<


periodictxtest.dxe: $(OBJS)
	$(LD) $(OBJS)  $(LDFLAGS) -o periodictxtest.dxe

clean:
	rm -f *.o


ldr: simpletest.ldr

periodictxtest.ldr: periodictxtest.dxe
	rm -f periodictxtest.ldr
	bfin-elf-ldr -T BF533 -c -p f --gpio=1  periodictxtest.ldr periodictxtest.dxe
