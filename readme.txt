Notes for DSPboard design

Here, we will be using the new ADSP-21262 200 MHz floating-point DSPs
running at 200 MHz. 
A Spartan-IIE-50 FPGA connected to the system bus
2 DSPs
fiber interfaces

Now, the event bus and system busses run at 20 MHz. 
The DSPs need a 25 MHz clock
The fiber interface requirers an 8 MHz clock. 

We can drive the FPGA with a 50 MHz clock. CLK/2 can be sent to the DSPs, which at 8x gives us 200 MHz. 
The FPGA can also have a 40 MHz clock that, divided down by 5, gives us our 8 MHz output. 
Another CLKIO is used for the 20 MHz system bus clock. 

Power: We have an input 3.3 and 5V. 

5V: Fiber interface
3.3V : FPGA IO, system bus, DSP IO
1.8 : FPGA core power
1.2 : DSP core power. 


We're going to use the parallel port for booting and data transfer. A few reasons: 
   1. fewer pins
   2. easy to interface with
   3. sufficiently fast -- DMA in the input data, and use DMA chaining to output past data. 
   4. easy to do, well, neat things with. Like, when we say "load new filter", it can just read it in from some location in IO space. 

   The FPGA controls the RESET pin. 
   FPGA is interfaced to the necessary FLAG pins

DSP flag pin 4 is interfaced to the pin that runs CCLK, which also will contain the TINC signal


---------------------------------------------------------------------------
POWER
---------------------------------------------------------------------------
500 mA / DSP for 1.2 V int.

Unfortunately, at 3.3V core, 1.2V/1A LDO would disappate ~3W, which totally sucks. 
in addition to the 1W lost for the FPGA core. This suggests I'll want to use
switching converters, versus LDOs, as with 16 of these boards, that's 50W of space heating going on. 


So I thought I might use a 2A buck converter to 1.8V, and then from 1.8V to 1.2V with an LDO. 

LT1764A appears to be the best LDO out there, and the adjustable one can go to 1.21 V, at 1.5A, and you can get it for $3.00 from the Linear store. 



Buck-converter: 1.8V output TPS54314
Equations were from SLAV111 from TI. Inductor? what the hell is an inductor?

FSEL to VIN for 550 kHz switching. 
Input cap: 10 uF 10V 1210 X5R cap  (i.e. panasonic ECJ-8YB1A106M)
Bulk not needed as VIN ripple (per SLVA111 eq1) is 90 mV. Now, admittedly, we're going to have 16 of these things in series, so we should probably do the bulk dance anyway. 


Sequencing issues:
for the spartan-IIE : Vcco and Vcint at the same time (?)




Pin counts:
6 FPGA boot
    2 TCK/TLK stuff (not to FPGA)
DSP: 
3 FLAGS
1 RESET
1 CLK
19 parallel
=23*2 = 44

   26  event bus
1 system 20 mhz clock
18 system data bus

2 system input clocks(40 MHz, 50 Mhz)


