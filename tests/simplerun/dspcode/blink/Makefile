OBJS=Initialization.o ISRs.o main.o
SRCS=$(SRCS:%.o=%.c)
CFLAGS=-g

all: blink

.c.o:
	bfin-elf-gcc -c -mcpu=bf537 $(CFLAGS) $< -o $@

blink: $(OBJS)
	bfin-elf-gcc -o $@ -mcpu=bf537 $(OBJS)

clean:
	rm -f blink *.o *.i *.s
