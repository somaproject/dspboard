# Makefile for SPI test. 
#
# based off of Blink example via:
# 11/2004 Martin Strubel <hackfin@section5.ch>


ASMSRCS = crt0.asm 
CCSRCS   = main.cc

CPUDEFINES = -D__ADSPBF561__ -D__ADSPLPBLACKFIN__
INCLUDES = -I../../../dspcode/include -I. 
ASMFLAGS = -x assembler-with-cpp $(CPUDEFINES) $(INCLUDES)
ASMFLAGS += -DBOARD_$(BOARD) -g 
CFLAGS = $(INCLUDES) -g -DBOARD_$(BOARD) 
CFLAGS += $(CPUDEFINES) 

BOARD=STAMP_BF533

LDFLAGS =  -g -T bftiny.x  -L/opt/uClinux/bfin-elf/lib/ -L/opt/uClinux/bfin-elf/lib/gcc/bfin-elf/4.1.0/ 

OBJS = $(ASMSRCS:%.asm=%.o) $(CCSRCS:%.cc=%.o)

AS = bfin-elf-as
CC = bfin-elf-gcc-4.1.0
CXX = bfin-elf-g++-4.1.0

LD = bfin-elf-ld

all: $(OBJS) spitest.elf

main.o: main.cc
	$(CXX) $(CFLAGS)  -c -o main.o main.cc
%.o: %.asm
	$(CC) $(ASMFLAGS) -c -o $@ $<


spitest.elf: $(OBJS)
	$(LD) $(OBJS)  $(LDFLAGS) -o spitest.elf

clean:
	rm -f *.o


