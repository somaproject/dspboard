#
# Register dump auxiliary routines
#
# (c) 08/2005 <hackfin@section5.ch>
#
# This file is subjected to the Gnu Public License.
#
# $Id: dump.gdb,v 1.6 2005/11/09 11:25:19 strubi Exp $
#

# dump exception text and details according to code argument
define dump_exc
	# Get EXCAUSE field from SEQSTAT register:
	set $a = ($seqstat & 0x3f)
	echo -----------------------------------------------------------------\n
	echo -- Exception !!\n
	printf "-- EXCAUSE: %02x\n", $a

	echo -- Reason: \ 
	if $a == 0x10
		echo "Single Step"
	end
	if $a == 0x10
		echo "Trace buffer full"
	end
	if $a == 0x21
		echo "Undefined Instruction"
	end
	if $a == 0x22
		echo "Illegal instruction combination"
	end
	if $a == 0x23
		echo "Memory access violation"
	end
	if $a == 0x24
		echo "Address error / misalignment"
	end
	if $a == 0x25
		echo "Unrecoverable Event"
	end
	if $a == 0x26
		echo "Data access CPLB miss"
	end
	if $a == 0x27
		echo "CPLB multiple hits"
	end
	if $a == 0x28
		echo "Watchpoint match"
	end
	if $a == 0x2a
		echo "Instruction fetch misalignment"
	end
	if $a == 0x2b
		echo "Illegal instruction fetch"
	end
	if $a == 0x2c
		echo "Instruction fetch CPLB miss"
	end
	if $a == 0x2d
		echo "Instruction fetch CPLB multiple hits"
	end
	if $a == 0x2e
		echo "Illegal use of protected resource"
	end
	echo \n
	printf "-- Instruction: "
	x/i $retx
	echo -----------------------------------------------------------------\n

end

define dump_hwerr
	# Get HWERR field from SEQSTAT register:
	set $a = ($seqstat & 0x0007c000) >> 14
	echo -----------------------------------------------------------------\n
	echo -- Hardware Error !!\n
	printf "-- HWERRCAUSE: %02x\n", $a

	echo -- Reason: \ 
	if $a == 0x01
		echo "DMA Bus Comparator Source"
	end
	if $a == 0x02
		echo "System MMR error"
	end
	if $a == 0x03
		echo "External Memory Adressing Error"
	end
	if $a == 0x12
		echo "Performance Monitor Overflow"
	end
	if $a == 0x18
		echo "Raise 5 instruction"
	end
	echo \n
	printf "-- Instruction: "
	x/i $retx
	echo -----------------------------------------------------------------\n
end


define dump_ebiu
	printf "-----------------------\n"
	set $x = *$EBIU_SDGCTL
	printf "EBIU_SDGCTL: %08lx\n", $x
	if !($x & 1)
		echo SDC disabled\n
	end
	printf "CAS latency: %d\n", ($x >> 2) & 3

	set $y = ($x >> 4) & 3
	printf "Refresh: "

	if ($y == 0)
		echo All four banks\n
	end
	if ($y == 1)
		echo Int bank 0, 1
	end
	if ($y == 2)
		echo Int bank 0 only
	end
	if ($y == 3)
		echo Reserved
	end

	printf "TRAS cycles: %d\n", ($x >> 6) & 0xf
	printf "TRP  cycles: %d\n", ($x >> 11) & 0x7
	printf "TRCD cycles: %d\n", ($x >> 15) & 0x7
	printf "TWR  cycles: %d\n", ($x >> 19) & 0x3

	printf "Bits: "

	if ($x & 0x00400000)
		echo PSM, 
	end
	if ($x & 0x00800000)
		echo PSS, 
	end
	if ($x & 0x01000000)
		echo SRFS, 
	end
	if ($x & 0x02000000)
		echo EBUFE, 
	end
	if ($x & 0x04000000)
		echo FBBRW, 
	end
	if ($x & 0x10000000)
		echo EMREN, 
	end
	if ($x & 0x20000000)
		echo TCSR, 
	end
	if ($x & 0x40000000)
		echo CDDBG, 
	end

	echo \n

	printf "-----------------------\n"
	set $x = *$EBIU_SDBCTL
	printf "EBIU_SDBCTL: %04x\n", $x

	if !($x & 1)
		echo SDRAM disabled\n
	end
	printf "Bank size: %d MB\n", (1 << (($x >> 1) & 3)) * 16

	printf "Col address width: %d bits\n", 8 + (($x >> 4) & 3)

	printf "-----------------------\n"
	printf "EBIU_SDRRC:  %04x\n", *$EBIU_SDRRC
	printf "----- EBIU_SDSTAT -----\n"
	if (*$EBIU_SDSTAT & $SDCI)
		echo SDRAM is idle\n
	end
	if (*$EBIU_SDSTAT & $SDEASE)
		echo SDRAM EAB error occured!\n
	end
	if !(*$EBIU_SDSTAT & $SDRS)
		echo SDRAM was powered up\n
	end
	if (*$EBIU_SDSTAT & $SDPUA)
		echo SDRAM in powerup sequence.\n
	end
	printf "-----------------------\n"
