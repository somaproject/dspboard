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
    DSPASERTFS  : out std_logic;
    DSPBSERDT   : out std_logic;
    DSPBSERTFS  : out std_logic;
    -- uart interfaces
    DSPAUARTRX  : in  std_logic;
    DSPBUARTRX  : in  std_logic;
    -- link status
    DSPALINKUP  : out std_logic;
    DSPBLINKUP  : out std_logic;
    DEBUG       : out std_logic_vector(31 downto 0)
    );
end acqserial;

architecture Behavioral of acqserial is

  -- rx input signals
  signal fiberdata          : std_logic_vector(7 downto 0) := (others => '0');
  signal inwe               : std_logic                    := '0';
  signal kin                : std_logic                    := '0';

  -- frame disassembled
  signal frameout   : std_logic_vector(255 downto 0) := (others => '0');
  signal newsamples : std_logic                      := '0';

  signal rxlinkup : std_logic := '0';
  signal linkup   : std_logic := '0';


  -- recovered inputs
  signal newcmda, newcmdb : std_logic                     := '0';
  signal cmdina           : std_logic_vector(47 downto 0) := (others => '0');
  signal cmdinb           : std_logic_vector(47 downto 0) := (others => '0');

  signal serdt  : std_logic := '0';
  signal sertfs : std_logic := '0';
  signal serdra : std_logic := '0';
  signal serdrb : std_logic := '0';

  signal serrfsa, serrfsb : std_logic := '0';

  signal version : std_logic_vector(7 downto 0) := (others => '0');

  -- outputs
  signal cmdout  : std_logic_vector(47 downto 0) := (others => '0');
  signal sendcmd : std_logic                     := '0';


  -- data
  signal sample    : std_logic_vector(15 downto 0) := (others => '0');
  signal samplesel : std_logic_vector(3 downto 0)  := (others => '0');

  signal cmdsts, cmdid : std_logic_vector(3 downto 0) := (others => '0');
  signal success       : std_logic                    := '0';

  -- debug
  signal cmdidl, cmdidll   : std_logic_vector(3 downto 0) := (others => '0');
  signal cmdoutl, cmdoutll : std_logic_vector(7 downto 0) := (others => '0');
  signal cmdina_cmdidl     : std_logic_vector(3 downto 0) := (others => '0');
  signal cmdinb_cmdidl     : std_logic_vector(3 downto 0) := (others => '0');
  signal successl          : std_logic                    := '0';
  signal successll         : std_logic                    := '0';


  -- input componnets
  component fiberrx
    port (CLK     : in  std_logic;
          DIN     : in  std_logic;
          DATAOUT : out std_logic_vector(7 downto 0);
          KOUT    : out std_logic;
          LINKUP  : out std_logic;
          DATAEN  : out std_logic;
          RESET   : in  std_logic);
  end component;


  component framedis
    port (CLK        : in  std_logic;
          RESET      : in  std_logic;
          DIN        : in  std_logic_vector(7 downto 0);
          INWE       : in  std_logic;
          KIN        : in  std_logic;
          LINKUPIN   : in  std_logic;
          LINKUP     : out std_logic;
          NEWSAMPLES : out std_logic;
          SAMPLE     : out std_logic_vector(15 downto 0);
          SAMPLESEL  : in  std_logic_vector(3 downto 0);
          CMDID      : out std_logic_vector(3 downto 0);
          CMDST      : out std_logic_vector(3 downto 0);
          SUCCESS    : out std_logic;
          VERSION    : out std_logic_vector(7 downto 0));
  end component;

  component acqcmdmux
    port (
      CLK      : in  std_logic;
      CMDIDRX  : in  std_logic_vector(3 downto 0);
      CMDINTXA : in  std_logic_vector(47 downto 0);
      CMDINTXB : in  std_logic_vector(47 downto 0);
      NEWCMDA  : in  std_logic;
      NEWCMDB  : in  std_logic;
      LINKUP   : in  std_logic;
      CMDOUT   : out std_logic_vector(47 downto 0);
      SENDCMD  : out std_logic
      );
  end component;

  component sportacqser
    port (
      CLK       : in  std_logic;
      SERCLK    : in  std_logic;
      SERTFS    : out std_logic;
      SERDT     : out std_logic;
      START     : in  std_logic;
      DONE      : out std_logic;
      SAMPLEIN  : in  std_logic_vector(15 downto 0);
      SAMPLESEL : out std_logic_vector(3 downto 0);
      CMDSTS    : in  std_logic_vector(3 downto 0);
      CMDID     : in  std_logic_vector(3 downto 0);
      SUCCESS   : in  std_logic;
      VERSION   : in  std_logic_vector(7 downto 0)
      );
  end component;

