VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/fiberrx/behavioral.dat: $(WORKDIR)/touched ../../vhdl/fiberrx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/fiberrx.vhd

$(WORKDIR)/framedis/behavioral.dat: $(WORKDIR)/touched ../../vhdl/fiberrx.vhd ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/framedis.vhd

$(WORKDIR)/sportacqser/behavioral.dat: $(WORKDIR)/touched ../../vhdl/fiberrx.vhd ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/sportacqser.vhd

$(WORKDIR)/sportacqrx/behavioral.dat: $(WORKDIR)/touched ../../vhdl/fiberrx.vhd ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqrx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/sportacqrx.vhd

$(WORKDIR)/regfile/behavioral.dat: $(WORKDIR)/touched ../../vhdl/fiberrx.vhd ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/regfile.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/regfile.vhd

$(WORKDIR)/acqcmdmux/behavioral.dat: $(WORKDIR)/touched ../../vhdl/fiberrx.vhd ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/acqcmdmux.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/acqcmdmux.vhd

$(WORKDIR)/fibertx/behavioral.dat: $(WORKDIR)/touched ../../vhdl/fiberrx.vhd ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/acqcmdmux.vhd ../../vhdl/acqcmdmux.vhd ../../vhdl/fibertx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/fibertx.vhd

$(WORKDIR)/acqserial/behavioral.dat: $(WORKDIR)/touched ../../vhdl/fiberrx.vhd ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/acqcmdmux.vhd ../../vhdl/acqcmdmux.vhd ../../vhdl/fibertx.vhd ../../vhdl/fibertx.vhd ../../vhdl/acqserial.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/acqserial.vhd

$(WORKDIR)/uartacqrx/behavioral.dat: $(WORKDIR)/touched ../../vhdl/fiberrx.vhd ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/acqcmdmux.vhd ../../vhdl/acqcmdmux.vhd ../../vhdl/fibertx.vhd ../../vhdl/fibertx.vhd ../../vhdl/acqserial.vhd ../../vhdl/acqserial.vhd ../../vhdl/uartacqrx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/uartacqrx.vhd
