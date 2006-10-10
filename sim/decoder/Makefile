VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/fiberrx/_behavioral.var: ../../vhdl/fiberrx.vhd
	$(VHDLC) ../../vhdl/fiberrx.vhd

hw: $(WORKDIR)/fiberrx/_behavioral.var 

comp: 

$(WORKDIR)/fiberrxtest/_behavioral.var: fiberrxtest.vhd
	$(VHDLC) fiberrxtest.vhd

sim: $(WORKDIR)/fiberrxtest/_behavioral.var 
runsim: all
	$(VHDLS) fiberrxtest.vhd


clean:
	rm -Rf $(WORKDIR)$