end

# Documentation
document dump_ebiu
Dumps the SDRAM configuration register configuration verbosely.
end


define dump_pll
	printf "------- PLL -------\n"
	set $p = *$PLL_CTL
	set $d = *$PLL_DIV
	printf "PLL_CTL      : 0x%04x\n", $p
	printf "PLL_DIV      : 0x%04x\n", $d
	printf "PLL_STAT     : 0x%04x\n", *$PLL_STAT
	printf "PLL_LOCKCNT  : 0x%04x\n\n", *$PLL_LOCKCNT
	set $mul = (($p >> 9) & 0x3f)
	if $mul == 0
		set $mul = 64
	end
	set $mul = (float) $mul / (($p & 1) + 1)
	printf "VCO multiplier: %.1f\n", $mul
	printf "Sys clock multiplier: %f\n", $mul / ($d & 0xf)
	printf "Core clock multiplier: %f\n", $mul / (1 << (($d >> 4) & 0x3))
end

# Documentation
document dump_pll
Dumps the PLL configuration register configuration.
end

define dump_irqbits
	set $r = *$arg0
	if $r & 0x0002
		echo [RST]
	end
	if $r & 0x0004
		echo [NMI]
	end
	if $r & 0x0008
		echo [EVX]
	end
	if $r & 0x0020
		echo [IVHW]
	end
	if $r & 0x0040
		echo [IVTMR]
	end
	set $r = $r >> 7
	set $i = 7
	while ($r)
		if $r & 1
			printf "[IVG%d]", $i
		end
		set $r = $r >> 1
		set $i = $i + 1
	end
	echo \n
end

define dump_irq
	echo ----------- IPEND -------------\n
	dump_irqbits $IPEND
	echo ----------- ILAT  -------------\n
	dump_irqbits $ILAT
	echo ----------- IMASK -------------\n
	dump_irqbits $IMASK
end

# Documentation
document dump_irq
Dumps the IRQ pend, latch and mask registers verbosely.
end

