library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity events is
    Port ( CLK : in std_logic;
           SYSCLK : in std_logic;
           RESET : in std_logic;
           DIN : in std_logic_vector(15 downto 0);
           DOUT : out std_logic_vector(15 downto 0);
           ADDR : in std_logic_vector(3 downto 0);
           WE : in std_logic;
			  RD : in std_logic; 
			  MODE : out std_logic;
			  DSPRESET : out std_logic; 
           RAIN : out std_logic_vector(9 downto 0);
           RDIN : out std_logic_vector(15 downto 0);
			  RWE : out std_logic; 
           EDATAO : out std_logic_vector(15 downto 0);
           EADDRO : out std_logic_vector(7 downto 0);
           EOE : out std_logic;
           EEVENT : in std_logic;
           ECE : in std_logic;
           EDATAI : in std_logic_vector(15 downto 0);
           EADDRI : in std_logic_vector(7 downto 0);
			  NEWEVENTS : out std_logic;
			  MADDR : in std_logic_vector(7 downto 0);
			  MODERST : in std_logic;
			  NEWMYEVENT : out std_logic);
end events;

architecture Behavioral of events is
-- EVENTS.VHD -- this is the combined events architecture for a DSP. The E* 
-- outputs are to be connected to the event bus, with the EOE controlling
-- the output tristate. 

	-- event out signals
	signal adspout : std_logic_vector(7 downto 0) := (others => '0');
	signal aeout, aeoutl : std_logic_vector(7 downto 0) := (others => '0');
	signal eoutfaddrinc, ewe : std_logic := '0';
	signal edin : std_logic_vector(15 downto 0) := (others => '0'); 

	type outstates is (eoutchk, evbufw0, evbufw1, evbufw2, evbufw3,
							 evbufw4, evbufw5, evbufw6, evbufw7, evbufw8, waitdone);
							 
	signal outcs, outns : outstates := eoutchk;  
	-- event in signals
	signal adspin : std_logic_vector(8 downto 0) := (others => '0'); 
	signal aein : std_logic_vector(8 downto 0) := (others => '0'); 

	signal einfaddrinc, einfwe, einl, einll, ein, eindelta : std_logic := '0';
	signal edout : std_logic_vector(15 downto 0) := (others => '0');
	signal rainen : std_logic := '0';
	signal raincnt : std_logic_vector(9 downto 0) := (others => '0');

	type instates is (none, einchk, modeen, dspen, bramwevt,
							bramw0, bramw1, bramw2, bramw3, 
							dspram1, dspram2, dspram3, dspram4, dspram5); 

	signal incs, inns : instates := none; 

   signal mine, done, loaddone : std_logic := '0'; 




	component EventInputs is
	    Port ( CLK : in std_logic;
	           EADDR : in std_logic_vector(7 downto 0);
	           EDATA : in std_logic_vector(15 downto 0);
	           EEVENT : in std_logic;
	           DOUT : out std_logic_vector(15 downto 0);
				  ADDR : in std_logic_vector(2 downto 0); 
				  MADDR : in std_logic_vector(6 downto 0); 
	           MINE : out std_logic;
	           EVENT : out std_logic);
	end component;


	component EventOutputs is
	    Port ( CLK : in std_logic;
	           SYSCLK : in std_logic;
	           ADDR : in std_logic_vector(3 downto 0);
	           DIN : in std_logic_vector(15 downto 0);
				  LOADDONE : in std_logic; 
	           DONE : out std_logic;
	           WE : in std_logic;
	           EDATA : out std_logic_vector(15 downto 0);
	           EADDR : out std_logic_vector(7 downto 0);
	           EOE : out std_logic;
	           EEVENT : in std_logic;
	           ECE : in std_logic);
	end component;

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

	component RAMB4_S8_S8
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
	  port (DIA    : in STD_LOGIC_VECTOR (7 downto 0);
	        DIB    : in STD_LOGIC_VECTOR (7 downto 0);
	        ENA    : in STD_logic;
	        ENB    : in STD_logic;
	        WEA    : in STD_logic;
	        WEB    : in STD_logic;
	        RSTA   : in STD_logic;
	        RSTB   : in STD_logic;
	        CLKA   : in STD_logic;
	        CLKB   : in STD_logic;
	        ADDRA  : in STD_LOGIC_VECTOR (8 downto 0);
	        ADDRB  : in STD_LOGIC_VECTOR (8 downto 0);
	        DOA    : out STD_LOGIC_VECTOR (7 downto 0);
	        DOB    : out STD_LOGIC_VECTOR (7 downto 0)); 
	end component;


