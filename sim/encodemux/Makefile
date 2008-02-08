VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/encodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/encodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/encodemux.vhd

hw: $(WORKDIR)/encodemux/behavioral.dat 

comp: 

$(WORKDIR)/encodemuxtest/behavioral.dat: $(WORKDIR)/touched encodemuxtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) encodemuxtest.vhd

sim: $(WORKDIR)/encodemuxtest/behavioral.dat 
runsim: all
	$(VHDLS) encodemuxtest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
