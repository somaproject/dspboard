library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity datamux is
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
end datamux;

architecture Behavioral of datamux is
  signal epos : integer range 0 to 1023 := 0;

begin  -- Behavioral

  main : process(CLK)
  begin
    if rising_edge(clk) then
      if ECYCLE = '1' then
        epos   <= 1;
      else
        if epos < 1000 then
          epos <= epos + 1;
        end if;
      end if;
    end if;
  end process main;

  
  ENCDOUT <= ddataa when dgrantin(0) = '1' else
             ddatab when dgrantin(1) = '1' else
             ddatac when dgrantin(2) = '1' else
             ddatad when dgrantin(3) = '1' else
             X"00";
  
  ENCDREQ <= dreq(0) when dgrantin(0) = '1' else
             dreq(1) when dgrantin(1) = '1' else
             dreq(2) when dgrantin(2) = '1' else
             dreq(3) when dgrantin(3) = '1' else
             '0';

  ENCDDONE <= ddone(0) when dgrantin(0) = '1' else
             ddone(1) when dgrantin(1) = '1' else
             ddone(2) when dgrantin(2) = '1' else
             ddone(3) when dgrantin(3) = '1' else
             '0';
  
  DGRANT(0) <= ENCDGRANT when dgrantin(0) = '1' else '0';
  DGRANT(1) <= ENCDGRANT when dgrantin(1) = '1' else '0';
  DGRANT(2) <= ENCDGRANT when dgrantin(2) = '1' else '0';
  DGRANT(3) <= ENCDGRANT when dgrantin(3) = '1' else '0';
  

  
             
  
end Behavioral;
