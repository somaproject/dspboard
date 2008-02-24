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
CFLAGS = $(INCLUDES)  -g -DBOARD_$(BOARD) 
CFLAGS += $(CPUDEFINES) 
BOARD=STAMP_BF533

BFROOT = /home/jonas/blackfin/opt/uClinux/bfin-elf/

LDFLAGS =  -g -T bftiny.x  -L$(BFROOT)lib/ -L$(BFROOT)/lib/gcc/bfin-elf/4.1.1/

OBJS = $(ASMSRCS:%.asm=%.o)  $(CCSRCS:%.cc=%.o) 

AS = bfin-elf-as
CC = bfin-elf-gcc-4.1.1
CXX = bfin-elf-g++-4.1.1

LD = bfin-elf-ld

all: $(OBJS) simpletest.elf

main.o: main.cc
	$(CXX) $(CFLAGS)  -c -o main.o main.cc


%.o: %.asm
	$(CC) $(ASMFLAGS) -c -o $@ $<


simpletest.elf: $(OBJS)
	$(LD) $(OBJS)  $(LDFLAGS) -o simpletest.elf

clean:
	rm -f *.o


