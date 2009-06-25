library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library eproc;
use eproc.all;

library UNISIM;
use UNISIM.VComponents.all;

entity dspcontproc is
  generic (
    RAM_INIT_00 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_01 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_02 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_03 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_04 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_05 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_06 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_07 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_08 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_09 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_0A : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_0B : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_0C : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_0D : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_0E : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_0F : bit_vector(0 to 255) := (others => '0');

    RAM_INIT_10 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_11 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_12 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_13 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_14 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_15 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_16 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_17 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_18 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_19 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_1A : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_1B : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_1C : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_1D : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_1E : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_1F : bit_vector(0 to 255) := (others => '0');

    RAM_INIT_20 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_21 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_22 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_23 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_24 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_25 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_26 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_27 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_28 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_29 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_2A : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_2B : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_2C : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_2D : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_2E : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_2F : bit_vector(0 to 255) := (others => '0');

    RAM_INIT_30 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_31 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_32 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_33 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_34 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_35 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_36 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_37 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_38 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_39 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_3A : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_3B : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_3C : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_3D : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_3E : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_3F : bit_vector(0 to 255) := (others => '0');

    RAM_INITP_00 : bit_vector(0 to 255) := (others => '0');
    RAM_INITP_01 : bit_vector(0 to 255) := (others => '0');
    RAM_INITP_02 : bit_vector(0 to 255) := (others => '0');
    RAM_INITP_03 : bit_vector(0 to 255) := (others => '0');
    RAM_INITP_04 : bit_vector(0 to 255) := (others => '0');
    RAM_INITP_05 : bit_vector(0 to 255) := (others => '0');
    RAM_INITP_06 : bit_vector(0 to 255) := (others => '0');
    RAM_INITP_07 : bit_vector(0 to 255) := (others => '0'));
  port (
    CLK         : in  std_logic;
    CLKHI       : in  std_logic;
    RESET       : in  std_logic;
    -- Event input
    ECYCLE      : in  std_logic;
    EARXBYTE    : in  std_logic_vector(7 downto 0);
    EARXBYTESEL : out std_logic_vector(3 downto 0);
    EDRX        : in  std_logic_vector(7 downto 0);
    -- Event output 
    ESENDREQ    : out std_logic;
    ESENDGRANT  : in  std_logic;
    ESENDDONE   : out std_logic;
    ESENDDATA   : out std_logic_vector(7 downto 0);
    ESENDDATAEN : in  std_logic;
    -- DSP interface
    DSPRESET    : out std_logic := '0';
    DSPSPIEN    : out std_logic := '1';
    DSPSPISS    : out std_logic := '1';
    DSPSPIMISO  : in  std_logic;
    DSPSPIMOSI  : out std_logic;
    DSPSPICLK   : out std_logic := '0';
    DSPSPIHOLD  : in  std_logic;
    DSPUARTTX   : out std_logic;
    -- STATUS
    LEDEVENT    : out std_logic;
    DEBUGIN     : in  std_logic_vector(31 downto 0)

    );
end dspcontproc;

architecture Behavioral of dspcontproc is

  signal oportaddr   : std_logic_vector(7 downto 0)  := (others => '0');
  signal oportdata   : std_logic_vector(15 downto 0) := (others => '0');
  signal oportstrobe : std_logic                     := '0';

  signal iportaddr   : std_logic_vector(7 downto 0)  := (others => '0');
  signal iportdata   : std_logic_vector(15 downto 0) := (others => '0');
  signal iportstrobe : std_logic                     := '0';

  signal earxl : std_logic_vector(79 downto 0) := (others => '0');

  signal iaddr : std_logic_vector(9 downto 0)  := (others => '0');
  signal idata : std_logic_vector(17 downto 0) := (others => '0');

  signal eaout, eaoutl : std_logic_vector(77 downto 0) := (others => '0');
  signal edout, edoutl : std_logic_vector(95 downto 0) := (others => '0');

  signal enewout, enewoutl, enewoutd : std_logic := '0';

  signal lledevent : std_logic := '0';

  signal eventtxwe : std_logic                     := '0';
  signal debuginl  : std_logic_vector(31 downto 0) := (others => '0');
  signal debuginll : std_logic_vector(31 downto 0) := (others => '0');

  signal device : std_logic_vector(7 downto 0) := (others => '1');  -- not set

  component bootser
    port (CLK       : in  std_logic;
           DIN      : in  std_logic_vector(15 downto 0);
           ADDRIN   : in  std_logic_vector(15 downto 0);
           WE       : in  std_logic;
           START    : in  std_logic;
           STARTLEN : in  std_logic_vector(15 downto 0);
           DONE     : out std_logic;
           MOSI     : out std_logic;
           HOLD     : in  std_logic;
           SCLK     : out std_logic
           );
  end component;

  signal bootserwe       : std_logic                     := '0';
  signal bootseraddrin   : std_logic_vector(15 downto 0) := (others => '0');
  signal bootserstartlen : std_logic_vector(15 downto 0) := (others => '0');
  signal bootserstart    : std_logic                     := '0';
  signal bootserdone     : std_logic                     := '0';


  component uartbyteout
    port (
      CLK    : in  std_logic;           -- '0'
      DIN    : in  std_logic_vector(7 downto 0);
      SEND   : in  std_logic;
      DONE   : out std_logic;
      UARTTX : out std_logic
      );
  end component;

  signal uarttxsend              : std_logic := '0';
  signal uarttxdone, uarttxdonel : std_logic := '0';
  
