library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity regfilesingle is
  generic (
    BITS : integer := 16); 
  port (
    CLK   : in std_logic;
    DI   : in std_logic_vector(BITS-1 downto 0);
    DO : out std_logic_vector(BITS -1 downto 0); 
    ADDR : in std_logic_vector(3 downto 0);
    WE: in std_logic
    );
end regfilesingle;

architecture Behavioral of regfilesingle is

begin  -- Behavioral

  regs: for i in 0 to BITS-1 generate
    ramb : RAM16X1S port map (
      O   => DO(i),
      A0    => ADDR(0),
      A1    => ADDR(1),
      A2    => ADDR(2),
      A3    => ADDR(3),
      D     => DI(i),
      WCLK => CLK,
      WE => WE); 
  end generate regs;

end Behavioral;
