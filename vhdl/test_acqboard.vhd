library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_acqboard is
    Port ( CLK : in std_logic;
           FIBEROUT : out std_logic;
           FIBERIN : in std_logic);
end test_acqboard;

architecture Behavioral of test_acqboard is
-- TEST_ACQBOARD.VHD -- really simple code to generate simple
-- 8b/10b output over and over and over again; 

	signal din : std_logic_vector(7 downto 0) := (others => '0'); 
	signal kin : std_logic := '0';
	signal ce : std_logic := '0';
	signal ldout, dout : std_logic_vector(9 downto 0) := (others => '0'); 
	signal bitpos, bytepos : integer := 0; 
	signal cnt : std_logic_vector(15 downto 0) := (others => '0');

 	component encode8b10b IS
		port (
		din: IN std_logic_VECTOR(7 downto 0);
		kin: IN std_logic;
		clk: IN std_logic;
		dout: OUT std_logic_VECTOR(9 downto 0);
		ce: IN std_logic);
	END component;


begin
	encoder: encode8b10b port map (
		DIN => din,
		KIN => kin,
		CE => ce,
		DOUT => ldout, 
		CLK => CLK);
		
   process (CLK) is
	begin
		if rising_edge(CLK) then
			if bitpos = 9 then
				bitpos <= 0;
			else
				bitpos <= bitpos + 1;
			end if; 

			if bitpos = 6 then
				if bytepos = 24 then
					bytepos <= 0;
					cnt <= cnt + 1; 
				else
					bytepos <= bytepos + 1;
				end if; 
			end if; 

			case bytepos is
				when 0 => 
					kin <= '1';
					din <= X"BC";
				when 1 =>
					kin <= '0';
					din <= X"00"; 
				when 2 | 4| 6| 8| 10| 12| 14| 16| 18| 20 =>
					kin <= '0';
					din <= cnt(15 downto 8);
				when 3| 5| 7| 9| 11| 13| 15| 17| 19| 21 =>
					kin <= '0';
					din <= cnt(7 downto 0);
				when others =>
				 	kin <= '0';
					din <= (others => '0');
			end case; 

			if bitpos = 8 then
				ce <= '1';
			else
				ce  <= '0';
			end if; 
			if bitpos = 9 then 
				dout <= ldout; 
				
			end if; 

			FIBEROUT <= dout(bitpos); 
	  end if; 
	
	
	end process;  

end Behavioral;
