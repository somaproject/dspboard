library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
entity dgranttest is
end dgranttest;

architecture Behavioral of dgranttest is

  component decodemux
    port (
      CLK     : in  std_logic;
      DIN     : in  std_logic_vector(7 downto 0);
      KIN     : in  std_logic;
      LOCKED  : in  std_logic;
      ECYCLE  : out std_logic;
      EDATA   : out std_logic_vector(7 downto 0);
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

  component datamux
    port (
      CLK       : in  std_logic;
      ECYCLE    : in  std_logic;
      -- collection of grants
      DGRANTIN  : in  std_logic_vector(3 downto 0);
      -- encodemux interface
      ENCDOUT   : out std_logic_vector(7 downto 0);
      ENCDGRANT : in  std_logic;
      ENCDREQ   : out std_logic;
      ENCDDONE  : out std_logic;
      -- individual datasport interfaces
      DDATAA    : in  std_logic_vector(7 downto 0);
      DDATAB    : in  std_logic_vector(7 downto 0);
      DDATAC    : in  std_logic_vector(7 downto 0);
      DDATAD    : in  std_logic_vector(7 downto 0);
      DGRANT    : out std_logic_vector(3 downto 0);
      DREQ      : in  std_logic_vector(3 downto 0);
      DDONE     : in  std_logic_vector(3 downto 0)
      );
  end component;


  component fakesport
    port (
      CLK    : in  std_logic;
      RESET  : in  std_logic;
      -- serial IO
      SERCLK : in  std_logic;
      SERDT  : out std_logic;
      SERTFS : out std_logic;
      FULL   : in  std_logic);
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
      DONE   : out std_logic;
      DEBUG  : out std_logic_vector(15 downto 0));
  end component;

  component fakebackplane
    port (
      CLK    : in  std_logic;
      TXDOUT : out std_logic_vector(7 downto 0);
      TXKOUT : out std_logic;
      RXDIN  : in  std_logic_vector(7 downto 0);
      RXKIN  : in  std_logic
      );

  end component;



  signal CLK    : std_logic                    := '0';
  signal DIN    : std_logic_vector(7 downto 0) := (others => '0');
  signal KIN    : std_logic                    := '0';
  signal LOCKED : std_logic                    := '1';
  signal ECYCLE : std_logic                    := '0';
  signal EDATA  : std_logic_vector(7 downto 0) := (others => '0');

  -- data interface
  signal dgrantin : std_logic_vector(3 downto 0)  := (others => '0');
  signal EARXA    : std_logic_vector(79 downto 0) := (others => '0');
  signal EARXB    : std_logic_vector(79 downto 0) := (others => '0');
  signal EARXC    : std_logic_vector(79 downto 0) := (others => '0');
  signal EARXD    : std_logic_vector(79 downto 0) := (others => '0');

  signal SERCLK : std_logic := '0';

  signal pos : integer range 0 to 999 := 950;


  signal dout : std_logic_vector(7 downto 0) := (others => '0');
  signal kout : std_logic                    := '0';

  signal encdreq   : std_logic                    := '0';
  signal encdgrant : std_logic                    := '0';
  signal encddone  : std_logic                    := '0';
  signal encddata  : std_logic_vector(7 downto 0) := (others => '0');

  signal ddataa : std_logic_vector(7 downto 0) := (others => '0');
  signal ddatab : std_logic_vector(7 downto 0) := (others => '0');
  signal ddatac : std_logic_vector(7 downto 0) := (others => '0');
  signal ddatad : std_logic_vector(7 downto 0) := (others => '0');

  signal dgrant, dreq, ddone : std_logic_vector(3 downto 0) := (others => '0');

  signal serdt  : std_logic_vector(3 downto 0) := (others => '0');
  signal sertfs : std_logic_vector(3 downto 0) := (others => '0');
  signal full   : std_logic_vector(3 downto 0) := (others => '0');


