library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity multichantesttest is
end multichantesttest;

architecture Behavioral of multichantesttest is

  component multichanneltest
    port (
      REFCLKIN  : in  std_logic;
      DSPCLKOUT : out std_logic;
      DSPRESET  : out std_logic;
      LEDPOWER  : out std_logic;
      RSCLK     : out std_logic;
      DR        : out std_logic;
      RFS       : out std_logic;
      DT        : in  std_logic;
      TFS       : in  std_logic
      );
  end component;

  signal REFCLKIN  : std_logic := '0';
  signal DSPCLKOUT : std_logic := '0';
  signal DSPRESET  : std_logic := '0';
  signal LEDPOWER  : std_logic := '0';
  signal RSCLK     : std_logic := '0';
  signal DR        : std_logic := '0';
  signal RFS       : std_logic := '0';
  signal DT        : std_logic := '0';
  signal TFS       : std_logic := '0';


  
begin  -- Behavioral

  multichanneltest_uut: multichanneltest
    port map (
      REFCLKIN  => REFCLKIN,
      DSPCLKOUT => DSPCLKOUT,
      DSPRESET  => DSPRESET,
      LEDPOWER  => LEDPOWER,
      RSCLK     => RSCLK,
      DR        => DR,
      RFS       => RFS,
      DT        => DT,
      TFS       => TFS);
  
  REFCLKIN <= not REFCLKIN after 10 ns;
  
    

end Behavioral;


