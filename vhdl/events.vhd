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
           WR : in std_logic;
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
			  BUFWR : in std_logic;
			  NEWEVENTS : out std_logic);
end events;

architecture Behavioral of events is
-- EVENTS.VHD -- this is the combined events architecture for a DSP. The E* 
-- outputs are to be connected to the event bus, with the EOE controlling
-- the output tristate. 

	-- DSP IO signals
	signal dspbpr, dspbpw : std_logic_vector(2 downto 0) := (others => '0');
	signal bdspa : std_logic_vector(7 downto 0) := (others => '0'); 
	signal wea : std_logic := '0'; 


	-- event IO signals
	signal addrbr, addrbw : std_logic_vector(2 downto 0) := (others => '0');
	signal addrbenr, addrbenw : std_logic := '0';
	signal rainen : std_logic := '0'; 

	signal edout, edin : std_logic_vector(15 downto 0) := (others => '0'); 
	signal web, ewe, mine, event, addrsel , done : std_logic := '0';

	signal addrb : std_logic_vector(7 downto 0) := (others => '0'); 
	signal maddr : std_logic_vector(6 downto 0) := "0000001"; 
	signal raincnt : std_logic_vector(9 downto 0) := (others => '0'); 


	type states is (none, einchk, modeen, dspen, bramwevt, bramw0,
						 bramw1, bramw2, bramw3, dspram1, dspram2, dspram3,
						 dspram4, dspram5, eoutchk, evbufw0, evbufw1, evbufw2,
						 evbufw3, evbufw4, evbufw5, evbufw6, evbufw7, evbufw8); 
	signal cs, ns : states := none; 

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


