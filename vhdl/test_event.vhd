library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_event is
    Port ( CLK : in std_logic;
           CMDIN : in std_logic_vector(15 downto 0);
           DIN0 : in std_logic_vector(15 downto 0);
           DIN1 : in std_logic_vector(15 downto 0);
           DIN2 : in std_logic_vector(15 downto 0);
           DIN3 : in std_logic_vector(15 downto 0);
           DIN4 : in std_logic_vector(15 downto 0);
           ADDRIN : in std_logic_vector(47 downto 0);
           SENDEVENT : in std_logic;
           QUERYEVENT : in std_logic;
           DONE : out std_logic;
			  CMDOUT: out std_logic_vector(15 downto 0); 
           DOUT0 : out std_logic_vector(15 downto 0);
           DOUT1 : out std_logic_vector(15 downto 0);
           DOUT2 : out std_logic_vector(15 downto 0);
           DOUT3 : out std_logic_vector(15 downto 0);
           DOUT4 : out std_logic_vector(15 downto 0);
			  EDATA : inout std_logic_vector(15 downto 0);
			  EADDR : inout std_logic_vector(7 downto 0);  
			  ECE : out std_logic;
			  EEVENT : out std_logic
			  );
end test_event;

architecture Behavioral of test_event is
-- TEST_EVENT.VHD -- test event code. 
begin
	process is
	begin
		while (1 = 1) loop
			EEVENT <= '1'; 
			ECE <= '1'; 
			wait until rising_edge(CLK);
			if SENDEVENT = '1' then
				DONE <= '0'; 
				ECE <= '1';
				EEVENT <= '0';
				wait until rising_edge(CLK);
				ECE <= '1'; 
				EEVENT <= '1'; 
				EDATA <= CMDIN; 
				EADDR <= ADDRIN(7 downto 0); 
				wait until rising_edge(CLK);
				ECE <= '1'; 
				EDATA <= DIN0; 
				EADDR <= ADDRIN(15 downto 8); 
				wait until rising_edge(CLK);
				ECE <= '1'; 
				EDATA <= DIN1; 
				EADDR <= ADDRIN(23 downto 16); 
				wait until rising_edge(CLK);
				ECE <= '1'; 
				EDATA <= DIN2; 
				EADDR <= ADDRIN(31 downto 24); 
				wait until rising_edge(CLK);
				ECE <= '1'; 
				EDATA <= DIN3; 
				EADDR <= ADDRIN(39 downto 32); 
				wait until rising_edge(CLK);
				ECE <= '1'; 
				EDATA <= DIN4; 
				EADDR <= ADDRIN(47 downto 40); 
		  		wait until rising_edge(CLK); 
				DONE <= '1'; 
			elsif QUERYEVENT = '1' then
				ECE <= '0';
				EEVENT <= '0';
				EDATA <= (others => 'Z'); 
				EADDR <= (others => 'Z'); 
				DONE <= '0'; 
				wait until rising_edge(CLK);
				ECE <= '1'; 
				EEVENT <= '1';
				CMDOUT <= EDATA; 
				wait until rising_edge(CLK);
				ECE <= '1'; 
				EEVENT <= '1';
				DOUT0 <= EDATA; 
				wait until rising_edge(CLK);
				ECE <= '1'; 
				EEVENT <= '1';
				DOUT1 <= EDATA; 
				wait until rising_edge(CLK);
				ECE <= '1'; 
				EEVENT <= '1';
				DOUT2 <= EDATA; 
				wait until rising_edge(CLK);
				ECE <= '1'; 
				EEVENT <= '1';
				DOUT3 <= EDATA; 
				wait until rising_edge(CLK);
				ECE <= '1'; 
				EEVENT <= '1';
				DOUT4 <= EDATA; 
				wait until rising_edge(CLK);
				DONE <= '1'; 
			end if; 
		end loop; 
	end process; 


end Behavioral;
