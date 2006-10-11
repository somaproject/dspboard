library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity multichanneltest is
  port (
    REFCLKIN  : in  std_logic;
    DSPCLKOUT : out std_logic;
    DSPRESET  : out std_logic;
    LEDPOWER  : out std_logic;
    RSCLK     : out std_logic;
    DR        : out std_logic;
    RFS       : out std_logic;
    DT        : in  std_logic;
    TFS       : in  std_logic
    );
end multichanneltest;


architecture Behavioral of multichanneltest is

  signal clk        : std_logic                     := '0';
  signal dspcntdown : std_logic_vector(24 downto 0) := (others => '1');
  signal cnt        : std_logic_vector(21 downto 0) := (others => '0');
  signal ldspreset  : std_logic                     := '0';

  signal lrsclk, ldr, lrfs : std_logic := '0';

  signal wordcnt  : std_logic_vector(3 downto 0)  := (others => '0');
  signal framecnt : std_logic_vector(11 downto 0) := (others => '0');

  type states is (none, start, startw, start1,
                  start2, start3,
                  clkl, clkh, nextword,
                  donef);
  signal cs, ns : states := none;

  signal bitcnt  : integer range 0 to 15    := 0;
  signal waitcnt : integer range 0 to 65535 := 0;

begin  -- Behavioral

  clk <= REFCLKIN;

  DSPCLKOUT <= clk;

  ldr <= framecnt(11) when bitcnt = 0  else
         framecnt(10) when bitcnt = 1  else
         framecnt(9)  when bitcnt = 2  else
         framecnt(8)  when bitcnt = 3  else
         framecnt(7)  when bitcnt = 4  else
         framecnt(6)  when bitcnt = 5  else
         framecnt(5)  when bitcnt = 6  else
         framecnt(4)  when bitcnt = 7  else
         framecnt(3)  when bitcnt = 8  else
         framecnt(2)  when bitcnt = 9  else
         framecnt(1)  when bitcnt = 10 else
         framecnt(0)  when bitcnt = 11 else
         wordcnt(3)   when bitcnt = 12 else
         wordcnt(2)   when bitcnt = 13 else
         wordcnt(1)   when bitcnt = 14 else
         wordcnt(0);


  main : process(clk)
  begin
    if rising_edge(clk) then

      cs <= ns;

      RSCLK <= lrsclk;
      DR    <= ldr;
      RFS   <= lrfs;

      DSPRESET     <= ldspreset;
      if dspcntdown /= "0000000000000000000000000" then
        dspcntdown <= dspcntdown - 1;
      else
        ldspreset  <= '1';
      end if;

      cnt <= cnt + 1;

      LEDPOWER <= cnt(21);

      if cs = clkh then
        if bitcnt = 15 then
          bitcnt <= 0;
        else
          bitcnt <= bitcnt + 1;
        end if;
      end if;

      if cs = nextword then
        if wordcnt = "1111" then
          wordcnt <= (others => '0');
        else
          wordcnt <= wordcnt + 1;
        end if;
      end if;

      if cs = start1 then
        waitcnt <= 0;
      elsif cs = startw then
        waitcnt <= waitcnt + 1;
      end if;

      if cs = donef then
        framecnt <= framecnt + 1;

      end if;
    end if;
  end process main;

  lrfs <= '1' when (cs = start1 or cs = start2 or cs = start3) else '0';
  

  fsm : process(cs, bitcnt, wordcnt, cnt)
  begin
    case cs is
      when none =>
        lrsclk <= '0';
        ns     <= start1;

      when startw =>
        lrsclk <= '0';

        if waitcnt = 3000 then
          ns <= start1;
        else
          ns <= startw;
        end if;

      when start1 =>
        lrsclk <= '0';
        ns     <= start2;
      when start2 =>
        lrsclk <= '1';
        ns     <= start3;

      when start3 =>
        lrsclk <= '0';
        ns     <= clkl;

      when clkl =>
        lrsclk <= '0';
        ns     <= clkh;

      when clkh =>
        lrsclk <= '1';

        if bitcnt = 15 then
          ns <= nextword;
        else
          ns <= clkl;
        end if;

      when nextword =>
        lrsclk <= '0';
        if wordcnt = "1111" then
          ns   <= donef;
        else
          ns   <= clkl;
        end if;

      when donef =>
        lrsclk <= '0';
        ns     <= startw;

      when others =>
        lrsclk <= '0';
        ns     <= none;

    end case;
  end process fsm;

end Behavioral;
