library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity dspboard is
  port (
    -- DeviceLink Serial Interface
    REFCLKIN  : in  std_logic;
    REFCLKOUT : out std_logic;
    RXCLKIN   : in  std_logic;
    RXLOCKED  : in  std_logic;
    RXDIN     : in  std_logic_vector(9 downto 0);
    TXIO_P    : out std_logic;
    TXIO_N    : out std_logic;
    -- STATUS LEDS
    LEDPOWER  : out std_logic;
    LEDEVENTA : out std_logic;
    LEDEVENTB : out std_logic;
    LEDEVENTC : out std_logic;
    LEDEVENTD : out std_logic;

    DSPPPIDOUT    : out   std_logic_vector(7 downto 0);
    DSPPPICLK     : out   std_logic;
    -- DSP A
    DSPRESETA     : out   std_logic;
    DSPCLKA       : out   std_logic;
    DSPSPIMISOA   : inout std_logic;
    DSPSPIMOSIA   : inout std_logic;
    DSPSPICLKA    : inout std_logic;
    DSPFLAG0A     : out   std_logic;
    DSPFLAG1A     : in    std_logic;
    DSPFLAG2A     : out   std_logic;
    DSPFLAG4A     : out   std_logic;
    DSPSPORTSCLKA : out   std_logic;
    DSPSPORT0RFSA : out   std_logic;
    DSPSPORT0DRA  : out   std_logic;
    DSPSPORT0TFSA : in    std_logic;
    DSPSPORT0DTA  : in    std_logic;
    DSPSPORT1TFSA : in    std_logic;
    DSPSPORT1DTA  : in    std_logic;
    DSPPPIFS1A    : out   std_logic;
    -- DSP B
    DSPRESETB     : out   std_logic;
    DSPCLKB       : out   std_logic;
    DSPSPIMISOB   : inout std_logic;
    DSPSPIMOSIB   : inout std_logic;
    DSPSPICLKB    : inout std_logic;
    DSPFLAG0B     : out   std_logic;
    DSPFLAG1B     : in    std_logic;
    DSPFLAG2B     : out   std_logic;
    DSPFLAG4B     : out   std_logic;
    DSPSPORTSCLKB : out   std_logic;
    DSPSPORT0RFSB : out   std_logic;
    DSPSPORT0DRB  : out   std_logic;
    DSPSPORT0TFSB : in    std_logic;
    DSPSPORT0DTB  : in    std_logic;
    DSPSPORT1TFSB : in    std_logic;
    DSPSPORT1DTB  : in    std_logic;
    DSPPPIFS1B    : out   std_logic;

    -- DSP C
    DSPRESETC     : out   std_logic;
    DSPCLKC       : out   std_logic;
    DSPSPIMISOC   : inout std_logic;
    DSPSPIMOSIC   : inout std_logic;
    DSPSPICLKC    : inout std_logic;
    DSPFLAG0C     : out   std_logic;
    DSPFLAG1C     : in    std_logic;
    DSPFLAG2C     : out   std_logic;
    DSPFLAG4C     : out   std_logic;
    DSPSPORTSCLKC : out   std_logic;
    DSPSPORT0RFSC : out   std_logic;
    DSPSPORT0DRC  : out   std_logic;
    DSPSPORT0TFSC : in    std_logic;
    DSPSPORT0DTC  : in    std_logic;
    DSPSPORT1TFSC : in    std_logic;
    DSPSPORT1DTC  : in    std_logic;
    DSPPPIFS1C    : out   std_logic;

    -- DSP D
    DSPRESETD     : out   std_logic;
    DSPCLKD       : out   std_logic;
    DSPSPIMISOD   : inout std_logic;
    DSPSPIMOSID   : inout std_logic;
    DSPSPICLKD    : inout std_logic;
    DSPFLAG0D     : out   std_logic;
    DSPFLAG1D     : in    std_logic;
    DSPFLAG2D     : out   std_logic;
    DSPFLAG4D     : out   std_logic;
    DSPSPORTSCLKD : out   std_logic;
    DSPSPORT0RFSD : out   std_logic;
    DSPSPORT0DRD  : out   std_logic;
    DSPSPORT0TFSD : in    std_logic;
    DSPSPORT0DTD  : in    std_logic;
    DSPSPORT1TFSD : in    std_logic;
    DSPSPORT1DTD  : in    std_logic;
    DSPPPIFS1D    : out   std_logic;

    -- FIBER INTERFACE
    FIBEROUTAB : out std_logic;
    FIBERINAB  : in  std_logic;
    FIBEROUTCD : out std_logic;
    FIBERINCD  : in  std_logic );
