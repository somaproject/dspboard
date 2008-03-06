VHDLC=vcom
VHDLS=vsim
WORKDIR=work
all: hw comp sim

$(WORKDIR)/eventtxtest/behavioral.dat: $(WORKDIR)/touched ../vhdl/eventtxtest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) ../vhdl/eventtxtest.vhd

hw: $(WORKDIR)/eventtxtest/behavioral.dat 

comp: 

$(WORKDIR)/eventtxtesttest/behavioral.dat: $(WORKDIR)/touched eventtxtesttest.vhd
	mkdir -p $(WORKDIR)
	$(VHDLC) eventtxtesttest.vhd

sim: $(WORKDIR)/eventtxtesttest/behavioral.dat 
runsim: all
	$(VHDLS) eventtxtesttest


clean:
	rm -Rf work 

work/touched:
	vlib  work
	touch  work/touched
