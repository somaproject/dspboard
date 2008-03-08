library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity acqserial is
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
end acqserial;

architecture Behavioral of acqserial is

  -- rx input signals
  signal fiberdata          : std_logic_vector(7 downto 0) := (others => '0');
  signal inwe               : std_logic                    := '0';
  signal kin                : std_logic                    := '0';
  signal code_err, disp_err : std_logic                    := '0';
  signal rxerr              : std_logic                    := '0';

  -- frame disassembled
  signal frameout   : std_logic_vector(255 downto 0) := (others => '0');
  signal newsamples : std_logic                      := '0';

  signal linkup : std_logic := '0';


  -- recovered inputs
  signal newcmds : std_logic                     := '0';
  signal cmdina  : std_logic_vector(63 downto 0) := (others => '0');
  signal cmdinb  : std_logic_vector(63 downto 0) := (others => '0');

  signal serdt  : std_logic := '0';
  signal serfs  : std_logic := '0';
  signal serdra : std_logic := '0';
  signal serdrb : std_logic := '0';


  -- outputs
  signal cmdout  : std_logic_vector(47 downto 0) := (others => '0');
  signal sendcmd : std_logic                     := '0';


  -- data
  signal sample    : std_logic_vector(15 downto 0) := (others => '0');
  signal samplesel : std_logic_vector(3 downto 0)  := (others => '0');

  signal cmdsts, cmdid : std_logic_vector(3 downto 0) := (others => '0');

  -- input componnets
  component fiberrx
    port ( CLK      : in  std_logic;
           DIN      : in  std_logic;
           DATAOUT  : out std_logic_vector(7 downto 0);
           KOUT     : out std_logic;
           CODE_ERR : out std_logic;
           DISP_ERR : out std_logic;
           DATALOCK : out std_logic;
           RESET    : in  std_logic);
  end component;


  component framedis
    port ( CLK        : in  std_logic;
           RESET      : in  std_logic;
           DIN        : in  std_logic_vector(7 downto 0);
           INWE       : in  std_logic;
           KIN        : in  std_logic;
           ERRIN      : in  std_logic;
           LINKUP     : out std_logic;
           NEWSAMPLES : out std_logic;
           SAMPLE     : out std_logic_vector(15 downto 0);
           SAMPLESEL  : in  std_logic_vector(3 downto 0);
           CMDID      : out std_logic_vector(3 downto 0);
           CMDST      : out std_logic_vector(3 downto 0));
  end component;

  component acqcmdmux
    port (
      CLK     : in  std_logic;
      CMDID   : in  std_logic_vector(3 downto 0);
      CMDINA  : in  std_logic_vector(47 downto 0);
      CMDINB  : in  std_logic_vector(47 downto 0);
      NEWCMDS : in  std_logic;
      LINKUP  : in  std_logic;
      CMDOUT  : out std_logic_vector(47 downto 0);
      SENDCMD : out std_logic
      );
  end component;

  component sportacqser
    port (
      CLK       : in  std_logic;
      SERCLK    : in  std_logic;
      SERDT     : out std_logic;
      SERFS     : out std_logic;
      SERDRA    : in  std_logic;
      SERDRB    : in  std_logic;
      START     : in  std_logic;
      DONE      : out std_logic;
      SAMPLEIN  : in  std_logic_vector(15 downto 0);
      SAMPLESEL : out std_logic_vector(3 downto 0);
      CMDSTS    : in  std_logic_vector(3 downto 0);
      CMDID     : in  std_logic_vector(3 downto 0);

      DATAOUTA : out std_logic_vector(63 downto 0);
      DATAOUTB : out std_logic_vector(63 downto 0)
      );
  end component;

-- output
  component fibertx
    port ( CLK      : in  std_logic;
           CMDIN    : in  std_logic_vector(47 downto 0);
           SENDCMD  : in  std_logic;
           FIBEROUT : out std_logic);
  end component;


begin  -- Behavioral

  fiberrx_inst : fiberrx
    port map (
      CLK      => clk,
      DIN      => FIBERIN,
      DATAOUT  => fiberdata,
      KOUT     => kin,
      CODE_ERR => code_err,
      DISP_ERR => disp_err,
      DATALOCK => inwe,
      RESET    => '0');

  framedis_inst : framedis
    port map (
      CLK        => clk,
      RESET      => reset,
      DIN        => fiberdata,
      INWE       => inwe,
      KIN        => kin,
      ERRIN      => rxerr,
      LINKUP     => linkup,
      NEWSAMPLES => newsamples,
      CMDID      => cmdid,
      CMDST      => cmdsts,
      SAMPLESEL  => samplesel,
      SAMPLE     => sample);


  sportacqser_inst : sportacqser
    port map (
      CLK       => clk,
      SERCLK    => SERCLK,
      SERDT     => serdt,
      SERFS     => serfs,
      SERDRA    => serdra,
      SERDRB    => serdrb,
      START     => newsamples,
      DONE      => newcmds,
      SAMPLEIN  => sample,
      SAMPLESEL => samplesel,
      CMDSTS    => cmdsts,
      CMDID     => cmdid,
      DATAOUTA  => cmdina,
      DATAOUTB  => cmdinb);

  acqcmdmux_inst : acqcmdmux
    port map (
      CLK     => clk,
      cmdid   => cmdid,
      cmdina  => cmdina(63 downto 16),
      CMDINB  => cmdinb(63 downto 16),
      NEWCMDS => newcmds,
      LINKUP  => linkup,
      CMDOUT  => cmdout,
      SENDCMD => sendcmd);



  fibertx_inst : fibertx
    port map (
      CLK      => clkhi,
      CMDIN    => cmdout,
      SENDCMD  => sendcmd,
      FIBEROUT => FIBEROUT);

  NEWCMDDEBUG <= sendcmd;
  rxerr       <= code_err or disp_err;

  DSPASERDT <= serdt;
  DSPASERFS <= serfs;
  serdra    <= DSPASERDR;

  DSPBSERDT <= serdt;
  DSPBSERFS <= serfs;
  serdrb    <= DSPBSERDR;

  DSPALINKUP <= linkup;
  DSPBLINKUP <= linkup;

end Behavioral;
