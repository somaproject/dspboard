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

Uhh, okay, nevermind on that whole parallel-port thing, at least not yet. Keep in mind that it's an ASYNCHRONOUS port, where the ALE cycle is _at best_ 2 CCLKs long -- i.e. 10 ns!! Yikes! 

So, my first recourse was the SPI port, which in addition to letting me use fewer wires, can boot, etc. Just like the parallel port. However, the SPI port is running at max 50 MHz, i.e. 50 Mbps or 6.25 MBps. Ouch. This means that transferring the new set of samples costs 1.6 us, and transferring a full spike out costs 41 us! Yikes! 

Because, the ideal coding situation is:
get new samples
perform computation
check for thresholding
if necessary, send out spikes, eeg chunks, react to events, etc. (maybe events are a separate interrupt, but whatever)

keep in mind that a sample cycle is 31.25 us. 

So, uhh, what we actually want to do is... use a latch and latch the address pins! we can use a larger PQFP FPGA and we can use a decoder IC too, because you know, board space is free or something. 
 




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

Note that all current consumed at 1.2V is actually going through the LDO, so it's actually using I*1.8 watts of power.

DSPs: 1A each, at 1.8 V, plus 100 mA @ 3.3V for ext = 4.26 W total
FPGA : 500 mA int * 1.8 + 500 mA ext + 3.3V = 2.55W

Total == 6.81 W
 

Let's assume each DSP uses 1 A on VCCINT, for a total of 2A @ 1.2V == 2.4 W. Externally, each can do 100 mA @ 3.3 V, == .330*2 = .660 W. FPGA is using .5 @ 3.3V == 1.6W, and 500 mA @ 1.8 V int == .9W, so total is: 5.56 W. 

the board has 4 VCC connectors at 500 mA each for 3.3 V = 6.6W. This is such total overkill it's not even funny. 




FSEL to VIN for 550 kHz switching. 
Input cap: 10 uF 10V 1210 X5R cap  (i.e. panasonic ECJ-8YB1A106M)
Bulk not needed as VIN ripple (per SLVA111 eq1) is 110 mV. Now, admittedly, we're going to have 16 of these things in parallel, so we should probably do the bulk dance anyway. 

A rep from TI said that I shouldn't worry about the ripple voltages adding as they will have random phase, so I don't really have to worry about ripple too much, plus it will precess. 

output inductor: 
       RMS current rating: 2.5 A
       peak : 2.7 A

       we can use: panasonic ELL-ATV6R8N
       6.8 uH, 16 mOhm DCR, 4.0 A rated, digikey has them

Output capacitor:

       ripple current greater than : 63 mA
       esr: for < 10 mV ripple, we need <37 mOhm esr
       T520D687M003ASE015 : KEMET polymer tantalum chip capacitor
       680 uF, 15 mOhm ESR, 1.8 A ripple RMS, 3.0V rated 
       digikey has it
       also falls in region of stability for 6.8 uH inductor per app note. 
       note if this doesn't work, we can use the 40 mOhm one, with just more
       output ripple



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


