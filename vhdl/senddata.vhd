library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity senddata is
  port (
    CLK    : in  std_logic;
    DIN    : in  std_logic_vector(7 downto 0);
    ADDR   : out std_logic_vector(9 downto 0);
    DOUT   : out std_logic_vector(7 downto 0);
    KOUT   : out std_logic;
    DOUTEN : in  std_logic;
    START  : in  std_logic;
    DONE   : out std_logic
    );
end senddata;

architecture Behavioral of senddata is
  signal osel : integer range 0 to 2 := 0;

  signal bcnt : std_logic_vector(9 downto 0) := (others => '0');

  type   states is (none, hdrsend, datasend, ftrsend, dones);
  signal cs, ns : states := none;
  
begin  -- Behavioral

  DOUT <= X"DC" when osel = 0 else
          DIN when osel = 1 else
          X"FC";
  
  ADDR <= bcnt;

  DONE <= '1' when cs = dones else '0';

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      if cs = none then
        bcnt <= (others => '0');
      else
        bcnt <= bcnt + 1;
      end if;
      
    end if;
  end process main;

  fsm : process(cs, START, bcnt)
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
        ns   <= datasend;
        
      when datasend =>
        osel <= 1;
        KOUT <= '0';
        if bcnt = "1001011000" then
          ns <= ftrsend;
        else
          ns <= datasend;
        end if;
        
      when ftrsend =>
        osel <= 2;
        KOUT <= '1';
        ns   <= dones;
        
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
