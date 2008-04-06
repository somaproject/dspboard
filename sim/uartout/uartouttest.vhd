library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity uartouttest is

end uartouttest;

architecture Behavioral of uartouttest is
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
begin

    uartbyteout_inst: uartbyteout
    port map (
      CLK    => CLK,
      DIN    => DIN, 
      SEND   => uarttxsend,
      DONE   => uarttxdone,
      UARTTX => DSPUARTTX); 


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
    wait for 3 ms;
    
    wait until rising_edge(CLK);
    DIN <= X"AB";
    uarttxsend <= '1';
    wait until rising_edge(CLK);
    DIN <= X"00";
    uarttxsend <= '0';
    
    end process; 

end Behavioral;
