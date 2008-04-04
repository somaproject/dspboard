VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/uartacqrx/behavioral.dat: $(WORKDIR)/touched ../../vhdl/uartacqrx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/uartacqrx.vhd

hw: $(WORKDIR)/uartacqrx/behavioral.dat 

comp: 

$(WORKDIR)/uartacqrxtest/behavioral.dat: $(WORKDIR)/touched uartacqrxtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) uartacqrxtest.vhd

sim: $(WORKDIR)/uartacqrxtest/behavioral.dat 
runsim: all
	$(VHDLS) uartacqrxtest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
