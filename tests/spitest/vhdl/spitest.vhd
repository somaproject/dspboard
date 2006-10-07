library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity spitest is
  port (
    REFCLKIN  : in  std_logic;
    DSPCLKOUT : out std_logic;
    DSPRESET  : out std_logic;
    LEDPOWER  : out std_logic;
    SPISS     : out std_logic;
    GOFLAG : in std_logic; 
    MOSI      : out std_logic;
    MISO      : in  std_logic;
    MSCLK     : out std_logic
    );
end spitest;


architecture Behavioral of spitest is

  signal clk        : std_logic                     := '0';
  signal dspcntdown : std_logic_vector(24 downto 0) := (others => '1');
  signal cnt        : std_logic_vector(21 downto 0) := (others => '0');
  signal ldspreset  : std_logic                     := '0';

  signal lmosi, lsclk : std_logic                     := '0';
  signal lspiss        : std_logic                     := '1';
  signal wordcnt       : std_logic_vector(15 downto 0) := (others => '0');
  signal bitcnt        : integer range 0 to 15         := 0;

  type states is (none, start, clkl0, clkh0, clkh1, clkl1, clkl2, nextword);
  signal cs, ns : states := none;

begin  -- Behavioral

  clk       <= REFCLKIN;
  DSPCLKOUT <= clk;

  lmosi <= wordcnt(bitcnt);

  main : process(clk)
  begin
    if rising_edge(clk) then

      cs <= ns;

      SPISS    <= lspiss;
      MOSI     <= lmosi;
      MSCLK <= lsclk;
      

      DSPRESET <= ldspreset;

      if dspcntdown /= "0000000000000000000000000" then
        dspcntdown <= dspcntdown - 1;
      else
        ldspreset  <= '1';
      end if;

      cnt <= cnt + 1;

      LEDPOWER <= cnt(21);

      if cs = clkl2 then
        if bitcnt = 15 then
          bitcnt <= 0;
        else
          bitcnt <= bitcnt + 1;
        end if;
      end if;

      if cs = nextword then
        wordcnt <= wordcnt + 1;
      end if;

    end if;
  end process main;

  fsm : process(cs, bitcnt, wordcnt, cnt, GOFLAG)
  begin
    case cs is
      when none =>
        lspiss <= '1';
        lsclk  <= '0';
        if cnt(11 downto 0) = "000000000000" and GOFLAG = '1' then
          ns <= start;
        else
          ns <= none; 
        end if;
      when start =>
        lspiss <= '0';
        lsclk  <= '0';
        ns     <= clkl0;

      when clkl0 =>
        lspiss <= '0';
        lsclk  <= '0';
        ns     <= clkh0;

      when clkh0 =>
        lspiss <= '0';
        lsclk  <= '1';
        ns     <= clkh1;

      when clkh1 =>
        lspiss <= '0';
        lsclk  <= '1';
        ns     <= clkl1;

      when clkl1 =>
        lspiss <= '0';
        lsclk  <= '0';
        ns     <= clkl2;

      when clkl2 =>
        lspiss <= '0';
        lsclk  <= '0';
        if bitcnt = 15 then
          ns   <= nextword;
        else

          ns <= clkl0;
        end if;

      when nextword =>
        lspiss <= '1';
        lsclk  <= '0';
        ns     <= none;

      when others =>
        lspiss <= '1';
        lsclk  <= '0';
        ns     <= none;

    end case;
  end process fsm;

end Behavioral;
