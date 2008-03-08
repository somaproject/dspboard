VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/datasport/behavioral.dat: $(WORKDIR)/touched ../../vhdl/datasport.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/datasport.vhd

hw: $(WORKDIR)/datasport/behavioral.dat 

comp: 

$(WORKDIR)/datasporttest/behavioral.dat: $(WORKDIR)/touched datasporttest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) datasporttest.vhd

sim: $(WORKDIR)/datasporttest/behavioral.dat 
runsim: all
	$(VHDLS) datasporttest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
