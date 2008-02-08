VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/decodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/decodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/decodemux.vhd

hw: $(WORKDIR)/decodemux/behavioral.dat 

comp: 

$(WORKDIR)/decodemuxtext/behavioral.dat: $(WORKDIR)/touched decodemuxtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) decodemuxtest.vhd

sim: $(WORKDIR)/decodemuxtext/behavioral.dat 
runsim: all
	$(VHDLS) decodemuxtest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
