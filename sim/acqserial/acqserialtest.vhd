library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

entity acqserialtest is

end acqserialtest;

architecture Behavioral of acqserialtest is

  component acqserial
    port (
      CLK        : in  std_logic;
      CLKHI      : in  std_logic;
      RESET      : in  std_logic;
      FIBERIN    : in  std_logic;
      FIBEROUT   : out std_logic;
      -- SPORT outputs
      DSPASERCLK : out std_logic;
      DSPASERDT  : out std_logic;
      DSPASERFS  : out std_logic;
      DSPASERDR  : in  std_logic;

      DSPBSERCLK : out std_logic;
      DSPBSERDT  : out std_logic;
      DSPBSERFS  : out std_logic;
      DSPBSERDR  : in  std_logic;

      -- link status
      DSPALINKUP : out std_logic;
      DSPBLINKUP : out std_logic
      );
  end component;

  signal CLK        : std_logic := '0';
  signal CLKHI      : std_logic := '0';
  signal RESET      : std_logic := '0';
  signal FIBERIN    : std_logic := '0';
  signal FIBEROUT   : std_logic := '0';
  -- SPORT outputs
  signal DSPASERCLK : std_logic := '0';
  signal DSPASERDT  : std_logic := '0';
  signal DSPASERFS  : std_logic := '0';
  signal DSPASERDR  : std_logic := '0';

  signal DSPBSERCLK : std_logic := '0';
  signal DSPBSERDT  : std_logic := '0';
  signal DSPBSERFS  : std_logic := '0';
  signal DSPBSERDR  : std_logic := '0';

  -- link status
  signal DSPALINKUP : std_logic := '0';
  signal DSPBLINKUP : std_logic := '0';

  signal dspadatain  : std_logic_vector(255 downto 0) := (others => '0');
  signal dspadataout : std_logic_vector(255 downto 0) := (others => '0');
  signal dspadone    : std_logic                      := '0';
  signal dspabitpos  : integer                        := 0;

  signal dspacmdout   : std_logic_vector(3 downto 0) := (others => '0');
  signal dspacmdidout : std_logic_vector(3 downto 0) := (others => '0');
  signal dspadata0out : std_logic_vector(7 downto 0) := (others => '0');



  signal dspbdatain  : std_logic_vector(255 downto 0) := (others => '0');
  signal dspbdataout : std_logic_vector(255 downto 0) := (others => '0');
  signal dspbdone    : std_logic                      := '0';
  signal dspbbitpos  : integer                        := 0;

  signal dspbcmdout   : std_logic_vector(3 downto 0) := (others => '0');
  signal dspbcmdidout : std_logic_vector(3 downto 0) := (others => '0');
  signal dspbdata0out : std_logic_vector(7 downto 0) := (others => '0');




  component acqboard
    port (
      CLKIN        : in  std_logic;
      RXDATA       : out std_logic_vector(31 downto 0) := (others => '0');
      RXCMD        : out std_logic_vector(3 downto 0);
      rxcmdid : out std_logic_vector(3 downto 0); 
      RXCHKSUM     : out std_logic_vector(7 downto 0);
      FIBEROUT     : out std_logic;
      FIBERIN      : in  std_logic;
      TXCMDSTS     : in  std_logic_vector(3 downto 0);
      TXCMDSUCCESS : in  std_logic;
      TXCHKSUM     : in  std_logic_vector(7 downto 0));
  end component;

  signal acqclk       : std_logic                    := '0';
  signal TXCMDDONE    : std_logic                    := '0';
  signal TXCMDSTS     : std_logic_vector(3 downto 0) := (others => '0');
  signal TXCMDID      : std_logic_vector(3 downto 0) := (others => '0');
  signal TXCMDSUCCESS : std_logic                    := '0';
  signal TXCHKSUM     : std_logic_vector(7 downto 0) := (others => '0');

  signal RXDATA   : std_logic_vector(31 downto 0) := (others => '0');
  signal RXCMD    : std_logic_vector(3 downto 0);
  signal RXNEWCMD : std_logic;
  signal RXCMDID  : std_logic_vector(3 downto 0);
  signal RXCHKSUM : std_logic_vector(7 downto 0);

