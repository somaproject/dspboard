library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity uartacqrxtest is
  port (
    REFCLKIN  : in  std_logic;
    DSPCLKOUT : out std_logic;
    DSPRESET  : out std_logic;
    LEDPOWER  : out std_logic;
    UARTRX    : in  std_logic

    );
end uartacqrxtest;

architecture Behavioral of uartacqrxtest is

  -- clkhi generation
  signal clk, clkint     : std_logic := '0';
  signal clkhi, clkhiint : std_logic := '0';
  signal base_lock       : std_logic := '0';

  signal clk2, clk2int     : std_logic := '0';
  signal clkacq, clkacqint : std_logic := '0';
  signal base_lock2        : std_logic := '0';
  signal RESET             : std_logic := '0';


  component uartacqrx
    port (
      CLK        : in  std_logic;
      RESET      : in  std_logic;
      UARTRX     : in  std_logic;
      DATAOUT    : out std_logic_vector(47 downto 0);
      DATAOUTNEW : out std_logic);
  end component;



  signal jtagcapture : std_logic := '0';
  signal jtagdrck1   : std_logic := '0';
  signal jtagdrck2   : std_logic := '0';
  signal jtagsel1    : std_logic := '0';
  signal jtagsel2    : std_logic := '0';
  signal jtagshift   : std_logic := '0';
  signal jtagtdi     : std_logic := '0';
  signal jtagtdo1    : std_logic := '0';
  signal jtagtdo2    : std_logic := '0';
  signal jtagupdate  : std_logic := '0';

  signal jtagout : std_logic_vector(63 downto 0) := (others => '0');

  signal inword, inwordl : std_logic_vector(15 downto 0) := (others => '0');

  signal dspalinkupint, dspblinkupint : std_logic := '0';

  signal serclkpos : integer range 0 to 2 := 0;
  signal serclkint : std_logic            := '0';

  signal reset2, reset3 : std_logic := '1';

  signal debug : std_logic_vector(31 downto 0) := (others => '0');

  signal dataoutnew : std_logic                     := '0';
  signal dataout    : std_logic_vector(47 downto 0) := (others => '0');
  signal dataoutl    : std_logic_vector(47 downto 0) := (others => '0');
  signal datacnt : std_logic_vector(15 downto 0) := (others => '0'); 
    
begin  -- Behavioral

  mainclksrc : DCM
    generic map (
      CLKFX_DIVIDE   => 5,              -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY => 8,              -- Can be any integer from 2 to 32
      CLKIN_PERIOD   => 15.0,
      CLK_FEEDBACK   => "1X")
    port map(
      CLKIN          => REFCLKIN,
      CLK0           => clkint,
      CLKFB          => clk,
      CLKFX          => clkhiint,
      RST            => RESET,
      LOCKED         => base_lock
      );

  reset2 <= not base_lock;

  clk_bufg : BUFG
    port map (
      O => clk,
      I => clkint);

  DSPCLKOUT <= clk;

  hiclk_bufg : BUFG
    port map (
      O => clkhi,
      I => clkhiint);

  uartacqrx_uut : Uartacqrx
    port map (
      CLK        => CLK,
      RESET      => RESET,
      UARTRX     => UARTRX,
      DATAOUT    => DATAOUT,
      DATAOUTNEW => DATAOUTNEW);

-- ACQFIBEROUT <= '1';                  -- DEBUGGING; 

  LEDPOWER <= '1';
  DSPRESET <= not reset2;

  process(CLK)
  begin
    if rising_edge(CLK) then
      if dataoutnew = '1' then
        datacnt <= datacnt + 1; 
        dataoutl <= dataout; 
      end if;
    end if;

  end process;
  process(jtagDRCK1, clk)
  begin

    if jtagupdate = '1' then
      jtagout    <= datacnt & dataoutl;
    else
      if rising_edge(jtagDRCK1) then
        jtagout  <= '0' & jtagout(63 downto 1);
        jtagtdo1 <= jtagout(0);
      end if;

    end if;
  end process;

  process(jtagDRCK2, jtagUPDATE)
  begin
    if JTAGUPDATE = '1' and jtagsel2 = '1' then
      inwordl <= inword;
    end if;
    if rising_edge(jtagDRCK2) then
      inword  <= jtagtdi & inword(15 downto 1);
    end if;
  end process;

  BSCAN_SPARTAN3_inst : BSCAN_SPARTAN3
    port map (
      CAPTURE => jtagcapture,           -- CAPTURE output from TAP controller
      DRCK1   => jtagdrck1,             -- Data register output for USER1 functions
      DRCK2   => jtagDRCK2,             -- Data register output for USER2 functions
      SEL1    => jtagSEL1,              -- USER1 active output
      SEL2    => jtagSEL2,              -- USER2 active output
      SHIFT   => jtagSHIFT,             -- SHIFT output from TAP controller
      TDI     => jtagTDI,               -- TDI output from TAP controller
      UPDATE  => jtagUPDATE,            -- UPDATE output from TAP controller
      TDO1    => jtagtdo1,              -- Data input for USER1 function
      TDO2    => jtagtdo2               -- Data input for USER2 function
      );

end Behavioral;
