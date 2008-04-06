VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/uartbyteout/behavioral.dat: $(WORKDIR)/touched ../../vhdl/uartbyteout.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/uartbyteout.vhd

hw: $(WORKDIR)/uartbyteout/behavioral.dat 

comp: 

$(WORKDIR)/uartacqrxtest/behavioral.dat: $(WORKDIR)/touched uartouttest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) uartouttest.vhd

sim: $(WORKDIR)/uartacqrxtest/behavioral.dat 
runsim: all
	$(VHDLS) uartouttest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
