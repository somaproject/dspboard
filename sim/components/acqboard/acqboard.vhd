library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity acqboard is
  port (
    CLKIN        : in  std_logic;
    RXDATA       : out std_logic_vector(31 downto 0) := (others => '0');
    RXCMD        : out std_logic_vector(3 downto 0);
    RXCMDID      : out std_logic_vector(3 downto 0);
    RXCHKSUM     : out std_logic_vector(7 downto 0);
    FIBEROUT     : out std_logic;
    FIBERIN      : in  std_logic;
    TXCMDSTS     : in  std_logic_vector(3 downto 0);
    TXCMDSUCCESS : in  std_logic;
    TXCHKSUM     : in  std_logic_vector(7 downto 0));

end acqboard;


architecture Behavioral of acqboard is

  component acqclocks
    port ( CLKIN     : in  std_logic;
           CLK       : out std_logic;
           CLK8      : out std_logic;
           RESET     : in  std_logic;
           INSAMPLE  : out std_logic;
           OUTSAMPLE : out std_logic;
           OUTBYTE   : out std_logic := '0';
           SPICLK    : out std_logic;
           LOCKED    : out std_logic);
  end component;

  signal clk       : std_logic := '0';
  signal clk8      : std_logic := '0';
  signal insample  : std_logic := '0';
  signal outsample : std_logic := '0';
  signal outbyte   : std_logic := '0';

  component acqfibertx
    port ( CLK        : in  std_logic;
           CLK8       : in  std_logic;
           RESET      : in  std_logic;
           OUTSAMPLE  : in  std_logic;
           FIBEROUT   : out std_logic;
           CMDDONE    : in  std_logic;
           Y          : in  std_logic_vector(15 downto 0);
           YEN        :     std_logic;
           CMDSTS     : in  std_logic_vector(3 downto 0);
           CMDID      : in  std_logic_vector(3 downto 0);
           CMDSUCCESS : in  std_logic;
           OUTBYTE    : in  std_logic;
           CHKSUM     : in  std_logic_vector(7 downto 0));
  end component;

  signal y       : std_logic_vector(15 downto 0) := (others => '0');
  signal yen     : std_logic                     := '0';
  signal channum : std_logic_vector(3 downto 0)  := (others => '0');
  signal sampcnt : std_logic_vector(7 downto 0)  := (others => '1');

  signal rxcmdid_int         : std_logic_vector(3 downto 0) := (others => '0');
  signal txcmdid             : std_logic_vector(3 downto 0) := (others => '0');
  signal cmddelay            : std_logic_vector(9 downto 0) := (others => '1');
  signal rxnewcmd, rxnewcmdl : std_logic                    := '0';
  signal txcmddone           : std_logic                    := '0';

  signal pending : std_logic := '0';

  signal reset  : std_logic := '1';
  signal locked : std_logic := '0';


  component Acqfiberrx
    port ( CLK     : in  std_logic;
           FIBERIN : in  std_logic;
           RESET   : in  std_logic;
           DATA    : out std_logic_vector(31 downto 0) := (others => '0');
           CMD     : out std_logic_vector(3 downto 0);
           NEWCMD  : out std_logic;
           PENDING : in  std_logic;
           CMDID   : out std_logic_vector(3 downto 0);
           CHKSUM  : out std_logic_vector(7 downto 0));
  end component;

begin  -- Behavioral

  RESET <= not locked;

  acqclocks_inst : acqclocks
    port map (
      CLKIN     => CLKIN,
      CLK       => clk,
      CLK8      => clk8,
      RESET     => '0',
      INSAMPLE  => insample,
      OUTSAMPLE => outsample,
      OUTBYTE   => outbyte,
      SPICLK    => open,
      LOCKED    => locked);


  acqfibertx_uut : acqfibertx
    port map (
      CLK        => clk,
      CLK8       => clk8,
      RESET      => RESET,
      OUTSAMPLE  => outsample,
      FIBEROUT   => FIBEROUT,
      CMDDONE    => TXCMDDONE,
      Y          => y,
      YEN        => yen,
      CMDSTS     => TXCMDSTS,
      CMDID      => rxcmdid_int,
      CMDSUCCESS => TXCMDSUCCESS,
      OUTBYTE    => outbyte,
      CHKSUM     => TXCHKSUM);


  process(clk)
  begin
    if RESET = '1' then
    else
      if rising_edge(CLK) then
        if outsample = '1' then
          sampcnt   <= sampcnt + 1;
          channum   <= (others => '0');
          yen       <= '0';
        else
          if channum /= X"A" then
            yen     <= '1';
            channum <= channum + 1;
            y       <= sampcnt & "0000" & channum;
          else
            yen     <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;


  acqfiberrx_inst : acqfiberrx
    port map (
      RESET   => '0',
      CLK     => CLK,
      FIBERIN => FIBERIN,
      DATA    => RXDATA,
      CMD     => RXCMD,
      NEWCMD  => RXNEWCMD,
      CMDID   => RXCMDID_int,
      CHKSUM  => RXCHKSUM,
      PENDING => pending);

  process(clk)
  begin
    if RESET = '1' then
      -- pass
    else
      if rising_edge(clk) then
        rxnewcmdl <= rxnewcmd;

        -- simple wait
        if rxnewcmd = '1' and rxnewcmdl = '0' then
          -- rising edge
          cmddelay   <= (others => '0');
          pending    <= '1';
        else
          if cmddelay /= "1111111111" then
            cmddelay <= cmddelay + 1;
          else
            pending  <= '0';
          end if;
        end if;

        if cmddelay = "1111111110" then
          txcmdid   <= rxcmdid_int;
          txcmddone <= '1';
        else
          txcmddone <= '0';
        end if;
      end if;
    end if;
  end process;

  RXCMDID <= rxcmdid_int;

end Behavioral;
