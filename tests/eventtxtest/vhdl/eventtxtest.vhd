library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity eventtxtest is
  port (
    REFCLKIN  : in  std_logic;
    DSPCLKOUT : out std_logic;
    DSPRESET  : out std_logic;
    LEDPOWER  : out std_logic;
    DIN       : in  std_logic_vector(7 downto 0);
    KIN       : in  std_logic;
    INTGEN    : in  std_logic;
    ERRIN     : in  std_logic;
    EVENTENA  : out std_logic;
    EVENTENB  : out std_logic;
    EVENTENC  : out std_logic;
    EVENTEND  : out std_logic;
    EVENTTXD  : out std_logic_vector(7 downto 0)
    );
end eventtxtest;


architecture Behavioral of eventtxtest is

  component eventtx
    port (
      CLK      : in  std_logic;
      DIN      : in  std_logic_vector(7 downto 0);
      KIN      : in  std_logic;
      ERRIN    : in  std_logic;
      EVENTENA : out std_logic;
      EVENTENB : out std_logic;
      EVENTENC : out std_logic;
      EVENTEND : out std_logic;
      EVENTTXD : out std_logic_vector(7 downto 0));
  end component;

  signal clk : std_logic := '0';

  signal dint : std_logic_vector(7 downto 0) := (others => '0');
  signal errint, kint : std_logic := '0';

begin  -- Behavioral


  clk <= REFCLKIN;

  DSPCLKOUT <= clk;

  eventtx_inst: eventtx
    port map (
      CLK      => CLK,
      DIN      => dint,
      KIN      => kint,
      ERRIN    => errint,
      EVENTENA => EVENTENA,
      EVENTENB => EVENTENB,
      EVENTENC => EVENTENC,
      EVENTEND => EVENTEND,
      EVENTTXD => EVENTTXD); 
    
  main : process (CLK)
  begin
    if rising_edge(CLK) then
      if INTGEN = '0' then
        dint <= DIN;
        kint <= KIN;
        errint <= ERRIN; 
      end if;
    end if;
  end process main;

  LEDPOWER <= '1';
  DSPRESET <= '1';
  

end Behavioral;
