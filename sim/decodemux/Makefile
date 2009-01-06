VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/decodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/decodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/decodemux.vhd

$(WORKDIR)/regfile/behavioral.dat: $(WORKDIR)/touched ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/regfile.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/regfile.vhd

hw: $(WORKDIR)/decodemux/behavioral.dat $(WORKDIR)/regfile/behavioral.dat 

comp: 

$(WORKDIR)/decodemuxtest/behavioral.dat: $(WORKDIR)/touched decodemuxtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) decodemuxtest.vhd

sim: $(WORKDIR)/decodemuxtest/behavioral.dat 
runsim: all
	$(VHDLS) decodemuxtest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
