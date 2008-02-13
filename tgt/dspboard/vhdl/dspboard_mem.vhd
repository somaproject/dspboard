library ieee;
use ieee.std_logic_1164;
package dspboard_mem_pkg is
		constant dspcontproc_a_instruction_ram_INIT_00 : bit_vector(0 to 255) := X"12018441300113A184213FF11001841131011101840130011351888130011341";
		constant dspcontproc_a_instruction_ram_INIT_01 : bit_vector(0 to 255) := X"101185911011855110118511101184D110118491101184613FF1100184513201";
		constant dspcontproc_a_instruction_ram_INIT_02 : bit_vector(0 to 255) := X"101187911011875110118711101186D1101186911011865110118611101185D1";
		constant dspcontproc_a_instruction_ram_INIT_03 : bit_vector(0 to 255) := X"3DE01AD088200A208870091003908011100180111011034003308890101087D1";
		constant dspcontproc_a_instruction_ram_INIT_04 : bit_vector(0 to 255) := X"00000000000000000000000000000000000004608800116088403BE01EF08830";
		constant dspcontproc_a_instruction_ram_INIT_05 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_06 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_07 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_08 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_09 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_0A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_0B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_0C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_0D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_0E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_0F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_10 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_11 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_12 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_13 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_14 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_15 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_16 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_17 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_18 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_19 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_1A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_1B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_1C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_1D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_1E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_1F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_20 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_21 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_22 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_23 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_24 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_25 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_26 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_27 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_28 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_29 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_2A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_2B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_2C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_2D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_2E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_2F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_30 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_31 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_32 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_33 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_34 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_35 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_36 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_37 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_38 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_39 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_3A : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_3B : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_3C : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_3D : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_3E : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INIT_3F : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INITP_00 : bit_vector(0 to 255) := X"00000000000000000000000000001EEBACC7B97BBBBBBBBBBBBBBBAEBAEBAEBA";
		constant dspcontproc_a_instruction_ram_INITP_01 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INITP_02 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INITP_03 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INITP_04 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INITP_05 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INITP_06 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INITP_07 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
end dspboard_mem_pkg;