begin  -- Behavioral

  CLK <= not CLK after 10 ns;

  -- fake sports for testing
  sportgen         : for i in 0 to 3 generate
    fakesport_inst : fakesport
      port map (
        CLK    => CLK,
        RESET  => '0',
        SERCLK => serclk,
        SERDT  => serdt(i),
        SERTFS => sertfs(i),
        FULL   => full(i));

  end generate sportgen;

  datasport_a : datasport
    port map (
      CLK    => CLK,
      rESET  => '0',
      SERCLK => serclk,
      SERDT  => serdt(0),
      SERTFS => sertfs(0),
      FULL   => full(0),
      REQ    => dreq(0),
      GRANT  => dgrant(0),
      DONE   => ddone(0),
      DOUT   => ddataa);


  datasport_b : datasport
    port map (
      CLK    => CLK,
      rESET  => '0',
      SERCLK => serclk,
      SERDT  => serdt(1),
      SERTFS => sertfs(1),
      FULL   => full(1),
      REQ    => dreq(1),
      GRANT  => dgrant(1),
      DONE   => ddone(1),
      DOUT   => ddatab);


  datasport_c : datasport
    port map (
      CLK    => CLK,
      rESET  => '0',
      SERCLK => serclk,
      SERDT  => serdt(2),
      SERTFS => sertfs(2),
      FULL   => full(2),
      REQ    => dreq(2),
      GRANT  => dgrant(2),
      DONE   => ddone(2),
      DOUT   => ddatac);


  datasport_d : datasport
    port map (
      CLK    => CLK,
      rESET  => '0',
      SERCLK => serclk,
      SERDT  => serdt(3),
      SERTFS => sertfs(3),
      FULL   => full(3),
      REQ    => dreq(3),
      GRANT  => dgrant(3),
      DONE   => ddone(3),
      DOUT   => ddatad);

  fakebackplane_inst : fakebackplane
    port map (
      CLK    => CLK,
      TXDOUT => DIN,
      TXKOUT => kin,
      RXDIN  => dout,
      RXKIN => kout);



  decodemux_inst : decodemux
    port map (
      CLK     => CLK,
      DIN     => DIN,
      KIN     => KIN,
      LOCKED  => LOCKED,
      ECYCLE  => ECYCLE,
      EDATA   => EDATA,
      DGRANTA => dgrantin(0),
      EARXA   => EARXA,
      DGRANTB => dgrantin(1),
      EARXB   => EARXB,
      DGRANTC => dgrantin(2),
      EARXC   => EARXC,
      DGRANTD => dgrantin(3),
      EARXD   => EARXD);

  encodemux_inst : encodemux
    port map (
      CLK    => clk,
      ECYCLE => ecycle,
      DOUT   => dout,
      KOUT   => kout,
      DREQ   => encdreq,
      DGRANT => encdgrant,
      DDONE  => encddone,
      DDATA  => encddata,

      EDSPREQ   => "0000",
      EDSPGRANT => open,
      EDSPDONE  => "0000",
      EDSPDATAA => X"00",
      EDSPDATAB => X"00",
      EDSPDATAC => X"00",
      EDSPDATAD => X"00",

      EPROCREQ   => "0000",
      EPROCGRANT => open,
      EPROCDONE  => "0000",
      EPROCDATAA => X"00",
      EPROCDATAB => X"00",
      EPROCDATAC => X"00",
      EPROCDATAD => X"00");

  datamux_uut : datamux
    port map (
      CLK       => CLK,
      ECYCLE    => ecycle,
      DGRANTIN  => dgrantin,
      ENCDOUT   => encddata,
      ENCDGRANT => encdgrant,
      ENCDREQ   => encdreq,
      ENCDDONE  => encddone,
      DDATAA    => ddataa,
      DDATAB    => ddatab,
      DDATAC    => ddatac,
      DDATAD    => ddatad,
      DGRANT    => dgrant,
      DREQ      => dreq,
      DDONE     => ddone);

  ecycle_generation : process(CLK)
  begin
    if rising_edge(CLK) then
      if pos = 999 then
        pos <= 0;
      else
        pos <= pos + 1;
      end if;

    end if;
  end process ecycle_generation;

  -- input data

  process(CLK)
    variable bpos : integer range 0 to 2 := 0;
  begin
    if rising_edge(CLK) then
      if bpos = 2 then
        bpos                             := 0;
      else
        bpos                             := bpos + 1;
      end if;

      if bpos = 2 then
        SERCLK <= '1';
      else
        SERCLK <= '0';
      end if;
    end if;

  end process;
end Behavioral;
