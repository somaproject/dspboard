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

    SERCLK : out std_logic;
    SERDT  : in  std_logic;
    SERTFS : in  std_logic;
    FULL   : out std_logic
    );
end datasporttest;


architecture Behavioral of datasporttest is

  signal clk : std_logic := '0';

  component datasport
    port (
      CLK    : in  std_logic;
      RESET  : in  std_logic;
      -- serial IO
      SERCLK : in  std_logic;
      SERDT  : in  std_logic;
      SERTFS : in  std_logic;
      FULL   : out std_logic;
      -- FiFO interface
      REQ    : out std_logic;
      GRANT  : in  std_logic;
      DOUT   : out std_logic_vector(7 downto 0);
      DONE   : out std_logic);
  end component;


  signal bcnt : integer range 0 to 2 := 0;

  signal lserclk : std_logic := '0';

  signal req   : std_logic                    := '0';
  signal grant : std_logic                    := '0';
  signal dout  : std_logic_vector(7 downto 0) := (others => '0');
  signal done  : std_logic                    := '0';

  signal addra, addrb : std_logic_vector(10 downto 0) := (others => '0');
  signal wea          : std_logic                     := '0';
  signal dob          : std_logic_vector(7 downto 0)  := (others => '0');

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

  signal jtagout : std_logic_vector(7 downto 0) := (others => '0');

  signal inword, inwordl : std_logic_vector(15 downto 0) := (others => '0');
  signal inwordll        : std_logic_vector(15 downto 0) := (others => '0');


begin  -- Behavioral

  DSPRESET <= '1'; 
  clk <= REFCLKIN;

  DSPCLKOUT <= clk;

  LEDPOWER <= '1';
  
  datasport_inst : datasport
    port map (
      CLK    => CLK,
      RESET  => '0',
      SERCLK => lserclk,
      SERDT  => SERDT,
      SERTFS => SERTFS,
      FULL   => FULL,
      REQ    => req,
      GRANT  => grant,
      DOUT   => dout,
      DONE   => DONE);


  RAM1 : RAMB16_S9_S9
    generic map (
      WRITE_MODE_A        => "WRITE_FIRST",
      WRITE_MODE_B        => "WRITE_FIRST",
      SIM_COLLISION_CHECK => "NONE")
    port map (
      DOA                 => open,
      DOB                 => dob,
      DOPB                => open,
      ADDRA               => addra,
      ADDRB               => addrb,
      CLKA                => CLK,
      CLKB                => CLK,
      DIB                 => X"00",
      DIA                 => dout,
      DIPB                => "0",
      ENA                 => '1',
      ENB                 => '1',
      SSRA                => '0',
      SSRB                => '0',
      WEA                 => wea,
      WEB                 => '0' );


  process(CLK)
  begin
    if rising_edge(CLK) then

      if bcnt = 2 then
        bcnt <= 0;
      else
        bcnt <= bcnt + 1;
      end if;


      if bcnt = 1 then
        lserclk <= '1';
      else
        lserclk <= '0';
      end if;

      SERCLK <= lserclk;

      if grant = '1' then
        addra   <= (others => '0');
      else
        if addra /= "11111111111" then
          addra <= addrb + 1;
        end if;
      end if;

      inwordll <= inwordl;

      if inwordll(15) = '0' and inwordl(15) = '1' then
        req <= '1';
      else
        req <= '0'; 
      end if;

      addrb <= inwordl(10 downto 0);
      
    end if;
  end process;

  process(jtagDRCK1, clk)
  begin

    if jtagupdate = '1' then
      jtagout    <= dob;
    else
      if rising_edge(jtagDRCK1) then
        jtagout  <= '0' & jtagout(7 downto 1);
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
