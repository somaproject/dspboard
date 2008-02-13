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
    -- DSP A
    DSPRESETA : out std_logic;
    -- DSP B
    DSPRESETB : out std_logic;
    -- DSP C
    DSPRESETC : out std_logic;
    -- DSP D
    DSPRESETD : out std_logic; 
    -- FIBER INTERFACE
    FIBEROUTA : out std_logic;
    FIBEROUTB : out std_logic
    );
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
      EPROCDATAD : in  std_logic_vector(7 downto 0));
  end component;


  signal ECYCLE : std_logic                    := '0';
  signal EDATA  : std_logic_vector(7 downto 0) := (others => '0');

  -- decodemux signals interface
  signal DGRANTA : std_logic                     := '0';
  signal EARXA   : std_logic_vector(79 downto 0) := (others => '0');
  signal DGRANTB : std_logic                     := '0';
  signal EARXB   : std_logic_vector(79 downto 0) := (others => '0');
  signal DGRANTC : std_logic                     := '0';
  signal EARXC   : std_logic_vector(79 downto 0) := (others => '0');
  signal DGRANTD : std_logic                     := '0';
  signal EARXD   : std_logic_vector(79 downto 0) := (others => '0');

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
      LEDEVENT : out std_logic
      );
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

  signal devicea     : std_logic_vector(7 downto 0) := (others => '0');
  signal dspspiena   : std_logic                    := '0';
  signal dspspissa   : std_logic                    := '0';
  signal dspspimisoa : std_logic                    := '0';
  signal dspspimosia : std_logic                    := '0';
  signal dspspiclka  : std_logic                    := '0';

  signal deviceb     : std_logic_vector(7 downto 0) := (others => '0');
  signal dspspienb   : std_logic                    := '0';
  signal dspspissb   : std_logic                    := '0';
  signal dspspimisob : std_logic                    := '0';
  signal dspspimosib : std_logic                    := '0';
  signal dspspiclkb  : std_logic                    := '0';

  signal devicec     : std_logic_vector(7 downto 0) := (others => '0');
  signal dspspienc   : std_logic                    := '0';
  signal dspspissc   : std_logic                    := '0';
  signal dspspimisoc : std_logic                    := '0';
  signal dspspimosic : std_logic                    := '0';
  signal dspspiclkc  : std_logic                    := '0';

  signal deviced     : std_logic_vector(7 downto 0) := (others => '0');
  signal dspspiend   : std_logic                    := '0';
  signal dspspissd   : std_logic                    := '0';
  signal dspspimisod : std_logic                    := '0';
  signal dspspimosid : std_logic                    := '0';
  signal dspspiclkd  : std_logic                    := '0';


  signal ddata : std_logic_vector(7 downto 0) := (others => '0');

  signal linkup : std_logic := '0';

  signal clk2, clk2int : std_logic := '0';

  signal clk2x, clk2xint : std_logic := '0';

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
      RESET     => RESET,
      RXDIN     => txdata,
      RXKIN     => txk,
      RXIO_P    => TXIO_P,
      RXIO_N    => TXIO_N,
      DECODEERR => decodeerrint);

  maindcm : dcm
    port map (
      CLKIN => clk,
      CLKFB => clk2,
      RST   => '0',
      CLK0  => clk2int,
      CLK2x => clk2xint);

  clk2_bufg : BUFG port map (
    O => clk2,
    I => clk2int);

  clk2x_bufg : BUFG port map (
    O => clk2x,
    I => clk2xint);


  REFCLKOUT <= REFCLKIN;

  decodemux_inst : decodemux
    port map (
      CLK     => CLK,
      DIN     => rxdatal,
      KIN     => rxkl,
      LOCKED  => linkup,
      ECYCLE  => ecycle,
      EDATA   => edata,
      DGRANTA => dgranta,
      EARXA   => earxa,
      DGRANTB => dgrantb,
      EARXB   => earxb,
      DGRANTC => dgrantc,
      EARXC   => earxc,
      DGRANTD => dgrantd,
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
      DSPSPIEN   => dspspiena,
      DSPSPISS   => dspspissa,
      DSPSPIMISO => dspspimisoa,
      DSPSPIMOSI => dspspimosia,
      DSPSPICLK  => dspspiclka,
      LEDEVENT => LEDEVENTA);

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
      DSPSPIEN   => dspspienb,
      DSPSPISS   => dspspissb,
      DSPSPIMISO => dspspimisob,
      DSPSPIMOSI => dspspimosib,
      DSPSPICLK  => dspspiclkb,
      LEDEVENT => LEDEVENTB);

  process(CLK)
  begin
    if rising_edge(clk) then
      rxdatal <= rxdata;
      rxkl    <= rxk;

      LEDPOWER <= decodeerrint; 
      FIBEROUTA <= ecycle;
      FIBEROUTB <= rxk; 
    end if;
  end process;
  
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
      DSPSPIEN   => dspspienc,
      DSPSPISS   => dspspissc,
      DSPSPIMISO => dspspimisoc,
      DSPSPIMOSI => dspspimosic,
      DSPSPICLK  => dspspiclkc,
      LEDEVENT => LEDEVENTC);

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
      DSPSPIEN   => dspspiend,
      DSPSPISS   => dspspissd,
      DSPSPIMISO => dspspimisod,
      DSPSPIMOSI => dspspimosid,
      DSPSPICLK  => dspspiclkd,
      LEDEVENT => LEDEVENTD);

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
      EPROCDATAD => eprocdatad);


end Behavioral;