-- output
  component fibertx
    port (CLK      : in  std_logic;
          CMDIN    : in  std_logic_vector(47 downto 0);
          SENDCMD  : in  std_logic;
          FIBEROUT : out std_logic);
  end component;

  component uartacqrx
    port (
      CLK        : in  std_logic;
      RESET      : in  std_logic;
      UARTRX     : in  std_logic;
      DATAOUT    : out std_logic_vector(47 downto 0);
      DATAOUTNEW : out std_logic);
  end component;


begin  -- Behavioral

  fiberrx_inst : fiberrx
    port map (
      CLK     => clk,
      DIN     => FIBERIN,
      DATAOUT => fiberdata,
      KOUT    => kin,
      LINKUP  => rxlinkup,
      DATAEN  => inwe,
      RESET   => '0');

  framedis_inst : framedis
    port map (
      CLK        => clk,
      RESET      => reset,
      DIN        => fiberdata,
      INWE       => inwe,
      KIN        => kin,
      LINKUPIN   => rxlinkup,
      LINKUP     => linkup,
      NEWSAMPLES => newsamples,
      CMDID      => cmdid,
      CMDST      => cmdsts,
      SAMPLESEL  => samplesel,
      SAMPLE     => sample,
      success    => success,
      VERSION    => version);


  sportacqser_inst : sportacqser
    port map (
      CLK       => clk,
      SERCLK    => SERCLK,
      SERTFS    => sertfs,
      SERDT     => serdt,
      START     => newsamples,
      DONE      => open,
      SAMPLEIN  => sample,
      SAMPLESEL => samplesel,
      CMDSTS    => cmdsts,
      CMDID     => cmdid,
      SUCCESS   => success,
      VERSION   => version);


  acqcmdmux_inst : acqcmdmux
    port map (
      CLK      => clk,
      CMDIDRX  => cmdid,
      CMDINTXA => cmdina,
      CMDINTXB => cmdinb,
      NEWCMDA  => newcmda,
      NEWCMDB  => newcmdb,
      LINKUP   => linkup,
      CMDOUT   => cmdout,
      SENDCMD  => sendcmd);

  uartacqrx_a : uartacqrx
    port map (
      CLK        => CLK,
      RESET      => RESET,
      UARTRX     => DSPAUARTRX,
      DATAOUT    => cmdina,
      DATAOUTNEW => newcmda);


  uartacqrx_b : uartacqrx
    port map (
      CLK        => CLK,
      RESET      => RESET,
      UARTRX     => DSPBUARTRX,
      DATAOUT    => cmdinb,
      DATAOUTNEW => newcmdb);



  process(CLK)
  begin
    if rising_edge(CLK) then
      cmdidl    <= cmdid;
      cmdidll   <= cmdidl;
      cmdoutl   <= cmdout(7 downto 0);
      cmdoutll  <= cmdoutl;
      successl  <= success;
      successll <= successl;

--      if newcmdb = '1' then
--        cmdinb_cmdidl <= cmdinb(7 downto 4); 
--      end if;
--      if newcmda = '1' then
--        cmdina_cmdidl <= cmdina(7 downto 4); 
--      end if;
      DEBUG <= "00000" & inwe & linkup & rxlinkup
               & X"00" & cmdoutll & "000" & successll & cmdidll;  --  & cmdinb_cmdidl & cmdina_cmdidl & lcmdid  & lcmdsts;
    end if;
  end process;

  fibertx_inst : fibertx
    port map (
      CLK      => clkhi,
      CMDIN    => cmdout,
      SENDCMD  => sendcmd,
      FIBEROUT => FIBEROUT);

  NEWCMDDEBUG <= sendcmd;

  DSPASERDT  <= serdt;
  DSPASERTFS <= sertfs;

  DSPBSERDT  <= serdt;
  DSPBSERTFS <= sertfs;

  DSPALINKUP <= linkup;
  DSPBLINKUP <= linkup;

end Behavioral;
