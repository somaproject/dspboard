library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity dspiomux is
  port (
    CLK         : in    std_logic;
    PSEL        : in    std_logic;
    -- dsp pins                      
    SPISCLK     : inout std_logic;
    SPIMOSI     : inout std_logic;
    SPIMISO     : inout std_logic;
    FLAG0       : out   std_logic;
    FLAG1       : in    std_logic;
    FLAG2       : out   std_logic;
    FLAG4       : out   std_logic;
    -- FPGA Master SPI interface
    SPISSM      : in    std_logic;
    SPISCLKM    : in    std_logic;
    SPIMOSIM    : in    std_logic;
    SPIMISOM    : out   std_logic;
    BOOTHOLDOFF : out   std_logic;
    -- FPGA Slave SPI interface
    SPISSS      : out   std_logic;
    SPISCLKS    : out   std_logic;
    SPIMOSIS    : out   std_logic;
    SPIMISOS    : in    std_logic;
    EVTFIFOFULL : in    std_logic
    );
end dspiomux;

architecture Behavioral of dspiomux is
  -- PSEL = '1' means EPROC is in control, normally for booting

begin  -- Behavioral
  SPISCLK  <= SPISCLKM when PSEL = '1' else 'Z';
  SPISCLKS <= SPISCLK  when PSEL = '0' else '0';

  SPIMOSI  <= SPIMOSIM when PSEL = '1' else 'Z';
  SPIMOSIS <= SPIMOSI  when PSEL = '0' else '0';

  SPIMISO  <= SPIMISOS when PSEL = '0' else 'Z';
  SPIMISOM <= SPIMISO  when PSEL = '1' else '0';

  FLAG0       <= SPISSM when PSEL = '1' else EVTFIFOFULL;
  BOOTHOLDOFF <= FLAG1;
  SPISSS      <= FLAG1  when PSEL = '0' else '1';

  FLAG2 <= '0';
  FLAG4 <= '0'; 

end Behavioral;
