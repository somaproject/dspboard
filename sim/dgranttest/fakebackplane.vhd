library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;
use soma.all;

entity fakebackplane is
  port (
    CLK    : in  std_logic;
    TXDOUT : out  std_logic_vector(7 downto 0);
    TXKOUT : out std_logic;
    RXDIN  : in  std_logic_vector(7 downto 0);
    RXKIN  : in  std_logic
    );

end fakebackplane;

architecture Behavioral of fakebackplane is

  component devicemux
    port (
      CLK      : in  std_logic;
      ECYCLE   : in  std_logic;
      -- DATA PORT
      DATADOUT : out std_logic_vector(7 downto 0);
      DATADOEN : out std_logic;
      -- port A
      DGRANTA  : in  std_logic;
      EARXA    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXA    : out std_logic_vector(7 downto 0);
      EDSELRXA : in  std_logic_vector(3 downto 0);
      EATXA    : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXA    : in  std_logic_vector(7 downto 0);
      -- port B
      DGRANTB  : in  std_logic;
      EARXB    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXB    : out std_logic_vector(7 downto 0);
      EDSELRXB : in  std_logic_vector(3 downto 0);
      EATXB    : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXB    : in  std_logic_vector(7 downto 0);
      -- port C
      DGRANTC  : in  std_logic;
      EARXC    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXC    : out std_logic_vector(7 downto 0);
      EDSELRXC : in  std_logic_vector(3 downto 0);
      EATXC    : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXC    : in  std_logic_vector(7 downto 0);
      -- port D
      DGRANTD  : in  std_logic;
      EARXD    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXD    : out std_logic_vector(7 downto 0);
      EDSELRXD : in  std_logic_vector(3 downto 0);
      EATXD    : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXD    : in  std_logic_vector(7 downto 0);
      -- IO 
      TXDOUT   : out std_logic_vector(7 downto 0);
      TXKOUT   : out std_logic;
      RXDIN    : in  std_logic_vector(7 downto 0);
      RXKIN    : in  std_logic;
      LOCKED   : in  std_logic );
  end component;



  signal ecycle : std_logic := '0';
  

  signal pos : integer range 0 to 999 := 950;

  signal datadout : std_logic_vector(7 downto 0) := (others => '0');
  signal datadoen : std_logic                    := '0';

  type dataarray_t is array (7 downto 0) of std_logic_vector(7 downto 0); 
  
  signal routedin   : somabackplane.dataroutearray := (others => (others => '0'));
  signal routedinen : std_logic_vector(7 downto 0)  := (others => '0');
  signal routedout  : std_logic_vector(7 downto 0)  := (others => '0');
  signal routedoen  : std_logic                     := '0';
  signal dgrant     : std_logic_vector(31 downto 0) := (others => '0');

begin  -- Behavioral

  datarouter_test: entity soma.datarouter
    port map (
      CLK    => CLK,
      ECYCLE => ecycle,
      DIN    => routedin,
      DINEN  => routedinen,
      DOUT   => routedout,
      doen   => routedoen,
      dgrant => dgrant);

  devicemux_test : devicemux
    port map (
      CLK      => CLK,
      ECYCLE   => ecycle,
      DATADOUT => routedin(0),
      DATADOEN => routedinen(0),

      DGRANTA  => dgrant(0),
      EARXA    => open,
      EDRXA    => open,
      EDSELRXA => "0000",
      EATXA    => (others => '0'),
      EDTXA    => X"00",

      DGRANTB  => dgrant(1),
      EARXB    => open,
      EDRXB    => open,
      EDSELRXB => "0000",
      EATXB    => (others => '0'),
      EDTXB    => X"00",

      DGRANTC  => dgrant(2),
      EARXC    => open,
      EDRXC    => open,
      EDSELRXC => "0000",
      EATXC    => (others => '0'),
      EDTXC    => X"00",

      DGRANTD  => dgrant(3),
      EARXD    => open,
      EDRXD    => open,
      EDSELRXD => "0000",
      EATXD    => (others => '0'),
      EDTXD    => X"00",

      TXDOUT => TXDOUT,
      TXKOUT => TXKOUT,
      RXDIN  => RXDIN,
      RXKIN  => RXKIN,
      LOCKED => '1');

  ecycle_generation : process(CLK)
  begin
    if rising_edge(CLK) then
      if pos = 999 then
        pos <= 0;
      else
        pos <= pos + 1;
      end if;

      if pos = 999 then
        ECYCLE <= '1';
      else
        ECYCLE <= '0';
      end if;

    end if;
  end process ecycle_generation;




end Behavioral;