begin  -- Behavioral

  acqboard_inst : acqboard
    port map (
      CLKIN        => acqclk,
      FIBEROUT     => FIBERIN,
      FIBERIN      => FIBEROUT,
      RXDATA       => RXDATA,
      RXCMD        => RXCMD,
      RXCMDID => RXCMDID, 
      RXCHKSUM     => RXCHKSUM,
      TXCMDSTS     => TXCMDSTS,
      TXCMDSUCCESS => TXCMDSUCCESS,
      TXCHKSUM     => TXCHKSUM);

  -- clocks
  CLK    <= not CLK    after 10 ns;     -- 50 MHz
  CLKHI  <= not CLKHI  after 6.25 ns;   -- 80 MHz
  acqclk <= not acqclk after 13.88888 ns;


  acqserial_uut : acqserial
    port map (
      CLK        => CLK,
      CLKHI      => CLKHI,
      RESET      => RESET,
      FIBERIN    => FIBERIN,
      FIBEROUT   => FIBEROUT,
      DSPASERCLK => DSPASERCLK,
      DSPASERDT  => DSPASERDT,
      DSPASERFS  => DSPASERFS,
      DSPASERDR  => DSPASERDR,

      DSPBSERCLK => DSPBSERCLK,
      DSPBSERDT  => DSPBSERDT,
      DSPBSERFS  => DSPBSERFS,
      DSPBSERDR  => DSPBSERDR,
      DSPALINKUP => DSPALINKUP,
      DSPBLINKUP => DSPBLINKUP
      );

  -----------------------------------------------------------------------------
  -- DSP A 
  -----------------------------------------------------------------------------
  process(DSPASERCLK)
  begin
    if rising_edge(DSPASERCLK) then
      if DSPASERFS = '1' then
        dspabitpos             <= 0;
      else
        dspabitpos             <= dspabitpos + 1;
        dspadatain(dspabitpos) <= DSPASERDT;
      end if;

      -- bit rx
    end if;
    if falling_edge(DSPASERCLK) then
      if dspabitpos < 256 then
        DSPASERDR <= dspadataout(dspabitpos);
      end if;
    end if;
  end process;

  -- dspa transmit test
  dspadataout(3 downto 0)   <= dspacmdout;
  dspadataout(7 downto 4)   <= dspacmdidout;
  dspadataout(23 downto 16) <= dspadata0out;

  -----------------------------------------------------------------------------
  -- DSP B
  -----------------------------------------------------------------------------
  process(DSPBSERCLK)
  begin
    if rising_edge(DSPBSERCLK) then
      if DSPBSERFS = '1' then
        dspbbitpos             <= 0;
      else
        dspbbitpos             <= dspbbitpos + 1;
        dspbdatain(dspbbitpos) <= DSPBSERDT;
      end if;

      -- bit rx
    end if;
    if falling_edge(DSPBSERCLK) then
      if dspbbitpos < 256 then
        DSPBSERDR <= dspbdataout(dspbbitpos);
      end if;
    end if;
  end process;

  -- dspb transmit test
  dspbdataout(3 downto 0)   <= dspbcmdout;
  dspbdataout(7 downto 4)   <= dspbcmdidout;
  dspbdataout(23 downto 16) <= dspbdata0out;

  -------------------------------------------------------------------------------
  --  A test
  -------------------------------------------------------------------------------                               

  process

  begin
    for i in 0 to 7 loop
      wait until rising_edge(clk) and dspabitpos = 256;
      dspacmdout <= X"1"; 

      dspacmdidout <= std_logic_vector(TO_UNSIGNED(i*2+1, 4));
      dspadata0out <= X"FE";
      wait until rising_edge(clk) and dspabitpos = 0;
      wait until rising_edge(clk) and dspabitpos = 256;
      dspacmdout   <= X"0";

      wait until rising_edge(clk) and dspabitpos = 256 and
        dspadatain(11 downto 8) = std_logic_vector(TO_UNSIGNED(i*2+1, 4)); 
      report "Successful read of A event";
    end loop;  -- i
    

    wait;

  end process;

  -------------------------------------------------------------------------------
  --  b test
  -------------------------------------------------------------------------------                               

  process

  begin
    for i in 0 to 6 loop
      wait until rising_edge(clk) and dspbbitpos = 256;
      dspbcmdout <= X"1"; 

      dspbcmdidout <= std_logic_vector(TO_UNSIGNED(i*2+2, 4));
      dspbdata0out <= X"FE";
      wait until rising_edge(clk) and dspbbitpos = 0;
      wait until rising_edge(clk) and dspbbitpos = 256;
      dspbcmdout   <= X"0";

      wait until rising_edge(clk) and dspbbitpos = 256 and
        dspbdatain(11 downto 8) = std_logic_vector(TO_UNSIGNED(i*2+2, 4)); 
      report "Successful read a B event";
      wait for 3 us;

      
    end loop;  -- i
    

    wait;

  end process;

  -- generic output verify
  
end Behavioral;
