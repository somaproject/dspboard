library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity databuffer is
    Port ( CLKA : in std_logic;
           CLKB : in std_logic;
			  RESET : in std_logic; 
           BUFWE : in std_logic;
           BUFADDRIN : in std_logic_vector(7 downto 0);
           BUFDIN : in std_logic_vector(15 downto 0);
           BUFERROR : out std_logic;
           BUFDOUT : out std_logic_vector(15 downto 0);
           NEXTOUT : in std_logic;
           BUFACKOUT : out std_logic;
           RAIN : in std_logic_vector(9 downto 0);
           RAOUT : in std_logic_vector(10 downto 0);
           RDOUT : out std_logic_vector(7 downto 0);
           RDIN : in std_logic_vector(15 downto 0);
           RWE : in std_logic;
           MODE : in std_logic);
end databuffer;

architecture Behavioral of databuffer is
-- DATABUFFER.VHD -- implements triple-buffering to let DSP write data
-- events to the databus. uses 3 blockselect+ rams. 

	-- buffer input side
	signal bufwein, bufwedone : std_logic := '0';
	signal fulla, fullb, fullc : std_logic := '0';
	signal weaa, weab, weac : std_logic := '0';
	signal addra : std_logic_vector(7 downto 0) := (others => '0');
   signal buflenin : std_logic_vector(7 downto 0) := (others => '0'); 
	signal bufwdone : std_logic := '0'; 
	type instates is (waita, a, waitb, b, waitc, c); 
	signal incs, inns : instates := waita; 

	-- ram output side
	signal doaa, doab, doac : std_logic_vector(15 downto 0) := (others => '0');
	signal doa : std_logic_vector(15 downto 0) := (others => '0'); 

	-- buffer output side
	signal doba, dobb, dobc, dob : std_logic_vector(15 downto 0) 
				:= (others => '0');
	signal outsel : integer range 0 to 2 := 0;
	signal buflenout : std_logic_vector(7 downto 0) := (others => '0');
	signal bufcnt : std_logic_vector(7 downto 0) := (others => '0');
	signal bufcnten, bufcntrst : std_logic := '0';
	signal clra, clrb, clrc : std_logic := '0';
	signal bufack : std_logic := '0'; 
	signal addrb : std_logic_vector(7 downto 0) := (others => '0');

	type outstates is ( waita, a, donea, waitb, b, doneb, waitc, c, donec);
	signal outcs, outns : outstates := waita; 

	-- ram input side
	signal rwea, rweb, rwec : std_logic := '0';

	component RAMB4_S16_S16
	  generic (
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
	       INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000" );
	  port (DIA    : in STD_LOGIC_VECTOR (15 downto 0);
	        DIB    : in STD_LOGIC_VECTOR (15 downto 0);
	        ENA    : in STD_logic;
	        ENB    : in STD_logic;
	        WEA    : in STD_logic;
	        WEB    : in STD_logic;
	        RSTA   : in STD_logic;
	        RSTB   : in STD_logic;
	        CLKA   : in STD_logic;
	        CLKB   : in STD_logic;
	        ADDRA  : in STD_LOGIC_VECTOR (7 downto 0);
	        ADDRB  : in STD_LOGIC_VECTOR (7 downto 0);
	        DOA    : out STD_LOGIC_VECTOR (15 downto 0);
	        DOB    : out STD_LOGIC_VECTOR (15 downto 0)); 
	end component;


begin

	-- start with ram blocks:
	buffera : RAMB4_S16_S16 port map (
		DIA => BUFDIN,
		DIB => RDIN,
		ENA => '1',
		ENB => '1',
		WEA => weaa,
		WEB => rwea,
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLKA,
		CLKB => CLKB,
		ADDRA => addra,
		ADDRB => addrb,
		DOA => doaa,
		DOB => doba); 

	bufferb : RAMB4_S16_S16 port map (
		DIA => BUFDIN,
		DIB => RDIN,
		ENA => '1',
		ENB => '1',
		WEA => weab,
		WEB => rweb,
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLKA,
		CLKB => CLKB,
		ADDRA => addra,
		ADDRB => addrb,
		DOA => doab,
		DOB => dobb); 

	bufferc : RAMB4_S16_S16 port map (
		DIA => BUFDIN,
		DIB => RDIN,
		ENA => '1',
		ENB => '1',
		WEA => weac,
		WEB => rwec,
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLKA,
		CLKB => CLKB,
		ADDRA => addra,
		ADDRB => addrb,
		DOA => doac,
		DOB => dobc); 


	-- CLKA side combinational
	bufwein <= bufwe and (not mode);
	bufwdone <= '1' when bufwein = '1' and buflenin = BUFADDRIN else
					'0';
	weaa <= '1' when bufwein = '1' and (incs = A) else '0';
	weab <= '1' when bufwein = '1' and (incs = B) else '0';
	weac <= '1' when bufwein = '1' and (incs = C) else '0';
	
	doa <= doaa when RAIN(10 downto 9) = "00" else
			 doab when RAIN(10 downto 9) = "01" else
			 doac; 
	RDOUT <= doa(7 downto 0) when rain(0) = '0' else
				doa(15 downto 8); 
	BUFERROR <= '1' when  bufwe = '1' 
					and (incs = A or incs = B or incs = C) else '0'; 

	addra <= bufaddrin when mode = '0' else RAIN(8 downto 1);  

	clocka : process(CLKA, RESET) is
	begin
		if RESET = '1' then
			incs <= waita; 
		else
			if rising_edge(CLKA) then
				incs <= inns; 

				if bufaddrin = X"0A" and bufwe = '1' then
					buflenin <= BUFDIN(8 downto 1); 
				end if; 


				-- buffer full set/reset registers
				if clra = '1' then
					fulla <= '0';
				else
					if bufwedone = '1' and incs = A then
						fulla <= '1';
					end if;
				end if; 

				if clrb = '1' then
					fullb <= '0';
				else
					if bufwedone = '1' and incs = B then
						fullb <= '1';
					end if;
				end if; 

				if clrc = '1' then
					fullc <= '0';
				else
					if bufwedone = '1' and incs = C then
						fullc <= '1';
					end if;
				end if; 
			end if; 
		end if;
	end process clocka; 

	infsm: process (fulla, fullb, fullc, incs, inns) is
	begin
		case incs is 
			when waita =>
				if fulla = '0' then
					inns <= a;
				else
					inns <= waita;
				end if; 
			when a =>
				if fulla = '1' then
					inns <= waitb;
				else
					inns <= a;
				end if; 
			when waitb =>
				if fullb = '0' then
					inns <=b;
				else
					inns <= waitb;
				end if; 
			when b =>
				if fullb = '1' then
					inns <= waitc;
				else
					inns <= b;
				end if; 
			when waitc =>
				if fullc = '0' then
					inns <= c;
				else
					inns <= waitc;
				end if; 
			when c =>
				if fullc = '1' then
					inns <= waita;
				else
					inns <= c;
				end if; 
			when others =>
				inns <= waita; 
		end case; 
	end process infsm;

	-- combinational for B side
	dob <= doba when outsel = 0 else
			 dobb when outsel = 1 else
			 dobc; 
	BUFDOUT <= dob; 
	
	rwea <= '1' when rwe = '1' and rain(9 downto 8) = "00";
	rweb <= '1' when rwe = '1' and rain(9 downto 8) = "01";
	rwec <= '1' when rwe = '1' and rain(9 downto 8) = "10";

	addrb <= bufcnt when mode = '0' else RAIN(7 downto 0); 

	clockb: process(CLKB, RESET) is
	begin
		if RESET = '1' then
			outcs <= waita;
		else
			if rising_edge(CLKB) then
				outcs <= outns; 

				if bufaddrin = (X"0B") then
					buflenout <= dob(7 downto 0); 
				end if; 

				BUFACKOUT <= bufack; 

				bufack <= bufcnten; 
				
				if bufcntrst = '1' then
					bufcnt <= (others => '0');
				else
					if bufcnten = '1' then
						bufcnt <= bufcnt + 1;
					end if;
				end if; 



			end if;
		end if;
	end process clockb; 

	outfsm : process (outcs, fulla, fullb, fullc, nextout, buflenout, bufcnt) is
	begin
		case outcs is
			when waita => 
				bufcnten <= '0';
				bufcntrst <= '1';
				clra <= '0';
				clrb <= '0';
				clrc <= '0';
				outsel <= 0; 
				if fulla = '1' and nextout = '1' then
					outns <= a;
				else
					outns <= waita;
				end if; 
			when a => 
				bufcnten <= '1';
				bufcntrst <= '0';
				clra <= '0';
				clrb <= '0';
				clrc <= '0';
				outsel <= 0; 
				if bufcnt = buflenout then
					outns <= donea;
				else
					outns <= a;
				end if; 
			when donea => 
				bufcnten <= '1';
				bufcntrst <= '0';
				clra <= '1';
				clrb <= '0';
				clrc <= '0';
				outsel <= 0; 
				outns <= waitb; 
			when waitb => 
				bufcnten <= '0';
				bufcntrst <= '1';
				clra <= '0';
				clrb <= '0';
				clrc <= '0';
				outsel <= 0; 
				if fullc = '1' and nextout = '1' then
					outns <= b;
				else
					outns <= waitb;
				end if; 
			when b => 
				bufcnten <= '1';
				bufcntrst <= '0';
				clra <= '0';
				clrb <= '0';
				clrc <= '0';
				outsel <= 0; 
				if bufcnt = buflenout then
					outns <= doneb;
				else
					outns <= b;
				end if; 
			when doneb => 
				bufcnten <= '1';
				bufcntrst <= '0';
				clra <= '0';
				clrb <= '1';
				clrc <= '0';
				outsel <= 0; 
				outns <= waitc; 
			when waitc => 
				bufcnten <= '0';
				bufcntrst <= '1';
				clra <= '0';
				clrb <= '0';
				clrc <= '0';
				outsel <= 0; 
				if fullc = '1' and nextout = '1' then
					outns <= c;
				else
					outns <= waitc;
				end if; 
			when c => 
				bufcnten <= '1';
				bufcntrst <= '0';
				clra <= '0';
				clrb <= '0';
				clrc <= '0';
				outsel <= 0; 
				if bufcnt = buflenout then
					outns <= donec;
				else
					outns <= c;
				end if; 
			when donec => 
				bufcnten <= '1';
				bufcntrst <= '0';
				clra <= '0';
				clrb <= '0';
				clrc <= '1';
				outsel <= 0; 
				outns <= waita;
			when others => 
				bufcnten <= '0';
				bufcntrst <= '1';
				clra <= '0';
				clrb <= '0';
				clrc <= '0';
				outsel <= 0; 
				outns <= waita;
		end case; 
	end process outfsm; 
end Behavioral;
