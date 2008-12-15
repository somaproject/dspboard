VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/evtendianrev/behavioral.dat: $(WORKDIR)/touched ../../vhdl/evtendianrev.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/evtendianrev.vhd

hw: $(WORKDIR)/evtendianrev/behavioral.dat 

comp: 

$(WORKDIR)/evtendianrevtest/behavioral.dat: $(WORKDIR)/touched evtendianrevtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) evtendianrevtest.vhd

sim: $(WORKDIR)/evtendianrevtest/behavioral.dat 
runsim: all
	$(VHDLS) evtendianrevtest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
