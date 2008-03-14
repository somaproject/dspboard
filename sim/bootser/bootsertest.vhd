library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity bootsertest is

end bootsertest;


architecture Behavioral of bootsertest is
  component bootser
    port ( CLK   : in  std_logic;
           DIN   : in  std_logic_vector(15 downto 0);
           WE    : in  std_logic;
           START : in  std_logic;
           DONE  : out std_logic;
           MOSI  : out std_logic;
           HOLD  : in  std_logic;
           SCLK  : out std_logic
           );
  end component;

  signal CLK   : std_logic                     := '0';
  signal DIN   : std_logic_vector(15 downto 0) := (others => '0');
  signal WE    : std_logic                     := '0';
  signal START : std_logic                     := '0';
  signal DONE  : std_logic                     := '0';
  signal MOSI  : std_logic                     := '0';
  signal HOLD  : std_logic                     := '0';
  signal SCLK  : std_logic                     := '0';

begin  -- Behavioral

  CLK <= not CLK after 5 ns;

  bootser_uut : bootser
    port map (
      CLK   => CLK,
      DIN   => DIN,
      WE    => WE,
      START => START,
      DONE  => DONE,
      MOSI  => MOSI,
      HOLD  => HOLD,
      SCLK  => SCLK);


  process
    variable recoveredword : std_logic_vector(15 downto 0) := (others => '0');
  begin
    wait for 10 us;

    for i in 0 to 43 loop
      DIN <= X"AB" & std_logic_vector(TO_UNSIGNED(i, 8));
      WE  <= '1';
      wait until rising_edge(CLK);
    end loop;  -- i
    WE    <= '0';
    -- trigger the write
    wait until rising_edge(CLK);
    START <= '1';
    wait until rising_edge(CLK);
    START <= '0';
    wait until rising_edge(CLK);

    for i in 0 to 43 loop
      for bitpos in 7 downto 0 loop
        wait until rising_edge(SCLK);
        recoveredword(8 + bitpos) := MOSI;
      end loop;

      if i mod 17  = 3 then
        HOLD <= '1';
        wait for 10 us;
        HOLD <= '0'; 
      end if;
      
      for bitpos in 7 downto 0 loop
        wait until rising_edge(SCLK);
        recoveredword(bitpos) := MOSI;
      end loop;  

      if i mod 23  = 3 then
        HOLD <= '1';
        wait for 7 us;
        HOLD <= '0'; 
      end if;
      assert recoveredword = X"AB" & std_logic_vector(TO_UNSIGNED(i, 8))
        report "Error reading data" severity Error;
    end loop;  -- i

    wait until rising_edge(DONE);


    for i in 0 to 27 loop
      DIN <= X"CD" & std_logic_vector(TO_UNSIGNED(i, 8));
      WE  <= '1';
      wait until rising_edge(CLK);
    end loop;  -- i
    
    WE    <= '0';

    -- trigger the write
    wait until rising_edge(CLK);
    START <= '1';
    wait until rising_edge(CLK);
    START <= '0';
    wait until rising_edge(CLK);


    for i in 0 to 27 loop
      for bitpos in 7 downto 0 loop
        wait until rising_edge(SCLK);
        recoveredword(8 + bitpos) := MOSI;
      end loop;

      if i mod 17  = 3 then
        HOLD <= '1';
        wait for 10 us;
        HOLD <= '0'; 
      end if;
      
      for bitpos in 7 downto 0 loop
        wait until rising_edge(SCLK);
        recoveredword(bitpos) := MOSI;
      end loop;  

      if i mod 23  = 3 then
        HOLD <= '1';
        wait for 7 us;
        HOLD <= '0'; 
      end if;
      assert recoveredword = X"CD" & std_logic_vector(TO_UNSIGNED(i, 8))
        report "Error reading data" severity Error;
    end loop;  -- i

    wait until rising_edge(DONE);
    

    report "End of Simulation" severity Failure;
    
    wait;

  end process;

end Behavioral;
