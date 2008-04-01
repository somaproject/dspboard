library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity uartacqrx is
  port (
    CLK        : in  std_logic;
    RESET      : in  std_logic;
    UARTRX     : in  std_logic;
    DATAOUT    : out std_logic_vector(47 downto 0);
    DATAOUTNEW : out std_logic);
end uartacqrx;

architecture Behavioral of uartacqrx is
  signal uartrxl : std_logic                     := '1';
  signal datareg : std_logic_vector(47 downto 0) := (others => '0');

  signal cnt    : integer range 0 to 5400 := 0;
  signal cntrst : std_logic               := '0';

  signal bitcnt  : integer range 0 to 7 := 0;
  signal bytecnt : integer range 0 to 7 := 0;

  type states is (none, syncwait, bytestart, waitbit, getbit, waitstop, bytechk, donerx);

  signal cs, ns : states := none;

begin  -- Behavioral

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        cs           <= none;
        cnt          <= 0;
        bitcnt       <= 0;
        bytecnt      <= 0;
      else
        cs <= ns;
        
        uartrxl      <= UARTRX;
        if cs = donerx then
          DATAOUTNEW <= '1';
          DATAOUT    <= datareg;
        else
          DATAOUTNEW <= '0';
        end if;

        if cs = getbit then
          datareg <= uartrxl & datareg(47 downto 1);
        end if;

        if cntrst = '1' then
          cnt <= 0;
        else
          cnt <= cnt + 1;
        end if;

        if cs = waitstop then
          bitcnt <= 0;
        else
          if cs = getbit then
            if bitcnt = 7  then
              bitcnt <= 0;
            else
              bitcnt <= bitcnt + 1;            
            end if;

          end if;
        end if;

        if cs = donerx then
          bytecnt   <= 0;
        else
          if cs = bytechk then
            bytecnt <= bytecnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process main;

  fsm : process(cs, uartrxl, cnt, bitcnt, bytecnt)
  begin
    case cs is
      when none =>
        cntrst <= '1';
        if uartrxl = '0' then
          ns   <= syncwait;
        else
          ns   <= none;
        end if;

      when syncwait =>
        cntrst <= '0';
        if cnt = 2604 then
          ns   <= bytestart;
        else
          ns   <= syncwait;
        end if;

      when bytestart =>
        cntrst <= '1';
        ns     <= waitbit;

      when waitbit =>
        cntrst <= '0';
        if cnt = 5206 then
          ns   <= getbit;
        else
          ns   <= waitbit;
        end if;

      when getbit =>
        cntrst <= '1';
        if bitcnt = 7 then
          ns   <= waitstop;
        else
          ns   <= waitbit;
        end if;

      when waitstop =>
        cntrst <= '0';
        if cnt = 5206 then
          ns   <= bytechk;
        else
          ns   <= waitstop;
        end if;

      when bytechk =>
        cntrst <= '0';
        if bytecnt = 5 then
          ns   <= donerx;
        else
          ns   <= none;
        end if;

      when donerx =>
        cntrst <= '0';
        ns     <= none;

      when others =>
        cntrst <= '0';
        ns     <= none;
    end case;

  end process fsm;

end Behavioral;
