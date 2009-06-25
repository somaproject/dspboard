VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/encodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/encodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/encodemux.vhd

eproc/txreqbrambuffer/behavioral.dat: eproc/touched ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/eproc/vhdl/txreqbrambuffer.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/vhdl/txreqbrambuffer.vhd

hw: $(WORKDIR)/encodemux/behavioral.dat eproc/txreqbrambuffer/behavioral.dat 

comp: 

$(WORKDIR)/encodemuxtest/behavioral.dat: $(WORKDIR)/touched encodemuxtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) encodemuxtest.vhd

sim: $(WORKDIR)/encodemuxtest/behavioral.dat 
runsim: all
	$(VHDLS) encodemuxtest


clean:
	rm -Rf eproc work 

eproc/touched:
	vlib  eproc
	touch  eproc/touched
work/touched:
	vlib  work
	touch  work/touched
