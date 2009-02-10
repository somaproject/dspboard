VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim always

soma/somabackplane/body.dat: soma/touched ../../vhdl/somabackplane.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../vhdl/somabackplane.vhd

eproc/alu/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/vhdl/alu.vhd

eproc/regfile/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd ../../vhdl/eproc/vhdl/regfile.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/vhdl/regfile.vhd

eproc/ecore/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd ../../vhdl/eproc/vhdl/regfile.vhd ../../vhdl/eproc/vhdl/ecore.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/vhdl/ecore.vhd

eproc/eventtx/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd ../../vhdl/eproc/vhdl/regfile.vhd ../../vhdl/eproc/vhdl/ecore.vhd ../../vhdl/eproc/vhdl/eventtx.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/vhdl/eventtx.vhd

eproc/evtdnd/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd ../../vhdl/eproc/vhdl/regfile.vhd ../../vhdl/eproc/vhdl/ecore.vhd ../../vhdl/eproc/vhdl/eventtx.vhd ../../vhdl/eproc/vhdl/evtdnd.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/vhdl/evtdnd.vhd

eproc/txreqeventbuffer/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd ../../vhdl/eproc/vhdl/regfile.vhd ../../vhdl/eproc/vhdl/ecore.vhd ../../vhdl/eproc/vhdl/eventtx.vhd ../../vhdl/eproc/vhdl/evtdnd.vhd ../../vhdl/eproc/vhdl/txreqeventbuffer.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/vhdl/txreqeventbuffer.vhd

eproc/txreqbrambuffer/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd ../../vhdl/eproc/vhdl/regfile.vhd ../../vhdl/eproc/vhdl/ecore.vhd ../../vhdl/eproc/vhdl/eventtx.vhd ../../vhdl/eproc/vhdl/evtdnd.vhd ../../vhdl/eproc/vhdl/txreqeventbuffer.vhd ../../vhdl/eproc/vhdl/txreqbrambuffer.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/vhdl/txreqbrambuffer.vhd

eproc/eproc/behavioral.dat: eproc/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd ../../vhdl/eproc/vhdl/regfile.vhd ../../vhdl/eproc/vhdl/ecore.vhd ../../vhdl/eproc/vhdl/eventtx.vhd ../../vhdl/eproc/vhdl/evtdnd.vhd ../../vhdl/eproc/vhdl/txreqeventbuffer.vhd ../../vhdl/eproc/vhdl/txreqbrambuffer.vhd ../../vhdl/eproc/vhdl/eproc.vhd
	mkdir -p eproc
	$(VHDLC) -work eproc  ../../vhdl/eproc/vhdl/eproc.vhd

$(WORKDIR)/bootser/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd ../../vhdl/eproc/vhdl/regfile.vhd ../../vhdl/eproc/vhdl/ecore.vhd ../../vhdl/eproc/vhdl/eventtx.vhd ../../vhdl/eproc/vhdl/evtdnd.vhd ../../vhdl/eproc/vhdl/txreqeventbuffer.vhd ../../vhdl/eproc/vhdl/txreqbrambuffer.vhd ../../vhdl/eproc/vhdl/eproc.vhd ../../vhdl/bootser.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/bootser.vhd

$(WORKDIR)/decodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd ../../vhdl/eproc/vhdl/regfile.vhd ../../vhdl/eproc/vhdl/ecore.vhd ../../vhdl/eproc/vhdl/eventtx.vhd ../../vhdl/eproc/vhdl/evtdnd.vhd ../../vhdl/eproc/vhdl/txreqeventbuffer.vhd ../../vhdl/eproc/vhdl/txreqbrambuffer.vhd ../../vhdl/eproc/vhdl/eproc.vhd ../../vhdl/bootser.vhd ../../vhdl/bootser.vhd ../../vhdl/decodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/decodemux.vhd

$(WORKDIR)/encodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd ../../vhdl/eproc/vhdl/regfile.vhd ../../vhdl/eproc/vhdl/ecore.vhd ../../vhdl/eproc/vhdl/eventtx.vhd ../../vhdl/eproc/vhdl/evtdnd.vhd ../../vhdl/eproc/vhdl/txreqeventbuffer.vhd ../../vhdl/eproc/vhdl/txreqbrambuffer.vhd ../../vhdl/eproc/vhdl/eproc.vhd ../../vhdl/bootser.vhd ../../vhdl/bootser.vhd ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/encodemux.vhd

$(WORKDIR)/regfile/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd ../../vhdl/eproc/vhdl/regfile.vhd ../../vhdl/eproc/vhdl/ecore.vhd ../../vhdl/eproc/vhdl/eventtx.vhd ../../vhdl/eproc/vhdl/evtdnd.vhd ../../vhdl/eproc/vhdl/txreqeventbuffer.vhd ../../vhdl/eproc/vhdl/txreqbrambuffer.vhd ../../vhdl/eproc/vhdl/eproc.vhd ../../vhdl/bootser.vhd ../../vhdl/bootser.vhd ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/regfile.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/regfile.vhd

$(WORKDIR)/dspcontproc/behavioral.dat: $(WORKDIR)/touched ../../vhdl/somabackplane.vhd ../../vhdl/eproc/vhdl/alu.vhd ../../vhdl/eproc/vhdl/regfile.vhd ../../vhdl/eproc/vhdl/ecore.vhd ../../vhdl/eproc/vhdl/eventtx.vhd ../../vhdl/eproc/vhdl/evtdnd.vhd ../../vhdl/eproc/vhdl/txreqeventbuffer.vhd ../../vhdl/eproc/vhdl/txreqbrambuffer.vhd ../../vhdl/eproc/vhdl/eproc.vhd ../../vhdl/bootser.vhd ../../vhdl/bootser.vhd ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/dspcontproc.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/dspcontproc.vhd

hw: soma/somabackplane/body.dat eproc/alu/behavioral.dat eproc/regfile/behavioral.dat eproc/ecore/behavioral.dat eproc/eventtx/behavioral.dat eproc/evtdnd/behavioral.dat eproc/txreqeventbuffer/behavioral.dat eproc/txreqbrambuffer/behavioral.dat eproc/eproc/behavioral.dat $(WORKDIR)/bootser/behavioral.dat $(WORKDIR)/decodemux/behavioral.dat $(WORKDIR)/encodemux/behavioral.dat $(WORKDIR)/regfile/behavioral.dat $(WORKDIR)/dspcontproc/behavioral.dat 

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
always:
	#python ../../../backplane/eproc/assemble/assemble.py ../../vhdl/netcontrol/netcontrol.asmpy netcontrol.imem
	#python ../../../backplane/eproc/assemble/genrom.py netcontroltest.bmm netcontrol.imem