# Dump system interrupt bits of BF533
define dump_sicbits_533
	set $r = *$arg0
	if $r & 0x00000001
		echo PLL Wakeup, 
	end
	if $r & 0x00000002
		echo DMA Error, 
	end
	if $r & 0x00000004
		echo PPI Error, 
	end
	if $r & 0x00000008
		echo SPORT0 Error, 
	end
	if $r & 0x00000010
		echo SPORT1 Error, 
	end
	if $r & 0x00000020
		echo SPI Error, 
	end
	if $r & 0x00000040
		echo UART Error, 
	end
	if $r & 0x00000080
		echo Real Time Clock, 
	end
	if $r & 0x00000100
		echo PPI, 
	end
	if $r & 0x00000200
		echo SPORT0 RX, 
	end
	if $r & 0x00000400
		echo SPORT0 TX, 
	end
	if $r & 0x00000800
		echo SPORT1 RX, 
	end
	if $r & 0x00001000
		echo SPORT1 TX, 
	end
	if $r & 0x00002000
		echo SPI, 
	end
	if $r & 0x00004000
		echo UART RX, 
	end
	if $r & 0x00008000
		echo UART TX, 
	end
	if $r & 0x00010000
		echo Timer0, 
	end
	if $r & 0x00020000
		echo Timer1, 
	end
	if $r & 0x00040000
		echo Timer2, 
	end
	if $r & 0x00080000
		echo PF A, 
	end
	if $r & 0x100000
		echo PF B, 
	end
	if $r & 0x00200000
		echo MDMA0, 
	end
	if $r & 0x00400000
		echo MDMA1, 
	end
	if $r & 0x00800000
		echo SW Watchdog, 
	end
	echo \n
end

# Dump system interrupt bits of BF537
define dump_sicbits_537
	set $r = *$arg0
	if $r & 0x00000001
		echo PLL Wakeup, 
	end
	if $r & 0x00000002
		echo DMA Error, 
	end
	if $r & 0x00000004
		echo Peripheral Port Error, 
	end
	if $r & 0x00000008
		echo Real Time Clock, 
	end
	if $r & 0x00000010
		echo PPI, 
	end
	if $r & 0x00000020
		echo SPORT0 RX, 
	end
	if $r & 0x00000040
		echo SPORT0 TX, 
	end
	if $r & 0x00000080
		echo SPORT1 RX, 
	end
	if $r & 0x00000100
		echo SPORT1 TX, 
	end
	if $r & 0x00000200
		echo TWI,
	end
	if $r & 0x00000400
		echo SPI DMA,
	end
	if $r & 0x00000800
		echo UART0 RX, 
	end
	if $r & 0x00001000
		echo UART0 TX, 
	end
	if $r & 0x00002000
		echo UART1 RX, 
	end
	if $r & 0x00004000
		echo UART1 TX, 
	end
	if $r & 0x00008000
		echo CAN RX,
	end
	if $r & 0x00010000
		echo CAN TX,
	end
	if $r & 0x00020000
		echo MAC RX,
	end
	if $r & 0x00040000
		echo MAC TX,
	end
	if $r & 0x00080000
		echo TIMER0,
	end
	if $r & 0x00100000
		echo TIMER1,
	end
	if $r & 0x00200000
		echo TIMER2,
	end
	if $r & 0x00400000
		echo TIMER3,
	end
	if $r & 0x00800000
		echo TIMER4,
	end
	if $r & 0x01000000
		echo TIMER5,
	end
	if $r & 0x02000000
		echo TIMER6,
	end
	if $r & 0x04000000
		echo TIMER7,
	end
	if $r & 0x08000000
		echo Port F/G IRQ A,
	end
	if $r & 0x10000000
		echo Port G IRQ B,
	end
	if $r & 0x20000000
		echo MDMA 0,
	end
	if $r & 0x40000000
		echo MDMA 1,
	end
	if $r & 0x80000000
		echo Port F IRQ B,
	end
	echo \n
end


define dump_sic
	set $id = *$DSPID
	if $id == 0xe5040001
		echo -----------------  SIC_ISR  ----------------------\n
		dump_sicbits_537 $SIC_ISR
		echo -----------------  SIC_IMASK ---------------------\n
		dump_sicbits_537 $SIC_IMASK
	else
		echo -----------------  SIC_ISR  ----------------------\n
		dump_sicbits_533 $SIC_ISR
		echo -----------------  SIC_IMASK ---------------------\n
		dump_sicbits_533 $SIC_IMASK
	end
end

# Documentation
document dump_sic
Dumps the System interrupt controller configuration verbosely.
end


