library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
    Port ( CLK : in std_logic;
           DIN : in std_logic;
           DATAOUT : out std_logic_vector(7 downto 0);
           KOUT : out std_logic;
           CODE_ERR : out std_logic;
           DISP_ERR : out std_logic;
           DATALOCK : out std_logic;
		 		RESET : in std_logic);
end decoder;

architecture Behavioral of decoder is
-- DECODER.VHD -- 8B/10B deserializer and decoder
-- Very similar to the one used for the DSP board

   signal curbit, lastbit : std_logic := '0';
   signal dout, dout_en: std_logic := '0';
   signal doutrdy, doutrdyl : std_logic := '0';
   signal lldatalock, ldatalock : std_logic := '0';

   signal ticcnt : std_logic_vector(2 downto 0) := (others => '0');

   signal bitcnt : std_logic_vector(3 downto 0) := (others => '0');

   signal datareg, doutreg, dataregl : 
    		std_logic_vector(9 downto 0) := (others => '0');


-- components
	component decode8b10b IS
		port (
		clk: IN std_logic;
		din: IN std_logic_VECTOR(9 downto 0);
		dout: OUT std_logic_VECTOR(7 downto 0);
		kout: OUT std_logic;
		ce: IN std_logic;
		code_err: OUT std_logic;
		disp_err: OUT std_logic);
	END component;

begin

   clocks : process(CLK) is
   begin
   	if rising_edge(CLK) then
   	   
	   -- input bits
	   curbit <= din;
	   lastbit <= curbit; 
	   
	   if lastbit = not curbit then
	   	  ticcnt <= "000";
	   else
	   	  ticcnt <= ticcnt + 1;
	   end if; 
	   
	   -- shift register, et. al.
	   if dout_en = '1' then 
	   	 dout <= curbit;
        end if; 
	   
	   if dout_en = '1' then
	   	 datareg <= dout & datareg(9 downto 1);
		 dataregl <= datareg; 
	   end if;     
	  	

	   if dout_en = '1' then
	   	 if datareg = "0101111100" or datareg = "1010000011" then
		    bitcnt <= "0000";
		 else
		    if bitcnt = "1001" then
		    	  bitcnt <= "0000";
		    else
		    	  bitcnt <= bitcnt + 1;
		    end if;
		 end if; 
	   end if; 


	

	  if bitcnt = "0000" and dout_en = '1' then
	  	doutreg <= dataregl;
	  end if;

	  doutrdyl <= doutrdy; 
	  ldatalock <= lldatalock;
	  DATALOCK <= ldatalock; 
	  
	  

	end if;
   end process clocks; 

   lldatalock <= '1' when doutrdyl = '0' and doutrdy = '1' else '0'; 


   dout_en <= '1' when ticcnt = "100" else '0';
   doutrdy <= '1' when bitcnt = "0011" else '0';

   -- instantiate decoder
   decode: decode8b10b 
   	port map (
		clk => clk,
		din => doutreg,
		dout => DATAOUT,
		kout => KOUT,
		code_err => CODE_ERR,
		disp_err => DISP_ERR,
		ce => lldatalock );
	

			

end Behavioral;
