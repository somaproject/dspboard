library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity fibertx is
    Port ( CLK : in std_logic;
	 		  RESET : in std_logic; 
           DATAA : in std_logic_vector(15 downto 0);
           ADDRA : in std_logic_vector(2 downto 0);
           WRA : in std_logic;
           DATAB : in std_logic_vector(15 downto 0);
           ADDRB : in std_logic_vector(2 downto 0);
           WRB : in std_logic;
           FIBEROUT : out std_logic;
			  CMDIDA : in std_logic_vector(2 downto 0);
			  CMDIDB : in std_logic_vector(2 downto 0);
			  ERRORA : out std_logic;
			  ERRORB : out std_logic;
			  STATUS : in std_logic);
end fibertx;

architecture Behavioral of fibertx is
-- FIBERTX.VHD -- memory-mapped acqboard-command-output system. 

  -- data A signals
  signal cmda, dw12a, dw34a : std_logic_vector(15 downto 0) := (others => '0');
  signal byteina : std_logic_vector(7 downto 0) := (others => '0');
  signal newcmda, rstcmda : std_logic := '0';

  -- data B signals
  signal cmdb, dw12b, dw34b : std_logic_vector(15 downto 0) := (others => '0');
  signal byteinb : std_logic_vector(7 downto 0) := (others => '0');
  signal newcmdb, rstcmdb : std_logic := '0';

  signal modesel : integer range 0 to 3 := 0;

  signal din, dinl : std_logic_vector(7 downto 0) := (others => '0'); 

  signal bytesel : integer range 0 to 7 := 0; 
  signal byteselrst : std_logic := '0'; 

  -- output-related signals
  signal outbyte, clk8 : std_logic := '0';

  signal kin, sout : std_logic := '0';
  signal dout, doutreg : std_logic_vector(9 downto 0) := (others => '0');

  type states is (chka, sendka, sendbytea, donea, chkb, sendkb, sendbyteb, doneb,
  					waita, waitb, error);
  signal cs, ns : states := chka; 

  signal timing : std_logic_vector(7 downto 0) := (others => '0'); 

  -- watchdog-related signals
  signal pcmdida, pcmdidb: std_logic_vector(2 downto 0); 
  signal rsttimeout, seterr : std_logic := '0';
  signal timeout : integer := 0; 


	component encode8b10b IS
		port (
		din: IN std_logic_VECTOR(7 downto 0);
		kin: IN std_logic;
		clk: IN std_logic;
		dout: OUT std_logic_VECTOR(9 downto 0);
		ce: IN std_logic);
	END component;

