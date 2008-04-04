library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity uartacqrxtest is

end uartacqrxtest;

architecture Behavioral of uartacqrxtest is

  component uartacqrx
    port (
      CLK        : in  std_logic;
      RESET      : in  std_logic;
      UARTRX     : in  std_logic;
      DATAOUT    : out std_logic_vector(47 downto 0);
      DATAOUTNEW : out std_logic);
  end component;


  signal CLK   : std_logic := '0';
  signal RESET : std_logic := '1';

  signal UARTRX     : std_logic                     := '1';
  signal DATAOUT    : std_logic_vector(47 downto 0) := (others => '0');
  signal DATAOUTNEW : std_logic                     := '0';

  signal outbyte      : std_logic_vector(7 downto 0) := (others => '0');
  signal sendbyte     : std_logic                    := '0';
  signal sendbytedone : std_logic                    := '0';

  constant bitlen : time := 1.0 sec / 9600;
begin

  CLK   <= not CLK after 10 ns;
  RESET <= '0'     after 100 ns;

  uartacqrx_uut : Uartacqrx
    port map (
      CLK        => CLK,
      RESET      => RESET,
      UARTRX     => UARTRX,
      DATAOUT    => DATAOUT,
      DATAOUTNEW => DATAOUTNEW);

  -- send test
  process
    variable outword : std_logic_vector(9 downto 0) := (others => '0');
  begin
    wait until falling_edge(CLK) and RESET = '0';
    while true loop

      wait until rising_edge(sendbyte);
      outword(0)          := '0';
      outword(8 downto 1) := outbyte;
      outword(9 )         := '1';

      for i in 0 to 9 loop
        UARTRX     <= outword(i);
        wait for bitlen;
      end loop;  -- i
      sendbytedone <= '1';
      wait until rising_edge(CLK);
      sendbytedone <= '0';

    end loop;
  end process;

  -- sending
  process
  begin
    wait until falling_edge(CLK) and RESET = '0';
    for txset in 0 to 9 loop

      for i in 0 to 5 loop
        outbyte <= std_logic_vector(TO_UNSIGNED(txset + i * 17+ 3, 8));

        wait until rising_edge(CLK);
        sendbyte <= '1';
        wait until rising_edge(CLK);
        sendbyte <= '0';

        wait until rising_edge(sendbytedone);


      end loop;  -- i

    end loop;  -- txset

  end process;

  validate : process
  begin
    for txset in 0 to 9 loop

      wait until rising_edge(CLK) and DATAOUTNEW = '1';

      for i in 0 to 5 loop
        assert TO_INTEGER(unsigned(dataout(i*8 + 7 downto i*8)))
           = txset + i *17 + 3 report "Error" severity error;
      end loop;  -- i
      report "Read dataout" severity note;

    end loop;
    report "End of Simulation" severity Failure;

  end process;
end Behavioral;
