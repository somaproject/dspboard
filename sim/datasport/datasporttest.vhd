library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity datasporttest is

end datasporttest;

architecture Behavioral of datasporttest is

  component datasport
    port (
      CLK    : in  std_logic;
      RESET  : in  std_logic;
      -- serial IO
      SERCLK : in  std_logic;
      SERDT  : in  std_logic;
      SERTFS : in  std_logic;
      FULL   : out std_logic;
      -- FiFO interface
      REQ    : out std_logic;
      GRANT  : in  std_logic;
      DOUT   : out std_logic_vector(7 downto 0);
      DONE   : out std_logic);
  end component;

  signal CLK    : std_logic := '0';
  signal RESET  : std_logic := '0';
  -- serial IO
  signal SERCLK : std_logic := '0';
  signal SERDT  : std_logic := '0';
  signal SERTFS : std_logic := '0';
  signal FULL   : std_logic := '0';

  -- FiFO interface
  signal REQ   : std_logic                    := '0';
  signal GRANT : std_logic                    := '0';
  signal DOUT  : std_logic_vector(7 downto 0) := (others => '0');

  signal DONE, donel : std_logic := '0';

  type databuffer_t is array (0 to 1023) of std_logic_vector(7 downto 0);
  signal databuffer : databuffer_t := (others => (others => '0'));


begin

  datasport_uut : datasport
    port map (
      CLK    => CLK,
      RESET  => RESET,
      SERCLK => SERCLK,
      SERDT  => SERDT,
      SERTFS => SERTFS,
      FULL   => FULL,
      REQ    => REQ,
      GRANT  => GRANT,
      DOUT   => DOUT,
      DONE => DONE);

  CLK   <= not CLK after 10 ns;
  RESET <= '0'     after 100 ns;

  process(CLK)
    variable bpos : integer range 0 to 2 := 0;
  begin
    if rising_edge(CLK) then
      if bpos = 2 then
        bpos                             := 0;
      else
        bpos                             := bpos + 1;
      end if;

      if bpos = 2 then
        SERCLK <= '1';
      else
        SERCLK <= '0';
      end if;
    end if;

  end process;
  process
    -- we need the BEswap variables because we must seend each byte
    -- LSB first, but we need to send the high-byte first
    variable tmpword, tmpwordBEswap : std_logic_vector(15 downto 0) := X"0000";
    variable pktlen, pktlenBEswap : std_logic_vector(15 downto 0) := X"0000";
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
      pktlen := std_logic_vector(TO_UNSIGNED(bufnum*20 + 172, 16 ));
      pktlenBEswap := pktlen(7 downto 0) & pktlen(15 downto 8); 
      for bpos in 0 to 15 loop
        SERDT <= pktlenBEswap(bpos);
        wait until falling_edge(SERCLK);
      end loop;  -- bpos

      -- then the body
      for bufpos in 0 to 510 loop
        tmpword := std_logic_vector(TO_UNSIGNED(bufnum * 256 + bufpos, 16));
        tmpwordBEswap := tmpword(7 downto 0) & tmpword(15 downto 8); 
        for bpos in 0 to 15 loop
          SERDT <= tmpwordBEswap(bpos);
          wait until falling_edge(SERCLK);
        end loop;
      end loop;

    end loop;  -- bufnum
  end process;


  process(clk)
    begin
      if rising_edge(clk) then
        donel <= done; 
      end if;

    end process;
    
  -- output read
  process
    variable bufpos : integer := 0;
    variable lenword, dataword : std_logic_vector(15 downto 0) := (others => '0');
  begin
    for bufnum in 0 to 19 loop

      wait until rising_edge(CLK) and REQ = '1';
      wait for 100 us;
      wait until rising_edge(CLK);
      GRANT <= '1';
      bufpos := 0;
      wait until rising_edge(CLK);

      GRANT                <= '0';
      wait until rising_edge(CLK);
      while donel /= '1' loop
        databuffer(bufpos) <= DOUT;
        wait until rising_edge(CLK);
        bufpos := bufpos + 1;
      end loop;

      -- validate packet

      assert bufpos = bufnum * 20 + 172 -1 report "Incorrect recovered pkt len" severity Error;

      for i in 0 to (bufpos-2)/2 loop
        dataword := databuffer(i*2 ) & databuffer(i*2+1 );
        assert dataword = std_logic_vector(TO_UNSIGNED(bufnum * 256 + i, 16))
          report "Error reading data word " & integer'image(i) severity Error;
                                           
      end loop;  -- i
      
      report "received packet";
    end loop;  -- bufnum
    report "End of Simulation" severity Failure;
    
  end process;
end Behavioral;
