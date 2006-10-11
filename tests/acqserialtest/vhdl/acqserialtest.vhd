library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity acqserialtest is
  port (
    REFCLKIN  : in  std_logic;
    DSPCLKOUT : out std_logic;
    DSPRESET  : out std_logic;
    LEDPOWER  : out std_logic;

    DSPARSCLK  : out std_logic;
    DSPADR     : out std_logic;
    DSPARFS    : out std_logic;
    DSPADT     : in  std_logic;
    DSPALINKUP : out std_logic;

    DSPBRSCLK  : out std_logic;
    DSPBDR     : out std_logic;
    DSPBRFS    : out std_logic;
    DSPBDT     : in  std_logic;
    DSPBLINKUP : out std_logic;

    -- fiber IO, we actually take this off-chip
    DSPFIBEROUT : out std_logic;
    DSPFIBERIN  : in  std_logic;

    ACQFIBEROUT : out std_logic;
    ACQFIBERIN  : in  std_logic
    );
end acqserialtest;

architecture Behavioral of acqserialtest is

  -- clkhi generation
  signal clk, clkint     : std_logic := '0';
  signal clkhi, clkhiint : std_logic := '0';
  signal base_lock       :  std_logic := '0';

  signal clk2, clk2int     : std_logic := '0';
  signal clkacq, clkacqint : std_logic := '0';
  signal base_lock2        :std_logic := '0'; 
  signal RESET : std_logic := '0';
  

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

component acqboard 
  port (
    CLKIN        : in  std_logic;
    RXDATA       : out std_logic_vector(31 downto 0) := (others => '0');
    RXCMD        : out std_logic_vector(3 downto 0);
    RXCMDID      : out std_logic_vector(3 downto 0);
    RXCHKSUM     : out std_logic_vector(7 downto 0);
    FIBEROUT     : out std_logic;
    FIBERIN : in std_logic;
    TXCMDSTS     : in  std_logic_vector(3 downto 0);
    TXCMDSUCCESS : in  std_logic;
    TXCHKSUM     : in  std_logic_vector(7 downto 0));

end component;



begin  -- Behavioral

  mainclksrc : DCM
    generic map (
      CLKFX_DIVIDE          => 5,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 8,       -- Can be any integer from 2 to 32
      CLKIN_PERIOD          => 15.0,
      CLK_FEEDBACK          => "1X")
    port map(
      CLKIN                 => REFCLKIN,
      CLK0                  => clkint,
      CLKFB                 => clk,
      CLKFX                 => clkhiint,
      RST                   => RESET,
      LOCKED                => base_lock
      );

  clk_bufg : BUFG
    port map (
      O => clk,
      I => clkint);

  DSPCLKOUT <= clk;
  
  hiclk_bufg : BUFG
    port map (
      O => clkhi,
      I => clkhiint);


  acqclksrc : DCM
    generic map (
      CLKFX_DIVIDE          => 25,      -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 18,      -- Can be any integer from 2 to 32
      CLKIN_PERIOD          => 15.0,
      CLKOUT_PHASE_SHIFT    => "NONE",
      CLK_FEEDBACK          => "1X")
    port map(
      CLKIN                 => REFCLKIN,
      CLK0                  => clk2int,
      CLKFB                 => clk2,
      CLKFX                 => clkacqint,
      RST                   => RESET,
      LOCKED                => base_lock2
      );


  
  clk2_bufg : BUFG
    port map (
      O => clk2,
      I => clk2int);

  acqclk_bufg : BUFG
    port map (
      O => clkacq,
      I => clkacqint); 

  
  acqserial_inst: acqserial
    port map (
      CLK        => clk,
      RESET => reset, 
      CLKHI      => clkhi,
      FIBERIN    => DSPFIBERIN,
      FIBEROUT   => DSPFIBEROUT,
      
      DSPASERCLK => DSPARSCLK,
      DSPASERDT  => DSPADR,
      DSPASERFS  => DSPARFS,
      DSPASERDR  => DSPADT,
      DSPALINKUP => DSPALINKUP,

      DSPBSERCLK => DSPBRSCLK,
      DSPBSERDT  => DSPBDR,
      DSPBSERFS  => DSPBRFS,
      DSPBSERDR  => DSPBDT,
      DSPBLINKUP => DSPBLINKUP); 

    acqboard_inst: acqboard
    port map (
      CLKIN        => clkacq,
      RXDATA       => open,
      RXCMD        => open,
      RXCMDID      => open,
      RXCHKSUM     => open,
      FIBEROUT     => ACQFIBEROUT,
      FIBERIN      => ACQFIBERIN,
      TXCMDSTS     => "0101",
      TXCMDSUCCESS => '1',
      TXCHKSUM     => X"AB"); 

  LEDPOWER <= '1';
  DSPRESET <= '1';
  
              
end Behavioral;
