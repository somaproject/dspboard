library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.test_mem_pkg.all;


entity proceventiotest is

end proceventiotest;


architecture Behavioral of proceventiotest is
  signal valid : std_logic := '0';

  signal txdata : std_logic_vector(7 downto 0) := (others => '0');
  signal txk    : std_logic                    := '0';

  signal rxdata : std_logic_vector(7 downto 0) := (others => '0');
  signal rxk    : std_logic                    := '0';

  signal clk   : std_logic := '0';
  signal RESET : std_logic := '1';

  signal pcnt         : std_logic_vector(21 downto 0) := (others => '0');
  signal decodeerrint : std_logic                     := '0';

  signal epos, lepos : integer range 0 to 999 := 800;


  component decodemux
    port (
      CLK    : in std_logic;
      DIN    : in std_logic_vector(7 downto 0);
      KIN    : in std_logic;
      LOCKED : in std_logic;

      ECYCLE : out std_logic;
      EDATA  : out std_logic_vector(7 downto 0);

      -- data interface
      DGRANTA      : out std_logic;
      EARXBYTEA    : out std_logic_vector(7 downto 0) := (others => '0');
      EARXBYTESELA : in  std_logic_vector(3 downto 0) := (others => '0');

      DGRANTB      : out std_logic;
      EARXBYTEB    : out std_logic_vector(7 downto 0) := (others => '0');
      EARXBYTESELB : in  std_logic_vector(3 downto 0) := (others => '0');

      DGRANTC      : out std_logic;
      EARXBYTEC    : out std_logic_vector(7 downto 0) := (others => '0');
      EARXBYTESELC : in  std_logic_vector(3 downto 0) := (others => '0');

      DGRANTD      : out std_logic;
      EARXBYTED    : out std_logic_vector(7 downto 0) := (others => '0');
      EARXBYTESELD : in  std_logic_vector(3 downto 0) := (others => '0')

      );
  end component;


  component encodemux
    port (
      CLK        : in  std_logic;
      ECYCLE     : in  std_logic;
      DOUT       : out std_logic_vector(7 downto 0);
      KOUT       : out std_logic;
      -- data interface
      DREQ       : in  std_logic;
      DGRANT     : out std_logic;
      DDONE      : in  std_logic;
      DDATA      : in  std_logic_vector(7 downto 0);
      -- event interface for DSPs
      EDSPREQ    : in  std_logic_vector(3 downto 0);
      EDSPGRANT  : out std_logic_vector(3 downto 0);
      EDSPDONE   : in  std_logic_vector(3 downto 0);
      EDSPDATAA  : in  std_logic_vector(7 downto 0);
      EDSPDATAB  : in  std_logic_vector(7 downto 0);
      EDSPDATAC  : in  std_logic_vector(7 downto 0);
      EDSPDATAD  : in  std_logic_vector(7 downto 0);
                                        -- event interface for EPROCs
      EPROCREQ   : in  std_logic_vector(3 downto 0);
      EPROCGRANT : out std_logic_vector(3 downto 0);
      EPROCDONE  : in  std_logic_vector(3 downto 0);
      EPROCDATAA : in  std_logic_vector(7 downto 0);
      EPROCDATAB : in  std_logic_vector(7 downto 0);
      EPROCDATAC : in  std_logic_vector(7 downto 0);
      EPROCDATAD : in  std_logic_vector(7 downto 0));
  end component;



  signal ECYCLE : std_logic                    := '0';
  signal EDATA  : std_logic_vector(7 downto 0) := (others => '0');

  -- decodemux signals interface
  signal DGRANTA      : std_logic                    := '0';
  signal EARXBYTEA    : std_logic_vector(7 downto 0) := (others => '0');
  signal EARXBYTESELA : std_logic_vector(3 downto 0) := (others => '0');


  signal DGRANTB      : std_logic                    := '0';
  signal EARXBYTEB    : std_logic_vector(7 downto 0) := (others => '0');
  signal EARXBYTESELB : std_logic_vector(3 downto 0) := (others => '0');

  signal DGRANTC      : std_logic                    := '0';
  signal EARXBYTEC    : std_logic_vector(7 downto 0) := (others => '0');
  signal EARXBYTESELC : std_logic_vector(3 downto 0) := (others => '0');

  signal DGRANTD      : std_logic                    := '0';
  signal EARXBYTED    : std_logic_vector(7 downto 0) := (others => '0');
  signal EARXBYTESELD : std_logic_vector(3 downto 0) := (others => '0');


  component dspcontproc
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

      RAM_INITP_00 :     bit_vector(0 to 255) := (others => '0');
      RAM_INITP_01 :     bit_vector(0 to 255) := (others => '0');
      RAM_INITP_02 :     bit_vector(0 to 255) := (others => '0');
      RAM_INITP_03 :     bit_vector(0 to 255) := (others => '0');
      RAM_INITP_04 :     bit_vector(0 to 255) := (others => '0');
      RAM_INITP_05 :     bit_vector(0 to 255) := (others => '0');
      RAM_INITP_06 :     bit_vector(0 to 255) := (others => '0');
      RAM_INITP_07 :     bit_vector(0 to 255) := (others => '0') );
    port (
      CLK          : in  std_logic;
      RESET        : in  std_logic;
      CLKHI        : in  std_logic;
      DEVICE       : in  std_logic_vector(7 downto 0);
      -- Event input
      ECYCLE       : in  std_logic;
      EARXBYTE     : in  std_logic_vector(7 downto 0);
      EARXBYTESEL  : out std_logic_vector(3 downto 0);
      EDRX         : in  std_logic_vector(7 downto 0);
      -- Event output 
      ESENDREQ     : out std_logic;
      ESENDGRANT   : in  std_logic;
      ESENDDONE    : out std_logic;
      ESENDDATA    : out std_logic_vector(7 downto 0);
      -- DSP interface
      DSPRESET     : out std_logic;
      DSPSPIEN     : out std_logic;
      DSPSPISS     : out std_logic;
      DSPSPIMISO   : in  std_logic;
      DSPSPIMOSI   : out std_logic;
      DSPSPICLK    : out std_logic;
      DSPSPIHOLD   : in  std_logic);
  end component;

  signal dreq   : std_logic                    := '0';
  signal dgrant : std_logic                    := '0';
  signal ddone  : std_logic                    := '0';
  signal ddata  : std_logic_vector(7 downto 0) := (others => '0');


  signal edspreq   : std_logic_vector(3 downto 0) := (others => '0');
  signal edspgrant : std_logic_vector(3 downto 0) := (others => '0');
  signal edspdone  : std_logic_vector(3 downto 0) := (others => '0');

  signal eprocreq   : std_logic_vector(3 downto 0) := (others => '0');
  signal eprocgrant : std_logic_vector(3 downto 0) := (others => '0');
  signal eprocdone  : std_logic_vector(3 downto 0) := (others => '0');

  signal eprocdataa : std_logic_vector(7 downto 0) := (others => '0');
  signal eprocdatab : std_logic_vector(7 downto 0) := (others => '0');
  signal eprocdatac : std_logic_vector(7 downto 0) := (others => '0');
  signal eprocdatad : std_logic_vector(7 downto 0) := (others => '0');

  signal edspdataa : std_logic_vector(7 downto 0) := (others => '0');
  signal edspdatab : std_logic_vector(7 downto 0) := (others => '0');
  signal edspdatac : std_logic_vector(7 downto 0) := (others => '0');
  signal edspdatad : std_logic_vector(7 downto 0) := (others => '0');

  signal devicea     : std_logic_vector(7 downto 0) := (others => '0');
  signal dspspiena   : std_logic                    := '0';
  signal dspspissa   : std_logic                    := '0';
  signal dspspimisoa : std_logic                    := '0';
  signal dspspimosia : std_logic                    := '0';
  signal dspspiclka  : std_logic                    := '0';
  signal dspspiholda : std_logic                    := '0';


  signal deviceb     : std_logic_vector(7 downto 0) := (others => '0');
  signal dspspienb   : std_logic                    := '0';
  signal dspspissb   : std_logic                    := '0';
  signal dspspimisob : std_logic                    := '0';
  signal dspspimosib : std_logic                    := '0';
  signal dspspiclkb  : std_logic                    := '0';
  signal dspspiholdb : std_logic                    := '0';

  signal devicec     : std_logic_vector(7 downto 0) := (others => '0');
  signal dspspienc   : std_logic                    := '0';
  signal dspspissc   : std_logic                    := '0';
  signal dspspimisoc : std_logic                    := '0';
  signal dspspimosic : std_logic                    := '0';
  signal dspspiclkc  : std_logic                    := '0';
  signal dspspiholdc : std_logic                    := '0';

  signal deviced     : std_logic_vector(7 downto 0) := (others => '0');
  signal dspspiend   : std_logic                    := '0';
  signal dspspissd   : std_logic                    := '0';
  signal dspspimisod : std_logic                    := '0';
  signal dspspimosid : std_logic                    := '0';
  signal dspspiclkd  : std_logic                    := '0';
  signal dspspiholdd : std_logic                    := '0';

  signal linkup : std_logic := '1';

  signal clk2x : std_logic := '0';

  signal clkstate : integer   := 0;
  signal mainclk  : std_logic := '0';

  signal dspreseta : std_logic := '0';
  signal dspresetb : std_logic := '0';
  signal dspresetc : std_logic := '0';
  signal dspresetd : std_logic := '0';


  signal dout : std_logic_vector(7 downto 0) := (others => '0');
  signal kout : std_logic                    := '0';

  -- event signals
  signal dlEATXa : std_logic_vector(79 downto 0) := (others => '0');
  signal dlEATXb : std_logic_vector(79 downto 0) := (others => '0');
  signal dlEATXc : std_logic_vector(79 downto 0) := (others => '0');
  signal dlEATXd : std_logic_vector(79 downto 0) := (others => '0');

  signal dlEDTX : std_logic_vector(7 downto 0) := (others => '0');

  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to 79) of eventarray;

  signal dleventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(79 downto 0) := (others => '0');

  -- event recovery
  type eventaddr is array(0 to 9) of std_logic_vector(7 downto 0);

  signal event_data_a : eventarray := (others => (others => '0'));
  signal event_data_b : eventarray := (others => (others => '0'));
  signal event_data_c : eventarray := (others => (others => '0'));
  signal event_data_d : eventarray := (others => (others => '0'));

  signal event_addr_a : eventaddr := (others => (others => '0'));
  signal event_addr_b : eventaddr := (others => (others => '0'));
  signal event_addr_c : eventaddr := (others => (others => '0'));
  signal event_addr_d : eventaddr := (others => (others => '0'));


