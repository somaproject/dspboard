VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/datasport/_behavioral.var: ../../vhdl/datasport.vhd
	$(VHDLC) ../../vhdl/datasport.vhd

hw: $(WORKDIR)/datasport/_behavioral.var 

comp: 

$(WORKDIR)/datasporttest/_behavioral.var: datasporttest.vhd
	$(VHDLC) datasporttest.vhd

sim: $(WORKDIR)/datasporttest/_behavioral.var 
runsim: all
	$(VHDLS) datasporttest


clean:
	rm -Rf $(WORKDIR)$

