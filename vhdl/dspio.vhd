library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dspio is
    Port ( CLK : in std_logic;
           WE : in std_logic;
           RD : in std_logic;
           DATA : inout std_logic_vector(15 downto 0);
           ADDR : in std_logic_vector(15 downto 0);
           DELTARD : out std_logic;
           DOUT : out std_logic_vector(15 downto 0);
           ADDROUT : out std_logic_vector(15 downto 0);
           EVENTDIN : in std_logic_vector(15 downto 0);
           RDIN : in std_logic_vector(7 downto 0);
           MODE : in std_logic;
           DWE : out std_logic;
           EWE : out std_logic;
           CWE : out std_logic;
           STATUS : in std_logic;
           CMDID : in std_logic_vector(2 downto 0);
           CMDSTS : in std_logic_vector(3 downto 0);
           SAMPLE1 : in std_logic_vector(15 downto 0);
           SAMPLE2 : in std_logic_vector(15 downto 0);
           SAMPLE3 : in std_logic_vector(15 downto 0);
           SAMPLE4 : in std_logic_vector(15 downto 0);
           SAMPLEC : in std_logic_vector(15 downto 0);
			  DSPRESET : in std_logic;
			  RESET : out std_logic;
			  NEWSAMPLE : in std_logic;
			  SAMPLES : out std_logic;
			  NEWEVENTS : in std_logic;
			  EVENTS : out std_logic; 
			  EBUFSEL : out std_logic; 
			  TIMEINC : in std_logic;
			  TINC : out std_logic;
			  TIMECLR : in std_logic;
			  TCLR : out std_logic;
			  MADDR : in std_logic_vector(7 downto 0));
end dspio;

architecture Behavioral of dspio is
-- DSPIO.VHD -- system to handle multiplexed interface to
-- the DSP data bus, and provides a pass-through for most IO connections. 
-- This is where address ranges are essentially assigned -- the goal is
-- to have the actual code not care where it's mapped into address space. 

	-- intermediate signals
	signal wel, well, welll, deltawe : std_logic := '0';
	signal rdl, rdll, rdlll : std_logic := '0';
	signal datainl, datainll, datainlll : std_logic_vector(15 downto 0)
			:= (others => '0');
	signal mts : std_logic := '0'; 
	signal dataoutl, dataout, dmux, smux : std_logic_vector(15 downto 0)
			:= (others => '0');
	signal addrl : std_logic_vector(15 downto 0) := (others => '0'); 


begin

	deltawe <= well and (not welll); 
	DWE <= '1' when deltawe = '1'  and addr(15 downto 12) = X"2" else '0';
	EWE <= '1' when deltawe = '1'  and addr(15 downto 12) = X"4" else '0';
	CWE <= '1' when deltawe = '1'  and addr(15 downto 12) = X"8" else '0';
	 
	DELTARD <= rdll and (not rdlll); 
	
	mts <= RD or MODE; 
	
	dataout <= dmux when mode = '0' else (X"00" & rdin); 
	
	dmux <= smux when addrl(15 downto 13) = "000" else 
			  EVENTDIN when addrl(15 downto 13) = "011" else
			  X"0000";
	  
	smux <= ("0000" & CMDSTS & '0' & CMDID & "000" &  STATUS) 
						when addrl(2 downto 0) = "000" else
			  sample1 when addrl(2 downto 0) = "001" else
			  sample2 when addrl(2 downto 0) = "010" else
			  sample3 when addrl(2 downto 0) = "011" else
			  sample4 when addrl(2 downto 0) = "100" else
			  sampleC when addrl(2 downto 0) = "101" else
			  X"0123" when addrl(2 downto 0) = "110" else
			  X"ABCD"; 

	DATA(7 downto 0) <= dataoutl(7 downto 0) when RD = '0' else "ZZZZZZZZ";
	DATA(15 downto 8) <= dataoutl(15 downto 8) when mts = '0' else "ZZZZZZZZ";
	 

	clock: process(CLK) is
	begin
		if rising_edge(CLK) then
			wel <= WE; 
			well <= wel;
			welll <= well; 

			rdl <= RD; 
			rdll <= rdl;
			rdlll <= rdll; 

			datainl <= DATA;
			datainll <= datainl;
			datainlll <= datainll; 
			DOUT <= datainlll; 

			dataoutl <= dataout; 
			
			addrl <= ADDR; 
			ADDROUT <= addrl; 

			if addrl (15 downto 12) = X"4" then
				EBUFSEL <= '1';
			else
				EBUFSEL <= '0';
			end if; 

			RESET <= DSPRESET;
			SAMPLES <= NEWSAMPLE;
			EVENTS <= NEWEVENTS;
			TINC <= TIMEINC;
			TCLR <= TIMECLR; 

		end if; 
	end process clock; 



end Behavioral;
