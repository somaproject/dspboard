library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity uartbyteouttest is

end uartbyteouttest;

architecture Behavioral of uartbyteouttest is
  component uartbyteout
    port (
      CLK         : in  std_logic;      -- '0'
      DIN         : in  std_logic_vector(7 downto 0);
      SEND        : in  std_logic;
      DONE        : out std_logic;
      UARTTX      : out std_logic
      );
  end component;


  signal CLK   : std_logic := '0';
  signal RESET : std_logic := '1';
  signal DIN : std_logic_vector(7 downto 0) := (others => '0');
  signal uarttxsend, uarttxdone : std_logic := '0';
  signal dspuarttx : std_logic := '0';

  
  constant bitlen : time := 1.0 sec / 9600;
  signal recoveredbyte  : std_logic_vector(7 downto 0) := (others => '0');
  signal recovered : std_logic := '0';
begin

    uartbyteout_inst: uartbyteout
    port map (
      CLK    => CLK,
      DIN    => DIN, 
      SEND   => uarttxsend,
      DONE   => uarttxdone,
      UARTTX => DSPUARTTX); 


  uartrecover: process
  begin  -- process uartrecover
    wait until falling_edge(DSPUARTTX);
    for i in 0 to 7 loop
      wait for bitlen/2.0;
      wait for bitlen/2.0;
      recoveredbyte(i)  <= DSPUARTTX; 
    end loop;
    wait until rising_edge(CLK);
    recovered <= '1';
    wait until rising_edge(CLK);
    recovered <= '0';
    
    
  end process uartrecover;
  CLK   <= not CLK after 5 ns;
  RESET <= '0'     after 100 ns;

  process
  begin
    wait until falling_edge(RESET);
    wait until rising_edge(CLK);
    DIN <= X"85";
    uarttxsend <= '1';
    wait until rising_edge(CLK);
    DIN <= X"00";
    uarttxsend <= '0';
    wait until rising_edge(CLK) and uarttxdone = '1';
    assert recoveredbyte = X"85" report "Error recovering byte" severity Error;
    wait for 1 ms;
    
    wait until rising_edge(CLK);
    DIN <= X"AB";
    uarttxsend <= '1';
    wait until rising_edge(CLK);
    DIN <= X"00";
    uarttxsend <= '0';
    wait until rising_edge(CLK) and uarttxdone = '1';
    assert recoveredbyte = X"AB" report "Error recovering byte" severity Error;
    report "End of Simulation" severity Failure;
    end process; 

end Behavioral;
