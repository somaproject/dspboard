library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity test_mem is
    Port ( CLK : in std_logic;
           MODE : in std_logic;
           ADDR : in std_logic_vector(15 downto 0);
           DIN : in std_logic_vector(15 downto 0);
           DOUT : out std_logic_vector(15 downto 0);
           GO : in std_logic;
           RW : in std_logic;
           DONE : out std_logic;
           MRD : out std_logic;
           MWE : out std_logic;
           MADDR : out std_logic_vector(15 downto 0);
           MDATA : inout std_logic_vector(15 downto 0));
end test_mem;

architecture Behavioral of test_mem is
-- TEST_MEM.VHD -- simple memory test interface, to simulate
-- dsp memory IO. 

	signal intaddr : std_logic_vector(15 downto 0) := (others => '0'); 
	signal intdin : std_logic_vector(15 downto 0) := (others => '0');


begin

	process  is
	begin
		MRD <= '1';
		MWE <= '1'; 
		MDATA <= (others => 'Z'); 
		MADDR <= (others => '0'); 

		while(1 = 1) loop
			wait until rising_edge(CLK); 
			if go = '1' then
				intaddr <= ADDR; 
				intdin <= DIN;
				DONE <= '0';  
				if rw = '1' then -- read
					if mode = '0' then -- normal

						MDATA <= (others => 'Z'); 
						wait until rising_edge(CLK); 
						MADDR <= intaddr;
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						MRD <= '0';
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						DOUT <= MDATA;
						wait until rising_edge(CLK);
						MRD <= '1';
						wait until rising_edge(CLK);
					else	-- 8-bit
						MDATA(7 downto 0) <= (others => 'Z'); 
						wait until rising_edge(CLK); 
						MADDR <= "00000000" & intaddr(15 downto 8); 
						MDATA(15 downto 8) <= intaddr(7 downto 0); 
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						MRD <= '0';
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						wait until rising_edge(CLK);
						DOUT <= X"00" & MDATA(7 downto 0); 
						wait until rising_edge(CLK);
						MRD <= '1';
						wait until rising_edge(CLK);
					end if;						

				elsif rw = '0' then -- write;
					MDATA <= (others => 'Z'); 
					wait until rising_edge(CLK); 
					MADDR <= intaddr;
					wait until rising_edge(CLK);
					wait until rising_edge(CLK);
					wait until rising_edge(CLK);
					MWE <= '0';
					wait until rising_edge(CLK);
					MDATA <= intdin; 
					wait until rising_edge(CLK);
					wait until rising_edge(CLK);
					wait until rising_edge(CLK);
					wait until rising_edge(CLK);
					wait until rising_edge(CLK);
					wait until rising_edge(CLK);
					wait until rising_edge(CLK);
					wait until rising_edge(CLK);
					wait until rising_edge(CLK);
					MWE <= '1';
					wait until rising_edge(CLK);
					MDATA <= (others => 'Z'); 
				end if; 
				DONE <= '1'; 

			end if; 
		end loop;
	end process; 




end Behavioral;
