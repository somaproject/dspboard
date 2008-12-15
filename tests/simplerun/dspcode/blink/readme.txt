****************************************************************************************************

ADSP-BF537 EZ-KIT Lite PORTF Interrupts and Timer in C

Analog Devices, Inc.
DSP Division
Three Technology Way
Norwood, MA 02062

Date Created:	12/10/04

____________________________________________________________________________________________________

This directory contains an example ADSP-BF537 project that shows how Programmable Flag pins PORTF,
Interrupts, and Timer can be configured in C. It also demonstrates the access to the LEDs
on the EZ-KIT Lite.


Files contained in this directory:

BF537 Flags C.dpj			VisualDSP++ project file
main.c						C file containing the main program and variable declaration
Initialisation.c			C file containing all initialization routines
ISRs.c						C file containing the interrupt service routines for Timer and PORTF
BF537 Flags.h				C header file containing prototypes and macros
readme.txt					this project description file
____________________________________________________________________________________________________


CONTENTS

I.	FUNCTIONAL DESCRIPTION
II.	IMPLEMENTATION DESCRIPTION
III.OPERATION DESCRIPTION


I.    FUNCTIONAL DESCRIPTION

This example demonstrates the initialization of Timer 0, PORTF IO pins,
and Interrupts.
The program simply turns on one LED and rotates the pattern left or right, depending on the state of
an internal flag. The switch connected to PORTF2 (PB1) can be used to toggle the state of this flag,
which results in a change of direction of the moving light.
 


II.   IMPLEMENTATION DESCRIPTION

The main file calls:

1. PORTF setup
2. Timer setup
5. Interrupt configuration
6. Endless loop waiting for Timer interrupt or Flag interrupt

III.  OPERATION DESCRIPTION

- Make sure that switch SW5 pin1 is turned on (connects switch PB1 to pin PORTF2)
- Open the project "BF537 Flags C.dpj" in the VisualDSP Integrated Development Environment (IDDE).
- Under the "Project" tab, select "Build Project" (program is then loaded automatically into DSP).
- Select "Run" from the "Debug" tab on the menu bar of VisualDSP.
- Toggle the direction of the moving light using the switch connected to PORTF2
  (and watch the LEDs)


