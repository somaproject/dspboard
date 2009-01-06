VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/uartbyteout/behavioral.dat: $(WORKDIR)/touched ../../vhdl/uartbyteout.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/uartbyteout.vhd

hw: $(WORKDIR)/uartbyteout/behavioral.dat 

comp: 

$(WORKDIR)/uartbyteouttest/behavioral.dat: $(WORKDIR)/touched uartbyteouttest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) uartbyteouttest.vhd

sim: $(WORKDIR)/uartbyteouttest/behavioral.dat 
runsim: all
	$(VHDLS) uartbyteouttest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
