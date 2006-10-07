VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/spitest/_behavioral.var: ../vhdl/spitest.vhd
	$(VHDLC) ../vhdl/spitest.vhd

hw: $(WORKDIR)/spitest/_behavioral.var 

comp: 

$(WORKDIR)/spitesttest/_behavioral.var: spitesttest.vhd
	$(VHDLC) spitesttest.vhd

sim: $(WORKDIR)/spitesttest/_behavioral.var 
runsim: all
	$(VHDLS) spitesttest


clean:
	rm -Rf $(WORKDIR)$

