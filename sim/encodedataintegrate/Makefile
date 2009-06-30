VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/encodedata/behavioral.dat: $(WORKDIR)/touched ../../vhdl/encodedata.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/encodedata.vhd

$(WORKDIR)/datamux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/encodedata.vhd ../../vhdl/encodedata.vhd ../../vhdl/datamux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/datamux.vhd

$(WORKDIR)/encodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/encodedata.vhd ../../vhdl/encodedata.vhd ../../vhdl/datamux.vhd ../../vhdl/datamux.vhd ../../vhdl/encodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/encodemux.vhd

hw: $(WORKDIR)/encodedata/behavioral.dat $(WORKDIR)/datamux/behavioral.dat $(WORKDIR)/encodemux/behavioral.dat 

comp: 

$(WORKDIR)/encodedataintegratetest/behavioral.dat: $(WORKDIR)/touched encodedataintegratetest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) encodedataintegratetest.vhd

sim: $(WORKDIR)/encodedataintegratetest/behavioral.dat 
runsim: all
	$(VHDLS) encodedataintegratetest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
