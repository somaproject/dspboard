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

$(WORKDIR)/fiberdecode8b10b/fiberdecode8b10b_a.dat: $(WORKDIR)/touched ../../vhdl/fiberrx.vhd ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/acqcmdmux.vhd ../../vhdl/acqcmdmux.vhd ../../vhdl/fibertx.vhd ../../vhdl/fibertx.vhd ../../vhdl/acqserial.vhd ../../vhdl/acqserial.vhd ../../vhdl/uartacqrx.vhd ../../vhdl/uartacqrx.vhd fiberdecode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) fiberdecode8b10b.vhd

$(WORKDIR)/fiberencode8b10b/fiberencode8b10b_a.dat: $(WORKDIR)/touched ../../vhdl/fiberrx.vhd ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqser.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/sportacqrx.vhd ../../vhdl/regfile.vhd ../../vhdl/regfile.vhd ../../vhdl/acqcmdmux.vhd ../../vhdl/acqcmdmux.vhd ../../vhdl/fibertx.vhd ../../vhdl/fibertx.vhd ../../vhdl/acqserial.vhd ../../vhdl/acqserial.vhd ../../vhdl/uartacqrx.vhd ../../vhdl/uartacqrx.vhd fiberdecode8b10b.vhd fiberdecode8b10b.vhd fiberencode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) fiberencode8b10b.vhd

hw: $(WORKDIR)/fiberrx/behavioral.dat $(WORKDIR)/framedis/behavioral.dat $(WORKDIR)/sportacqser/behavioral.dat $(WORKDIR)/sportacqrx/behavioral.dat $(WORKDIR)/regfile/behavioral.dat $(WORKDIR)/acqcmdmux/behavioral.dat $(WORKDIR)/fibertx/behavioral.dat $(WORKDIR)/acqserial/behavioral.dat $(WORKDIR)/uartacqrx/behavioral.dat $(WORKDIR)/fiberdecode8b10b/fiberdecode8b10b_a.dat $(WORKDIR)/fiberencode8b10b/fiberencode8b10b_a.dat 

$(WORKDIR)/encode8b10b/encode8b10b_a.dat: $(WORKDIR)/touched encode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) encode8b10b.vhd

$(WORKDIR)/decode8b10b/decode8b10b_a.dat: $(WORKDIR)/touched encode8b10b.vhd decode8b10b.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) decode8b10b.vhd

$(WORKDIR)/acqclocks/behavioral.dat: $(WORKDIR)/touched encode8b10b.vhd decode8b10b.vhd ../components/acqboard/acqclocks.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../components/acqboard/acqclocks.vhd

$(WORKDIR)/Acqfiberrx/behavioral.dat: $(WORKDIR)/touched encode8b10b.vhd decode8b10b.vhd ../components/acqboard/acqclocks.vhd ../components/acqboard/acqfiberrx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../components/acqboard/acqfiberrx.vhd

$(WORKDIR)/acqfibertx/behavioral.dat: $(WORKDIR)/touched encode8b10b.vhd decode8b10b.vhd ../components/acqboard/acqclocks.vhd ../components/acqboard/acqfiberrx.vhd ../components/acqboard/acqfibertx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../components/acqboard/acqfibertx.vhd

$(WORKDIR)/acqdecoder/behavioral.dat: $(WORKDIR)/touched encode8b10b.vhd decode8b10b.vhd ../components/acqboard/acqclocks.vhd ../components/acqboard/acqfiberrx.vhd ../components/acqboard/acqfibertx.vhd ../components/acqboard/acqdecoder.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../components/acqboard/acqdecoder.vhd

$(WORKDIR)/acqboard/behavioral.dat: $(WORKDIR)/touched encode8b10b.vhd decode8b10b.vhd ../components/acqboard/acqclocks.vhd ../components/acqboard/acqfiberrx.vhd ../components/acqboard/acqfibertx.vhd ../components/acqboard/acqdecoder.vhd ../components/acqboard/acqboard.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../components/acqboard/acqboard.vhd

comp: $(WORKDIR)/encode8b10b/encode8b10b_a.dat $(WORKDIR)/decode8b10b/decode8b10b_a.dat $(WORKDIR)/acqclocks/behavioral.dat $(WORKDIR)/Acqfiberrx/behavioral.dat $(WORKDIR)/acqfibertx/behavioral.dat $(WORKDIR)/acqdecoder/behavioral.dat $(WORKDIR)/acqboard/behavioral.dat 

$(WORKDIR)/acqserialtest/behavioral.dat: $(WORKDIR)/touched encode8b10b.vhd decode8b10b.vhd ../components/acqboard/acqclocks.vhd ../components/acqboard/acqfiberrx.vhd ../components/acqboard/acqfibertx.vhd ../components/acqboard/acqdecoder.vhd ../components/acqboard/acqboard.vhd acqserialtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) acqserialtest.vhd

sim: $(WORKDIR)/acqserialtest/behavioral.dat 
runsim: all
	$(VHDLS) acqserialtest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
