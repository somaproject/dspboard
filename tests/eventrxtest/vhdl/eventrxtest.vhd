library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity eventrxtest is
  port (
    SYSCLKIN  : in  std_logic;
    DSPCLKOUTA : out std_logic;
    DSPRESETA  : out std_logic := '0';
    LEDPOWER  : out std_logic;

    -- Actual DSP interface
    SCLK      : in  std_logic;
    MOSI      : in  std_logic;
    SCS       : in  std_logic;
    FIFOFULL  : out std_logic;
    -- debug if
    SENDEVENT : out std_logic
    );
end eventrxtest;

architecture Behavioral of eventrxtest is

  signal clk : std_logic := '0';

  signal dout : std_logic_vector(7 downto 0) := (others => '0');

  signal req, grant : std_logic := '0';

  signal grantl, grantdelta : std_logic := '0';


  component eventrx
    port (
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      SCLK     : in  std_logic;
      MOSI     : in  std_logic;
      SCS      : in  std_logic;
      FIFOFULL : out std_logic;
      DOUT     : out std_logic_vector(7 downto 0);
      REQ      : out std_logic;
      GRANT    : in  std_logic;
      DEBUG : out std_logic_vector(15 downto 0));
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

  signal jtagout : std_logic_vector(239 downto 0) := (others => '0');

  signal capturedevent : std_logic_vector(199 downto 0) := (others => '0');

  signal inword, inwordl : std_logic_vector(15 downto 0) := (others => '0');

  signal wordpos : integer range 0 to 22 := 0;

  signal debug : std_logic_vector(15 downto 0) := (others => '0');

  signal scslhist : std_logic := '1';
  
begin  -- Behavioral

  clk       <= SYSCLKIN; 
  DSPCLKOUTA <= clk;

  LEDPOWER <= '1';


  eventrx_inst : eventrx
    port map (
      CLK      => CLK,
      RESET    => '0',
      SCLK     => SCLK,
      MOSI     => MOSI,
      SCS      => SCS,
      FIFOFULL => FIFOFULL,
      DOUT     => DOUT,
      REQ      => req, 
      GRANT    => grantdelta,
      DEBUG => debug);


  capturedevent(199) <= req;
  capturedevent(198) <= grant;
  capturedevent(197) <= scslhist; 
  
  process(jtagDRCK1, clk)
  begin

    if jtagupdate = '1' then
      jtagout    <= X"1234" & capturedevent & X"AB" & inwordl;
    else
      if rising_edge(jtagDRCK1) then
        jtagout  <= '0' & jtagout(239 downto 1);
        jtagtdo1 <= jtagout(0);
      end if;

    end if;
  end process;

  SENDEVENT <= inwordl(0);

  process(clk)
  begin
    if rising_edge(clk) then
      DSPRESETA  <= inwordl(15); 

      if SCS = '0' then
        scslhist <= '0';
      else
        if inwordl(7) = '1' then
          scslhist <= '1'; 
        end if;
      end if;
      
      grant       <= inwordl(8);
      grantl       <= grant;
      if grant = '1' and grantl = '0' then
        grantdelta <= '1';
      else
        grantdelta <= '0';
      end if;

      if grantdelta = '1' then
        wordpos <= 0;
      else
        if wordpos < 22 then
          wordpos <= wordpos + 1;
        end if;
      end if;
    end if;
  end process;

  writebits: for i in 0 to 21 generate
    process(clk)
      begin
        if rising_edge(CLK) then
          if wordpos = i then 
            capturedevent(8 * i +7 downto 8*i) <= dout; 
          end if; 
        end if;
      end process; 
  end generate writebits;


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
