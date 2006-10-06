VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/decoder/_behavioral.var: ../../vhdl/decoder.vhd
	$(VHDLC) ../../vhdl/decoder.vhd

hw: $(WORKDIR)/decoder/_behavioral.var 

comp: 

$(WORKDIR)/decodertest/_behavioral.var: decodertest.vhd
	$(VHDLC) decodertest.vhd

sim: $(WORKDIR)/decodertest/_behavioral.var 
runsim: all
	$(VHDLS) decodertest.vhd


clean:
	rm -Rf $(WORKDIR)$

