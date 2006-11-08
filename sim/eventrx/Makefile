VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/eventrx/_behavioral.var: ../../vhdl/eventrx.vhd
	$(VHDLC) ../../vhdl/eventrx.vhd

hw: $(WORKDIR)/eventrx/_behavioral.var 

comp: 

$(WORKDIR)/eventrxtest/_behavioral.var: eventrxtest.vhd
	$(VHDLC) eventrxtest.vhd

sim: $(WORKDIR)/eventrxtest/_behavioral.var 
runsim: all
	$(VHDLS) eventrxtest


clean:
	rm -Rf $(WORKDIR)$

