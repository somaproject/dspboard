library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity EventOutputs is
    Port ( CLK : in std_logic;
           SYSCLK : in std_logic;
           DIN : in std_logic_vector(15 downto 0);
           WE : in std_logic;
           ADDR : in std_logic_vector(3 downto 0);
           EDATA : out std_logic_vector(15 downto 0);
           EADDR : out std_logic_vector(7 downto 0);
           EOE : out std_logic;
           ECE : in std_logic;
           EEVENT : in std_logic;
           RESET : in std_logic);
end EventOutputs;

architecture Behavioral of EventOutputs is
-- EVENTOUTPUTS.VHDL : Module places events to be written to the event
-- bus in a circular buffer, and then writes them when ECE is asserted. 

-- input side signals
	signal dinl, dia : std_logic_vector(15 downto 0) := (others=> '0'); 
	signal aen, wel, well, wea : std_logic := '0'; 
	signal aoh, aol : std_logic_vector(3 downto 0) := (others => '0'); 
	signal addrl : std_logic_vector(3 downto 0) := (others => '0');
	signal addra : std_logic_vector(9 downto 0) := (others => '0'); 
	signal ecntin: std_logic_vector(5 downto 0) := (others => '0'); 

-- output sysclk-side signals
	signal dob: std_logic_vector(31 downto 0) :=(others => '0');
	signal addrb: std_logic_vector(8 downto 0) := (others => '0');
	signal eend, wen, enout : std_logic := '0';
	signal wcnt : std_logic_vector(2 downto 0) := (others => '0'); 
	signal ecntout : std_logic_vector(5 downto 0) := (others => '0'); 
	signal ecntinl : std_logic_vector(5 downto 0) := (others => '0'); 
	
	component RAMB16_S18_S36 
	  generic (
	       WRITE_MODE_A : string := "WRITE_FIRST";
	       WRITE_MODE_B : string := "WRITE_FIRST";
	       INIT_A : bit_vector  := X"00000";
	       SRVAL_A : bit_vector := X"00000";

	       INIT_B : bit_vector  := X"00000";
	       SRVAL_B : bit_vector := X"00000";

	       INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_10 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_11 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_12 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_13 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_14 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_15 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_16 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_17 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_18 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_19 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
	  );

	  port (DIA    : in STD_LOGIC_VECTOR (15 downto 0);
	        DIB    : in STD_LOGIC_VECTOR (31 downto 0);
	        DIPA    : in STD_LOGIC_VECTOR (1 downto 0);
	        DIPB    : in STD_LOGIC_VECTOR (3 downto 0);
	        ENA    : in STD_logic;
	        ENB    : in STD_logic;
	        WEA    : in STD_logic;
	        WEB    : in STD_logic;
	        SSRA   : in STD_logic;
	        SSRB   : in STD_logic;
	        CLKA   : in STD_logic;
	        CLKB   : in STD_logic;
	        ADDRA  : in STD_LOGIC_VECTOR (9 downto 0);
	        ADDRB  : in STD_LOGIC_VECTOR (8 downto 0);
	        DOA    : out STD_LOGIC_VECTOR (15 downto 0);
	        DOB    : out STD_LOGIC_VECTOR (31 downto 0);
	        DOPA    : out STD_LOGIC_VECTOR (1 downto 0);
	        DOPB    : out STD_LOGIC_VECTOR (3 downto 0)
	       ); 
 	end component; 

begin
	circbuf: RAMB16_S18_S36 port map(	
		DIA => dia,
		DIB => X"00000000", 
		DIPA => "00",
		DIPB => "0000", 
		ENA => '1',
		ENB => '1', 
		WEA => wea, 
		WEB => '0',
		SSRA => '0',
		SSRB => '0',
		CLKA => CLK,
		CLKB => SYSCLK,
		ADDRA => addra, 
		ADDRB => addrb,
		DOA => open, 
		DOB => dob,
		DOPA => open,
		DOPB => open); 

	-- data inputs:
	dia(15 downto 8) <= dinl(15 downto 8);
	dia(7 downto 0) <= dinl(15 downto 8) when aen = '1' and well ='1'
			else dinl(7 downto 0); 

	wea <= well or wel;

	addra(3 downto 0) <= aoh when well = '0' else aol; 
	addra(9 downto 4) <= ecntin; 

	-- the ROM: 
	aen <= '1' when addrl = X"0" or addrl = X"1" or addrl = X"2" else '0';
	aoh <= X"0" when addrl = X"0" else
			 X"4" when addrl = X"1" else
			 X"8" when addrl = X"2" else
			 X"1" when addrl = X"3" else
			 X"3" when addrl = X"4" else
			 X"5" when addrl = X"5" else
			 X"7" when addrl = X"6" else
			 X"9" when addrl = X"7" else
			 X"B" when addrl = X"8" else
			 X"C";

	aol <= X"2" when addrl = X"0" else
			 X"6" when addrl = X"1" else
			 X"A" when addrl = X"2" else
			 X"1" when addrl = X"3" else
			 X"3" when addrl = X"4" else
			 X"5" when addrl = X"5" else
			 X"7" when addrl = X"6" else
			 X"9" when addrl = X"7" else
			 X"B" when addrl = X"8" else
			 X"C";

	clkmain: process(CLK) is
	begin
		if rising_edge(CLK) then
			dinl <= DIN;
			wel <= WE;
			well <= wel; 
			addrl <= ADDR;

			if addrl = X"9" and well = '1' then
				ecntin <= ecntin + 1; 
			end if; 
		end if; 
	end process clkmain; 

	-- now, the sysclk output side:
	EDATA <= dob(31 downto 16) when enout = '1' else X"0000";
	EADDR <= dob(7 downto 0) when enout = '1' else X"00"; 
	EOE <= ENOUT; 

	eend <= '1' when wcnt = "110" else '0';
	wen <= '1' when enout = '1' or (ece = '1' and eevent = '1') else '0'; 

	addrb <= ecntout & wcnt; 

	sysclkmain: process(SYSCLK) is
	begin
		if rising_edge(SYSCLK) then
			ecntinl <= ecntin; 

			if eend = '1' then
				wcnt <= "000";
			else
				if wen = '1' then 
					wcnt <= wcnt + 1;
				end if; 
			end if; 

			if eend = '1' then 
				ecntout <= ecntout + 1; 
			end if; 

			if eend = '1' then 
				enout <= '0';
			else
				if ecntout /= ecntinl and ece = '1' and eevent = '1' then
					enout <= '1';	
				end if; 
			end if; 

		end if; 
	end process sysclkmain; 

end Behavioral;
