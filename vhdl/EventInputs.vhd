library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EventInputs is
    Port ( CLK : in std_logic;
           EADDR : in std_logic_vector(7 downto 0);
           EDATA : in std_logic_vector(15 downto 0);
           EEVENT : in std_logic;
           DOUT : out std_logic_vector(15 downto 0);
			  ADDR : in std_logic_vector(2 downto 0); 
			  MADDR : in std_logic_vector(6 downto 0); 
           MINE : out std_logic;
           EVENT : out std_logic);
end EventInputs;

architecture Behavioral of EventInputs is
-- EVENTINPUTS.VHD -- simple interface to the event bus that lets me
-- read the event bus at CLK, and provides an asynchronous interface to 
-- the higher-order event buffers

	-- address management
	signal addrl : std_logic_vector(7 downto 0) := (others => '0'); 
	signal addrsel, smine, lmine : std_logic := '0'; 
	
	-- event managemnt
	signal eventl : std_logic := '0';
	signal cnt : std_logic_vector(2 downto 0) := (others => '0'); 
	 
	
	-- data
	signal datal, d0, d1, d2, d3, d4, d5, d0L, d1l, d2l, d3l, d4l, d5l
		: std_logic_vector(15 downto 0) := (others => '0'); 
		
	 
begin

	-- addrsel mux;
	addrsel <= addrl(0) when maddr(2 downto 0) = "000" else
					addrl(1) when maddr(2 downto 0) = "001" else
					addrl(2) when maddr(2 downto 0) = "010" else
					addrl(3) when maddr(2 downto 0) = "011" else
					addrl(4) when maddr(2 downto 0) = "100" else
					addrl(5) when maddr(2 downto 0) = "101" else
					addrl(6) when maddr(2 downto 0) = "110" else
					addrl(7) when maddr(2 downto 0) = "111"; 

	DOUT <= d0l when ADDR = "000" else
				d1l when ADDR = "001" else
				d2l when ADDR = "010" else
				d3l when ADDR = "011" else
				d4l when ADDR = "100" else
				d5l;
				
		 


   clock: process(CLK) is
	begin
		if rising_edge(CLK) then
			datal <= EDATA; 
			-- first, getting the addresses
			addrl <= EADDR; 
			if addrsel = '1' and maddr(5 downto 3) = cnt then 
				smine <= '1';
			else
				if cnt = "000" then 
					smine <= '0';
				end if; 
			end if; 

			if smine = '1' and cnt = "101" then
				lmine <= '1'; 
			else
				lmine <= '0';
			end if; 

			if cnt = "000" then
				MINE <= lmine;
			end if; 

			if cnt = "000" then 
				d0 <= datal; 
			end if; 
			if cnt = "001" then 
				d1 <= datal; 
			end if; 
			if cnt = "010" then 
				d2 <= datal; 
			end if; 
			if cnt = "011" then 
				d3 <= datal; 
			end if; 
			if cnt = "100" then 
				d4 <= datal; 
			end if; 
			if cnt = "101" then 
				d5 <= datal; 
			end if; 

			if lmine = '1' then
				d0l <= d0;
				d1l <= d1;
				d2l <= d2;
				d3l <= d3; 
				d4l <= d4; 
				d5l <= d5; 
			end if; 

			-- event stuff
			eventl <= EEVENT; 
			EVENT <= eventl;
			

			if eventl = '1' then
				cnt <= (others => '0');
			else
				if cnt /= "111" then
					cnt <= cnt + 1;
				end if; 
			end if; 
			 
			


		end if;
	end process clock; 

end Behavioral;
