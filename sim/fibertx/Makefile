VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/fibertx/_behavioral.var: ../../vhdl/fibertx.vhd
	$(VHDLC) ../../vhdl/fibertx.vhd

hw: $(WORKDIR)/fibertx/_behavioral.var 

comp: 

$(WORKDIR)/fibertxtest/_behavioral.var: fibertxtest.vhd
	$(VHDLC) fibertxtest.vhd

$(WORKDIR)/fiberrx/_behavioral.var: fibertxtest.vhd ../../vhdl/fiberrx.vhd
	$(VHDLC) ../../vhdl/fiberrx.vhd

sim: $(WORKDIR)/fibertxtest/_behavioral.var $(WORKDIR)/fiberrx/_behavioral.var 
runsim: all
	$(VHDLS) fibertxtest.vhd


clean:
	rm -Rf $(WORKDIR)$

