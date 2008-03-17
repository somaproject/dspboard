library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity fakesport is
  port (
    CLK    : in  std_logic;
    RESET  : in  std_logic;
    -- serial IO
    SERCLK : in  std_logic;
    SERDT  : out  std_logic;
    SERTFS : out  std_logic;
    FULL   : in std_logic);
end fakesport;

architecture Behavioral of fakesport is


  signal DOUT  : std_logic_vector(7 downto 0) := (others => '0');

  signal DONE, donel : std_logic := '0';

  type databuffer_t is array (0 to 1023) of std_logic_vector(7 downto 0);
  signal databuffer : databuffer_t := (others => (others => '0'));


begin


  process
    -- we need the BEswap variables because we must seend each byte
    -- LSB first, but we need to send the high-byte first
    variable tmpword, tmpwordBEswap : std_logic_vector(15 downto 0) := X"0000";
    variable pktlen, pktlenBEswap   : std_logic_vector(15 downto 0) := X"0000";
  begin
    wait for 10 us;

    for bufnum in 0 to 19 loop
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK) and FULL = '0';
      wait until falling_edge(SERCLK);
      SERTFS <= '1';
      wait until falling_edge(SERCLK);
      SERTFS <= '0';

      -- send the length
      pktlen       := std_logic_vector(TO_UNSIGNED(bufnum*20 + 172, 16 ));
      pktlenBEswap := pktlen(7 downto 0) & pktlen(15 downto 8);
      for bpos in 0 to 15 loop
        SERDT <= pktlenBEswap(bpos);
        wait until falling_edge(SERCLK);
      end loop;  -- bpos

      -- then the body
      for bufpos in 0 to 510 loop
        tmpword       := std_logic_vector(TO_UNSIGNED(bufnum * 256 + bufpos, 16));
        tmpwordBEswap := tmpword(7 downto 0) & tmpword(15 downto 8);
        for bpos in 0 to 15 loop
          SERDT <= tmpwordBEswap(bpos);
          wait until falling_edge(SERCLK);
        end loop;
      end loop;

    end loop;  -- bufnum
  end process;



end Behavioral;