# Dump all SIC assigment registers
define dump_siciar_533
	set $r = *$SIC_IAR0
	printf "PLL Wakeup IRQ: %d\n",              7 + ( $r & 0xf)
	printf "DMA Error IRQ:  %d\n",              7 + (($r >> 4)  & 0xf)
	printf "PPI Error IRQ:  %d\n",              7 + (($r >> 8)  & 0xf)
	printf "SPORT0 IRQ:     %d\n",              7 + (($r >> 12) & 0xf)
	printf "SPI Error IRQ:  %d\n",              7 + (($r >> 16) & 0xf)
	printf "SPORT1 IRQ:     %d\n",              7 + (($r >> 20) & 0xf)
	printf "UART Error IRQ: %d\n",              7 + (($r >> 24) & 0xf)
	printf "RTC IRQ:        %d\n",              7 + (($r >> 28) & 0xf)

	set $r = *$SIC_IAR1
	printf "PPI IRQ:        %d\n",              7 + ( $r & 0xf)
	printf "SPORT0 RX IRQ:  %d\n",              7 + (($r >> 4)  & 0xf)
	printf "SPORT0 TX IRQ:  %d\n",              7 + (($r >> 8)  & 0xf)
	printf "SPORT1 RX IRQ:  %d\n",              7 + (($r >> 12) & 0xf)
	printf "SPORT1 TX IRQ:  %d\n",              7 + (($r >> 16) & 0xf)
	printf "SPI IRQ:        %d\n",              7 + (($r >> 20) & 0xf)
	printf "UART RX IRQ:    %d\n",              7 + (($r >> 24) & 0xf)
	printf "UART TX IRQ:    %d\n",              7 + (($r >> 28) & 0xf)

	set $r = *$SIC_IAR2
	printf "Timer0 IRQ:           %d\n",        7 + ( $r & 0xf)
	printf "Timer1 IRQ:           %d\n",        7 + (($r >> 4)  & 0xf)
	printf "Timer2 IRQ:           %d\n",        7 + (($r >> 8)  & 0xf)
	printf "PF A IRQ:             %d\n",        7 + (($r >> 12) & 0xf)
	printf "PF B IRQ:             %d\n",        7 + (($r >> 16) & 0xf)
	printf "MDMA0 IRQ:            %d\n",        7 + (($r >> 20) & 0xf)
	printf "MDMA1 IRQ:            %d\n",        7 + (($r >> 24) & 0xf)
	printf "SW Watchdog Timer IRQ:%d\n",        7 + (($r >> 28) & 0xf)
end

