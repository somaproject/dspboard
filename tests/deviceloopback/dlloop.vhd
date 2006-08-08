library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity dlloop is
  port (
    REFCLKIN : in std_logic; 
    REFCLKOUT : out std_logic; 
    RXCLKIN : in std_logic; 
    RXLOCKED : in  std_logic;
    RXDIN    : in  std_logic_vector(9 downto 0);
    TXIO_P   : out std_logic;
    TXIO_N   : out std_logic;
    LEDPOWER : out std_logic;
    LEDLOCKED : out std_logic;
    LEDVALID : out std_logic;
    DECODEERR : out std_logic
    );

end dlloop;

architecture Behavioral of dlloop is

  component devicelink
    port (
      TXCLKIN  : in  std_logic;
      TXLOCKED : in  std_logic;
      TXDIN    : in  std_logic_vector(9 downto 0);
      TXDOUT   : out std_logic_vector(7 downto 0);
      TXKOUT   : out std_logic;
      CLK      : out std_logic;
      CLK2X    : out std_logic;
      RESET    : out std_logic;
      RXDIN    : in  std_logic_vector(7 downto 0);
      RXKIN    : in  std_logic;
      RXIO_P   : out std_logic;
      RXIO_N   : out std_logic;
      DECODEERR : out std_logic
      );

  end component;

  signal valid : std_logic := '0';
  
  signal data : std_logic_vector(7 downto 0) := (others => '0');
  signal k : std_logic := '0';
  signal clk, clk2x : std_logic := '0';
  signal RESET : std_logic := '0';
  
  signal pcnt : std_logic_vector(21 downto 0) := (others => '0');
  signal decodeerrint : std_logic := '0';

  
begin  -- Behavioral

  
  devicelink_inst: devicelink
    port map (
      TXCLKIN  => RXCLKIN,
      TXLOCKED => RXLOCKED,
      TXDIN    => RXDIN,
      TXDOUT   => data,
      TXKOUT   => k, 
      CLK      => clk,
      CLK2X    => clk2x,
      RESET    => RESET,
      RXDIN    => data,
      RXKIN    => '0', 
      RXIO_P   => TXIO_P,
      RXIO_N   => TXIO_N,
      DECODEERR => decodeerrint);
  
  ledpowerproc: process (clk)
  begin  -- process ledpowerproc
    if rising_edge(clk) then
      pcnt <= pcnt + 1;
      LEDPOWER <= pcnt(21);
      LEDVALID <= not decodeerrint;
      DECODEERR <= decodeerrint;
    end if;
  end process ledpowerproc;

  REFCLKOUT <= REFCLKIN; 
  LEDLOCKED <= not RXLOCKED;
  
end Behavioral;
