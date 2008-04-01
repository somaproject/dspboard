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
ASMFLAGS += -DUSE_LIBC
CFLAGS = $(INCLUDES)  -g -DBOARD_$(BOARD) -mcpu=bf533
CFLAGS += $(CPUDEFINES)  -fno-rtti --no-exceptions
BOARD=STAMP_BF533

BFROOT = /home/jonas/blackfin/out-elf/
BFROOTVER = 4.1.2


LDFLAGS =   -g -T bftiny.x  -L$(BFROOT)lib/ -L$(BFROOT)/lib/gcc/bfin-elf/4.1.2/ \
	#	 -lsupc++ -lc -lgcc -lnosys


#OBJS = $(CCSRCS:%.cc=%.o)  $(ASMSRCS:%.asm=%.o) # memory.o
OBJS = $(ASMSRCS:%.asm=%.o)  $(CCSRCS:%.cc=%.o) memory.o uarttx.o

AS = bfin-elf-as
CC = bfin-elf-gcc-4.1.2	
CXX = bfin-elf-g++

LD = bfin-elf-ld

all: $(OBJS) uartacqrxtest.dxe

main.o: main.cc
	$(CXX) $(CFLAGS)  -c main.cc -o main.o

memory.o: $(SRCDIR)/bf533/hw/memory.cc
	$(CXX) $(CFLAGS)  -c  $(SRCDIR)/bf533/hw/memory.cc

uarttx.o: $(SRCDIR)/bf533/hw/uarttx.cc
	$(CXX) $(CFLAGS)  -c  $(SRCDIR)/bf533/hw/uarttx.cc


%.o: %.asm
	$(CC) $(ASMFLAGS) -c -o $@ $<


uartacqrxtest.dxe: $(OBJS)
	$(LD)  \
	$(OBJS) \
	$(LDFLAGS) -o uartacqrxtest.dxe

clean:
	rm -f *.o

examine: 
	bfin-elf-objdump -d uartacqrxtest.elf
examine_crti:
	bfin-elf-objdump -d $(BFROOT)/lib/gcc/bfin-elf/$(BFROOTVER)/crti.o

examine_crtbegin:
	bfin-elf-objdump -d $(BFROOT)/lib/gcc/bfin-elf/$(BFROOTVER)/crtbegin.o

examine_crtend:
	bfin-elf-objdump -d $(BFROOT)/lib/gcc/bfin-elf/$(BFROOTVER)/crtend.o

ldr: uartacqrxtest.ldr

uartacqrxtest.ldr: uartacqrxtest.dxe
	rm -f uartacqrxtest.ldr
	bfin-elf-ldr -T BF533 -c -p f --gpio=1  uartacqrxtest.ldr uartacqrxtest.dxe
