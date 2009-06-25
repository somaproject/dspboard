library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity sendevent is
  
  port (
    CLK    : in  std_logic;
    ESEND  : in  std_logic_vector(1 downto 0);
    DIN    : in  std_logic_vector(7 downto 0);
    ADDR   : out std_logic_vector(4 downto 0);
    DOUT   : out std_logic_vector(7 downto 0);
    KOUT   : out std_logic;
    DOUTEN : in  std_logic;
    START  : in  std_logic;
    DONE   : out std_logic
    );

end sendevent;

architecture Behavioral of sendevent is
  signal osel : integer range 0 to 1 := 0;

  signal bcnt : std_logic_vector(4 downto 0) := (others => '0');

  type   states is (none, hdrsend, esends, dones);
  signal cs, ns : states := none;

  signal ehdr : std_logic_vector(7 downto 0) := (others => '0');

  
  
begin  -- Behavioral

  ehdr <= X"1C" when esend = "00" else
          X"3C" when esend = "01" else
          X"5C" when esend = "10" else
          X"7C";

  DOUT <= ehdr when osel = 0 else DIN;
  ADDR <= bcnt;

  DONE <= '1' when cs = dones else '0';

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      if cs = none then
        bcnt <= (others => '0');
      else
        if DOUTEN = '1' then
          bcnt <= bcnt + 1;
          
        end if;
      end if;
      
    end if;
  end process main;

  fsm : process(cs, START, bcnt, DOUTEN)
  begin
    case cs is
      when none =>
        osel <= 0;
        KOUT <= '0';
        if START = '1' then
          ns <= hdrsend;
        else
          ns <= none;
        end if;

      when hdrsend =>
        osel <= 0;
        KOUT <= '1';
        if DOUTEN = '1' then
          ns <= esends;
        else
          ns <= hdrsend;
        end if;
        
      when esends =>
        osel <= 1;
        KOUT <= '0';
        if DOUTEN = '1' then
          if bcnt = "10110" then
            ns <= dones;
          else
            ns <= esends;
          end if;
        else
          ns <= esends;
        end if;
        
      when dones =>
        osel <= 0;
        KOUT <= '0';
        ns   <= none;
        
      when others =>
        osel <= 0;
        KOUT <= '0';
        ns   <= none;
        
    end case;
  end process fsm;
  
end Behavioral;
