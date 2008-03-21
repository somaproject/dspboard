library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity evtendianrev is
  port (
    CLK    : in  std_logic;
    DIN    : in  std_logic_vector(7 downto 0);
    DINEN  : in  std_logic;
    DOUT   : out std_logic_vector(7 downto 0);
    DOUTEN : out std_logic);
end evtendianrev;

architecture Behavioral of evtendianrev is
  signal dinl : std_logic_vector(15 downto 0) := (others => '0');
  signal dinll : std_logic_vector(15 downto 0) := (others => '0');

  signal pos, posl: std_logic := '0';
  signal dinenl, dinenll, dinenlll, dinenllll : std_logic := '0';
begin
  
  process(CLK)
  begin
    if rising_edge(CLK) then
      dinenl <= DINEN;
      dinenll <= dinenl;
      dinenlll <= dinenll; 
      
                
      if DINEN = '1'  then
        pos <= '1';
      else
        pos <= not pos; 
      end if;

      posl <= pos;
      
      if pos = '0' then
        dinll <= dinl; 
        dinl(7 downto 0) <= DIN;
      else
        dinl(15 downto 8) <= DIN; 
      end if;

      if pos = '0' then
        DOUT <= dinll(7 downto 0);
      else
        DOUT <= dinll(15 downto 8); 
      end if;

      DOUTEN <= dinenlll;
      
    end if;
  end process;
end Behavioral;