begin  -- Behavioral

  eproc_inst : entity eproc.eproc
    generic map (
      EATXMUX   => true,
      DEMUXEOUT => false)
    port map (
      CLK         => CLK,
      CLKHI       => CLKHI,
      RESET       => RESET,
      EDTX        => EDRX,
-- EATX => X
      EATXBYTE    => EARXBYTE,
      EATXBYTESEL => EARXBYTESEL,
      EAOUT       => eaout,
      EDOUT       => edout,
      ENEWOUT     => enewout,
      ECYCLE      => ECYCLE,
      IADDR       => iaddr,
      IDATA       => idata,
      OPORTADDR   => oportaddr,
      OPORTDATA   => oportdata,
      OPORTSTROBE => oportstrobe,
      IPORTADDR   => iportaddr,
      IPORTDATA   => iportdata,
      IPORTSTROBE => iportstrobe,
      DEVICE      => DEVICE);

  eprocbuf_inst : entity eproc.txreqbrambuffer
    port map (
      CLK       => CLKHI,
      SRC       => DEVICE,
      ADDRIN    => oportaddr(2 downto 0),
      WEIN      => eventtxwe,
      DIN       => oportdata,
      OUTCLK    => CLK,
      SENDREQ   => ESENDREQ,
      SENDGRANT => ESENDGRANT,
      SENDDONE  => ESENDDONE,
      DOUT      => ESENDDATA,
      DOUTEN    => ESENDDATAEN);

  eventtxwe <= '1' when oportstrobe = '1' and oportaddr(7 downto 3) = "10000" else '0';

  bootser_inst : bootser
    port map (
      CLK      => clkhi,
      DIN      => oportdata,
      ADDRIN   => bootseraddrin,
      WE       => bootserwe,
      START    => bootserstart,
      STARTLEN => bootserstartlen,
      DONE     => bootserdone,
      MOSI     => DSPSPIMOSI,
      --MISO => DSPSPIMISO,
      HOLD     => DSPSPIHOLD,
      SCLK     => DSPSPICLK);

  uartbyteout_inst : uartbyteout
    port map (
      CLK    => clkhi,
      DIN    => oportdata(7 downto 0),
      SEND   => uarttxsend,
      DONE   => uarttxdone,
      UARTTX => DSPUARTTX); 

  instruction_ram : RAMB16_S18_S18
    generic map (
      INIT_00 => RAM_INIT_00,
      INIT_01 => RAM_INIT_01,
      INIT_02 => RAM_INIT_02,
      INIT_03 => RAM_INIT_03,
      INIT_04 => RAM_INIT_04,
      INIT_05 => RAM_INIT_05,
      INIT_06 => RAM_INIT_06,
      INIT_07 => RAM_INIT_07,
      INIT_08 => RAM_INIT_08,
      INIT_09 => RAM_INIT_09,
      INIT_0A => RAM_INIT_0A,
      INIT_0B => RAM_INIT_0B,
      INIT_0C => RAM_INIT_0C,
      INIT_0D => RAM_INIT_0D,
      INIT_0E => RAM_INIT_0E,
      INIT_0F => RAM_INIT_0F,

      INIT_10 => RAM_INIT_10,
      INIT_11 => RAM_INIT_11,
      INIT_12 => RAM_INIT_12,
      INIT_13 => RAM_INIT_13,
      INIT_14 => RAM_INIT_14,
      INIT_15 => RAM_INIT_15,
      INIT_16 => RAM_INIT_16,
      INIT_17 => RAM_INIT_17,
      INIT_18 => RAM_INIT_18,
      INIT_19 => RAM_INIT_19,
      INIT_1A => RAM_INIT_1A,
      INIT_1B => RAM_INIT_1B,
      INIT_1C => RAM_INIT_1C,
      INIT_1D => RAM_INIT_1D,
      INIT_1E => RAM_INIT_1E,
      INIT_1F => RAM_INIT_1F,

      INIT_20 => RAM_INIT_20,
      INIT_21 => RAM_INIT_21,
      INIT_22 => RAM_INIT_22,
      INIT_23 => RAM_INIT_23,
      INIT_24 => RAM_INIT_24,
      INIT_25 => RAM_INIT_25,
      INIT_26 => RAM_INIT_26,
      INIT_27 => RAM_INIT_27,
      INIT_28 => RAM_INIT_28,
      INIT_29 => RAM_INIT_29,
      INIT_2A => RAM_INIT_2A,
      INIT_2B => RAM_INIT_2B,
      INIT_2C => RAM_INIT_2C,
      INIT_2D => RAM_INIT_2D,
      INIT_2E => RAM_INIT_2E,
      INIT_2F => RAM_INIT_2F,

      INIT_30 => RAM_INIT_30,
      INIT_31 => RAM_INIT_31,
      INIT_32 => RAM_INIT_32,
      INIT_33 => RAM_INIT_33,
      INIT_34 => RAM_INIT_34,
      INIT_35 => RAM_INIT_35,
      INIT_36 => RAM_INIT_36,
      INIT_37 => RAM_INIT_37,
      INIT_38 => RAM_INIT_38,
      INIT_39 => RAM_INIT_39,
      INIT_3A => RAM_INIT_3A,
      INIT_3B => RAM_INIT_3B,
      INIT_3C => RAM_INIT_3C,
      INIT_3D => RAM_INIT_3D,
      INIT_3E => RAM_INIT_3E,
      INIT_3F => RAM_INIT_3F,

      INITP_00 => RAM_INITP_00,
      INITP_01 => RAM_INITP_01,
      INITP_02 => RAM_INITP_02,
      INITP_03 => RAM_INITP_03,
      INITP_04 => RAM_INITP_04,
      INITP_05 => RAM_INITP_05,
      INITP_06 => RAM_INITP_06,
      INITP_07 => RAM_INITP_07)
    port map (

      DOA   => idata(15 downto 0),
      DOPA  => idata(17 downto 16),
      ADDRA => iaddr,
      CLKA  => CLKHI,
      DIA   => X"0000",
      DIPA  => "00",
      ENA   => '1',
      WEA   => '0',
      SSRA  => RESET,
      DOB   => open,
      DOPB  => open,
      ADDRB => "0000000000",
      CLKB  => CLKHI,
      DIB   => X"0000",
      DIPB  => "00",
      ENB   => '0',
      WEB   => '0',
      SSRB  => RESET);

  bootserwe <= '1' when oportaddr = X"02" and oportstrobe = '1' else '0';


  bootserstart <= '1' when oportaddr = X"03" and oportstrobe = '1' else '0';

  uarttxsend      <= '1' when oportaddr = X"06" and oportstrobe = '1' else '0';
  bootserstartlen <= oportdata(15 downto 0);

  main : process(CLKHI)
  begin
    if rising_edge(CLkHI) then
      if oportaddr = X"00" and OPORTSTROBE = '1' then
        DSPRESET <= oportdata(0);
      elsif oportaddr = X"01" and OPORTSTROBE = '1' then
        lledevent <= oportdata(0);
      elsif oportaddr = X"04" and OPORTSTROBE = '1' then
        DSPSPISS <= oportdata(0);
      elsif oportaddr = X"05" and OPORTSTROBE = '1' then
        DSPSPIEN <= oportdata(0);
      elsif oportaddr = X"A0" and OPORTSTROBE = '1' then
        device <= oportdata(7 downto 0);
      elsif oportaddr = X"08" and OPORTSTROBE = '1' then
        bootseraddrin <= oportdata(15 downto 0);
      end if;



      if oportaddr = X"06" and oportstrobe = '1' then
        uarttxdonel <= '0';
      else
        if uarttxdone = '1' then
          uarttxdonel <= '1';
        end if;
      end if;

      if iportstrobe = '1' then
        if iportaddr = X"03" then
          iportdata <= X"000" & "000" & bootserdone;
        elsif iportaddr = X"07" then
          iportdata <= X"000" & "000" & uarttxdonel;
        elsif iportaddr = X"09" then
          iportdata <= debuginll(15 downto 0);
--        elsif iportaddr = X"0A" then
--          iportdata <= debuginll(31 downto 16); 
        end if;
      end if;

      LEDEVENT <= lledevent;

      enewoutl <= enewout;
      enewoutd <= enewoutl or enewout;

      debuginll <= debuginl;


    end if;

  end process main;

  debugproc : process(CLK)
  begin
    if rising_edge(CLK) then
      debuginl <= DEBUGIN;
    end if;
  end process debugproc;

  
end Behavioral;
