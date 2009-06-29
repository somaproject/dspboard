VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/encodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/encodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/encodemux.vhd

$(WORKDIR)/regfile/behavioral.dat: $(WORKDIR)/touched ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/regfile.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/regfile.vhd

$(WORKDIR)/eventrx/behavioral.dat: $(WORKDIR)/touched ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/eventrx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/eventrx.vhd

eproc/txreqbrambuffer/behavioral.dat: eproc/touched ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/eventrx.vhd ../../vhdl/eventrx.vhd ../../vhdl/eproc/vhdl/txreqbrambuffer.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/vhdl/txreqbrambuffer.vhd

hw: $(WORKDIR)/encodemux/behavioral.dat $(WORKDIR)/regfile/behavioral.dat $(WORKDIR)/eventrx/behavioral.dat eproc/txreqbrambuffer/behavioral.dat 

comp: 

$(WORKDIR)/encodemuxintegratetest/behavioral.dat: $(WORKDIR)/touched encodemuxintegratetest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) encodemuxintegratetest.vhd

sim: $(WORKDIR)/encodemuxintegratetest/behavioral.dat 
runsim: all
	$(VHDLS) encodemuxintegratetest


clean:
	rm -Rf eproc work 

eproc/touched:
	vlib  eproc
	touch  eproc/touched
work/touched:
	vlib  work
	touch  work/touched
