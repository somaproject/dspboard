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

