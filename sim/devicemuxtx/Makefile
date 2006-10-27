VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/senddata/_behavioral.var: ../../vhdl/senddata.vhd
	$(VHDLC) ../../vhdl/senddata.vhd

$(WORKDIR)/sendevent/_behavioral.var: ../../vhdl/senddata.vhd ../../vhdl/sendevent.vhd
	$(VHDLC) ../../vhdl/sendevent.vhd

$(WORKDIR)/devicemuxtx/_behavioral.var: ../../vhdl/senddata.vhd ../../vhdl/sendevent.vhd ../../vhdl/devicemuxtx.vhd
	$(VHDLC) ../../vhdl/devicemuxtx.vhd

hw: $(WORKDIR)/senddata/_behavioral.var $(WORKDIR)/sendevent/_behavioral.var $(WORKDIR)/devicemuxtx/_behavioral.var 

comp: 

$(WORKDIR)/devicemuxtxtest/_behavioral.var: devicemuxtxtest.vhd
	$(VHDLC) devicemuxtxtest.vhd

sim: $(WORKDIR)/devicemuxtxtest/_behavioral.var 
runsim: all
	$(VHDLS) devicemuxtxtest


clean:
	rm -Rf $(WORKDIR)$

