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

LDFLAGS =  -g -T bftiny.x  -L/opt/uClinux/bfin-elf/lib/ -L/opt/uClinux/bfin-elf/lib/gcc/bfin-elf/4.1.0/  -lsupc++  -lc  -lgcc 

OBJS = $(ASMSRCS:%.asm=%.o) acqserial.o  $(CCSRCS:%.cc=%.o) 

AS = bfin-elf-as
CC = bfin-elf-gcc-4.1.0
CXX = bfin-elf-g++-4.1.0

LD = bfin-elf-ld

all: $(OBJS) acqserialtest.elf

main.o: main.cc
	$(CXX) $(CFLAGS)  -c -o main.o main.cc

acqserial.o: $(SRCDIR)/bf533/acqserial.cc  $(SRCDIR)/bf533/acqserial.h
	$(CXX) $(CFLAGS) -c -o acqserial.o $(SRCDIR)/bf533/acqserial.cc


%.o: %.asm
	$(CC) $(ASMFLAGS) -c -o $@ $<


acqserialtest.elf: $(OBJS)
	$(LD) $(OBJS)  $(LDFLAGS) -o acqserialtest.elf

clean:
	rm -f *.o


