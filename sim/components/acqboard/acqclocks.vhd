library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following lines to use the declarations that are
-- provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity acqclocks is
  port ( CLKIN     : in  std_logic;
         CLK       : out std_logic;
         CLK8      : out std_logic;
         RESET     : in  std_logic;
         INSAMPLE  : out std_logic;
         OUTSAMPLE : out std_logic;
         OUTBYTE   : out std_logic := '0';
         SPICLK    : out std_logic; 
         LOCKED : out std_logic);
end acqclocks;

architecture Behavioral of acqclocks is

-- ACQCLOCKS.VHD : implementation of acqclocks and various clock-enables for
-- our system. Uses Xilinx Spartan-IIE DLL to give us a 2x clock, and
-- then additionally uses SRL16Es to generate the clock enables to save
-- space. 

  signal clkin_w, clk2x : std_logic := '0';
  signal clk_g, lockedint  : std_logic := '0';

  signal outsamplecnt : std_logic_vector(11 downto 0) := (others => '0');
  signal insamplecnt : std_logic_vector(8 downto 0) := (others => '0');
  signal outbytecnt : std_logic_vector(7 downto 0) := (others => '0');
  signal clk8cnt : std_logic_vector(3 downto 0) := (others => '0');
  
  signal outenable                              : std_logic := '1';
  signal loutsample, loutbyte, lclk8, linsample : std_logic := '0';

-- components
  component dll_standard
    port (CLKIN  : in  std_logic;
          RESET  : in  std_logic;
          CLK2X  : out std_logic;
          CLK4X  : out std_logic;
          LOCKED : out std_logic);
  end component;

  component SRL16E
    generic (
      INIT    :     bit_vector := X"0000");
    port (D   : in  std_logic;
          CE  : in  std_logic;
          CLK : in  std_logic;
          A0  : in  std_logic;
          A1  : in  std_logic;
          A2  : in  std_logic;
          A3  : in  std_logic;
          Q   : out std_logic);
  end component;
begin


  dll2x  : CLKDLL
    port map (
      CLKIN => clkin,
      CLKFB => clk_g,
      RST => RESET,
      CLK0  => open,
      CLK90 => open,
      CLK180 => open,
      CLK270 => open,
      CLK2X => clk2x,
      CLKDV => open,
      LOCKED => LOCKEDint);

  LOCKED <= lockedint; 
  clk2xg : BUFG
    port map (
      I       => clk2x,
      O => clk_g);

  CLK <= clk_g;

  
  process(clk_g, RESET)
  begin
    if RESET = '1' or LOCKEDint = '0' then
      INSAMPLE      <= '0';
      OUTBYTE       <= '0';
      OUTSAMPLE     <= '0';
      CLK8          <= '0';
    else
      if rising_edge(clk_g) then

        -- OUTSAMPLE 
        if outsamplecnt = X"8c9" then
          outsamplecnt <= (others => '0');
        else
          outsamplecnt <= outsamplecnt + 1; 
        end if;

        if outsamplecnt = X"000" then
          loutsample <= '1';
        else
          loutsample <= '0';
        end if;


        -- INSAMPLE 
        if insamplecnt = "101110110" then
          insamplecnt <= (others => '0');
        else
          insamplecnt <= insamplecnt + 1; 
        end if;

        if insamplecnt = "000000000" then
          linsample <= '1';
        else
          linsample <= '0';
        end if;

        -- OUTBYTE 
        if outbytecnt = X"59" then
          outbytecnt <= (others => '0');
        else
          outbytecnt <= outbytecnt + 1; 
        end if;

        if outbytecnt = X"00" then
          loutbyte <= '1';
        else
          loutbyte <= '0';
        end if;

        -- CLK8 
        if clk8cnt = X"8" then
          clk8cnt <= (others => '0');
        else
          clk8cnt <= clk8cnt + 1; 
        end if;

        if clk8cnt = X"0" then
          lclk8 <= '1';
        else
          lclk8 <= '0';
        end if;


        
        
        if outenable = '1' then
          INSAMPLE  <= linsample;
          OUTBYTE   <= loutbyte;
          OUTSAMPLE <= loutsample;
          CLK8      <= lclk8;  
        end if;
      end if;
    end if; 
  end process; 

  
  SPICLK <= loutbyte; 

end Behavioral;
