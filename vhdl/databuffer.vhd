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
           BUFADDRIN : in std_logic_vector(9 downto 0);
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
           MODE : in std_logic;
			  DSPRESET : in std_logic);
end databuffer;

architecture Behavioral of databuffer is
-- DATABUFFER.VHD -- implements triple-buffering to let DSP write data
-- events to the databus. uses 3 blockselect+ rams. 

	-- buffer input side
	signal bufwein, bufwdone : std_logic := '0';
	signal fulla, fullb, fullc : std_logic := '0';
	signal weaa, weab, weac : std_logic := '0';
	signal addra : std_logic_vector(9 downto 0) := (others => '0');
   signal buflenin, ra : std_logic_vector(9 downto 0) := (others => '0'); 
		type instates is (waita, a, waitb, b, waitc, c); 
	signal incs, inns : instates := waita;
	signal bufwea, bufweb, bufwec : std_logic := '0';  

	-- ram output side
	signal doa : std_logic_vector(15 downto 0) := (others => '0'); 

	-- buffer output side
	signal doba, dobb, dobc, dob : std_logic_vector(15 downto 0) 
				:= (others => '0');
	signal outsel : integer range 0 to 2 := 0;
	signal buflenout : std_logic_vector(9 downto 0) := (others => '0');
	signal bufcnt : std_logic_vector(9 downto 0) := (others => '0');
	signal bufcnten, bufcntrst : std_logic := '0';
	signal clra, clrb, clrc : std_logic := '0';

	type outstates is ( waita, a, donea, waitb, b, doneb, waitc, c, donec);
	signal outcs, outns : outstates := waita; 

	-- ram input side
	signal dia : std_logic_vector(15 downto 0) := (others => '0');

	constant LENADDR : std_logic_vector(9 downto 0) := "0000000001"; 	
	-- this is the location of the word that contains length info

	 

	component RAMB16_S18_S18 
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
	        DIB    : in STD_LOGIC_VECTOR (15 downto 0);
	        DIPA    : in STD_LOGIC_VECTOR (1 downto 0);
	        DIPB    : in STD_LOGIC_VECTOR (1 downto 0);
	        ENA    : in STD_logic;
	        ENB    : in STD_logic;
	        WEA    : in STD_logic;
	        WEB    : in STD_logic;
	        SSRA   : in STD_logic;
	        SSRB   : in STD_logic;
	        CLKA   : in STD_logic;
	        CLKB   : in STD_logic;
	        ADDRA  : in STD_LOGIC_VECTOR (9 downto 0);
	        ADDRB  : in STD_LOGIC_VECTOR (9 downto 0);
	        DOA    : out STD_LOGIC_VECTOR (15 downto 0);
	        DOB    : out STD_LOGIC_VECTOR (15 downto 0);
	        DOPA    : out STD_LOGIC_VECTOR (1 downto 0);
	        DOPB    : out STD_LOGIC_VECTOR (1 downto 0)
	       ); 

	end component;




begin

	-- start with ram blocks:
	buffera : RAMB16_S18_S18 port map (
		DIA => dia,
		DIB => X"0000",
		DIPA => "00",
		DIPB => "00", 
		ENA => '1', 
		ENB => '1', 
		WEA => weaa,
		WEB => '0',
		SSRA => '0',
		SSRB => '0',
		CLKA => CLKA,
		CLKB => CLKB, 
		ADDRA => addra,
		ADDRB => bufcnt,
		DOA => doa, 
		DOB => doba);

	bufferb : RAMB16_S18_S18 port map (
		DIA => BUFDIN,
		DIB => X"0000",
		DIPA => "00",
		DIPB => "00", 
		ENA => '1', 
		ENB => '1', 
		WEA => weab, 
		WEB => '0',
		SSRA => '0',
		SSRB => '0',
		CLKA => CLKA,
		CLKB => CLKB, 
		ADDRA => BUFADDRIN,
		ADDRB => bufcnt,
		DOA => open, 
		DOB => dobb);

	
	bufferc : RAMB16_S18_S18 port map (
		DIA => BUFDIN,
		DIB => X"0000",
		DIPA => "00",
		DIPB => "00", 
		ENA => '1', 
		ENB => '1', 
		WEA => weac, 
		WEB => '0',
		SSRA => '0',
		SSRB => '0',
		CLKA => CLKA,
		CLKB => CLKB, 
		ADDRA => BUFADDRIN,
		ADDRB => bufcnt,
		DOA => open, 
		DOB => dobc);

	




	-- CLKA side combinational
	bufwein <= bufwe and (not mode);
	bufwdone <= '1' when bufwein = '1' and (buflenin -1) = BUFADDRIN  else
					'0';
	bufwea <= '1' when bufwein = '1' and (incs = A) else '0';
	bufweb <= '1' when bufwein = '1' and (incs = B) else '0';
	bufwec <= '1' when bufwein = '1' and (incs = C) else '0';

	weaa <= RWE when mode = '1' else bufwea; 
	weab <= '0' when mode = '1' else bufweb; 
	weac <= '0' when mode = '1' else bufwec; 



	dia <= rdin when mode = '1' else bufdin; 

	
	RDOUT <= doa(7 downto 0) when RAOUT(0) = '0' else
				doa(15 downto 8); 
	BUFERROR <= '1' when  bufwe = '1' 
					and (incs = A or incs = B or incs = C) else '0'; 

	addra <= ra when mode = '1' else bufaddrin;
	ra <= raout(10 downto 1) when DSPRESET = '1' else RAIN(9 downto 0); 


	clocka : process(CLKA, RESET) is
	begin
		if RESET = '1' then
			incs <= waita; 
		else
			if rising_edge(CLKA) then
				incs <= inns; 

				if incs = waita or incs = waitb or incs = waitc then
					buflenin <= (others => '1'); 
				else
					if bufaddrin = LENADDR and bufwe = '1' then
						buflenin <=  BUFDIN(9 downto 0); 
					end if; 
				end if; 

				-- buffer full set/reset registers
				if clra = '1' then
					fulla <= '0';
				else
					if bufwdone = '1' and incs = A then
						fulla <= '1';
					end if;
				end if; 

				if clrb = '1' then
					fullb <= '0';
				else
					if bufwdone = '1' and incs = B then
						fullb <= '1';
					end if;
				end if; 

				if clrc = '1' then
					fullc <= '0';
				else
					if bufwdone = '1' and incs = C then
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
	
	clockb: process(CLKB, RESET) is
	begin
		if RESET = '1' then
			outcs <= waita;
		else
			if rising_edge(CLKB) then
				outcs <= outns; 

				if outcs = waita or outcs = waitb or outcs = waitc then
					buflenout <= (others => '1');
				else
					if bufcnt = (LENADDR + 1) then
						buflenout <= dob(9 downto 0); 
					end if; 
				end if; 
				--BUFACKOUT <= bufack; 

				BUFACKOUT <= bufcnten; 
				
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
				outsel <= 1; 
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
				outsel <= 1; 
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
				outsel <= 1; 
				outns <= waitc; 
			when waitc => 
				bufcnten <= '0';
				bufcntrst <= '1';
				clra <= '0';
				clrb <= '0';
				clrc <= '0';
				outsel <= 2; 
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
				outsel <= 2; 
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
				outsel <= 2; 
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