end dspboard;

architecture Behavioral of dspboard is

  component devicelink
    port (
      TXCLKIN   : in  std_logic;
      TXLOCKED  : in  std_logic;
      TXDIN     : in  std_logic_vector(9 downto 0);
      TXDOUT    : out std_logic_vector(7 downto 0);
      TXKOUT    : out std_logic;
      CLK       : out std_logic;
      CLK2X     : out std_logic;
      RESET     : out std_logic;
      RXDIN     : in  std_logic_vector(7 downto 0);
      RXKIN     : in  std_logic;
      RXIO_P    : out std_logic;
      RXIO_N    : out std_logic;
      DECODEERR : out std_logic
      );

  end component;

  signal valid : std_logic := '0';

  signal txdata : std_logic_vector(7 downto 0) := (others => '0');
  signal txk    : std_logic                    := '0';

  signal rxdata, rxdatal : std_logic_vector(7 downto 0) := (others => '0');
  signal rxk, rxkl       : std_logic                    := '0';

  signal clk   : std_logic := '0';
  signal RESET : std_logic := '0';

  signal pcnt         : std_logic_vector(21 downto 0) := (others => '0');
  signal decodeerrint : std_logic                     := '0';

  component decodemux
    port (
      CLK    : in std_logic;
      DIN    : in std_logic_vector(7 downto 0);
      KIN    : in std_logic;
      LOCKED : in std_logic;

      ECYCLE : out std_logic;
      EDATA  : out std_logic_vector(7 downto 0);

      -- data interface
      DGRANTA : out std_logic;
      EARXA   : out std_logic_vector(79 downto 0);
      DGRANTB : out std_logic;
      EARXB   : out std_logic_vector(79 downto 0);
      DGRANTC : out std_logic;
      EARXC   : out std_logic_vector(79 downto 0);
      DGRANTD : out std_logic;
      EARXD   : out std_logic_vector(79 downto 0)
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
      EPROCDATAD : in  std_logic_vector(7 downto 0);
      DEBUG      : out std_logic_vector(15 downto 0));
  end component;


  signal ECYCLE : std_logic                    := '0';
  signal EDATA  : std_logic_vector(7 downto 0) := (others => '0');

  -- decodemux signals interface
  signal dgrantina : std_logic                     := '0';
  signal earxa     : std_logic_vector(79 downto 0) := (others => '0');
  signal dgrantinb : std_logic                     := '0';
  signal earxb     : std_logic_vector(79 downto 0) := (others => '0');
  signal dgrantinc : std_logic                     := '0';
  signal earxc     : std_logic_vector(79 downto 0) := (others => '0');
  signal dgrantind : std_logic                     := '0';
  signal earxd     : std_logic_vector(79 downto 0) := (others => '0');

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
      CLKHI        : in  std_logic;
      DEVICE       : in  std_logic_vector(7 downto 0);
      -- Event input
      ECYCLE       : in  std_logic;
      EARX         : in  std_logic_vector(79 downto 0);
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
      DSPSPIHOLD   : in  std_logic;
      LEDEVENT     : out std_logic
      );
  end component;

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
      DONE     : out std_logic;
      DEBUG    : out std_logic_vector(15 downto 0));
  end component;

  component dspiomux
    port (
      CLK         : in    std_logic;
      PSEL        : in    std_logic;
      -- dsp pins                      
      SPISCLK     : inout std_logic;
      SPIMOSI     : inout std_logic;
      SPIMISO     : inout std_logic;
      FLAG0       : out   std_logic;
      FLAG1       : in    std_logic;
      FLAG2       : out   std_logic;
      FLAG4       : out   std_logic;
      -- FPGA Master SPI interface
      SPISSM      : in    std_logic;
      SPISCLKM    : in    std_logic;
      SPIMOSIM    : in    std_logic;
      SPIMISOM    : out   std_logic;
      BOOTHOLDOFF : out   std_logic;
      -- FPGA Slave SPI interface
      SPISSS      : out   std_logic;
      SPISCLKS    : out   std_logic;
      SPIMOSIS    : out   std_logic;
      SPIMISOS    : in    std_logic;
      EVTFIFOFULL : in    std_logic;
      -- DATA SPORT IF interface
      DATAFULL    : in    std_logic
      );
  end component;

  component acqserial
    port (
      CLK         : in  std_logic;
      CLKHI       : in  std_logic;
      RESET       : in  std_logic;
      FIBERIN     : in  std_logic;
      FIBEROUT    : out std_logic;
      NEWCMDDEBUG : out std_logic;
      SERCLK      : in  std_logic;
      -- SPORT outputs
      DSPASERDT   : out std_logic;
      DSPASERFS   : out std_logic;
      DSPASERDR   : in  std_logic;
      DSPBSERDT   : out std_logic;
      DSPBSERFS   : out std_logic;
      DSPBSERDR   : in  std_logic;
      -- link status
      DSPALINKUP  : out std_logic;
      DSPBLINKUP  : out std_logic
      );
  end component;

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

  signal dreq   : std_logic := '0';
  signal dgrant : std_logic := '0';
  signal ddone  : std_logic := '0';

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

  signal devicea         : std_logic_vector(7 downto 0) := X"08";
  signal procdspspiena   : std_logic                    := '0';
  signal procdspspissa   : std_logic                    := '0';
  signal procdspspimisoa : std_logic                    := '0';
  signal procdspspimosia : std_logic                    := '0';
  signal procdspspiclka  : std_logic                    := '0';
  signal procdspspiclkal : std_logic                    := '0';

  signal dspissa       : std_logic := '0';
  signal dspimisoa     : std_logic := '0';
  signal dspimosia     : std_logic := '0';
  signal dspiclka      : std_logic := '0';
  signal dspspiholda   : std_logic := '0';
  signal devtfifofulla : std_logic := '0';

  signal dreqa : std_logic := '0';

  signal ddataa    : std_logic_vector(7 downto 0) := (others => '0');
  signal ddonea    : std_logic                    := '0';
  signal dgranta   : std_logic                    := '0';
  signal datafulla : std_logic                    := '0';

  signal deviceb         : std_logic_vector(7 downto 0) := X"09";
  signal procdspspienb   : std_logic                    := '0';
  signal procdspspissb   : std_logic                    := '0';
  signal procdspspimisob : std_logic                    := '0';
  signal procdspspimosib : std_logic                    := '0';
  signal procdspspiclkb  : std_logic                    := '0';
  signal dspissb         : std_logic                    := '0';
  signal dspimisob       : std_logic                    := '0';
  signal dspimosib       : std_logic                    := '0';
  signal dspiclkb        : std_logic                    := '0';
  signal dspspiholdb     : std_logic                    := '0';
  signal devtfifofullb   : std_logic                    := '0';
  signal dreqb           : std_logic                    := '0';
  signal ddatab          : std_logic_vector(7 downto 0) := (others => '0');
  signal ddoneb          : std_logic                    := '0';
  signal dgrantb         : std_logic                    := '0';

  signal datafullb : std_logic := '0';

  signal devicec         : std_logic_vector(7 downto 0) := X"0A";
  signal procdspspienc   : std_logic                    := '0';
  signal procdspspissc   : std_logic                    := '0';
  signal procdspspimisoc : std_logic                    := '0';
  signal procdspspimosic : std_logic                    := '0';
  signal procdspspiclkc  : std_logic                    := '0';
  signal dspissc         : std_logic                    := '0';
  signal dspimisoc       : std_logic                    := '0';
  signal dspimosic       : std_logic                    := '0';
  signal dspiclkc        : std_logic                    := '0';
  signal dspspiholdc     : std_logic                    := '0';
  signal devtfifofullc   : std_logic                    := '0';
  signal dreqc           : std_logic                    := '0';
  signal ddatac          : std_logic_vector(7 downto 0) := (others => '0');
  signal ddonec          : std_logic                    := '0';
  signal dgrantc         : std_logic                    := '0';
  signal datafullc       : std_logic                    := '0';

  signal deviced         : std_logic_vector(7 downto 0) := X"0B";
  signal procdspspiend   : std_logic                    := '0';
  signal procdspspissd   : std_logic                    := '0';
  signal procdspspimisod : std_logic                    := '0';
  signal procdspspimosid : std_logic                    := '0';
  signal procdspspiclkd  : std_logic                    := '0';
  signal dspissd         : std_logic                    := '0';
  signal dspimisod       : std_logic                    := '0';
  signal dspimosid       : std_logic                    := '0';
  signal dspiclkd        : std_logic                    := '0';
  signal dspspiholdd     : std_logic                    := '0';
  signal devtfifofulld   : std_logic                    := '0';
  signal dreqd           : std_logic                    := '0';
  signal ddatad          : std_logic_vector(7 downto 0) := (others => '0');
  signal ddoned          : std_logic                    := '0';
  signal dgrantd         : std_logic                    := '0';
  signal datafulld       : std_logic                    := '0';

  signal sportsclk : std_logic := '0';

  signal ddata : std_logic_vector(7 downto 0) := (others => '0');

  signal linkup : std_logic := '0';

  signal fiberlinkupa, fiberlinkupb, fiberlinkupc, fiberlinkupd : std_logic := '0';

  signal clk2, clk2int : std_logic := '0';

  signal clk2x, clk2xint : std_logic := '0';

  signal clkacqint, clkacq : std_logic := '0';

  signal pos : std_logic_vector(9 downto 0) := (others => '0');

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

  signal jtagout     : std_logic_vector(63 downto 0) := (others => '0');
  signal jtagwordout : std_logic_vector(47 downto 0) := (others => '0');

  signal jtageventrxcnt_req   : std_logic_vector(7 downto 0) := (others => '0');
  signal jtageventrxcnt_grant : std_logic_vector(7 downto 0) := (others => '0');

  signal procdspspiclkcnta : std_logic_vector(15 downto 0) := (others => '0');

  signal encodemuxdebug : std_logic_vector(15 downto 0) := (others => '0');
  signal wordset : std_logic_vector(31 downto 0) := (others => '0');
  signal wordpos : integer range 0 to 4 := 0;
  
