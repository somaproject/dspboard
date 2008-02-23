VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/bootser/behavioral.dat: $(WORKDIR)/touched ../../vhdl/bootser.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/bootser.vhd

hw: $(WORKDIR)/bootser/behavioral.dat 

comp: 

$(WORKDIR)/bootsertest/behavioral.dat: $(WORKDIR)/touched bootsertest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) bootsertest.vhd

sim: $(WORKDIR)/bootsertest/behavioral.dat 
runsim: all
	$(VHDLS) bootsertest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
