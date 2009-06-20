library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity dlloop is
  port (
    REFCLKIN  : in  std_logic;
    REFCLKOUT : out std_logic;
    RXCLKIN   : in  std_logic;
    RXLOCKED  : in  std_logic;
    RXDIN     : in  std_logic_vector(9 downto 0);
    TXIO_P    : out std_logic;
    TXIO_N    : out std_logic;
    LEDPOWER  : out std_logic;
    LEDLOCKED : out std_logic;
    LEDVALID  : out std_logic;
    DSPRESETA : out std_logic;
    DSPRESETB : out std_logic;
    DSPRESETC : out std_logic;
    DSPRESETD : out std_logic;

    DECODEERR : out std_logic
    );

end dlloop;

architecture Behavioral of dlloop is

  component devicelink
    port (
      TXCLKIN    : in  std_logic;
      TXLOCKED   : in  std_logic;
      TXDIN      : in  std_logic_vector(9 downto 0);
      TXDOUT     : out std_logic_vector(7 downto 0);
      TXKOUT     : out std_logic;
      CLK        : out std_logic;
      CLK2X      : out std_logic;
      RESET      : out std_logic;
      RXDIN      : in  std_logic_vector(7 downto 0);
      RXKIN      : in  std_logic;
      RXIO_P     : out std_logic;
      RXIO_N     : out std_logic;
      LINKLOCK   : out std_logic;
      DECODEERR  : out std_logic;
      DEBUGOUT : out std_logic_vector(31 downto 0);
      DEBUGSTATE : out std_logic_vector(3 downto 0)
      );

  end component;

  component jtaginterface
    generic (
      JTAG1N : integer := 32;
      JTAG2N : integer := 32);
    port (
      CLK     : in  std_logic;
      DIN1    : in  std_logic_vector(JTAG1N-1 downto 0);
      DOUT1   : out std_logic_vector(JTAG1N-1 downto 0);
      DOUT1EN : out std_logic;
      DIN2    : in  std_logic_vector(JTAG2N-1 downto 0);
      DOUT2   : out std_logic_vector(JTAG2N-1 downto 0);
      DOUT2EN : out std_logic
      );
  end component;

  signal valid : std_logic := '0';

  signal data       : std_logic_vector(7 downto 0) := (others => '0');
  signal k          : std_logic                    := '0';
  signal datal      : std_logic_vector(7 downto 0) := (others => '0');
  signal kl         : std_logic                    := '0';
  signal clk, clk2x : std_logic                    := '0';
  signal RESET      : std_logic                    := '0';

  signal linklock : std_logic := '0';

  signal pcnt         : std_logic_vector(21 downto 0) := (others => '0');
  signal decodeerrint : std_logic                     := '0';
  signal debugstate   : std_logic_vector(31 downto 0) := (others => '0');
  signal intcounter   : std_logic_vector(31 downto 0) := (others => '0');
  signal intcounter2  : std_logic_vector(31 downto 0) := (others => '0');

  signal halfen : std_logic := '0';

  signal jtagdout1en : std_logic                     := '0';
  signal jtagdout1   : std_logic_vector(31 downto 0) := (others => '0');

  signal jtagdin2   : std_logic_vector(31 downto 0) := (others => '0');
  signal jtagdout2   : std_logic_vector(31 downto 0) := (others => '0');

  signal debugdata : std_logic_vector(31 downto 0) := (others => '0');
  
  component jtagbufdump
    port (
      CLKA     : in  std_logic;
      DIN      : in  std_logic_vector(31 downto 0);
      DINEN    : in  std_logic;
      NEXTBUF  : in  std_logic;
      -- readout side
      CLKB     : in  std_logic;
      READADDR : in  std_logic_vector(11 downto 0);
      DOUT     : out std_logic_vector(31 downto 0)
      );
  end component;

  signal bufdebug : std_logic_vector(31 downto 0) := (others => '0');
  signal bufdebug_en : std_logic := '0';
  signal bufdebug_next : std_logic := '0';

  

begin  -- Behavioral


  devicelink_inst : devicelink
    port map (
      TXCLKIN    => RXCLKIN,
      TXLOCKED   => RXLOCKED,
      TXDIN      => RXDIN,
      TXDOUT     => data,
      TXKOUT     => k,
      CLK        => clk,
      CLK2X      => clk2x,
      RESET      => RESET,
      RXDIN      => datal,
      RXKIN      => kl,
      LINKLOCK   => linklock,
      RXIO_P     => TXIO_P,
      RXIO_N     => TXIO_N,
      DECODEERR  => decodeerrint,
      DEBUGOUT => debugdata, 
      DEBUGSTATE => debugstate(3 downto 0));

  ledpowerproc : process (clk)
  begin  -- process ledpowerproc
    if reset = '1' then
      --intcounter <= (others => '0');
    else
      
      if rising_edge(clk) then
        pcnt      <= pcnt + 1;
        LEDVALID  <= not decodeerrint;
        LEDPOWER  <= pcnt(21);
        DECODEERR <= decodeerrint;
        halfen    <= not halfen;

        if linklock = '0' then
          datal <= (others => '0');
        else
          if halfen = '1' then
            datal <= datal + 1;
          end if;
        end if;

        kl <= '0';
--        if halfen = '1' then            -- downsample input data stream by 2x
--          datal <= data;
--          kl    <= k;
--        end if;

        intcounter <= intcounter + 1;
      end if;
    end if;
  end process ledpowerproc;


  REFCLKOUT <= REFCLKIN;
  LEDLOCKED <= not RXLOCKED;

  DSPRESETA <= '1';
  DSPRESETB <= '1';
  DSPRESETC <= '1';
  DSPRESETD <= '1';

  debugstate(31 downto 16) <= intcounter2(15 downto 0);

  process(RESET)
  begin
    if falling_edge(RESET) then
      intcounter2 <= intcounter2 + 1;
    end if;
  end process;

  jtaginterface_test : jtaginterface
    port map (
      CLK     => REFCLKIN,
      DIN1    => debugstate,
      DOUT1   => jtagdout1,
      DOUT1EN => jtagdout1en,
      DOUT2 => jtagdout2, 
      DIN2    => jtagdin2);

  jtagbufdump_inst : jtagbufdump
    port map (
      CLKA    => clk,
      DIN     => bufdebug, 
      DINEN   => bufdebug_en,
      NEXTBUF => bufdebug_next,
      CLKB => REFCLKIN,
      READADDR => jtagdout2(11 downto 0),
      DOUT => jtagdin2);

  bufdebug <= debugdata;
  bufdebug_en <= debugdata(0);
  bufdebug_next <= debugdata(1); 
  
end Behavioral;
