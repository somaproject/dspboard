VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/senddata/behavioral.dat: $(WORKDIR)/touched ../../vhdl/senddata.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/senddata.vhd

$(WORKDIR)/sendevent/behavioral.dat: $(WORKDIR)/touched ../../vhdl/senddata.vhd ../../vhdl/senddata.vhd ../../vhdl/sendevent.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/sendevent.vhd

$(WORKDIR)/devicemuxtx/behavioral.dat: $(WORKDIR)/touched ../../vhdl/senddata.vhd ../../vhdl/senddata.vhd ../../vhdl/sendevent.vhd ../../vhdl/sendevent.vhd ../../vhdl/devicemuxtx.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../../vhdl/devicemuxtx.vhd

hw: $(WORKDIR)/senddata/behavioral.dat $(WORKDIR)/sendevent/behavioral.dat $(WORKDIR)/devicemuxtx/behavioral.dat 

comp: 

$(WORKDIR)/devicemuxtxtest/behavioral.dat: $(WORKDIR)/touched devicemuxtxtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) devicemuxtxtest.vhd

sim: $(WORKDIR)/devicemuxtxtest/behavioral.dat 
runsim: all
	$(VHDLS) devicemuxtxtest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
