VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/regfile/behavioral.dat: $(WORKDIR)/touched ../../vhdl/regfile.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/regfile.vhd

$(WORKDIR)/eventrx/behavioral.dat: $(WORKDIR)/touched ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/eventrx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/eventrx.vhd

hw: $(WORKDIR)/regfile/behavioral.dat $(WORKDIR)/eventrx/behavioral.dat 

comp: 

$(WORKDIR)/eventrxtest/behavioral.dat: $(WORKDIR)/touched eventrxtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) eventrxtest.vhd

sim: $(WORKDIR)/eventrxtest/behavioral.dat 
runsim: all
	$(VHDLS) eventrxtest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
