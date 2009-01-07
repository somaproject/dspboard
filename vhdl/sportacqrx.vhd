library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity sportacqrx is
  port (
    CLK        : in  std_logic;
    SERCLK     : in  std_logic;
    SERDR      : in  std_logic;
    SERRFS     : in  std_logic;
    DATAOUT    : out std_logic_vector(63 downto 0);
    DATAOUTNEW : out std_logic);
end sportacqrx;


architecture Behavioral of sportacqrx is

  signal dinreg            : std_logic_vector(63 downto 0) := (others => '0');
  signal pos               : integer range 0 to 127        := 65;
  signal serclkl, serclkll : std_logic                     := '0';



begin  -- Behavioral

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      serclkl  <= SERCLK;
      serclkll <= serclkl; 

      if SERCLKLL = '1' then
        if SERRFS = '1' then
          pos   <= 0;
        else
          if pos < 65 then
            pos <= pos + 1;
          end if;
        end if;

        dinreg <= SERDR & dinreg(63 downto 1);

      end if;

      if SERCLKLL = '1' and pos = 64 then
        DATAOUT    <= dinreg;
        DATAOUTNEW <= '1';
      else
        DATAOUTNEW <= '0';
      end if;
    end if;
  end process;


end Behavioral;