begin

	byteina <= cmda(7 downto 0) when bytesel = 0 else	
				  dw12a(7 downto 0) when bytesel = 1 else
				  dw12a(15 downto 8) when bytesel = 2 else
				  dw34a(7 downto 0) when bytesel = 3 else
				  dw34a(15 downto 8);
	byteinb <= cmdb(7 downto 0) when bytesel = 0 else	
				  dw12b(7 downto 0) when bytesel = 1 else
				  dw12b(15 downto 8) when bytesel = 2 else
				  dw34b(7 downto 0) when bytesel = 3 else
				  dw34b(15 downto 8);
	

  	din <= byteina when modesel = 0 else
  			X"BC" when modesel = 1 else
			X"00" when modesel = 2 else
			byteinb when modesel = 3; 

	sout <= doutreg(0); 

	encoder: encode8b10b port map (
		DIN => dinl,
		KIN => kin,
		CE => outbyte,
		DOUT => dout, 
		CLK => CLK); 
	clock : process(RESET, CLK) is
	begin
		if RESET = '0' then
			cs <= chka;
		else
			if rising_edge(CLK) then
				cs <= ns; 


				-- TIMING CODE
				if timing = X"4F" then
					timing <= (others => '0'); 
				else
					timing <= timing + 1; 
				end if; 

				if timing(2 downto 0) = "000" then
					clk8 <= '1';
				else
					clk8 <= '0';
				end if; 

				if timing = X"00" then
					outbyte <= '1';
				else
					outbyte <= '0';
				end if; 


				-- A latches
				if ADDRA	= "000" and WRA = '1' then
					cmda(3 downto 0) <= DATAA(3 downto 0); 
				end if; 

				if ADDRA = "001" and WRA = '1' then
					cmda(7 downto 4) <= '0' & DATAA(2 downto 0);
				end if; 

				if ADDRA = "010" and WRA = '1' then
					dw12a <= DATAA;
				end if; 

				if ADDRA = "011" and WRA = '1' then
					dw34a <= DATAA;
				end if; 

				if WRA = '1' and ADDRA = "100" then
					newcmda <= '1';
				else
					if rstcmda = '1' then
						newcmda <= '0';
					end if; 
				end if; 


				-- B latches
				if ADDRB	= "000" and WRB = '1' then
					cmdb(3 downto 0) <= DATAB(3 downto 0); 
				end if; 

				if ADDRB = "001" and WRB = '1' then
					cmdb(7 downto 4) <= '1' & DATAB(2 downto 0);
				end if; 

				if ADDRB = "010" and WRB = '1' then
					dw12b <= DATAB;
				end if; 

				if ADDRB = "011" and WRB = '1' then
					dw34b <= DATAB;
				end if; 

				if WRB = '1' and ADDRB = "100" then
					newcmdb <= '1';
				else
					if rstcmdb = '1' then
						newcmdb <= '0';
					end if; 
				end if; 

				if byteselrst = '1' then
					bytesel <= 0;
				else
					if outbyte = '1' then
						bytesel <= bytesel + 1; 
					end if;
				end if; 


			   -- outbyte-related

				if outbyte = '1' then
					dinl <= din;
					if modesel = 1 then
						kin <= '1'; 
					else
						kin <= '0';
					end if; 
				end if; 

				if outbyte = '1' then
					doutreg <= dout; 
				else 
					if clk8 = '1' then
						doutreg <= '0' & doutreg(9 downto 1);
					end if; 
				end if; 
				if clk8 = '1' then
					FIBEROUT <= sout; 
				end if; 

				-- timeout errors
				if seterr = '1' then
					ERRORA <= '1';
				else
					if WRA = '1' and ADDRA = "100" then
						ERRORA <= '0';
					end if; 
				end if; 

				
				if seterr = '1' then
					ERRORB <= '1';
				else
					if WRB = '1' and ADDRB = "100" then
						ERRORB <= '0';
					end if; 
				end if; 

				if rsttimeout = '1' then
					timeout <= 200000000; 
				else
					if timeout /= 0 then
						timeout <= timeout - 1;
					end if; 
				end if; 

				if WRA = '1' and ADDRA = "100" then
					pcmdida <= cmda(6 downto 4); 
				end if; 
				if WRB = '1' and ADDRB = "100" then
					pcmdidb <= cmdb(6 downto 4); 
				end if; 


			end if;
		end if; 
	end process clock; 

	fsm : process(outbyte, newcmda, bytesel, newcmdb) is
	begin
		case cs is
			when chka => 
				modesel <= 2; 
				byteselrst <= '1'; 
				rstcmda <= '0'; 
				rstcmdb <= '0'; 
				rsttimeout <= '1';
				seterr <= '0'; 
				if outbyte = '1' then
					if newcmda = '1' then
						ns <= sendka;
					else
						ns <= chkb;
					end if; 
				else
					ns <= chka;
				end if; 
			when sendka => 
				modesel <= 1; 
				byteselrst <= '1'; 
				rstcmda <= '0'; 
				rstcmdb <= '0'; 
				rsttimeout <= '1';
				seterr <= '0';
				if outbyte = '1' then
					ns <= sendbytea;
				else
					ns <= sendka;
				end if; 
			when sendbytea	=>
				modesel <= 0; 
				byteselrst <= '0'; 
				rstcmda <= '0'; 
				rstcmdb <= '0';
				rsttimeout <= '1';
				seterr <= '0'; 
				if outbyte = '1' and bytesel = 4	 then
					ns <= waita;
				else
					ns <= sendbytea;
				end if; 
			when waita	=>
				modesel <= 0; 
				byteselrst <= '0'; 
				rstcmda <= '0'; 
				rstcmdb <= '0';
				rsttimeout <= '0';
				seterr <= '0'; 
				if timeout = 0 or STATUS = '0' then
					ns <= error;
				else
					if CMDIDA = pcmdida then
						ns <= donea; 
					else
						ns <= waita;
					end if;
				end if; 
			when donea =>
				modesel <= 0; 
				byteselrst <= '1'; 
				rstcmda <= '1'; 
				rstcmdb <= '0';
				rsttimeout <= '1';
				seterr <= '0'; 
				ns <= chkb; 
			when chkb => 
				modesel <= 2; 
				byteselrst <= '1'; 
				rstcmda <= '0'; 
				rstcmdb <= '0';
				rsttimeout <= '1';
				seterr <= '0'; 
				if outbyte = '1' then
					if newcmdb= '1' then
						ns <= sendkb;
					else
						ns <= chka;
					end if; 
				else
					ns <= chka;
				end if; 
			when sendkb => 
				modesel <= 1; 
				byteselrst <= '1'; 
				rstcmda <= '0'; 
				rstcmdb <= '0';
				rsttimeout <= '1';
				seterr <= '0'; 
				if outbyte = '1' then
					ns <= sendbyteb;
				else
					ns <= sendkb;
				end if; 
			when sendbyteb	=>
				modesel <= 0; 
				byteselrst <= '0'; 
				rstcmda <= '0'; 
				rstcmdb <= '0'; 
				rsttimeout <= '1';
				seterr <= '0';
				if outbyte = '1' and bytesel = 4	 then
					ns <= waitb;
				else
					ns <= sendbyteb;
				end if; 
			when waitb	=>
				modesel <= 0; 
				byteselrst <= '0'; 
				rstcmda <= '0'; 
				rstcmdb <= '0';
				rsttimeout <= '0';
				seterr <= '0'; 
				if timeout = 0 or STATUS = '0' then
					ns <= error;
				else
					if CMDIDB = pcmdidb then
						ns <= doneb; 
					else
						ns <= waitb;
					end if;
				end if; 

			when doneb =>
				modesel <= 0; 
				byteselrst <= '1'; 
				rstcmda <= '0'; 
				rstcmdb <= '1'; 
				rsttimeout <= '1';
				seterr <= '0';
				ns <= chka; 
			when error	=>
				modesel <= 0; 
				byteselrst <= '0'; 
				rstcmda <= '1'; 
				rstcmdb <= '1';
				rsttimeout <= '1';
				seterr <= '1';
				if STATUS = '1' then
					ns <= chka;
				else
					ns <= error; 
				end if; 
				 

			when others =>
				modesel <= 0; 
				byteselrst <= '1'; 
				rstcmda <= '0'; 
				rstcmdb <= '0';
				rsttimeout <= '1';
				seterr <= '0';
				ns <= chka; 

		end case;
	end process fsm; 
end Behavioral;