begin

	-- other components, external connections, etc. 
	fifoout: RAMB4_S16_S16 port map (
		DIA => DIN,
		DIB => X"0000",
		ENA => '1',
		ENB => '1',
		WEA => WE, 
		WEB => '0',
		RSTA => RESET,
		RSTB => RESET,
		CLKA => clk,
		CLKB => clk, 
		ADDRA => adspout,
		ADDRB => aeout,
		DOA => open,
		DOB => edin); 

	fifoin_low: RAMB4_S8_S8 port map (
		DIA => X"00",
		DIB => edout(7 downto 0),
		ENA => '1',
		ENB => '1',
		WEA => '0',
		WEB => einfwe,
		RSTA => RESET,
		RSTB => RESET,
		CLKA => clk,
		CLKB => clk,
		ADDRA => adspin,
		ADDRB => aein,
		DOA => DOUT(7 downto 0),
		DOB => open); 

	fifoin_high: RAMB4_S8_S8 port map (
		DIA => X"00",
		DIB => edout(15 downto 8),
		ENA => '1',
		ENB => '1',
		WEA => '0',
		WEB => einfwe,
		RSTA => RESET,
		RSTB => RESET,
		CLKA => clk,
		CLKB => clk,
		ADDRA => adspin,
		ADDRB => aein,
		DOA => DOUT(15 downto 8),
		DOB => open); 

 	einputs: EventInputs port map(
		CLK => SYSCLK,
		EADDR => EADDRI,
		EDATA => EDATAI,
		EEVENT => EEVENT,
		DOUT => edout,
		ADDR => aein(2 downto 0),
		MADDR => MADDR( 6 downto 0),
		MINE => mine,
		EVENT => ein); 
	
	eoutputs : EventOutputs port map (
		CLK => clk,
		SYSCLK => sysclk,
		ADDR => aeoutl(3 downto 0),
		DIN => edin,
		LOADDONE => loaddone, 
		DONE => done,
		WE => ewe,
		EDATA => EDATAO,
		EADDR => EADDRO, 
		EOE => EOE,
		EEVENT => EEVENT,
		ECE => ECE); 



	-- combinational
	adspout(3 downto 0) <= ADDR(3 downto 0); 
	adspin(2 downto 0) <= ADDR(2 downto 0) ;
	NEWEVENTS <= '1' when adspin(8 downto 3) /= aein(8 downto 3) else '0';
	loaddone <= '1' when addr(3 downto 0) = X"9" and WE = '1'; 
	eindelta <= einl and (not einll);

	NEWMYEVENT <= mine and ein; 

	clock: process(CLK, RESET) is
	begin
	    if RESET = '1' then
		 	incs <= none; 
			outcs <= eoutchk;
		else
			if rising_edge(CLK) then
				incs <= inns;
				outcs <= outns;

				-- counters for event outs
				if WE = '1' and ADDR = X"9" then
					adspout(7 downto 4) <= adspout(7 downto 4) + 1;
				end if; 

				if eoutfaddrinc = '1' then
					aeout(7 downto 4) <= aeout(7 downto 4) + 1;
				end if; 

				aeoutl <= aeout; 

				--event input counters, etc. 

				if RD = '1' and ADDR = X"6" and 
					(adspin(8 downto 3) /= aein(8 downto 3) ) then
					adspin(8 downto 3) <= adspin(8 downto 3) + 1;
				end if; 

				if einfaddrinc = '1' then
					aein(8 downto 3) <= aein(8 downto 3) + 1;
				end if; 

				-- event decoding
				einl <= ein;
				einll <= einl; 

				if moderst = '1' then
					MODE <= '0';
				else
					if edout(0) = '1' and incs = modeen then
						MODE <= '1';
					end if;
				end if; 

				if incs = dspen then
					DSPRESET <= not edout(0);
				end if; 

				if incs = bramwevt then
					RAINCNT <= edout(9 downto 0);
				else
					if rainen = '1' then
						raincnt <= raincnt + 1; 
					end if; 
				end if; 

				RAIN <= raincnt;
				RWE <= rainen;
				RDIN <= edout; 
			end if; 
		end if;
	end process clock; 
	
	
			
   outfsm: process(outcs, outns, adspout, aeout, done) is
	begin
		case outcs is 
			when eoutchk => 
				aeout(3 downto 0) <= X"0";
				ewe <= '0';
				eoutfaddrinc <= '0';
				if adspout /= aeout then
					outns <= evbufw0;
				else
					outns <= eoutchk;		
				end if; 
			when evbufw0 => 
				aeout(3 downto 0) <= X"1";
				ewe <= '1';
				eoutfaddrinc <= '0';
				outns <= evbufw1; 
			when evbufw1 => 
				aeout(3 downto 0) <= X"2";
				ewe <= '1';
				eoutfaddrinc <= '0';
				outns <= evbufw2; 
			when evbufw2 => 
				aeout(3 downto 0) <= X"3";
				ewe <= '1';
				eoutfaddrinc <= '0';
				outns <= evbufw3; 
			when evbufw3 => 
				aeout(3 downto 0) <= X"4";
				ewe <= '1';
				eoutfaddrinc <= '0';
				outns <= evbufw4; 
			when evbufw4 => 
				aeout(3 downto 0) <= X"5";
				ewe <= '1';
				eoutfaddrinc <= '0';
				outns <= evbufw5; 
			when evbufw5 => 
				aeout(3 downto 0) <= X"6";
				ewe <= '1';
				eoutfaddrinc <= '0';
				outns <= evbufw6; 
			when evbufw6 => 
				aeout(3 downto 0) <= X"7";
				ewe <= '1';
				eoutfaddrinc <= '0';
				outns <= evbufw7; 
			when evbufw7 => 
				aeout(3 downto 0) <= X"8";
				ewe <= '1';
				eoutfaddrinc <= '0';
				outns <= evbufw8; 
			when evbufw8 => 
				aeout(3 downto 0) <= X"8";
				ewe <= '1';
				eoutfaddrinc <= '1';
				outns <= waitdone; 
			when waitdone => 
				aeout(3 downto 0) <= X"0";
				ewe <= '0';
				eoutfaddrinc <= '0';
				if done = '1' then
					outns <= eoutchk;
				else
					outns <= waitdone;
				end if; 
			when others => 
				aeout(3 downto 0) <= X"0";
				eoutfaddrinc <= '0';
				ewe <= '0';
				outns <= eoutchk;
		end case; 
	end process outfsm; 


	infsm : process(incs, eindelta, mine, edout) is
	begin
		case incs is
			when none => 
				aein(2 downto 0) <= "000";
				einfwe <= '0';
				einfaddrinc <= '0';
				rainen <= '0';  
				if eindelta = '1' then
					inns <= einchk;
				else
					inns <= none;
				end if; 
			when einchk => 
				aein(2 downto 0) <= "000";
				einfwe <= '1';
				einfaddrinc <= '0';
				rainen <= '0';   
				if mine = '1' then
					if edout(7 downto 0) = X"02" then
						inns <= dspen;
					elsif edout(7 downto 0) = X"01" then
						inns <= modeen;
					elsif edout(7 downto 0) = X"03" then
						inns <= bramwevt;
					else
						inns <= dspram1; 
					end if; 
				else
					inns <= none;
				end if; 
			when modeen => 
				aein(2 downto 0) <= "001";
				einfwe <= '0';
				einfaddrinc <= '0';
				rainen <= '0';   
				inns <= none; 
			when dspen => 
				aein(2 downto 0) <= "001";
				einfwe <= '0';
				einfaddrinc <= '0';
				rainen <= '0';   
				inns <= none; 
			when bramwevt => 
				aein(2 downto 0) <= "001";
				einfwe <= '0';
				einfaddrinc <= '0';
				rainen <= '0';   
				inns <= bramw0; 
			when bramw0 => 
				aein(2 downto 0) <= "010";
				einfwe <= '0';
				einfaddrinc <= '0';
				rainen <= '1';   
				inns <= bramw1; 
			when bramw1 => 
				aein(2 downto 0) <= "011";
				einfwe <= '0';
				einfaddrinc <= '0';
				rainen <= '1';   
				inns <= bramw2; 
			when bramw2 => 
				aein(2 downto 0) <= "100";
				einfwe <= '0';
				einfaddrinc <= '0';
				rainen <= '1';   
				inns <= bramw3; 
			when bramw3 => 
				aein(2 downto 0) <= "101";
				einfwe <= '0';
				einfaddrinc <= '0';
				rainen <= '1';   
				inns <= none; 
			when dspram1 => 
				aein(2 downto 0) <= "001";
				einfwe <= '1';
				einfaddrinc <= '0';
				rainen <= '0';   
				inns <= dspram2; 
			when dspram2 => 
				aein(2 downto 0) <= "010";
				einfwe <= '1';
				einfaddrinc <= '0';
				rainen <= '0';   
				inns <= dspram3; 
			when dspram3 => 
				aein(2 downto 0) <= "011";
				einfwe <= '1';
				einfaddrinc <= '0';
				rainen <= '0';   
				inns <= dspram4; 
			when dspram4 => 
				aein(2 downto 0) <= "100";
				einfwe <= '1';
				einfaddrinc <= '0';
				rainen <= '0';   
				inns <= dspram5; 
			when dspram5 => 
				aein(2 downto 0) <= "101";
				einfwe <= '1';
				einfaddrinc <= '1';
				rainen <= '0';   
				inns <= none; 
			when others => 
				aein(2 downto 0) <= "000";
				einfwe <= '0';
				einfaddrinc <= '0';
				rainen <= '0';   
				inns <= none;
		end case;
	end process infsm;  


		
end Behavioral;
