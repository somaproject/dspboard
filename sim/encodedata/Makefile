VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/encodedata/behavioral.dat: $(WORKDIR)/touched ../../vhdl/encodedata.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/encodedata.vhd

hw: $(WORKDIR)/encodedata/behavioral.dat 

comp: 

$(WORKDIR)/encodedatatest/behavioral.dat: $(WORKDIR)/touched encodedatatest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) encodedatatest.vhd

sim: $(WORKDIR)/encodedatatest/behavioral.dat 
runsim: all
	$(VHDLS) encodedatatest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
