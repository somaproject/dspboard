library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity datamux is
  port (
    CLK          : in  std_logic;
    ECYCLE       : in  std_logic;
    -- collection of grants
    DGRANTIN     : in  std_logic_vector(3 downto 0);
    -- datamux interface
    ENCDOUT      : out std_logic_vector(7 downto 0);
    ENCDNEXTBYTE : in  std_logic;
    ENCDREQ      : out std_logic;
    ENCDLASTBYTE : out std_logic;
    -- individual datasport interfaces
    DDATAA       : in  std_logic_vector(7 downto 0);
    DDATAB       : in  std_logic_vector(7 downto 0);
    DDATAC       : in  std_logic_vector(7 downto 0);
    DDATAD       : in  std_logic_vector(7 downto 0);
    DNEXTBYTE    : out std_logic_vector(3 downto 0);
    DREQ         : in  std_logic_vector(3 downto 0);
    DLASTBYTE    : in  std_logic_vector(3 downto 0)
    );
end datamux;

architecture Behavioral of datamux is
  signal epos : integer range 0 to 1023 := 0;

begin  -- Behavioral

  main : process(CLK)
  begin
    if rising_edge(clk) then
      if ECYCLE = '1' then
        epos <= 1;
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

  ENCDLASTBYTE <= dlastbyte(0) when dgrantin(0) = '1' else
              dlastbyte(1) when dgrantin(1) = '1' else
              dlastbyte(2) when dgrantin(2) = '1' else
              dlastbyte(3) when dgrantin(3) = '1' else
              '0';
  
  DNEXTBYTE(0) <= ENCDNEXTBYTE when dgrantin(0) = '1' else '0';
  DNEXTBYTE(1) <= ENCDNEXTBYTE when dgrantin(1) = '1' else '0';
  DNEXTBYTE(2) <= ENCDNEXTBYTE when dgrantin(2) = '1' else '0';
  DNEXTBYTE(3) <= ENCDNEXTBYTE when dgrantin(3) = '1' else '0';
  
end Behavioral;
