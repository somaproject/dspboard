library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EventMux is
    Port ( SYSCLK : in std_logic;
           AIA : out std_logic_vector(7 downto 0);
           AIB : out std_logic_vector(7 downto 0);
           AOA : in std_logic_vector(7 downto 0);
           AOB : in std_logic_vector(7 downto 0);
           EADDR : inout std_logic_vector(7 downto 0);
           OEA : in std_logic;
           OEB : in std_logic;
           DOA : in std_logic_vector(15 downto 0);
           DOB : in std_logic_vector(15 downto 0);
           DIA : out std_logic_vector(15 downto 0);
           DIB : out std_logic_vector(15 downto 0);
           EDATA : inout std_logic_vector(15 downto 0);
           EB : out std_logic;
           EA : out std_logic;
           EVENT : in std_logic;
           ECE : in std_logic;
           CEA : out std_logic;
           CEB : out std_logic;
			  MADDR : out std_logic_vector(7 downto 0) := X"00");
end EventMux;

architecture Behavioral of EventMux is
	signal ao : std_logic_vector(7 downto 0) := (others => '0'); 
	signal do : std_logic_vector(15 downto 0) := (others => '0');

	signal ts, esel : std_logic := '0';
	signal maddrset : std_logic := '0'; 

begin
	AIA <= EADDR; 
	AIB <= EADDR;
	ao <= AOA when esel = '0' else AOB; 
	
	ts <= (not OEA) when esel = '0' else (not OEB); 
	do <= DOA when esel = '0' else DOB; 
	
 	
	
	DIA <= EDATA;
	DIB <= EDATA; 

	EADDR <= ao when ts = '0' else "ZZZZZZZZ";
	EDATA <= do when ts = '0' else "ZZZZZZZZZZZZZZZZ";
	
	EA <= (not EVENT) and maddrset;
	EB <= (not EVENT) and maddrset;
	
	CEA <= '1' when (esel = '1' and ECE = '0') else '0';
	CEB <= '1' when (esel = '0' and ECE = '0') else '0';
	
	process(SYSCLK) is
	begin

		if rising_edge(SYSCLK) then
			if ECE = '0' then 
				esel <= not esel;
			end if; 

			
			if ECE = '0' and  maddrset = '0' then
				maddrset <= '1';
				MADDR <= EDATA(7 downto 0); 
			end if; 
				 
		end if; 
	end process; 

end Behavioral;
