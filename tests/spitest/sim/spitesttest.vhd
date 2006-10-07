library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity spitesttest is

end spitesttest;

architecture Behavioral of spitesttest is

  component spitest
    port (
      REFCLKIN  : in  std_logic;
      DSPCLKOUT : out std_logic;
      DSPRESET  : out std_logic;
      LEDPOWER  : out std_logic;
      SPISS     : out std_logic;
      MOSI      : out std_logic;
      MISO      : in  std_logic;
      MSCLK     : out std_logic
      );
  end component;

  signal REFCLKIN  : std_logic := '0';
  signal DSPCLKOUT : std_logic;
  signal DSPRESET  : std_logic;
  signal LEDPOWER  : std_logic;
  signal SPISS     : std_logic;
  signal MOSI      : std_logic;
  signal MISO      : std_logic;
  signal MSCLK     : std_logic; 

begin  -- Behavioral

  spitest_uut : spitest
    port map (
      REFCLKIN  => REFCLKIN,
      DSPCLKOUT => DSPCLKOUT,
      DSPRESET  => DSPRESET,
      LEDPOWER  => LEDPOWER,
      SPISS     => SPISS,
      MOSI      => MOSI,
      MISO      => MISO,
      MSCLK     => MSCLK);
  
  REFCLKIN <= not REFCLKIN after 10 ns;

  
  

end Behavioral;
