# Makefile for SPI test. 
#
# based off of Blink example via:
# 11/2004 Martin Strubel <hackfin@section5.ch>


ASMSRCS = crt0.asm 
CCSRCS   = main.cc
SRCDIR= ../../../src/
CPUDEFINES = -D__ADSPBF561__ -D__ADSPLPBLACKFIN__
INCLUDES = -I../../../dspcode/include -I. -I$(SRCDIR)
ASMFLAGS = -x assembler-with-cpp $(CPUDEFINES) $(INCLUDES)
ASMFLAGS += -DBOARD_$(BOARD)
CFLAGS = -mcpu=bf533 $(INCLUDES)  -g -DBOARD_$(BOARD) 
CFLAGS += $(CPUDEFINES) 
BOARD=STAMP_BF533

BFROOT = /home/jonas/blackfin/opt/uClinux/bfin-elf/

LDFLAGS =  -g -T bftiny.x  -L$(BFROOT)lib/ -L$(BFROOT)/lib/gcc/bfin-elf/4.1.1/ -lsupc++ -lc -lgcc -lnosys


OBJS = $(ASMSRCS:%.asm=%.o)  $(CCSRCS:%.cc=%.o) eventtx.o


AS = bfin-elf-as
CC = bfin-elf-gcc-4.1.1
CXX = bfin-elf-g++-4.1.1

LD = bfin-elf-ld

all: $(OBJS) eventrxtest.dxe

main.o: main.cc
	$(CXX) $(CFLAGS)  -c -o main.o main.cc

eventtx.o: $(SRCDIR)bf533/hw/eventtx.cc
	$(CXX) $(CFLAGS) -c $(SRCDIR)bf533/hw/eventtx.cc -o eventtx.o

%.o: %.asm
	$(CC) $(ASMFLAGS) -c -o $@ $<


eventrxtest.dxe: $(OBJS)
	$(LD) $(OBJS)  $(LDFLAGS) -o eventrxtest.dxe

clean:
	rm -f *.o


