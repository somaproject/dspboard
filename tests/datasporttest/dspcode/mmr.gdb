# 
# Some auxiliary registers for blackfin debugging
#
# This file is not complete. The user is encouraged to add more important
# MMR registers and make this file available to everyone.
#
# This file is subjected to the Gnu Public License.
#
# 05/2005 Martin Strubel <hackfin@section5.ch>
#
# $Id: mmr.gdb,v 1.10 2005/11/05 16:08:54 strubi Exp $
#


set $DSPID         =  (unsigned long *)  0xffe05000

# Important System registers
set $SYSCR         =  (unsigned short *) 0xffc00104

# EVENT HANDLER
set $EVT = (void(*)() *) 0xffe02000

# DMA CHANNELS

set $MDMA_D0_CONFIG = (unsigned short *) 0xffc00e08
set $MDMA_S0_CONFIG = (unsigned short *) 0xffc00e48
set $MDMA_D0_IRQ_STATUS = (unsigned short *) 0xffc00e28
set $MDMA_S0_IRQ_STATUS = (unsigned short *) 0xffc00e68


set $DMA0_NEXT_DESC_PTR = (unsigned long *) 0xffc00c00
set $DMA0_START_ADDR    = (unsigned long *) 0xffc00c04
set $DMA0_CONFIG        = (unsigned short *) 0xffc00c08
set $DMA0_IRQ_STATUS    = (unsigned short *) 0xffc00c28

set $DMA1_IRQ_STATUS    = $DMA0_IRQ_STATUS + 0x20
set $DMA2_IRQ_STATUS    = $DMA1_IRQ_STATUS + 0x20

# Core Interrupt stuff

set $IMASK              = (unsigned long *) 0xffe02104
set $ILAT               = (unsigned long *) 0xffe0210c
set $IPEND              = (unsigned long *) 0xffe02108

# System Interrupt Control Registers
set $SIC_IMASK  = (unsigned long *) 0xffc0010c
set $SIC_ISR    = (unsigned long *) 0xffc00120
set $SIC_IWR    = (unsigned long *) 0xffc00124
set $SIC_IAR0   = (unsigned long *) 0xffc00110
set $SIC_IAR1   = (unsigned long *) 0xffc00114
set $SIC_IAR2   = (unsigned long *) 0xffc00118
set $SIC_IAR3   = (unsigned long *) 0xffc0011c
set $SIC_ISR    = (unsigned long *) 0xffc00120

# PF registers
set $FIO_FLAG_D = (unsigned short *) 0xffc00700
set $FIO_DIR    = (unsigned short *) 0xffc00730
set $FIO_POLAR  = (unsigned short *) 0xffc00734
set $FIO_EDGE   = (unsigned short *) 0xffc00738
set $FIO_BOTH   = (unsigned short *) 0xffc0073c
set $FIO_INEN   = (unsigned short *) 0xffc00740

# PLL control

set $PLL_CTL     = (unsigned short *) 0xffc00000
set $PLL_DIV     = (unsigned short *) 0xffc00004
set $PLL_STAT    = (unsigned short *) 0xffc0000c
set $PLL_LOCKCNT = (unsigned short *) 0xffc00010

# EBIU SRAM configuration registers
set $EBIU_SDGCTL = (unsigned long *)  0xffc00a10
set $EBIU_SDBCTL = (unsigned short *) 0xffc00a14
set $EBIU_SDRRC  = (unsigned short *) 0xffc00a18
set $EBIU_SDSTAT = (unsigned short *) 0xffc00a1c


# EBIU_SDGCTL bits
set $PSS      = 0x00800000 
set $SRFS     = 0x01000000

set $SDCI     =  0x0001
set $SDSRA    =  0x0002
set $SDPUA    =  0x0004
set $SDRS     =  0x0008
set $SDEASE   =  0x0010

# watchpoint auxiliary registers

set $WPIACTL     = (unsigned long *)  0xffe07000
set $WPIA        = (unsigned long *)  0xffe07040
set $WPIACNT     = (unsigned long *)  0xffe07080

set $WPDACTL     = (unsigned long *)  0xffe07100
set $WPDA        = (unsigned long *)  0xffe07140
set $WPSTAT      = (unsigned long *)  0xffe07200

# user defined commands

set $PPI_CONTROL = (unsigned short *) 0xffc01000
set $PPI_STATUS  = (unsigned short *) 0xffc01004
set $PPI_COUNT   = (unsigned short *) 0xffc01008
set $PPI_DELAY   = (unsigned short *) 0xffc0100c
set $PPI_FRAME   = (unsigned short *) 0xffc01010


