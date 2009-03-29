library ieee;
use ieee.std_logic_1164;
package dspboard_mem_pkg is
		constant dspcontproc_a_instruction_ram_INIT_00 : bit_vector(0 to 255) := X"10148444300417B484243FF410048414337413748404300417848884300416C4";
		constant dspcontproc_a_instruction_ram_INIT_01 : bit_vector(0 to 255) := X"3004187484A43FF410048494338413848484300417E484643FF4100484543014";
		constant dspcontproc_a_instruction_ram_INIT_02 : bit_vector(0 to 255) := X"85243FF410048514334413448504300418C484E43FF4100484D43324132484C4";
		constant dspcontproc_a_instruction_ram_INIT_03 : bit_vector(0 to 255) := X"100485943334133485843004192485643FF410048554331413148544300418F4";
		constant dspcontproc_a_instruction_ram_INIT_04 : bit_vector(0 to 255) := X"33541354860430041A4485E43FF4100485D43084108485C43004199485A43FF4";
		constant dspcontproc_a_instruction_ram_INIT_05 : bit_vector(0 to 255) := X"10148694101486643FF41004865433641364864430041A7486243FF410048614";
		constant dspcontproc_a_instruction_ram_INIT_06 : bit_vector(0 to 255) := X"100447708044003406B08894101487D4101487941014875410148714101486D4";
		constant dspcontproc_a_instruction_ram_INIT_07 : bit_vector(0 to 255) := X"8874091407D08A040A2407A080640A2407701002880413348813887247708024";
		constant dspcontproc_a_instruction_ram_INIT_08 : bit_vector(0 to 255) := X"0A2408E080440A2408B080240A2480840B34086088041384881400A488240094";
		constant dspcontproc_a_instruction_ram_INIT_09 : bit_vector(0 to 255) := X"0E6488318040101488208874091409808041101480340A240A23091209108014";
		constant dspcontproc_a_instruction_ram_INIT_0A : bit_vector(0 to 255) := X"0000000000000000000000000A9080040A240A6080540A240A30880410948854";
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
		constant dspcontproc_a_instruction_ram_INITP_00 : bit_vector(0 to 255) := X"C71C6EF4937BBBBBBBAEBAEBAEBAEBAEBAEBAEBAEBAEBAEBAEBAEBAEBAEBAEBA";
		constant dspcontproc_a_instruction_ram_INITP_01 : bit_vector(0 to 255) := X"000000000000000000000000000000000000000000071C7B32F12C071C731EFF";
		constant dspcontproc_a_instruction_ram_INITP_02 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INITP_03 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INITP_04 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INITP_05 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INITP_06 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
		constant dspcontproc_a_instruction_ram_INITP_07 : bit_vector(0 to 255) := X"0000000000000000000000000000000000000000000000000000000000000000";
end dspboard_mem_pkg;
