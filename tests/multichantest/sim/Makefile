VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/multichanneltest/_behavioral.var: ../vhdl/multichanneltest.vhd
	$(VHDLC) ../vhdl/multichanneltest.vhd

hw: $(WORKDIR)/multichanneltest/_behavioral.var 

comp: 

$(WORKDIR)/multichantesttest/_behavioral.var: multichantesttest.vhd
	$(VHDLC) multichantesttest.vhd

sim: $(WORKDIR)/multichantesttest/_behavioral.var 
runsim: all
	$(VHDLS) multichantesttest


clean:
	rm -Rf $(WORKDIR)$

