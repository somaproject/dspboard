# Makefile for SPI test. 
#
# based off of Blink example via:
# 11/2004 Martin Strubel <hackfin@section5.ch>


ASMSRCS = crt0.asm 
CCSRCS   = main.cc acqstatecontroltest.cc
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


OBJS = $(ASMSRCS:%.asm=%.o)  $(CCSRCS:%.cc=%.o) memory.o acqserial.o \
	uarttx.o acqstatecontrol.o 



AS = bfin-elf-as
CC = bfin-elf-gcc-$(BFROOTVER)
CXX = bfin-elf-g++

LD = bfin-elf-ld

all: $(OBJS) acqserialtest.dxe

main.o: main.cc
	$(CXX) $(CFLAGS)  -c -o main.o main.cc

acqstatecontroltest.o: acqstatecontroltest.cc
	$(CXX) $(CFLAGS)  -c -o acqstatecontroltest.o acqstatecontroltest.cc

memory.o: $(SRCDIR)/bf533/hw/memory.cc
	$(CXX) $(CFLAGS)  -c  $(SRCDIR)/bf533/hw/memory.cc

acqstatecontrol.o: $(SRCDIR)/acqstatecontrol.cc
	$(CXX) $(CFLAGS)  -c  $(SRCDIR)/acqstatecontrol.cc


acqserial.o: $(SRCDIR)bf533/hw/acqserial.cc
	$(CXX) $(CFLAGS) -c $(SRCDIR)bf533/hw/acqserial.cc -o acqserial.o

uarttx.o: $(SRCDIR)bf533/hw/uarttx.cc
	$(CXX) $(CFLAGS) -c $(SRCDIR)bf533/hw/uarttx.cc -o uarttx.o

%.o: %.asm
	$(CC) $(ASMFLAGS) -c -o $@ $<


acqserialtest.dxe: $(OBJS)
	$(LD) $(OBJS)  $(LDFLAGS) -o acqserialtest.dxe

clean:
	rm -f *.o


