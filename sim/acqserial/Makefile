VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/fiberrx/_behavioral.var: ../../vhdl/fiberrx.vhd
	$(VHDLC) ../../vhdl/fiberrx.vhd

$(WORKDIR)/framedis/_behavioral.var: ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd
	$(VHDLC) ../../vhdl/framedis.vhd

$(WORKDIR)/sportacqser/_behavioral.var: ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd
	$(VHDLC) ../../vhdl/sportacqser.vhd

$(WORKDIR)/acqcmdmux/_behavioral.var: ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd ../../vhdl/acqcmdmux.vhd
	$(VHDLC) ../../vhdl/acqcmdmux.vhd

$(WORKDIR)/fibertx/_behavioral.var: ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd ../../vhdl/acqcmdmux.vhd ../../vhdl/fibertx.vhd
	$(VHDLC) ../../vhdl/fibertx.vhd

$(WORKDIR)/acqserial/_behavioral.var: ../../vhdl/fiberrx.vhd ../../vhdl/framedis.vhd ../../vhdl/sportacqser.vhd ../../vhdl/acqcmdmux.vhd ../../vhdl/fibertx.vhd ../../vhdl/acqserial.vhd
	$(VHDLC) ../../vhdl/acqserial.vhd

hw: $(WORKDIR)/fiberrx/_behavioral.var $(WORKDIR)/framedis/_behavioral.var $(WORKDIR)/sportacqser/_behavioral.var $(WORKDIR)/acqcmdmux/_behavioral.var $(WORKDIR)/fibertx/_behavioral.var $(WORKDIR)/acqserial/_behavioral.var 

$(WORKDIR)/decode8b10b/_decode8b10b_a.var: decode8b10b.vhd
	$(VHDLC) decode8b10b.vhd

$(WORKDIR)/encode8b10b/_encode8b10b_a.var: decode8b10b.vhd encode8b10b.vhd
	$(VHDLC) encode8b10b.vhd

$(WORKDIR)/acqclocks/_behavioral.var: decode8b10b.vhd encode8b10b.vhd ../components/acqboard/acqclocks.vhd
	$(VHDLC) ../components/acqboard/acqclocks.vhd

$(WORKDIR)/acqfiberrx/_behavioral.var: decode8b10b.vhd encode8b10b.vhd ../components/acqboard/acqclocks.vhd ../components/acqboard/acqfiberrx.vhd
	$(VHDLC) ../components/acqboard/acqfiberrx.vhd

$(WORKDIR)/acqfibertx/_behavioral.var: decode8b10b.vhd encode8b10b.vhd ../components/acqboard/acqclocks.vhd ../components/acqboard/acqfiberrx.vhd ../components/acqboard/acqfibertx.vhd
	$(VHDLC) ../components/acqboard/acqfibertx.vhd

$(WORKDIR)/acqdecoder/_behavioral.var: decode8b10b.vhd encode8b10b.vhd ../components/acqboard/acqclocks.vhd ../components/acqboard/acqfiberrx.vhd ../components/acqboard/acqfibertx.vhd ../components/acqboard/acqdecoder.vhd
	$(VHDLC) ../components/acqboard/acqdecoder.vhd

$(WORKDIR)/acqboard/_behavioral.var: decode8b10b.vhd encode8b10b.vhd ../components/acqboard/acqclocks.vhd ../components/acqboard/acqfiberrx.vhd ../components/acqboard/acqfibertx.vhd ../components/acqboard/acqdecoder.vhd ../components/acqboard/acqboard.vhd
	$(VHDLC) ../components/acqboard/acqboard.vhd

comp: $(WORKDIR)/decode8b10b/_decode8b10b_a.var $(WORKDIR)/encode8b10b/_encode8b10b_a.var $(WORKDIR)/acqclocks/_behavioral.var $(WORKDIR)/acqfiberrx/_behavioral.var $(WORKDIR)/acqfibertx/_behavioral.var $(WORKDIR)/acqdecoder/_behavioral.var $(WORKDIR)/acqboard/_behavioral.var 

$(WORKDIR)/acqserialtest/_behavioral.var: decode8b10b.vhd encode8b10b.vhd ../components/acqboard/acqclocks.vhd ../components/acqboard/acqfiberrx.vhd ../components/acqboard/acqfibertx.vhd ../components/acqboard/acqdecoder.vhd ../components/acqboard/acqboard.vhd acqserialtest.vhd
	$(VHDLC) acqserialtest.vhd

sim: $(WORKDIR)/acqserialtest/_behavioral.var 
runsim: all
	$(VHDLS) acqserialtest


clean:
	rm -Rf $(WORKDIR)$

