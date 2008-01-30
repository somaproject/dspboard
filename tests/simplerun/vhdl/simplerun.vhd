library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity simplerun is
  port (
    SYSCLKIN  : in  std_logic;
    DSPCLKOUT : out std_logic;
    DSPRESET  : out std_logic;
    LEDPOWER  : out std_logic;
    LEDEVENTA : out std_logic;
    LEDEVENTB : out std_logic;
    LEDEVENTC : out std_logic;
    LEDEVENTD : out std_logic
    );
end simplerun;


architecture Behavioral of simplerun is

  signal clk        : std_logic                     := '0';
  signal dspcntdown : std_logic_vector(24 downto 0) := (others => '1');
  signal cnt        : std_logic_vector(23 downto 0) := (others => '0');
  signal ldspreset  : std_logic                     := '0';


begin  -- Behavioral

  clk       <= SYSCLKIN;
  DSPCLKOUT <= clk;

  main : process(clk)
  begin
    if rising_edge(clk) then

      DSPRESET <= ldspreset;

      if dspcntdown /= "0000000000000000000000000" then
        dspcntdown <= dspcntdown - 1;
      else
        ldspreset  <= '1';
      end if;

      cnt <= cnt + 1;

      LEDPOWER <= cnt(21);
      
      if cnt(23 downto 22) = "00" then
        LEDEVENTA <= '1';
      else
        LEDEVENTA <= '0';
      end if;

      if cnt(23 downto 22) = "01" then
        LEDEVENTB <= '1';
      else
        LEDEVENTB <= '0';
      end if;

      if cnt(23 downto 22) = "10" then
        LEDEVENTC <= '1';
      else
        LEDEVENTC <= '0';
      end if;

      if cnt(23 downto 22) = "11" then
        LEDEVENTD <= '1';
      else
        LEDEVENTD <= '0';
      end if;

    end if;
  end process main;


end Behavioral;
