library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity acqserial is
  port (
    CLK        : in  std_logic;
    CLKHI      : in  std_logic;
    RESET      : in  std_logic;
    FIBERIN    : in  std_logic;
    FIBEROUT   : out std_logic;
    NEWCMDDEBUG : out std_logic; 
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
  signal cmdina  : std_logic_vector(255 downto 0) := (others => '0');
  signal cmdinb  : std_logic_vector(255 downto 0) := (others => '0');

  signal serclk : std_logic := '0';
  signal serdt  : std_logic := '0';
  signal serfs  : std_logic := '0';
  signal serdra : std_logic := '0';
  signal serdrb : std_logic := '0';


  -- outputs
  signal cmdout  : std_logic_vector(47 downto 0) := (others => '0');
  signal sendcmd : std_logic                     := '0';



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
           SAMPLEA1   : out std_logic_vector(15 downto 0);
           SAMPLEA2   : out std_logic_vector(15 downto 0);
           SAMPLEA3   : out std_logic_vector(15 downto 0);
           SAMPLEA4   : out std_logic_vector(15 downto 0);
           SAMPLEAC   : out std_logic_vector(15 downto 0);
           SAMPLEB1   : out std_logic_vector(15 downto 0);
           SAMPLEB2   : out std_logic_vector(15 downto 0);
           SAMPLEB3   : out std_logic_vector(15 downto 0);
           SAMPLEB4   : out std_logic_vector(15 downto 0);
           SAMPLEBC   : out std_logic_vector(15 downto 0);
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
      CLK      : in  std_logic;
      SERCLK   : out std_logic;
      SERDT    : out std_logic;
      SERFS    : out std_logic;
      SERDRA   : in  std_logic;
      SERDRB   : in  std_logic;
      START    : in  std_logic;
      DONE     : out std_logic;
      DATAIN   : in  std_logic_vector(255 downto 0);
      DATAOUTA : out std_logic_vector(255 downto 0);
      DATAOUTB : out std_logic_vector(255 downto 0)
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
      CMDID      => frameout(11 downto 8),
      CMDST      => frameout(3 downto 0),
      SAMPLEA1   => frameout(31 downto 16),
      SAMPLEA2   => frameout(47 downto 32),
      SAMPLEA3   => frameout(63 downto 48),
      SAMPLEA4   => frameout(79 downto 64),
      SAMPLEAC   => frameout(95 downto 80),
      SAMPLEB1   => frameout(111 downto 96),
      SAMPLEB2   => frameout(127 downto 112),
      SAMPLEB3   => frameout(143 downto 128),
      SAMPLEB4   => frameout(159 downto 144),
      SAMPLEBC   => frameout(175 downto 160) );


  sportacqser_inst : sportacqser
    port map (
      CLK                   => clk,
      SERCLK                => serclk,
      SERDT                 => serdt,
      SERFS                 => serfs,
      SERDRA                => serdra,
      SERDRB                => serdrb,
      START                 => newsamples,
      DONE                  => newcmds,
      DATAIN                => frameout,
      DATAOUTA => cmdina,
      DATAOUTB => cmdinb);

  acqcmdmux_inst : acqcmdmux
    port map (
      CLK     => clk,
      cmdid   => frameout(11 downto 8),
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
  rxerr <= code_err or disp_err;

  DSPASERCLK <= serclk;
  DSPASERDT  <= serdt;
  DSPASERFS  <= serfs;
  serdra <= DSPASERDR; 

  DSPBSERCLK <= serclk;
  DSPBSERDT  <= serdt;
  DSPBSERFS  <= serfs;
  serdrb <= DSPBSERDR; 

  DSPALINKUP <= linkup;
  DSPBLINKUP <= linkup; 

end Behavioral;
