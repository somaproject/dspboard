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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity dpdistram is 
 port (clk  : in std_logic; 
 	we   : in std_logic; 
 	a    : in std_logic_vector(2 downto 0); 
 	dpra : in std_logic_vector(2 downto 0); 
 	di   : in std_logic_vector(15 downto 0); 
 	spo  : out std_logic_vector(15 downto 0); 
 	dpo  : out std_logic_vector(15 downto 0)); 
 end dpdistram;

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
							 evbufw4, evbufw5, evbufw6, evbufw7, evbufw8, 
							 wndone, waitdone);
							 
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

	-- interface to async dist ram:
	signal dra : std_logic_vector(2 downto 0) := (others => '0');
	signal dwe : std_logic := '0';
	signal ddi : std_logic_vector(15 downto 0) := (others => '0');

	type dstates is (echk, drw0, drw1, drw2, drw3, drw4, drw5, waitread,
					incaddr);
	signal dcs, dns : dstates := echk; 
	
	 


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
	       INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000403020100";
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



	component dpdistram is 
	 port (clk  : in std_logic; 
	 	we   : in std_logic; 
	 	a    : in std_logic_vector(2 downto 0); 
	 	dpra : in std_logic_vector(2 downto 0); 
	 	di   : in std_logic_vector(15 downto 0); 
	 	spo  : out std_logic_vector(15 downto 0); 
	 	dpo  : out std_logic_vector(15 downto 0)); 
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
		DOA => ddi(7 downto 0),
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
		DOA => ddi(15 downto 8),
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

 	outram: dpdistram port map (
		clk => CLK,
		we => dwe,
		a => dra,
		dpra => ADDR(2 downto 0),
		di =>  ddi,
		spo => open,
		dpo => DOUT); 



	-- combinational
	adspout(3 downto 0) <= ADDR(3 downto 0); 
	
	loaddone <= '1' when addr(3 downto 0) = X"9" and WE = '1' else '0'; 
	eindelta <= einl and (not einll);

	NEWMYEVENT <= mine and ein; 
	clock: process(CLK, RESET) is
	begin
	    if RESET = '1' then
		 	incs <= none; 
			outcs <= eoutchk;
			dcs <= echk; 
		else
			if rising_edge(CLK) then
				incs <= inns;
				outcs <= outns;
				dcs <= dns; 

				-- counters for event outs
				if WE = '1' and ADDR = X"9" then
					adspout(7 downto 4) <= adspout(7 downto 4) + 1;
				end if; 

				if eoutfaddrinc = '1' then
					aeout(7 downto 4) <= aeout(7 downto 4) + 1;
				end if; 

				aeoutl <= aeout; 

				--event input counters, etc. 

				if dcs = incaddr then
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
				if adspout(7 downto 4)  /= aeout(7 downto 4) then
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
				outns <= wndone; 
			when wndone => 
				aeout(3 downto 0) <= X"8";
				ewe <= '0';
				eoutfaddrinc <= '0';
				if done = '0' then
					outns <= waitdone;
				else
					outns <= wndone; 
				end if;  
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

	dfsm: process (dcs, ADDR, RD, adspin, aein) is 
	begin
		case dcs is 
			when echk => 
				dra <= "000";
				adspin(2 downto 0) <= "000";
				dwe <= '0';
				NEWEVENTS <= '0';
				if adspin(8 downto 3) /= aein(8 downto 3) then
					dns <= drw0;
				else
					dns <= echk; 
			   end if; 
			when drw0 =>
				dra <= "000";
				adspin(2 downto 0) <= "001";
				dwe <= '1';
				NEWEVENTS <= '0';
				dns <= drw1; 
			when drw1 =>
				dra <= "001";
				adspin(2 downto 0) <= "010";
				dwe <= '1';
				NEWEVENTS <= '0';
				dns <= drw2; 
			when drw2 =>
				dra <= "010";
				adspin(2 downto 0) <= "011";
				dwe <= '1';
				NEWEVENTS <= '0';
				dns <= drw3; 
			when drw3 =>
				dra <= "011";
				adspin(2 downto 0) <= "100";
				dwe <= '1';
				NEWEVENTS <= '0';
				dns <= drw4; 
			when drw4 =>
				dra <= "100";
				adspin(2 downto 0) <= "101";
				dwe <= '1';
				NEWEVENTS <= '0';
				dns <= drw5; 
			when drw5 =>
				dra <= "101";
				adspin(2 downto 0) <= "101";
				dwe <= '1';
				NEWEVENTS <= '0';
				dns <= waitread; 
			when waitread => 
				dra <= "000";
				adspin(2 downto 0) <= "000";
				dwe <= '0';
				NEWEVENTS <= '1'; 
				if ADDR = X"6" and RD = '1' then
					dns <= incaddr;		  
				else
					dns <= waitread; 
			   end if; 
			when incaddr =>
				dra <= "000";
				adspin(2 downto 0) <= "000";
				dwe <= '0';
				NEWEVENTS <= '0';
				dns <= echk; 
			when others =>
				dra <= "000";
				adspin(2 downto 0) <= "000";
				dwe <= '0';
				NEWEVENTS <= '0';
				dns <= echk; 
	  end case; 
	end process dfsm; 
		
end Behavioral;

 
 architecture syn of dpdistram is 
 type ram_type is array (7 downto 0) of std_logic_vector (15 downto 0); 
 signal RAM : ram_type; 
 
 begin 
 process (clk) 
 begin 
 	if (clk'event and clk = '1') then  
 		if (we = '1') then 
 			RAM(conv_integer(a)) <= di; 
 		end if; 
 	end if; 
 end process;
 
 spo <= RAM(conv_integer(a)); 
 dpo <= RAM(conv_integer(dpra)); 
 
 end syn;
 