begin  -- Behavioral

  mainclk <= not mainclk after 2.5 ns;
  reset   <= '0'         after 100 ns;

  process(mainclk)
  begin
    if rising_edge(mainclk) then
      if clkstate = 3 then
        clkstate <= 0;
      else
        clkstate <= clkstate + 1;
      end if;

      if clkstate = 0 or clkstate = 2 then
        CLK2x <= '0';
      else
        CLK2x <= '1';
      end if;

      if clkstate = 1 then
        CLK <= '0';
      elsif clkstate = 3 then
        CLK <= '1';
      end if;
    end if;
  end process;

  event_packet_generation : process
  begin

    while true loop

      wait until rising_edge(CLK) and lepos = 47;
      -- now we send the events
      for i in 0 to 78 loop
        -- output the event bytes
        for j in 0 to 5 loop
          dlEDTX <= dleventinputs(i)(j)(15 downto 8);
          wait until rising_edge(CLK);
          dlEDTX <= dleventinputs(i)(j)(7 downto 0);
          wait until rising_edge(CLK);
        end loop;  -- j
      end loop;  -- i
    end loop;

  end process;


  decodemux_inst : decodemux
    port map (
      CLK          => CLK,
      DIN          => rxdata,
      KIN          => rxk,
      LOCKED       => linkup,
      ECYCLE       => ecycle,
      EDATA        => edata,
      DGRANTA      => dgranta,
      EARXBYTEA    => EARXBYTEA,
      EARXBYTESELA => EARXBYTESELA,
      DGRANTB      => dgrantb,
      EARXBYTEB    => EARXBYTEB,
      EARXBYTESELB => EARXBYTESELB,
      DGRANTC      => dgrantc,
      EARXBYTEC    => EARXBYTEC,
      EARXBYTESELC => EARXBYTESELC,
      DGRANTD      => dgrantd,
      EARXBYTED    => EARXBYTED,
      EARXBYTESELD => EARXBYTESELD);

  dspcontproc_a : dspcontproc
    generic map (
      RAM_INIT_00 => test_INIT_00,
      RAM_INIT_01 => test_INIT_01,
      RAM_INIT_02 => test_INIT_02,
      RAM_INIT_03 => test_INIT_03,
      RAM_INIT_04 => test_INIT_04,
      RAM_INIT_05 => test_INIT_05,
      RAM_INIT_06 => test_INIT_06,
      RAM_INIT_07 => test_INIT_07,
      RAM_INIT_08 => test_INIT_08,
      RAM_INIT_09 => test_INIT_09,
      RAM_INIT_0A => test_INIT_0A,
      RAM_INIT_0B => test_INIT_0B,
      RAM_INIT_0C => test_INIT_0C,
      RAM_INIT_0D => test_INIT_0D,
      RAM_INIT_0E => test_INIT_0E,
      RAM_INIT_0F => test_INIT_0F,

      RAM_INIT_10 => test_INIT_10,
      RAM_INIT_11 => test_INIT_11,
      RAM_INIT_12 => test_INIT_12,
      RAM_INIT_13 => test_INIT_13,
      RAM_INIT_14 => test_INIT_14,
      RAM_INIT_15 => test_INIT_15,
      RAM_INIT_16 => test_INIT_16,
      RAM_INIT_17 => test_INIT_17,
      RAM_INIT_18 => test_INIT_18,
      RAM_INIT_19 => test_INIT_19,
      RAM_INIT_1A => test_INIT_1A,
      RAM_INIT_1B => test_INIT_1B,
      RAM_INIT_1C => test_INIT_1C,
      RAM_INIT_1D => test_INIT_1D,
      RAM_INIT_1E => test_INIT_1E,
      RAM_INIT_1F => test_INIT_1F,

      RAM_INIT_20 => test_INIT_20,
      RAM_INIT_21 => test_INIT_21,
      RAM_INIT_22 => test_INIT_22,
      RAM_INIT_23 => test_INIT_23,
      RAM_INIT_24 => test_INIT_24,
      RAM_INIT_25 => test_INIT_25,
      RAM_INIT_26 => test_INIT_26,
      RAM_INIT_27 => test_INIT_27,
      RAM_INIT_28 => test_INIT_28,
      RAM_INIT_29 => test_INIT_29,
      RAM_INIT_2A => test_INIT_2A,
      RAM_INIT_2B => test_INIT_2B,
      RAM_INIT_2C => test_INIT_2C,
      RAM_INIT_2D => test_INIT_2D,
      RAM_INIT_2E => test_INIT_2E,
      RAM_INIT_2F => test_INIT_2F,

      RAM_INIT_30 => test_INIT_30,
      RAM_INIT_31 => test_INIT_31,
      RAM_INIT_32 => test_INIT_32,
      RAM_INIT_33 => test_INIT_33,
      RAM_INIT_34 => test_INIT_34,
      RAM_INIT_35 => test_INIT_35,
      RAM_INIT_36 => test_INIT_36,
      RAM_INIT_37 => test_INIT_37,
      RAM_INIT_38 => test_INIT_38,
      RAM_INIT_39 => test_INIT_39,
      RAM_INIT_3A => test_INIT_3A,
      RAM_INIT_3B => test_INIT_3B,
      RAM_INIT_3C => test_INIT_3C,
      RAM_INIT_3D => test_INIT_3D,
      RAM_INIT_3E => test_INIT_3E,
      RAM_INIT_3F => test_INIT_3F,

      RAM_INITP_00 => test_INITP_00,
      RAM_INITP_01 => test_INITP_01,
      RAM_INITP_02 => test_INITP_02,
      RAM_INITP_03 => test_INITP_03,
      RAM_INITP_04 => test_INITP_04,
      RAM_INITP_05 => test_INITP_05,
      RAM_INITP_06 => test_INITP_06,
      RAM_INITP_07 => test_INITP_07)
    port map (
      CLK          => clk,
      RESET        => RESET,
      CLKHI        => clk2x,
      DEVICE       => devicea,
      ECYCLE       => ecycle,
      EARXBYTE     => EARXBYTEA,
      EARXBYTESEL  => EARXBYTESELA,
      EDRX         => edata,
      ESENDREQ     => eprocreq(0),
      ESENDGRANT   => eprocgrant(0),
      ESENDDONE    => eprocdone(0),
      ESENDDATA    => eprocdataa,
      -- dsp interface
      DSPRESET     => DSPRESETA,
      DSPSPIEN     => dspspiena,
      DSPSPISS     => dspspissa,
      DSPSPIMISO   => dspspimisoa,
      DSPSPIMOSI   => dspspimosia,
      DSPSPICLK    => dspspiclka,
      DSPSPIHOLD   => dspspiholda);

  dspcontproc_b : dspcontproc
    generic map (
      RAM_INIT_00 => test_INIT_00,
      RAM_INIT_01 => test_INIT_01,
      RAM_INIT_02 => test_INIT_02,
      RAM_INIT_03 => test_INIT_03,
      RAM_INIT_04 => test_INIT_04,
      RAM_INIT_05 => test_INIT_05,
      RAM_INIT_06 => test_INIT_06,
      RAM_INIT_07 => test_INIT_07,
      RAM_INIT_08 => test_INIT_08,
      RAM_INIT_09 => test_INIT_09,
      RAM_INIT_0A => test_INIT_0A,
      RAM_INIT_0B => test_INIT_0B,
      RAM_INIT_0C => test_INIT_0C,
      RAM_INIT_0D => test_INIT_0D,
      RAM_INIT_0E => test_INIT_0E,
      RAM_INIT_0F => test_INIT_0F,

      RAM_INIT_10 => test_INIT_10,
      RAM_INIT_11 => test_INIT_11,
      RAM_INIT_12 => test_INIT_12,
      RAM_INIT_13 => test_INIT_13,
      RAM_INIT_14 => test_INIT_14,
      RAM_INIT_15 => test_INIT_15,
      RAM_INIT_16 => test_INIT_16,
      RAM_INIT_17 => test_INIT_17,
      RAM_INIT_18 => test_INIT_18,
      RAM_INIT_19 => test_INIT_19,
      RAM_INIT_1A => test_INIT_1A,
      RAM_INIT_1B => test_INIT_1B,
      RAM_INIT_1C => test_INIT_1C,
      RAM_INIT_1D => test_INIT_1D,
      RAM_INIT_1E => test_INIT_1E,
      RAM_INIT_1F => test_INIT_1F,

      RAM_INIT_20 => test_INIT_20,
      RAM_INIT_21 => test_INIT_21,
      RAM_INIT_22 => test_INIT_22,
      RAM_INIT_23 => test_INIT_23,
      RAM_INIT_24 => test_INIT_24,
      RAM_INIT_25 => test_INIT_25,
      RAM_INIT_26 => test_INIT_26,
      RAM_INIT_27 => test_INIT_27,
      RAM_INIT_28 => test_INIT_28,
      RAM_INIT_29 => test_INIT_29,
      RAM_INIT_2A => test_INIT_2A,
      RAM_INIT_2B => test_INIT_2B,
      RAM_INIT_2C => test_INIT_2C,
      RAM_INIT_2D => test_INIT_2D,
      RAM_INIT_2E => test_INIT_2E,
      RAM_INIT_2F => test_INIT_2F,

      RAM_INIT_30 => test_INIT_30,
      RAM_INIT_31 => test_INIT_31,
      RAM_INIT_32 => test_INIT_32,
      RAM_INIT_33 => test_INIT_33,
      RAM_INIT_34 => test_INIT_34,
      RAM_INIT_35 => test_INIT_35,
      RAM_INIT_36 => test_INIT_36,
      RAM_INIT_37 => test_INIT_37,
      RAM_INIT_38 => test_INIT_38,
      RAM_INIT_39 => test_INIT_39,
      RAM_INIT_3A => test_INIT_3A,
      RAM_INIT_3B => test_INIT_3B,
      RAM_INIT_3C => test_INIT_3C,
      RAM_INIT_3D => test_INIT_3D,
      RAM_INIT_3E => test_INIT_3E,
      RAM_INIT_3F => test_INIT_3F,

      RAM_INITP_00 => test_INITP_00,
      RAM_INITP_01 => test_INITP_01,
      RAM_INITP_02 => test_INITP_02,
      RAM_INITP_03 => test_INITP_03,
      RAM_INITP_04 => test_INITP_04,
      RAM_INITP_05 => test_INITP_05,
      RAM_INITP_06 => test_INITP_06,
      RAM_INITP_07 => test_INITP_07)
    port map (
      CLK          => clk,
      RESET        => RESET,
      CLKHI        => clk2x,
      DEVICE       => deviceb,
      ECYCLE       => ecycle,
      EARXBYTE     => EARXBYTEB,
      EARXBYTESEL  => EARXBYTESELb,
      EDRX         => edata,
      ESENDREQ     => eprocreq(1),
      ESENDGRANT   => eprocgrant(1),
      ESENDDONE    => eprocdone(1),
      ESENDDATA    => eprocdatab,
      -- dsp interface
      DSPRESET     => DSPRESETB,
      DSPSPIEN     => dspspienb,
      DSPSPISS     => dspspissb,
      DSPSPIMISO   => dspspimisob,
      DSPSPIMOSI   => dspspimosib,
      DSPSPICLK    => dspspiclkb,
      DSPSPIHOLD   => dspspiholdb);

  dspcontproc_c : dspcontproc
    generic map (
      RAM_INIT_00 => test_INIT_00,
      RAM_INIT_01 => test_INIT_01,
      RAM_INIT_02 => test_INIT_02,
      RAM_INIT_03 => test_INIT_03,
      RAM_INIT_04 => test_INIT_04,
      RAM_INIT_05 => test_INIT_05,
      RAM_INIT_06 => test_INIT_06,
      RAM_INIT_07 => test_INIT_07,
      RAM_INIT_08 => test_INIT_08,
      RAM_INIT_09 => test_INIT_09,
      RAM_INIT_0A => test_INIT_0A,
      RAM_INIT_0B => test_INIT_0B,
      RAM_INIT_0C => test_INIT_0C,
      RAM_INIT_0D => test_INIT_0D,
      RAM_INIT_0E => test_INIT_0E,
      RAM_INIT_0F => test_INIT_0F,

      RAM_INIT_10 => test_INIT_10,
      RAM_INIT_11 => test_INIT_11,
      RAM_INIT_12 => test_INIT_12,
      RAM_INIT_13 => test_INIT_13,
      RAM_INIT_14 => test_INIT_14,
      RAM_INIT_15 => test_INIT_15,
      RAM_INIT_16 => test_INIT_16,
      RAM_INIT_17 => test_INIT_17,
      RAM_INIT_18 => test_INIT_18,
      RAM_INIT_19 => test_INIT_19,
      RAM_INIT_1A => test_INIT_1A,
      RAM_INIT_1B => test_INIT_1B,
      RAM_INIT_1C => test_INIT_1C,
      RAM_INIT_1D => test_INIT_1D,
      RAM_INIT_1E => test_INIT_1E,
      RAM_INIT_1F => test_INIT_1F,

      RAM_INIT_20 => test_INIT_20,
      RAM_INIT_21 => test_INIT_21,
      RAM_INIT_22 => test_INIT_22,
      RAM_INIT_23 => test_INIT_23,
      RAM_INIT_24 => test_INIT_24,
      RAM_INIT_25 => test_INIT_25,
      RAM_INIT_26 => test_INIT_26,
      RAM_INIT_27 => test_INIT_27,
      RAM_INIT_28 => test_INIT_28,
      RAM_INIT_29 => test_INIT_29,
      RAM_INIT_2A => test_INIT_2A,
      RAM_INIT_2B => test_INIT_2B,
      RAM_INIT_2C => test_INIT_2C,
      RAM_INIT_2D => test_INIT_2D,
      RAM_INIT_2E => test_INIT_2E,
      RAM_INIT_2F => test_INIT_2F,

      RAM_INIT_30 => test_INIT_30,
      RAM_INIT_31 => test_INIT_31,
      RAM_INIT_32 => test_INIT_32,
      RAM_INIT_33 => test_INIT_33,
      RAM_INIT_34 => test_INIT_34,
      RAM_INIT_35 => test_INIT_35,
      RAM_INIT_36 => test_INIT_36,
      RAM_INIT_37 => test_INIT_37,
      RAM_INIT_38 => test_INIT_38,
      RAM_INIT_39 => test_INIT_39,
      RAM_INIT_3A => test_INIT_3A,
      RAM_INIT_3B => test_INIT_3B,
      RAM_INIT_3C => test_INIT_3C,
      RAM_INIT_3D => test_INIT_3D,
      RAM_INIT_3E => test_INIT_3E,
      RAM_INIT_3F => test_INIT_3F,

      RAM_INITP_00 => test_INITP_00,
      RAM_INITP_01 => test_INITP_01,
      RAM_INITP_02 => test_INITP_02,
      RAM_INITP_03 => test_INITP_03,
      RAM_INITP_04 => test_INITP_04,
      RAM_INITP_05 => test_INITP_05,
      RAM_INITP_06 => test_INITP_06,
      RAM_INITP_07 => test_INITP_07)
    port map (
      CLK          => clk,
      RESET        => RESET,
      CLKHI        => clk2x,
      DEVICE       => devicec,
      ECYCLE       => ecycle,
      EARXBYTE     => EARXBYTEC,
      EARXBYTESEL  => EARXBYTESELC,
      EDRX         => edata,
      ESENDREQ     => eprocreq(2),
      ESENDGRANT   => eprocgrant(2),
      ESENDDONE    => eprocdone(2),
      ESENDDATA    => eprocdatac,
      -- dsp interface
      DSPRESET     => DSPRESETC,
      DSPSPIEN     => dspspienc,
      DSPSPISS     => dspspissc,
      DSPSPIMISO   => dspspimisoc,
      DSPSPIMOSI   => dspspimosic,
      DSPSPICLK    => dspspiclkc,
      DSPSPIHOLD   => dspspiholdc);

  dspcontproc_d : dspcontproc
    generic map (
      RAM_INIT_00 => test_INIT_00,
      RAM_INIT_01 => test_INIT_01,
      RAM_INIT_02 => test_INIT_02,
      RAM_INIT_03 => test_INIT_03,
      RAM_INIT_04 => test_INIT_04,
      RAM_INIT_05 => test_INIT_05,
      RAM_INIT_06 => test_INIT_06,
      RAM_INIT_07 => test_INIT_07,
      RAM_INIT_08 => test_INIT_08,
      RAM_INIT_09 => test_INIT_09,
      RAM_INIT_0A => test_INIT_0A,
      RAM_INIT_0B => test_INIT_0B,
      RAM_INIT_0C => test_INIT_0C,
      RAM_INIT_0D => test_INIT_0D,
      RAM_INIT_0E => test_INIT_0E,
      RAM_INIT_0F => test_INIT_0F,

      RAM_INIT_10 => test_INIT_10,
      RAM_INIT_11 => test_INIT_11,
      RAM_INIT_12 => test_INIT_12,
      RAM_INIT_13 => test_INIT_13,
      RAM_INIT_14 => test_INIT_14,
      RAM_INIT_15 => test_INIT_15,
      RAM_INIT_16 => test_INIT_16,
      RAM_INIT_17 => test_INIT_17,
      RAM_INIT_18 => test_INIT_18,
      RAM_INIT_19 => test_INIT_19,
      RAM_INIT_1A => test_INIT_1A,
      RAM_INIT_1B => test_INIT_1B,
      RAM_INIT_1C => test_INIT_1C,
      RAM_INIT_1D => test_INIT_1D,
      RAM_INIT_1E => test_INIT_1E,
      RAM_INIT_1F => test_INIT_1F,

      RAM_INIT_20 => test_INIT_20,
      RAM_INIT_21 => test_INIT_21,
      RAM_INIT_22 => test_INIT_22,
      RAM_INIT_23 => test_INIT_23,
      RAM_INIT_24 => test_INIT_24,
      RAM_INIT_25 => test_INIT_25,
      RAM_INIT_26 => test_INIT_26,
      RAM_INIT_27 => test_INIT_27,
      RAM_INIT_28 => test_INIT_28,
      RAM_INIT_29 => test_INIT_29,
      RAM_INIT_2A => test_INIT_2A,
      RAM_INIT_2B => test_INIT_2B,
      RAM_INIT_2C => test_INIT_2C,
      RAM_INIT_2D => test_INIT_2D,
      RAM_INIT_2E => test_INIT_2E,
      RAM_INIT_2F => test_INIT_2F,

      RAM_INIT_30 => test_INIT_30,
      RAM_INIT_31 => test_INIT_31,
      RAM_INIT_32 => test_INIT_32,
      RAM_INIT_33 => test_INIT_33,
      RAM_INIT_34 => test_INIT_34,
      RAM_INIT_35 => test_INIT_35,
      RAM_INIT_36 => test_INIT_36,
      RAM_INIT_37 => test_INIT_37,
      RAM_INIT_38 => test_INIT_38,
      RAM_INIT_39 => test_INIT_39,
      RAM_INIT_3A => test_INIT_3A,
      RAM_INIT_3B => test_INIT_3B,
      RAM_INIT_3C => test_INIT_3C,
      RAM_INIT_3D => test_INIT_3D,
      RAM_INIT_3E => test_INIT_3E,
      RAM_INIT_3F => test_INIT_3F,

      RAM_INITP_00 => test_INITP_00,
      RAM_INITP_01 => test_INITP_01,
      RAM_INITP_02 => test_INITP_02,
      RAM_INITP_03 => test_INITP_03,
      RAM_INITP_04 => test_INITP_04,
      RAM_INITP_05 => test_INITP_05,
      RAM_INITP_06 => test_INITP_06,
      RAM_INITP_07 => test_INITP_07)
    port map (
      CLK          => clk,
      RESET        => RESET,
      CLKHI        => clk2x,
      DEVICE       => deviced,
      ECYCLE       => ecycle,
      EARXBYTE     => EARXBYTED,
      EARXBYTESEL  => EARXBYTESELD,
      EDRX         => edata,
      ESENDREQ     => eprocreq(3),
      ESENDGRANT   => eprocgrant(3),
      ESENDDONE    => eprocdone(3),
      ESENDDATA    => eprocdatad,
      -- dsp interface
      DSPRESET     => DSPRESETD,
      DSPSPIEN     => dspspiend,
      DSPSPISS     => dspspissd,
      DSPSPIMISO   => dspspimisod,
      DSPSPIMOSI   => dspspimosid,
      DSPSPICLK    => dspspiclkd,
      DSPSPIHOLD   => dspspiholdd);

  encodemux_inst : encodemux
    port map (
      CLK        => CLK,
      ECYCLE     => ECYCLE,
      DOUT       => DOUT,
      KOUT       => KOUT,
      DREQ       => DREQ,
      DGRANT     => DGRANT,
      DDONE      => DDONE,
      DDATA      => DDATA,
      EDSPREQ    => EDSPREQ,
      EDSPGRANT  => edspgrant,
      EDSPDONE   => edspdone,
      EDSPDATAA  => edspdataa,
      EDSPDATAB  => edspdatab,
      EDSPDATAC  => edspdatac,
      EDSPDATAD  => edspdatad,
      EPROCREQ   => EPROCREQ,
      EPROCGRANT => eprocgrant,
      EPROCDONE  => eprocdone,
      EPROCDATAA => eprocdataa,
      EPROCDATAB => eprocdatab,
      EPROCDATAC => eprocdatac,
      EPROCDATAD => eprocdatad);

  -- tx test
  tx_devicelink_stream : process(CLK)
  begin
    if rising_edge(CLK) then
      epos    <= lepos;
      if lepos < 999 then
        lepos <= lepos +1;
      else
        lepos <= 0;
      end if;

      if lepos = 0 then
        rxdata <= X"BC";
        rxk    <= '1';
      elsif lepos = 1 then
        rxdata <= X"00";
        rxk    <= '0';
      elsif (lepos > 1) and (lepos < 12) then
        rxdata <= dlEATXa((lepos -2 )* 8 + 7 downto (lepos-2)*8);
        rxk    <= '0';

      elsif lepos = 12 then             -- DGRANT B 
        rxdata <= X"00";
        rxk    <= '0';
      elsif (lepos > 12) and (lepos < 23) then
        rxdata <= dlEATXa((lepos -13 )* 8 + 7 downto (lepos-13)*8);
        rxk    <= '0';

      elsif lepos = 23 then             -- DGRANT C 
        rxdata <= X"00";
        rxk    <= '0';
      elsif (lepos > 23) and (lepos < 34) then
        rxdata <= dlEATXa((lepos -24 )* 8 + 7 downto (lepos-24)*8);
        rxk    <= '0';
      elsif lepos > 47 then
        rxdata <= dlEDTX;
      end if;

    end if;
  end process tx_devicelink_stream;


  event_recovery      : process
    variable esrc     : integer := 0;
    variable ebytepos : integer := 0;

    variable event_data : eventarray := (others => (others => '0'));
    variable event_addr : eventaddr  := (others => (others => '0'));

  begin
    wait until rising_edge(CLK) and kout = '1';
    if dout = X"1C" then
      -- capture the next event
      esrc := 1;
    elsif dout = X"3C" then
      esrc := 2;
    elsif dout = X"5C" then
      esrc := 3;
    elsif dout = X"7C" then
      esrc := 4;
    end if;

    for i in 0 to 9 loop
      wait until rising_edge(CLK);
      event_addr(i) := dout;
    end loop;  -- i 

    for i in 0 to 5 loop
      wait until rising_edge(CLK);
      event_data(i)(15 downto 8) := dout;
      wait until rising_edge(CLK);
      event_data(i)(7 downto 0)  := dout;
    end loop;  -- i 
    wait until rising_edge(clk);
    if esrc = 1 then
      event_addr_a <= event_addr;
      event_data_a <= event_data;
    elsif esrc = 2 then
      event_addr_b <= event_addr;
      event_data_b <= event_data;
    elsif esrc = 3 then
      event_addr_c <= event_addr;
      event_data_c <= event_data;
    elsif esrc = 4 then
      event_addr_d <= event_addr;
      event_data_d <= event_data;
    end if;

  end process event_recovery;

  event_transmission : process
  begin
    wait until rising_edge(CLK) and epos = 0;

    wait until rising_edge(CLK) and epos = 0;
    wait until rising_edge(CLK) and epos = 0;
    -- try and get initial event TX
    assert event_data_a(0) = X"0800" report "errror with event_data_a" severity error;
    assert event_data_a(1) = X"1111" report "errror with event_data_a" severity error;
    assert event_data_a(2) = X"2222" report "errror with event_data_a" severity error;
    assert event_data_a(3) = X"3333" report "errror with event_data_a" severity error;
    assert event_data_a(4) = X"4444" report "errror with event_data_a" severity error;
    assert event_data_a(5) = X"5555" report "errror with event_data_a" severity error;


    wait until rising_edge(CLK) and epos = 0;
    wait until rising_edge(CLK) and epos = 0;
    wait until rising_edge(CLK) and epos = 0;
    wait until rising_edge(CLK) and epos = 0;
    -- send a simple event
    dleventinputs(0)(0) <= X"0123";
    dleventinputs(0)(1) <= X"4567";
    dleventinputs(0)(2) <= X"89AB";
    dleventinputs(0)(3) <= X"CDEF";
    dlEATXa(0)          <= '1';
    dlEATXb(0)          <= '1';
    dlEATXc(0)          <= '1';
    dlEATXd(0)          <= '1';
    wait until rising_edge(CLK) and epos = 0;
    dlEATXa             <= (others => '0');
    dlEATXb             <= (others => '0');
    dlEATXc             <= (others => '0');
    dlEATXd             <= (others => '0');
    wait until rising_edge(CLK) and epos = 0;
    -- now send the echo-request event
    -- 
    dleventinputs(0)(0) <= X"2007";
    dleventinputs(0)(1) <= X"1122";
    dleventinputs(0)(2) <= X"3344";
    dlEATXa(0)          <= '1';
    dlEATXb(0)          <= '0';
    dlEATXc(0)          <= '1';
    dlEATXd(0)          <= '0';
    wait until rising_edge(CLK) and epos = 0;
    dleventinputs(0)(0) <= (others => '0');
    dleventinputs(0)(1) <= (others => '0');
    dleventinputs(0)(2) <= (others => '0');

    dlEATXa <= (others => '0');
    dlEATXb <= (others => '0');
    dlEATXc <= (others => '0');
    dlEATXd <= (others => '0');

    report "End of Simulation" severity failure;

  end process event_transmission;
end Behavioral;
