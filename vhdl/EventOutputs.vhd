library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EventOutputs is
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
end EventOutputs;

architecture Behavioral of EventOutputs is
-- EVENTOUTPUTS.VHD -- handles crossing of clock boundaries and puts events
-- on the actual bus. 

   -- main latches
	signal a0, a1, a2, d0, d1, d2, d3, d4, d5 : std_logic_vector(15 downto 0)
				:= (others => '0');
	
	signal lloaded : std_logic := '0';
	
	-- sysclk domain signals
	signal cnt : integer range 0 to 7 := 0; 
	signal outsel : integer range 0 to 7 := 0; 
	signal cel, loaded, eventl, ldrst, go,  soe : std_logic := '0';
	 
	 	
begin

	EADDR <= a0(7 downto 0) when outsel = 0 else
				a0(15 downto 8) when outsel = 1 else
				a1(7 downto 0) when outsel = 2 else
				a1(15 downto 8) when outsel = 3 else 
				a2(7 downto 0) when outsel = 4 else
				a2(15 downto 8); 
	EDATA <= d0 when outsel = 0 else 
				d1 when outsel = 1 else
				d2 when outsel = 2 else
				d3 when outsel = 3 else
				d4 when outsel = 4 else
				d5; 



	outsel <=  cnt when eventl = '0' else 0; 

	EOE <= soe or go; 
	 go <= cel and loaded; 

	--a0 <= X"98F6"; -- DEBUGGING

	-- clk timing
	clockfast: process(CLK) is
	begin
		if rising_edge(CLK) then
			-- latch data
			if WE = '1' then
				if ADDR = "0000" then
					a0 <= DIN; -- DEBUGGING
					 
				end if;
				if ADDR = "0001" then
					a1 <= DIN; 
				end if;
				if ADDR = "0010" then
					a2 <= DIN; 
				end if;
				if ADDR = "0011" then
					d0 <= DIN; 
				end if;
				if ADDR = "0100" then
					d1 <= DIN; 
				end if;
				if ADDR = "0101" then
					d2 <= DIN; 
				end if;
				if ADDR = "0110" then
					d3 <= DIN; 
				end if;
				if ADDR = "0111" then
					d4 <= DIN; 
				end if;
				if ADDR = "1000" then
					d5 <= DIN; 
				end if;
			end if; 

			if ldrst = '1' then
				lloaded <= '0'; 
			else	
				if WE = '1' and  ADDR = X"8" then
					lloaded <= '1';
				end if;
			end if; 

			DONE <= not lloaded; 

		end if; 
	end process clockfast; 


	sysclock: process(SYSCLK) is
	begin
		if rising_edge(SYSCLK) then
			
			-- basics
			eventl <= EEVENT; 
			cel <= ECE;

			loaded <= lloaded; 

			if eventl = '1' then 
				cnt <= 1;
			else
				if cnt < 6 then
					cnt <= cnt + 1; 
				end if;
			end if; 
			
			if go =  '1'  then
				soe <= '1';
			else
				if outsel = 5 then
					soe <= '0';
				end if; 
			end if; 
			
			if soe = '1' and outsel = 5 then
				ldrst <= '1';
			else
				ldrst <= '0';
			end if; 
		 
		end if; 
	end process sysclock; 








				
end Behavioral;