begin  -- Behavioral


  devicelinkinst : devicelink
    port map (
      TXCLKIN   => RXCLKIN,
      TXLOCKED  => RXLOCKED,
      TXDIN     => RXDIN,
      TXDOUT    => rxdata,
      TXKOUT    => rxk,
      CLK       => clk,
      CLK2X     => open,
      RESET     => reset,
      RXDIN     => txdata,
      RXKIN     => txk,
      RXIO_P    => TXIO_P,
      RXIO_N    => TXIO_N,
      DECODEERR => decodeerrint);

  maindcm : dcm
    generic map (
      CLKFX_DIVIDE   => 5,              -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY => 8,              -- Can be any integer from 2 to 32
      CLKIN_PERIOD   => 15.0,
      CLK_FEEDBACK   => "1X")
    port map (
      CLKIN          => clk,
      CLKFB          => clk2,
      RST            => '0',
      CLK0           => clk2int,
      CLK2x          => clk2xint,
      CLKFX          => clkacqint);

  clk2_bufg : BUFG port map (
    O => clk2,
    I => clk2int);

  clk2x_bufg : BUFG
    port map (
      O => clk2x,
      I => clk2xint);

  clkacq_bufg : BUFG
    port map (
      O => clkacq,
      I => clkacqint);

  REFCLKOUT <= REFCLKIN;
  linkup    <= not RESET;

  DSPCLKA <= CLK;
  DSPCLKB <= CLK;
  DSPCLKC <= CLK;
  DSPCLKD <= CLK;

  DSPPPICLK <= clk;

  decodemux_inst : decodemux
    port map (
      CLK     => CLK,
      DIN     => rxdatal,
      KIN     => rxkl,
      LOCKED  => linkup,
      ECYCLE  => ecycle,
      EDATA   => edata,
      DGRANTA => dgrantina,
      EARXA   => earxa,
      DGRANTB => dgrantinb,
      EARXB   => earxb,
      DGRANTC => dgrantinc,
      EARXC   => earxc,
      DGRANTD => dgrantind,
      EARXD   => earxd);

  dspcontproc_a : dspcontproc
    port map (
      CLK        => clk,
      CLKHI      => clk2x,
      DEVICE     => devicea,
      ECYCLE     => ecycle,
      EARX       => earxa,
      EDRX       => edata,
      ESENDREQ   => eprocreq(0),
      ESENDGRANT => eprocgrant(0),
      ESENDDONE  => eprocdone(0),
      ESENDDATA  => eprocdataa,
      -- dsp interface
      DSPRESET   => DSPRESETA,
      DSPSPIEN   => procdspspiena,
      DSPSPISS   => procdspspissa,
      DSPSPIMISO => procdspspimisoa,
      DSPSPIMOSI => procdspspimosia,
      DSPSPICLK  => procdspspiclka,
      DSPSPIHOLD => dspspiholda,
      LEDEVENT   => LEDEVENTA);

  dspiomux_a : dspiomux
    port map (
      CLK         => CLK,
      PSEL        => procdspspiena,
      -- IO Pins
      SPISCLK     => DSPSPICLKA,
      SPIMOSI     => DSPSPIMOSIA,
      SPIMISO     => DSPSPIMISOA,
      FLAG0       => DSPFLAG0A,
      FLAG1       => DSPFLAG1A,
      FLAG2       => DSPFLAG2A,
      FLAG4       => DSPFLAG4A,
      -- FPGA EPROC master SPI interface
      SPISSM      => procdspspissa,
      SPISCLKM    => procdspspiclka,
      SPIMOSIM    => procdspspimosia,
      SPIMISOM    => procdspspimisoa,
      BOOTHOLDOFF => dspspiholda,
      -- DSP slave SPI interface
      SPISSS      => dspissa,
      SPISCLKS    => dspiclka,
      SPIMOSIS    => dspimosia,
      SPIMISOS    => dspimisoa,
      EVTFIFOFULL => devtfifofulla,
      -- DATA SPORT IF interface
      DATAFULL    => datafulla
      );

  eventrx_a : eventrx
    port map (
      CLK      => CLK,
      RESET    => '0',
      SCLK     => dspiclka,
      MOSI     => dspimosia,
      SCS      => dspissa,
      FIFOFULL => devtfifofulla,
      DOUT     => edspdataa,
      REQ      => edspreq(0),
      GRANT    => edspgrant(0),
      DONE     => edspdone(0));

  datasport_a : datasport
    port map (
      CLK    => CLK,
      RESET  => reset,
      SERCLK => sportsclk,
      SERDT  => DSPSPORT1DTA,
      SERTFS => DSPSPORT1TFSA,
      FULL   => datafulla,
      REQ    => dreqa,
      GRANT  => dgranta,
      DOUT   => ddataa,
      DONE   => ddonea);


  dspcontproc_b : dspcontproc
    port map (
      CLK        => clk,
      CLKHI      => clk2x,
      DEVICE     => deviceb,
      ECYCLE     => ecycle,
      EARX       => earxb,
      EDRX       => edata,
      ESENDREQ   => eprocreq(1),
      ESENDGRANT => eprocgrant(1),
      ESENDDONE  => eprocdone(1),
      ESENDDATA  => eprocdatab,
      -- dsp interface
      DSPRESET   => DSPRESETB,
      DSPSPIEN   => procdspspienb,
      DSPSPISS   => procdspspissb,
      DSPSPIMISO => procdspspimisob,
      DSPSPIMOSI => procdspspimosib,
      DSPSPICLK  => procdspspiclkb,
      DSPSPIHOLD => dspspiholdb,
      LEDEVENT   => LEDEVENTB);

  eventr_b : eventrx
    port map (
      CLK      => CLK,
      RESET    => '0',
      SCLK     => dspiclkb,
      MOSI     => dspimosib,
      SCS      => dspissb,
      FIFOFULL => devtfifofullb,
      DOUT     => edspdatab,
      REQ      => edspreq(1),
      GRANT    => edspgrant(1),
      DONE => edspdone(1));


  dspiomux_b : dspiomux
    port map (
      CLK         => CLK,
      PSEL        => procdspspienb,
      -- IO Pins
      SPISCLK     => DSPSPICLKB,
      SPIMOSI     => DSPSPIMOSIB,
      SPIMISO     => DSPSPIMISOB,
      FLAG0       => DSPFLAG0B,
      FLAG1       => DSPFLAG1B,
      FLAG2       => DSPFLAG2B,
      FLAG4       => DSPFLAG4B,
      -- FPGA EPROC master SPI interface
      SPISSM      => procdspspissb,
      SPISCLKM    => procdspspiclkb,
      SPIMOSIM    => procdspspimosib,
      SPIMISOM    => procdspspimisob,
      BOOTHOLDOFF => dspspiholdb,
      -- DSP slave SPI interface
      SPISSS      => dspissb,
      SPISCLKS    => dspiclkb,
      SPIMOSIS    => dspimosib,
      SPIMISOS    => dspimisob,
      EVTFIFOFULL => devtfifofullb,
      -- DATA SPORT IF interface
      DATAFULL    => datafullb
      );

  datasport_b : datasport
    port map (
      CLK    => CLK,
      RESET  => reset,
      SERCLK => sportsclk,
      SERDT  => DSPSPORT1DTB,
      SERTFS => DSPSPORT1TFSB,
      FULL   => datafullb,
      REQ    => dreqb,
      GRANT  => dgrantb,
      DOUT   => ddatab,
      DONE   => ddoneb);


  dspcontproc_c : dspcontproc
    port map (
      CLK        => clk,
      CLKHI      => clk2x,
      DEVICE     => devicec,
      ECYCLE     => ecycle,
      EARX       => earxc,
      EDRX       => edata,
      ESENDREQ   => eprocreq(2),
      ESENDGRANT => eprocgrant(2),
      ESENDDONE  => eprocdone(2),
      ESENDDATA  => eprocdatac,
      -- dsp interface
      DSPRESET   => DSPRESETC,
      DSPSPIEN   => procdspspienc,
      DSPSPISS   => procdspspissc,
      DSPSPIMISO => procdspspimisoc,
      DSPSPIMOSI => procdspspimosic,
      DSPSPICLK  => procdspspiclkc,
      DSPSPIHOLD => DSPSPIHOLDC,
      LEDEVENT   => LEDEVENTC);

  dspiomux_c : dspiomux
    port map (
      CLK         => CLK,
      PSEL        => procdspspienc,
      -- IO Pins
      SPISCLK     => DSPSPICLKC,
      SPIMOSI     => DSPSPIMOSIC,
      SPIMISO     => DSPSPIMISOC,
      FLAG0       => DSPFLAG0C,
      FLAG1       => DSPFLAG1C,
      FLAG2       => DSPFLAG2C,
      FLAG4       => DSPFLAG4C,
      -- FPGA EPROC master SPI interface
      SPISSM      => procdspspissc,
      SPISCLKM    => procdspspiclkc,
      SPIMOSIM    => procdspspimosic,
      SPIMISOM    => procdspspimisoc,
      BOOTHOLDOFF => dspspiholdc,
      -- DSP slave SPI interface
      SPISSS      => dspissc,
      SPISCLKS    => dspiclkc,
      SPIMOSIS    => dspimosic,
      SPIMISOS    => dspimisoc,
      EVTFIFOFULL => devtfifofullc,
      -- DATA SPORT IF interface
      DATAFULL    => datafullc
      );

  eventrx_c : eventrx
    port map (
      CLK      => CLK,
      RESET    => '0',
      SCLK     => dspiclkc,
      MOSI     => dspimosic,
      SCS      => dspissc,
      FIFOFULL => devtfifofullc,
      DOUT     => edspdatac,
      REQ      => edspreq(2),
      GRANT    => edspgrant(2),
      DONE => edspdone(2));


  datasport_c : datasport
    port map (
      CLK    => CLK,
      RESET  => reset,
      SERCLK => sportsclk,
      SERDT  => DSPSPORT1DTC,
      SERTFS => DSPSPORT1TFSC,
      FULL   => datafullc,
      REQ    => dreqc,
      GRANT  => dgrantc,
      DOUT   => ddatac,
      DONE   => ddonec);




  dspcontproc_d : dspcontproc
    port map (
      CLK        => clk,
      CLKHI      => clk2x,
      DEVICE     => deviced,
      ECYCLE     => ecycle,
      EARX       => earxd,
      EDRX       => edata,
      ESENDREQ   => eprocreq(3),
      ESENDGRANT => eprocgrant(3),
      ESENDDONE  => eprocdone(3),
      ESENDDATA  => eprocdatad,
      -- dsp interface
      DSPRESET   => DSPRESETD,
      DSPSPIEN   => procdspspiend,
      DSPSPISS   => procdspspissd,
      DSPSPIMISO => procdspspimisod,
      DSPSPIMOSI => procdspspimosid,
      DSPSPICLK  => procdspspiclkd,
      DSPSPIHOLD => DSPSPIHOLDD,
      LEDEVENT   => LEDEVENTD);


  dspiomux_d : dspiomux
    port map (
      CLK         => CLK,
      PSEL        => procdspspiend,
      -- IO Pins
      SPISCLK     => DSPSPICLKD,
      SPIMOSI     => DSPSPIMOSID,
      SPIMISO     => DSPSPIMISOD,
      FLAG0       => DSPFLAG0D,
      FLAG1       => DSPFLAG1D,
      FLAG2       => DSPFLAG2D,
      FLAG4       => DSPFLAG4D,
      -- FPGA EPROC master SPI interface
      SPISSM      => procdspspissd,
      SPISCLKM    => procdspspiclkd,
      SPIMOSIM    => procdspspimosid,
      SPIMISOM    => procdspspimisod,
      BOOTHOLDOFF => dspspiholdd,
      -- DSP slave SPI interface
      SPISSS      => dspissd,
      SPISCLKS    => dspiclkd,
      SPIMOSIS    => dspimosid,
      SPIMISOS    => dspimisod,
      EVTFIFOFULL => devtfifofulld,
      -- DATA SPORT IF interface
      DATAFULL    => datafulld
      );

  eventrx_d : eventrx
    port map (
      CLK      => CLK,
      RESET    => '0',
      SCLK     => dspiclkd,
      MOSI     => dspimosid,
      SCS      => dspissd,
      FIFOFULL => devtfifofulld,
      DOUT     => edspdatad,
      REQ      => edspreq(3),
      GRANT    => edspgrant(3),
      DONE => edspdone(3) );

  datasport_d : datasport
    port map (
      CLK    => CLK,
      RESET  => reset,
      SERCLK => sportsclk,
      SERDT  => DSPSPORT1DTD,
      SERTFS => DSPSPORT1TFSD,
      FULL   => datafulld,
      REQ    => dreqd,
      GRANT  => dgrantd,
      DOUT   => ddatad,
      DONE   => ddoned);


  encodemux_inst : encodemux
    port map (
      CLK        => CLK,
      ECYCLE     => ECYCLE,
      DOUT       => txdata,
      KOUT       => txk,
      DREQ       => DREQ,
      DGRANT     => DGRANT,
      DDONE      => DDONE,
      DDATA      => ddata,
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
      EPROCDATAD => eprocdatad,
      DEBUG      => encodemuxdebug);

  acqserial_ab : acqserial
    port map (
      CLK         => clk,
      CLKHI       => clkacq,
      RESET       => '0',
      FIBERIN     => FIBERINAB,
      FIBEROUT    => FIBEROUTAB,
      NEWCMDDEBUG => open,
      SERCLK      => SPORTSCLK,
      DSPASERDT   => DSPSPORT0DRA,
      DSPASERFS   => DSPSPORT0RFSA,
      DSPASERDR   => DSPSPORT0DTA,
      DSPBSERDT   => DSPSPORT0DRB,
      DSPBSERFS   => DSPSPORT0RFSB,
      DSPBSERDR   => DSPSPORT0DTB,
      DSPALINKUP  => fiberlinkupa,
      DSPBLINKUP  => fiberlinkupb);

  acqserial_cd : acqserial
    port map (
      CLK         => clk,
      CLKHI       => clkacq,
      RESET       => '0',
      FIBERIN     => FIBERINCD,
      FIBEROUT    => FIBEROUTCD,
      NEWCMDDEBUG => open,
      SERCLK      => SPORTSCLK,
      DSPASERDT   => DSPSPORT0DRC,
      DSPASERFS   => DSPSPORT0RFSC,
      DSPASERDR   => DSPSPORT0DTC,
      DSPBSERDT   => DSPSPORT0DRD,
      DSPBSERFS   => DSPSPORT0RFSD,
      DSPBSERDR   => DSPSPORT0DTD,
      DSPALINKUP  => fiberlinkupc,
      DSPBLINKUP  => fiberlinkupd);


  process(jtagDRCK1, clk)
  begin
    if jtagupdate = '1' then
      jtagout    <= X"1234" & jtagwordout;
    else
      if rising_edge(jtagDRCK1) then
        jtagout  <= '0' & jtagout(63 downto 1);
        jtagtdo1 <= jtagout(0);
      end if;

    end if;
  end process;

  BSCAN_SPARTAN3_inst : BSCAN_SPARTAN3
    port map (
      CAPTURE => jtagcapture,
      DRCK1   => jtagdrck1,
      DRCK2   => jtagDRCK2,
      SEL1    => jtagSEL1,
      SEL2    => jtagSEL2,
      SHIFT   => jtagSHIFT,
      TDI     => jtagTDI,
      UPDATE  => jtagUPDATE,
      TDO1    => jtagtdo1,
      TDO2    => jtagtdo2
      );


  ddata <= ddataa when dgrantina = '1' else
           ddatab when dgrantinb = '1' else
           ddatac when dgrantinc = '1' else
           ddatad;

  jtagwordout(31 downto 0) <= wordset; 
  jtagwordout(47 downto 32) <= jtageventrxcnt_req &  jtageventrxcnt_grant; 

  process(CLK)
    variable scnt : integer range 0 to 2 := 0;
  begin

    if rising_edge(clk) then
      rxdatal <= rxdata;
      rxkl    <= rxk;

      LEDPOWER <= decodeerrint;
      if ecycle = '1' then
        pos    <= "0000000001";
      else
        pos    <= pos + 1;
      end if;

      if edspreq(0) = '1' then
        jtageventrxcnt_req <= jtageventrxcnt_req + 1;
      end if;

      if edspgrant(0) = '1' then
        jtageventrxcnt_grant <= jtageventrxcnt_grant + 1;
      end if;

      if edspgrant(0) = '1' then
        wordpos <= 0;
      else
        if wordpos < 4 then
          wordpos <= wordpos + 1; 
        end if;
      end if;

      if wordpos = 0 then
        wordset(7 downto 0) <= edspdataa; 
      end if;
      
      if wordpos = 1 then
        wordset(15 downto 8) <= edspdataa; 
      end if;
      
      if wordpos = 2 then
        wordset(23 downto 16) <= edspdataa; 
      end if;
      
      if wordpos = 3 then
        wordset(31 downto 24) <= edspdataa; 
      end if;
      
      procdspspiclkal     <= procdspspiclka;
      if procdspspiclka = '1' and procdspspiclkal = '0' then
        procdspspiclkcnta <= procdspspiclkcnta + 1;
      end if;

      if scnt = 2 then
        scnt := 0;
      else
        scnt := scnt + 1;
      end if;

      if scnt = 1 then
        sportsclk <= '1';
      else
        sportsclk <= '0';
      end if;

      DSPSPORTSCLKA <= sportsclk;
      DSPSPORTSCLKB <= sportsclk;
      DSPSPORTSCLKC <= sportsclk;
      DSPSPORTSCLKD <= sportsclk;

      DSPPPIDOUT <= edata;
      DSPPPIFS1A <= ecycle and linkup;
      DSPPPIFS1B <= ecycle and linkup;
      DSPPPIFS1C <= ecycle and linkup;
      DSPPPIFS1D <= ecycle and linkup;

    end if;
  end process;


end Behavioral;
