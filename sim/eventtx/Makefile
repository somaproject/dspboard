VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/eventfilter/_behavioral.var: ../../vhdl/eventfilter.vhd
	$(VHDLC) ../../vhdl/eventfilter.vhd

$(WORKDIR)/eventtx/_behavioral.var: ../../vhdl/eventfilter.vhd ../../vhdl/eventtx.vhd
	$(VHDLC) ../../vhdl/eventtx.vhd

hw: $(WORKDIR)/eventfilter/_behavioral.var $(WORKDIR)/eventtx/_behavioral.var 

comp: 

$(WORKDIR)/eventtxtest/_behavioral.var: eventtxtest.vhd
	$(VHDLC) eventtxtest.vhd

sim: $(WORKDIR)/eventtxtest/_behavioral.var 
runsim: all
	$(VHDLS) eventtxtest


clean:
	rm -Rf $(WORKDIR)$

