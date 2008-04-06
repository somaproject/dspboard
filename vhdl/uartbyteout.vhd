library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity uartbyteout is
  port (
    CLK    : in  std_logic;             -- '0'
    DIN    : in  std_logic_vector(7 downto 0);
    SEND   : in  std_logic;
    DONE   : out std_logic;
    UARTTX : out std_logic := '1'
    );
end uartbyteout;

architecture Behavioral of uartbyteout is


  signal dinl    : std_logic_vector(7 downto 0)  := (others => '0');
  signal startl  : std_logic                     := '0';

  signal datareg : std_logic_vector(9 downto 0) := (others => '1');


  signal cnt    : integer range 0 to 11000 := 0;
  signal bitcnt : integer range 0 to 15   := 0;

  signal cntrst : std_logic := '0';

  type states is (none, loadbytes, waitbit, nextbit, donetx);
  signal cs, ns : states := none;

begin  -- Behavioral

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;
      
      startl <= SEND;
      if SEND = '1'  then
        dinl <= DIN;         
      end if;

      UARTTX <= datareg(0);
      if cs = donetx then
        DONE <= '1';
      else
        DONE <= '0';
      end if;

      if cs = loadbytes then
        datareg   <= "1" & dinl & "0";
      else
        if cs = nextbit then
          datareg <= '1' & datareg(9 downto 1);
        end if;
      end if;

      if cntrst = '1' then
        cnt <= 0;
      else
        cnt <= cnt + 1;
      end if;

      if cs = nextbit then
        bitcnt <= bitcnt + 1;
      else

        if cs = none then
          bitcnt <= 0; 
        end if;
      end if;
      
    end if;


  end process;

  fsm : process(cs, startl, cnt, bitcnt)
  begin
    case cs is
      when none =>
        cntrst <= '1';
        if startl = '1' then
          ns <= loadbytes;
        else
          ns <= none; 
        end if;

      when loadbytes =>
        cntrst <= '0';
        ns <= waitbit;
      
      when waitbit =>
        cntrst <= '0';
        if cnt = 10412 then
          ns <= nextbit;
        else
          ns <= waitbit; 
        end if;

      when nextbit =>
        cntrst <=   '1';
        if bitcnt = 11 then
          ns <= donetx;
        else
          ns <= waitbit; 
        end if;

      when donetx =>
        cntrst <= '1';
        ns <= none;

      when others =>
        cntrst <= '0';
        ns <= none; 
    end case;

  end process fsm;
end Behavioral;
