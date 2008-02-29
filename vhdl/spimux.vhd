library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity spimux is
  port (
    CLK : in std_logic;
    ASEL : in std_logic;
    
    SPISS : out std_logic;
    SPISCLK : out std_logic;
    SPIMOSI : out std_logic;
    SPIMISO : in std_logic;
    -- A port
    SPISSA : in std_logic;
    SPISCLKA : in std_logic;
    SPIMOSIA : in std_logic;
    SPIMISOA : out std_logic;
    -- B port
    SPISSB : in std_logic;
    SPISCLKB : in std_logic;
    SPIMOSIB : in std_logic;
    SPIMISOB : out std_logic  
    );
end spimux;

architecture Behavioral of spimux is

begin  -- Behavioral

  SPISS <= SPISSA when ASEL = '1' else SPISSB;

  SPISCLK <= SPISCLKA when ASEL = '1' else SPISCLKB;

  SPIMOSI <= SPIMOSIA when ASEL = '1' else SPIMOSIB;

  SPIMISOA <= SPIMISO;
  SPIMISOB <= SPIMISO;

  

end Behavioral;
