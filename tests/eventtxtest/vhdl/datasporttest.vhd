library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity datasporttest is
  port (
    REFCLKIN  : in  std_logic;
    DSPCLKOUT : out std_logic;
    DSPRESET  : out std_logic;
    LEDPOWER  : out std_logic;
    RSCLK     : out std_logic;
    TSCLK     : out std_logic;
    DR        : out std_logic;
    RFS       : out std_logic;
    DT        : in  std_logic;
    TFS       : in  std_logic
    );
end datasporttest;


architecture Behavioral of datasporttest is

  signal clk : std_logic := '0';

  signal sclktoggle : std_logic := '0';


  component datasport
    port (
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      -- serial IO
      SDIN     : in  std_logic;
      STFS     : in  std_logic;
      SCLK     : in  std_logic;
      -- FiFO interface
      VALID    : out std_logic;
      DOUT     : out std_logic_vector(7 downto 0);
      ADDRIN   : in  std_logic_vector(9 downto 0);
      FIFONEXT : in  std_logic);
  end component;

  signal valid    : std_logic                    := '0';
  signal dout     : std_logic_vector(7 downto 0) := (others => '0');
  signal addr     : std_logic_vector(9 downto 0) := (others => '0');
  signal fifonext : std_logic                    := '0';
  signal f1, f2   : std_logic                    := '0';



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

  signal jtagout : std_logic_vector(23 downto 0) := (others => '0');
  signal jtagin  : std_logic_vector(15 downto 0) := (others => '0');

  signal tfscnt : std_logic_vector(7 downto 0) := (others => '0');
  

begin  -- Behavioral


  clk <= REFCLKIN;

  DSPCLKOUT <= clk;

  DR       <= '0';
  RFS      <= '0';
  DSPRESET <= '1';

  datasportinst : datasport
    port map (
      CLK      => CLK,
      reset    => '0',
      SDIN     => DT,
      STFS     => TFS,
      SCLK     => sclktoggle,
      VALID    => valid,
      dout     => dout,
      ADDRIN   => addr,
      fifonext => fifonext
      );


  main : process (CLK)
  begin
    if rising_edge(CLK) then
      sclktoggle <= not sclktoggle;
      RSCLK      <= sclktoggle;
      TSCLK <= sclktoggle;
      
      if jtagupdate = '1' then
        f1 <= jtagin(15);
      end if;

      f2 <= f1;

      if f1 = '1' and f2 = '0' then
        fifonext <= '1';
      else
        fifonext <= '0';
      end if;
      LEDPOWER   <= fifonext;


      if sclktoggle = '1' and  tfs= '1'  then
        tfscnt <= tfscnt + 1;
      end if;

    end if;
  end process main;

  process(jtagDRCK1, clk, jtagupdate, jtagsel1, jtagsel2)
  begin

    if jtagupdate = '1' and jtagsel1 = '1' then
      jtagout    <= "0000000" & valid & tfscnt & dout;
      addr       <= jtagin(9 downto 0);
    else
      if rising_edge(jtagDRCK1) then
        jtagout  <= '0' & jtagout(23 downto 1);
        jtagtdo1 <= jtagout(0);

        jtagin <= (jtagTDI & jtagin(15 downto 1));

      end if;

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
