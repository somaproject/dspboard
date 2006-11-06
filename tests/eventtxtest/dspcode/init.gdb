#
# Board/Hardware initialization auxiliaries
#
# This file is subjected to the Gnu Public License.
#
# (c) 08/2005 <hackfin@section5.ch>
#
# $Id: init.gdb,v 1.5 2005/11/09 11:23:41 strubi Exp $
#

# Memory setup

mem 0x00000000 0x08000000 rw 16 cache
mem 0xff800000 0xffa00000 rw 32 nocache
mem 0xffa00000 0xffa10000 rw 32 cache
mem 0x20000000 0x20400000 ro 32 cache
mem 0xef000000 0xff800000 ro 32 cache


# initialize SDRAM EBIU for STAMP
define initmem_STAMP
	set *$EBIU_SDGCTL = 0x0091998d
	set *$EBIU_SDBCTL = 0x0025 
	set *$EBIU_SDRRC  = 0x0817
end

define initmem_EZKIT_533
	set *$EBIU_SDGCTL = 0x0091998d
	set *$EBIU_SDBCTL = 0x0013
	set *$EBIU_SDRRC  = 0x0817
end

define initmem_EZKIT_537
	set *$EBIU_SDGCTL = 0x0091998d
	set *$EBIU_SDBCTL = 0x0025
	set *$EBIU_SDRRC  = 0x03a0
end

define initmem_DSPSTAMP
	set *$EBIU_SDGCTL = 0x0091998d
	set *$EBIU_SDBCTL = 0x0013
	set *$EBIU_SDRRC  = 0x0817
end

define initmem
	#	initmem_STAMP
end