# Dump all SIC assigment registers
define dump_siciar_537
	set $r = *$SIC_IAR0
	printf "PLL Wakeup IRQ:    %d\n",           7 + ( $r & 0xf)
	printf "DMA Error IRQ:     %d\n",           7 + (($r >> 4)  & 0xf)
	printf "Port Error IRQ:    %d\n",           7 + (($r >> 8)  & 0xf)
	printf "RTC IRQ:           %d\n",           7 + (($r >> 12) & 0xf)
	printf "PPI DMA IRQ:       %d\n",           7 + (($r >> 16) & 0xf)
	printf "SPORT0 RX IRQ:     %d\n",           7 + (($r >> 20) & 0xf)
	printf "SPORT0 TX IRQ:     %d\n",           7 + (($r >> 24) & 0xf)
	printf "SPORT1 RX IRQ:     %d\n",           7 + (($r >> 28) & 0xf)

	set $r = *$SIC_IAR1
	printf "SPORT1 TX IRQ:     %d\n",           7 + ( $r & 0xf)
	printf "TWI IRQ:           %d\n",           7 + (($r >> 4)  & 0xf)
	printf "SPI DMA IRQ:       %d\n",           7 + (($r >> 8)  & 0xf)
	printf "UART0 RX IRQ:      %d\n",           7 + (($r >> 12) & 0xf)
	printf "UART0 TX IRQ:      %d\n",           7 + (($r >> 16) & 0xf)
	printf "UART1 RX IRQ:      %d\n",           7 + (($r >> 20) & 0xf)
	printf "UART1 TX IRQ:      %d\n",           7 + (($r >> 24) & 0xf)
	printf "CAN RX IRQ:        %d\n",           7 + (($r >> 28) & 0xf)

	set $r = *$SIC_IAR2
	printf "CAN TX IRQ:        %d\n",           7 + ( $r & 0xf)
	printf "MAC RX IRQ:        %d\n",           7 + (($r >> 4)  & 0xf)
	printf "MAC TX IRQ:        %d\n",           7 + (($r >> 8)  & 0xf)
	printf "TIMER0 IRQ:        %d\n",           7 + (($r >> 12) & 0xf)
	printf "TIMER1 IRQ:        %d\n",           7 + (($r >> 16) & 0xf)
	printf "TIMER2 IRQ:        %d\n",           7 + (($r >> 20) & 0xf)
	printf "TIMER3 IRQ:        %d\n",           7 + (($r >> 24) & 0xf)
	printf "TIMER4 IRQ:        %d\n",           7 + (($r >> 28) & 0xf)

	set $r = *$SIC_IAR3
	printf "TIMER5 IRQ:        %d\n",           7 + ( $r & 0xf)
	printf "TIMER6 IRQ:        %d\n",           7 + (($r >> 4)  & 0xf)
	printf "TIMER7 IRQ:        %d\n",           7 + (($r >> 8)  & 0xf)
	printf "PORT F,G IRQ A:    %d\n",           7 + (($r >> 12) & 0xf)
	printf "PORT G IRQ B:      %d\n",           7 + (($r >> 16) & 0xf)
	printf "MDMA0 IRQ:         %d\n",           7 + (($r >> 20) & 0xf)
	printf "MDMA1 IRQ:         %d\n",           7 + (($r >> 24) & 0xf)
	printf "PORT F IRQ B:      %d\n",           7 + (($r >> 28) & 0xf)
end

define dump_siciar
	set $id = *$DSPID
	if $id == 0xe5040001
		dump_siciar_537
	else
		dump_siciar_533
	end
end



# Documentation
document dump_siciar
Dumps the System interrupt assignment verbosely.
end

define dump_wpu
	echo WPIACTL\t
	print/x $WPIACTL[0]
	echo WPIA0\t
	print/x $WPIA[0]
	echo WPDACTL\t
	print/x $WPDACTL[0]
	echo WPDA0\t
	print/x $WPDA[0]
	echo WPDA1\t
	print/x $WPDA[1]
end

define ppi_status
	echo PPI_STATUS\t
	set $r = *$PPI_STATUS
	if $r & 0x8000
		echo [Error not corrected],
	end
	if $r & 0x4000
		echo [ITU-R 656 Error],
	end
	if $r & 0x2000
		echo [FIFO Underrun],
	end
	if $r & 0x1000
		echo [FIFO Overflow],
	end
	if $r & 0x0800
		echo [Frame Track Error],
	end
	if $r & 0x0400
		echo [Field 2]
	else
		echo [Field 1]
	end
	echo \n
end

define dump_dmabits
	set $r = $arg0

	if $r & 0x0001
		echo [DMA done],
	end
	if $r & 0x0002
		echo [DMA Error],
	end
	if $r & 0x0004
		echo [DMA Descriptor Fetch],
	end
	if $r & 0x0008
		echo [DMA Running],
	end
	echo \n
end

define dma_status
	set $r = *($DMA0_IRQ_STATUS + $arg0 * 0x20)
	printf "-----------------  DMA%d  ----------------------\n", $arg0
	printf "DMA%d:  %04x\n", $arg0, $r
	dump_dmabits $r
end

define dump_dma
	set $i = 0
	while $i < 8
		dma_status $i
		set $i = $i + 1
	end
end
