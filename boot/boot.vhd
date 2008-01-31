library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity boot is
  port (
    CLK    : in  std_logic;
    SERDIN : in std_logic;
    FPROG : out std_logic;
    FCLK : out std_logic;
    FDIN : out std_logic
    );
end boot;


architecture Behavioral of boot is

  
begin  -- Behavioral 
  
  deserialize_inst: entity work.bootdeserialize
    port map (
      CLK   => CLK,
      SERIN => SERDIN,
      FPROG => FPROG,
      FCLK  => FCLK,
      FDIN  => FDIN); 

end Behavioral ;

