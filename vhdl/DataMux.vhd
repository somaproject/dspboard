library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity DataMux is
    Port ( SYSCLK : in std_logic;
           DINA : in std_logic_vector(15 downto 0);
           DINB : in std_logic_vector(15 downto 0);
           DATAEN : in std_logic;
           ACKA : in std_logic;
           ACKB : in std_logic;
           DATAACK : out std_logic;
           SYSDATA : out std_logic_vector(15 downto 0);
           NEXTA : out std_logic;
           NEXTB : out std_logic);
end DataMux;

architecture Behavioral of DataMux is
-- DATAMUX.VHD -- a simple multiplexor to control which buffer we read from
   signal bufsel, ack, enl, enll, newen : std_logic := '0';
	signal din : std_logic_vector(15 downto 0) := (others => '0'); 
	component OBUFT
	      port (I, T: in std_logic; O: out std_logic);
	end component;   

begin
	din <= DINA when bufsel = '0' else DINB; 

	ack <= acka when bufsel = '0' else ackb; 

	NEXTA <= '1' when (bufsel = '1' and DATAEN = '0') else '0';
	NEXTB <= '1' when (bufsel = '1' and DATAEN = '0') else '0';

	newen <= enl and (not enll); 

	sysbufs : for i in 0 to 15 generate
		sysbuf: OBUFT port map (I => din(i), T => DATAEN, O => SYSDATA(i)); 
	end generate; 

	addrbuf : OBUFT port map (I => ack, T => DATAEN, O=> DATAACK); 


	process(SYSCLK) is
	begin
		if rising_edge(SYSCLK) then
			enl <= DATAEN; 
			enll <= enl; 
	
			if newen = '1' then
				bufsel <= not bufsel;
			end if; 

		end if;
	end process; 
end Behavioral;
