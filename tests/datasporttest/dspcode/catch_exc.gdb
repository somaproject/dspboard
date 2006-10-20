#
# GDB script to catch excptions on blackfin platforms
#
# 05/2005 Martin Strubel <hackfin@section5.ch>
#
# $Id: catch_exc.gdb,v 1.5 2005/11/04 03:17:58 strubi Exp $


# enable HW interrupt
set *$IMASK = *$IMASK | 0x20

# Break at exception handler #3
b *$EVT[3]

command
	dump_exc 
end

# also catch hardware errors
b *$EVT[5]
command
	dump_hwerr 
end

