library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity EventInputs is
    Port ( CLK : in std_logic;
           SYSCLK : in std_logic;
           RESET : in std_logic;
           DOUT : out std_logic_vector(15 downto 0);
           ADDR : in std_logic_vector(3 downto 0);
			  RD : in std_logic; 
			  MODE : out std_logic;
			  DSPRESET : out std_logic; 
           RAIN : out std_logic_vector(9 downto 0);
           RDIN : out std_logic_vector(15 downto 0);
			  RWE : out std_logic; 
           EEVENT : in std_logic;
           EDATAI : in std_logic_vector(15 downto 0);
           EADDRI : in std_logic_vector(7 downto 0);
			  NEWEVENTS : out std_logic;
			  MADDR : in std_logic_vector(7 downto 0);
			  MODERST : in std_logic);
end EventInputs;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



architecture Behavioral of EventInputs is
-- EVENTINPUTS.VHD -- Event input stage for the DSP, responsible for
-- decoding initial events and pushing them into the buffer. 


	-- event in signals
	signal adspin : std_logic_vector(9 downto 0) := (others => '0'); 
	signal aein : std_logic_vector(9 downto 0) := (others => '0'); 

	signal einfaddrinc, einwe, einl, einll, ein, eindelta : std_logic := '0';
	signal edout : std_logic_vector(15 downto 0) := (others => '0');
	signal rainen : std_logic := '0';
	signal raincnt : std_logic_vector(9 downto 0) := (others => '0');

	type states is (none, einchk, modeen, dspen, bramwevt,
							bramw0, bramw1, bramw2, bramw3, 
							dspram1, dspram2, dspram3, dspram4, dspram5); 

	signal cs, ns : states := none; 

   signal mine: std_logic := '0'; 

	 


	component EventReader is
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

	-- other components, external connections, etc. 
	circbuf: RAMB16_S18_S18 port map (
		DIA => edout,
		DIB => X"0000",
		DIPA => "00",
		DIPB => "00",
		ENA => '1', 
		ENB => '1', 
		WEA => einwe,
		WEB => '0',
		SSRA => '0',
		SSRB => '0', 
		CLKA => CLK,
		CLKB => CLK, 
		ADDRA => aein,
		ADDRB => adspin,
		DOA => open,
		DOB => DOUT,
		DOPA => open,
		DOPB => open); 
		 

 	ereader: EventReader port map(
		CLK => SYSCLK,
		EADDR => EADDRI,
		EDATA => EDATAI,
		EEVENT => EEVENT,
		DOUT => edout,
		ADDR => aein(2 downto 0),
		MADDR => MADDR( 6 downto 0),
		MINE => mine,
		EVENT => ein); 


	-- combinational
	
	eindelta <= einl and (not einll);

	NEWEVENTS <= '1' when aein(9 downto 3) /= adspin(9 downto 3) else '0';
	adspin(2 downto 0) <= addr(2 downto 0); 

	clock: process(CLK, RESET) is
	begin
	    if RESET = '1' then
		 	cs <= none; 
		else
			if rising_edge(CLK) then
				cs <= ns; 



				--event input counters, etc. 

				if ADDR = "110" and RD = '1' then
					adspin(9 downto 3) <= adspin(9 downto 3) + 1;
				end if; 

				if einfaddrinc = '1' then
					aein(9 downto 3) <= aein(9 downto 3) + 1;
				end if; 

				-- event decoding
				einl <= ein;
				einll <= einl; 

				if moderst = '1' then
					MODE <= '0';
				else
					if edout(0) = '1' and cs = modeen then
						MODE <= '1';
					end if;
				end if; 

				if cs = dspen then
					DSPRESET <= not edout(0);
				end if; 

				if cs = bramwevt then
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
	
	

	fsm : process(cs, eindelta, mine, edout) is
	begin
		case cs is
			when none => 
				aein(2 downto 0) <= "000";
				einwe <= '0';
				einfaddrinc <= '0';
				rainen <= '0';  
				if eindelta = '1' then
					ns <= einchk;
				else
					ns <= none;
				end if; 
			when einchk => 
				aein(2 downto 0) <= "000";
				einwe <= '1';
				einfaddrinc <= '0';
				rainen <= '0';   
				if mine = '1' then
					if edout(7 downto 0) = X"02" then
						ns <= dspen;
					elsif edout(7 downto 0) = X"01" then
						ns <= modeen;
					elsif edout(7 downto 0) = X"03" then
						ns <= bramwevt;
					else
						ns <= dspram1; 
					end if; 
				else
					ns <= none;
				end if; 
			when modeen => 
				aein(2 downto 0) <= "001";
				einwe <= '0';
				einfaddrinc <= '0';
				rainen <= '0';   
				ns <= none; 
			when dspen => 
				aein(2 downto 0) <= "001";
				einwe <= '0';
				einfaddrinc <= '0';
				rainen <= '0';   
				ns <= none; 
			when bramwevt => 
				aein(2 downto 0) <= "001";
				einwe <= '0';
				einfaddrinc <= '0';
				rainen <= '0';   
				ns <= bramw0; 
			when bramw0 => 
				aein(2 downto 0) <= "010";
				einwe <= '0';
				einfaddrinc <= '0';
				rainen <= '1';   
				ns <= bramw1; 
			when bramw1 => 
				aein(2 downto 0) <= "011";
				einwe <= '0';
				einfaddrinc <= '0';
				rainen <= '1';   
				ns <= bramw2; 
			when bramw2 => 
				aein(2 downto 0) <= "100";
				einwe <= '0';
				einfaddrinc <= '0';
				rainen <= '1';   
				ns <= none; 
			when dspram1 => 
				aein(2 downto 0) <= "001";
				einwe <= '1';
				einfaddrinc <= '0';
				rainen <= '0';   
				ns <= dspram2; 
			when dspram2 => 
				aein(2 downto 0) <= "010";
				einwe <= '1';
				einfaddrinc <= '0';
				rainen <= '0';   
				ns <= dspram3; 
			when dspram3 => 
				aein(2 downto 0) <= "011";
				einwe <= '1';
				einfaddrinc <= '0';
				rainen <= '0';   
				ns <= dspram4; 
			when dspram4 => 
				aein(2 downto 0) <= "100";
				einwe <= '1';
				einfaddrinc <= '0';
				rainen <= '0';   
				ns <= dspram5; 
			when dspram5 => 
				aein(2 downto 0) <= "101";
				einwe <= '1';
				einfaddrinc <= '1';
				rainen <= '0';   
				ns <= none; 
			when others => 
				aein(2 downto 0) <= "000";
				einwe <= '0';
				einfaddrinc <= '0';
				rainen <= '0';   
				ns <= none;
		end case;
	end process fsm; 

end Behavioral;

 
