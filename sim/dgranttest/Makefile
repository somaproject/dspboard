VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/decodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/decodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/decodemux.vhd

$(WORKDIR)/encodemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/encodemux.vhd

$(WORKDIR)/datamux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/datamux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/datamux.vhd

$(WORKDIR)/datasport/behavioral.dat: $(WORKDIR)/touched ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/datamux.vhd ../../vhdl/datamux.vhd ../../vhdl/datasport.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/datasport.vhd

soma/somabackplane/body.dat: soma/touched ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/datamux.vhd ../../vhdl/datamux.vhd ../../vhdl/datasport.vhd ../../vhdl/datasport.vhd ../../../backplane/vhdl/somabackplane.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../backplane/vhdl/somabackplane.vhd

$(WORKDIR)/regfile/behavioral.dat: $(WORKDIR)/touched ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/datamux.vhd ../../vhdl/datamux.vhd ../../vhdl/datasport.vhd ../../vhdl/datasport.vhd ../../../backplane/vhdl/somabackplane.vhd ../../../backplane/vhdl/coredevicemux/regfile.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../backplane/vhdl/coredevicemux/regfile.vhd

$(WORKDIR)/devicemuxeventrx2/behavioral.dat: $(WORKDIR)/touched ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/datamux.vhd ../../vhdl/datamux.vhd ../../vhdl/datasport.vhd ../../vhdl/datasport.vhd ../../../backplane/vhdl/somabackplane.vhd ../../../backplane/vhdl/coredevicemux/regfile.vhd ../../../backplane/vhdl/coredevicemux/regfile.vhd ../../../backplane/vhdl/coredevicemux/devicemuxeventrx2.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../backplane/vhdl/coredevicemux/devicemuxeventrx2.vhd

$(WORKDIR)/devicemuxtx/behavioral.dat: $(WORKDIR)/touched ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/datamux.vhd ../../vhdl/datamux.vhd ../../vhdl/datasport.vhd ../../vhdl/datasport.vhd ../../../backplane/vhdl/somabackplane.vhd ../../../backplane/vhdl/coredevicemux/regfile.vhd ../../../backplane/vhdl/coredevicemux/regfile.vhd ../../../backplane/vhdl/coredevicemux/devicemuxeventrx2.vhd ../../../backplane/vhdl/coredevicemux/devicemuxeventrx2.vhd ../../../backplane/vhdl/coredevicemux/devicemuxtx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../backplane/vhdl/coredevicemux/devicemuxtx.vhd

$(WORKDIR)/devicemuxrx/behavioral.dat: $(WORKDIR)/touched ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/datamux.vhd ../../vhdl/datamux.vhd ../../vhdl/datasport.vhd ../../vhdl/datasport.vhd ../../../backplane/vhdl/somabackplane.vhd ../../../backplane/vhdl/coredevicemux/regfile.vhd ../../../backplane/vhdl/coredevicemux/regfile.vhd ../../../backplane/vhdl/coredevicemux/devicemuxeventrx2.vhd ../../../backplane/vhdl/coredevicemux/devicemuxeventrx2.vhd ../../../backplane/vhdl/coredevicemux/devicemuxtx.vhd ../../../backplane/vhdl/coredevicemux/devicemuxtx.vhd ../../../backplane/vhdl/coredevicemux/devicemuxrx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../backplane/vhdl/coredevicemux/devicemuxrx.vhd

$(WORKDIR)/devicemux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/datamux.vhd ../../vhdl/datamux.vhd ../../vhdl/datasport.vhd ../../vhdl/datasport.vhd ../../../backplane/vhdl/somabackplane.vhd ../../../backplane/vhdl/coredevicemux/regfile.vhd ../../../backplane/vhdl/coredevicemux/regfile.vhd ../../../backplane/vhdl/coredevicemux/devicemuxeventrx2.vhd ../../../backplane/vhdl/coredevicemux/devicemuxeventrx2.vhd ../../../backplane/vhdl/coredevicemux/devicemuxtx.vhd ../../../backplane/vhdl/coredevicemux/devicemuxtx.vhd ../../../backplane/vhdl/coredevicemux/devicemuxrx.vhd ../../../backplane/vhdl/coredevicemux/devicemuxrx.vhd ../../../backplane/vhdl/coredevicemux/devicemux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../../backplane/vhdl/coredevicemux/devicemux.vhd

soma/datarouter/behavioral.dat: soma/touched ../../vhdl/decodemux.vhd ../../vhdl/decodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/encodemux.vhd ../../vhdl/datamux.vhd ../../vhdl/datamux.vhd ../../vhdl/datasport.vhd ../../vhdl/datasport.vhd ../../../backplane/vhdl/somabackplane.vhd ../../../backplane/vhdl/coredevicemux/regfile.vhd ../../../backplane/vhdl/coredevicemux/regfile.vhd ../../../backplane/vhdl/coredevicemux/devicemuxeventrx2.vhd ../../../backplane/vhdl/coredevicemux/devicemuxeventrx2.vhd ../../../backplane/vhdl/coredevicemux/devicemuxtx.vhd ../../../backplane/vhdl/coredevicemux/devicemuxtx.vhd ../../../backplane/vhdl/coredevicemux/devicemuxrx.vhd ../../../backplane/vhdl/coredevicemux/devicemuxrx.vhd ../../../backplane/vhdl/coredevicemux/devicemux.vhd ../../../backplane/vhdl/coredevicemux/devicemux.vhd ../../../backplane/vhdl/core/datarouter.vhd
	mkdir -p soma
	$(VHDLC) -work soma  ../../../backplane/vhdl/core/datarouter.vhd

hw: $(WORKDIR)/decodemux/behavioral.dat $(WORKDIR)/encodemux/behavioral.dat $(WORKDIR)/datamux/behavioral.dat $(WORKDIR)/datasport/behavioral.dat soma/somabackplane/body.dat $(WORKDIR)/regfile/behavioral.dat $(WORKDIR)/devicemuxeventrx2/behavioral.dat $(WORKDIR)/devicemuxtx/behavioral.dat $(WORKDIR)/devicemuxrx/behavioral.dat $(WORKDIR)/devicemux/behavioral.dat soma/datarouter/behavioral.dat 

$(WORKDIR)/fakesport/behavioral.dat: $(WORKDIR)/touched fakesport.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) fakesport.vhd

$(WORKDIR)/fakebackplane/behavioral.dat: $(WORKDIR)/touched fakesport.vhd fakebackplane.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) fakebackplane.vhd

comp: $(WORKDIR)/fakesport/behavioral.dat $(WORKDIR)/fakebackplane/behavioral.dat 

$(WORKDIR)/dgranttest/behavioral.dat: $(WORKDIR)/touched fakesport.vhd fakebackplane.vhd dgranttest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) dgranttest.vhd

sim: $(WORKDIR)/dgranttest/behavioral.dat 
runsim: all
	$(VHDLS) dgranttest


clean:
	rm -Rf soma work 

soma/touched:
	vlib  soma
	touch  soma/touched
work/touched:
	vlib  work
	touch  work/touched
