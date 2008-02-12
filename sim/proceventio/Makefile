VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

soma/somabackplane/body.dat: soma/touched ../../vhdl/somabackplane.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/somabackplane.vhd

eproc/alu/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/alu.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/alu.vhd

eproc/regfile/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/alu.vhd ../../vhdl/eproc/regfile.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/regfile.vhd

eproc/ecore/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/alu.vhd ../../vhdl/eproc/regfile.vhd ../../vhdl/eproc/ecore.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/ecore.vhd

eproc/eventtx/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/alu.vhd ../../vhdl/eproc/regfile.vhd ../../vhdl/eproc/ecore.vhd ../../vhdl/eproc/eventtx.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/eventtx.vhd

eproc/evtdnd/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/alu.vhd ../../vhdl/eproc/regfile.vhd ../../vhdl/eproc/ecore.vhd ../../vhdl/eproc/eventtx.vhd ../../vhdl/eproc/evtdnd.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/evtdnd.vhd

eproc/txreqeventbuffer/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/alu.vhd ../../vhdl/eproc/regfile.vhd ../../vhdl/eproc/ecore.vhd ../../vhdl/eproc/eventtx.vhd ../../vhdl/eproc/evtdnd.vhd ../../vhdl/eproc/txreqeventbuffer.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/txreqeventbuffer.vhd

eproc/eproc/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/alu.vhd ../../vhdl/eproc/regfile.vhd ../../vhdl/eproc/ecore.vhd ../../vhdl/eproc/eventtx.vhd ../../vhdl/eproc/evtdnd.vhd ../../vhdl/eproc/txreqeventbuffer.vhd ../../vhdl/eproc/eproc.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/eproc.vhd

$(WORKDIR)/decodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/alu.vhd ../../vhdl/eproc/regfile.vhd ../../vhdl/eproc/ecore.vhd ../../vhdl/eproc/eventtx.vhd ../../vhdl/eproc/evtdnd.vhd ../../vhdl/eproc/txreqeventbuffer.vhd ../../vhdl/eproc/eproc.vhd ../../vhdl/decodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/decodemux.vhd

$(WORKDIR)/encodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/alu.vhd ../../vhdl/eproc/regfile.vhd ../../vhdl/eproc/ecore.vhd ../../vhdl/eproc/eventtx.vhd ../../vhdl/eproc/evtdnd.vhd ../../vhdl/eproc/txreqeventbuffer.vhd ../../vhdl/eproc/eproc.vhd ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/encodemux.vhd

$(WORKDIR)/dspcontproc/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/alu.vhd ../../vhdl/eproc/regfile.vhd ../../vhdl/eproc/ecore.vhd ../../vhdl/eproc/eventtx.vhd ../../vhdl/eproc/evtdnd.vhd ../../vhdl/eproc/txreqeventbuffer.vhd ../../vhdl/eproc/eproc.vhd ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/dspcontproc.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/dspcontproc.vhd

hw: soma/somabackplane/body.dat eproc/alu/behavioral.dat eproc/regfile/behavioral.dat eproc/ecore/behavioral.dat eproc/eventtx/behavioral.dat eproc/evtdnd/behavioral.dat eproc/txreqeventbuffer/behavioral.dat eproc/eproc/behavioral.dat $(WORKDIR)/decodemux/behavioral.dat $(WORKDIR)/encodemux/behavioral.dat $(WORKDIR)/dspcontproc/behavioral.dat 

comp: 

$(WORKDIR)/test_mem/body.dat: $(WORKDIR)/touched test_mem.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) test_mem.vhd

$(WORKDIR)/proceventiotest/behavioral.dat: $(WORKDIR)/touched test_mem.vhd proceventiotest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) proceventiotest.vhd

sim: $(WORKDIR)/test_mem/body.dat $(WORKDIR)/proceventiotest/behavioral.dat 
runsim: all
	$(VHDLS) proceventiotest


clean:
	rm -Rf soma eproc work 

soma/touched:
	vlib  soma
	touch  soma/touched
eproc/touched:
	vlib  eproc
	touch  eproc/touched
work/touched:
	vlib  work
	touch  work/touched