begin

	-- other components, external connections, etc. 

	bufferram: RAMB4_S16_S16 port map (
		DIA => DIN,
		DIB => EDOUT,
		ENA => '1',
		ENB => '1',
		WEA => wea,
		WEB => web,
		RSTA => RESET,
		RSTB => RESET,
		CLKA => clk,
		CLKB => clk,
		ADDRA => bdspa,
		ADDRB => addrb,
		DOA => DOUT,
		DOB => edin);

	eventin: EventInputs port map(
		CLK => SYSCLK,
		EADDR => EADDRI,
		EDATA => EDATAI,
		EEVENT => EEVENT,
		DOUT => edout,
		ADDR => addrb(2 downto 0),
		MADDR => maddr,
		MINE => mine,
		EVENT => event); 

	eventout : EventOutputs  port map(
		CLK => CLK,
		SYSCLK => SYSCLK,
		ADDR => addrb(3 downto 0),
		DIN => edin,
		DONE => done, 
		WE => ewe,
		EDATA => EDATAO,
		EADDR => EADDRO,
		EOE => EOE,
		EEVENT => EEVENT,
		ECE => ECE); 


	-- strictly combinational
	bdspa(6 downto 4) <= dspbpw when BUFWR = '1' else dspbpr; 
	bdspa(7) <= '1' when BUFWR = '1' else '0';
	bdspa(3 downto 0) <= addr(3 downto 0); 

	wea <= '1' when ((WR = '1')  and  BUFWR = '1') else '0';

	addrb(6 downto 4) <= addrbw  when addrsel = '1' else addrbr; 

	addrb(7) <= addrsel; 

	clock: process(CLK, RESET) is
	begin
		if RESET = '1' then
			cs <= none;
		else
			if rising_edge(CLK) then
				cs <= ns; 

				-- dsp side counters
				if RD = '1' and ADDR = X"6" then
					dspbpr <= dspbpr + 1; 
				end if; 
				if WR = '1' and ADDR = X"8" then
					dspbpw <= dspbpw + 1; 
				end if;
				
				-- event side counters
				if addrbenr = '1' then
					addrbr <= addrbr + 1;
				end if;
				if addrbenw = '1' then
					addrbw <= addrbw + 1;
				end if; 
				
				-- output latches
				if cs = modeen then
					MODE <= edout(0);
				end if; 
				
				if cs = dspen then
					DSPRESET <= edout(0);
				end if; 
				
				if cs = bramwevt then
					raincnt <= edout(9 downto 0);
				else
					if rainen = '1' then
						raincnt <= raincnt + 1;
					end if;
				end if; 

				RAIN <= raincnt; 
				RDIN <= edout; 
				RWE <= rainen; 
				  
				if addrbw =  dspbpw then
					NEWEVENTS <= '0';
				else
					NEWEVENTS <= '1';
				end if; 



				
			end if; 
		end if;
	end process clock; 


	fsm : process(cs, mine, edout, edin, dspbpw, addrbr, done, event) is
	begin
		case cs is
			when none => 
				addrb(3 downto 0) <= X"0";
				addrsel <= '0';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '0';
				rainen <= '0';
				ewe <= '0';
				if event = '1' then
					ns <= einchk;
				else
					ns <= none;
				end if; 
			when einchk => 
				addrb(3 downto 0) <= X"0";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '0';
				if mine = '1' then
					if edin = X"01" then
						ns <= modeen;
					elsif edin = X"02" then
						ns <= dspen;
					elsif edin = X"03" then
						ns <= bramwevt;
					else
						ns <= dspram1;
					end if; 
				else
					ns <= eoutchk;
				end if; 
			when modeen => 
				addrb(3 downto 0) <= X"1";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '0';
				rainen <= '0';
				ewe <= '0';
				ns <= eoutchk; 
			when dspen => 
				addrb(3 downto 0) <= X"1";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '0';
				rainen <= '0';
				ewe <= '0';
				ns <= eoutchk; 
			when bramwevt => 
				addrb(3 downto 0) <= X"1";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '0';
				rainen <= '0';
				ewe <= '0';
				ns <= bramw0; 
			when bramw0 => 
				addrb(3 downto 0) <= X"2";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '0';
				rainen <= '1';
				ewe <= '0';
				ns <= bramw1; 
			when bramw1 => 
				addrb(3 downto 0) <= X"3";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '0';
				rainen <= '1';
				ewe <= '0';
				ns <= bramw2; 
			when bramw2 => 
				addrb(3 downto 0) <= X"4";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '0';
				rainen <= '1';
				ewe <= '0';
				ns <= bramw3; 
			when bramw3 => 
				addrb(3 downto 0) <= X"5";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '0';
				rainen <= '1';
				ewe <= '0';
				ns <= eoutchk; 
			when dspram1 =>
				addrb(3 downto 0) <= X"1";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '0';	 
				ns <= dspram2;
			when dspram2 =>
				addrb(3 downto 0) <= X"2";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '0';
				ns <= dspram3;
			when dspram3 =>
				addrb(3 downto 0) <= X"3";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '0';
				ns <= dspram4;
			when dspram4 =>
				addrb(3 downto 0) <= X"4";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '0';
				ns <= dspram5;
			when dspram5 =>
				addrb(3 downto 0) <= X"5";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '1';
				web <= '1';
				rainen <= '1';
				ewe <= '0';
				ns <= eoutchk;
			when eoutchk =>
				addrb(3 downto 0) <= X"0";
				addrsel <= '0';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '0';
				rainen <= '0';
				ewe <= '0';
				if dspbpw /= addrbr and done = '1' then
					ns <= evbufw0;	
				else	
					ns <= none; 
				end if; 
			when evbufw0 =>
				addrb(3 downto 0) <= X"0";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '1';
				ns <= evbufw1;
			when evbufw1 =>
				addrb(3 downto 0) <= X"1";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '1';
				ns <= evbufw2;
			when evbufw2 =>
				addrb(3 downto 0) <= X"2";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '1';
				ns <= evbufw3; 
			when evbufw3 =>
				addrb(3 downto 0) <= X"3";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '1';
				ns <= evbufw4; 
			when evbufw4 =>
				addrb(3 downto 0) <= X"4";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '1';
				ns <= evbufw5; 
			when evbufw5 =>
				addrb(3 downto 0) <= X"5";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '1';
				ns <= evbufw6; 
			when evbufw6  =>
				addrb(3 downto 0) <= X"6";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '1';
				ns <= evbufw7; 
			when evbufw7  =>
				addrb(3 downto 0) <= X"7";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '1';
				ns <= evbufw8; 
			when evbufw8  =>
				addrb(3 downto 0) <= X"8";
				addrsel <= '1';
				addrbenr <= '1';
				addrbenw <= '0';
				web <= '1';
				rainen <= '0';
				ewe <= '1';
				ns <= none;
			when others	 =>
				addrb(3 downto 0) <= X"0";
				addrsel <= '1';
				addrbenr <= '0';
				addrbenw <= '0';
				web <= '0';
				rainen <= '0';
				ewe <= '0';
				ns <= none; 
		end case; 
	end process fsm; 

		
end Behavioral;
