library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity eventrxtest is

end eventrxtest;

architecture Behavioral of eventrxtest is

  component eventrx
    port (
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      SCLK     : in  std_logic;
      MOSI     : in  std_logic;
      SCS      : in  std_logic;
      FIFOFULL : out std_logic;
      DOUTEN : in std_logic; 
      DOUT     : out std_logic_vector(7 downto 0);
      REQ      : out  std_logic;
      GRANT    : in  std_logic);
  end component;

  signal CLK      : std_logic                    := '0';
  signal RESET    : std_logic                    := '0';
  signal SCLK     : std_logic                    := '0';
  signal MOSI     : std_logic                    := '0';
  signal SCS      : std_logic                    := '0';
  signal FIFOFULL : std_logic                    := '0';
  signal DOUT     : std_logic_vector(7 downto 0) := (others => '0');
  signal DOUTEN : std_logic := '0';
  
  signal REQ   : std_logic := '0';
  signal GRANT : std_logic := '0';


  type dataword_t is array (0 to 10) of std_logic_vector(15 downto 0 );

  signal txwords, txwordsa, txwordsb   : dataword_t := (others => (others => '0'));
  signal sendevent : std_logic  := '0';
  signal sendeventdone : std_logic  := '0';

  signal recoverdwords : dataword_t := (others => (others => '0'));

begin  -- Behavioral


  CLK <= not CLK after 10 ns;

  eventrx_uut : eventrx
    port map (
      CLK      => CLK,
      RESET    => RESET,
      SCLK     => SCLK,
      MOSI     => MOSI,
      SCS      => SCS,
      FIFOFULL => FIFOFULL,
      DOUT     => DOUT,
      DOUTEN => DOUTEN, 
      REQ      => REQ,
      GRANT    => GRANT);

  process(CLK)
    begin
      if rising_edge(CLK) then
        DOUTEN <= not DOUTEN; 
      end if;
    end process; 

  writedata : process
  begin
    while true loop
      SCS      <= '1';
      wait until rising_edge(sendevent);
      for word in 0 to 10 loop
        SCS    <= '1';
        wait for 500 ns;
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        SCS    <= '0';
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        for i in 15 downto 0 loop
          SCLK <= '1';
          MOSI <= txwords(word)(i);
          wait until rising_edge(CLK);
          wait until rising_edge(CLK);
          wait until rising_edge(CLK);
          SCLK <= '0';
          MOSI <= txwords(word)(i);
          wait until rising_edge(CLK);
          wait until rising_edge(CLK);
          wait until rising_edge(CLK);
        end loop;  -- i
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        SCS    <= '1';
        wait until rising_edge(CLK);
      end loop;  -- word
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      
      sendeventdone <= '1';
      wait until rising_edge(CLK);
      sendeventdone <= '0';

      
    end loop;
  end process writedata;


  main: process
    variable recoveredword : std_logic_vector(15 downto 0) := (others => '0');
    
    begin
      ---------------------------------------------------------------------
      -- Transmit first event
      --------------------------------------------------------------------
      wait for 10 us;
      for i in 0 to 10 loop
        txwords(i) <= X"AB" & std_logic_vector(TO_UNSIGNED(i,8));
      end loop;  -- i      
      wait until rising_edge(CLK);
      sendevent <= '1'; 
      wait until rising_edge(CLK);
      sendevent <= '0'; 

      wait until rising_edge(REQ);
      wait until rising_edge(sendeventdone); 
      GRANT <= '0'; 
      wait until rising_edge(CLK);
      GRANT <= '1' ;
      wait until rising_edge(CLK);
      GRANT <= '0'; 
      
      for i in 0 to 10 loop
        wait until rising_edge(CLK) and DOUTEN = '1';
        recoveredword(15 downto 8) := DOUT;
        wait until rising_edge(CLK) and DOUTEN = '1';
        recoveredword(7 downto 0) := DOUT;
        recoverdwords(i) <= recoveredword;
      end loop;  -- i

      -- check
      wait until rising_edge(CLK);
      
      for i in 0 to 10 loop
        assert recoverdwords(i) = txwords(i)
          report "Error reading recoverdwords " & integer'image(i) severity Error;
      end loop;  -- i
      
      ---------------------------------------------------------------------
      -- Transmit two events, check fifo
      --------------------------------------------------------------------
      wait for 10 us;
      for i in 0 to 10 loop
        txwordsA(i) <= X"12" & std_logic_vector(TO_UNSIGNED(i,8));
        txwordsB(i) <= X"34" & std_logic_vector(TO_UNSIGNED(i,8));
      end loop;  -- i
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);      
      txwords <= txwordsA; 
      wait until rising_edge(CLK);
      sendevent <= '1'; 
      wait until rising_edge(CLK);
      sendevent <= '0'; 
      wait until rising_edge(sendeventdone); 
      
      txwords <= txwordsB; 
      wait until rising_edge(CLK);
      sendevent <= '1'; 
      wait until rising_edge(CLK);
      sendevent <= '0'; 
      wait until rising_edge(sendeventdone); 
      assert FIFOFULL = '1' report "Fifofull not asserted" severity Error;
      -- first read
      wait until rising_edge(CLK) and REQ = '1'; 
      wait for 1 us;
      GRANT <= '0' ;
      wait until rising_edge(CLK);
      GRANT <= '1' ;
      wait until rising_edge(CLK);
      
      for i in 0 to 10 loop
        wait until rising_edge(CLK)  and DOUTEN = '1';
        recoveredword(15 downto 8) := DOUT;
        GRANT <= '0'; 
        wait until rising_edge(CLK)  and DOUTEN = '1';
        recoveredword(7 downto 0) := DOUT;
        recoverdwords(i) <= recoveredword;
      end loop;  -- i

      -- check
      wait until rising_edge(CLK);
      
      for i in 0 to 10 loop
        assert recoverdwords(i) = txwordsA(i)
          report "Error reading recoverdwords for txwordsA " & integer'image(i) severity Error;
      end loop;  -- i
      

      -- second read
      wait until rising_edge(CLK) and REQ = '1'; 

      wait for 1 us;
      GRANT <= '0'; 
      wait until rising_edge(CLK) and DOUTEN = '1';
      GRANT <= '1' ;
      wait until rising_edge(CLK) and DOUTEN = '1';
      GRANT <= '0';
      
      for i in 0 to 10 loop
        wait until rising_edge(CLK)  and DOUTEN = '1';
        recoveredword(15 downto 8) := DOUT;
        GRANT <= '0'; 
        wait until rising_edge(CLK)  and DOUTEN = '1';
        recoveredword(7 downto 0) := DOUT;
        recoverdwords(i) <= recoveredword;
      end loop;  -- i

      -- check
      wait until rising_edge(CLK);
      
      for i in 0 to 10 loop
        assert recoverdwords(i) = txwords(i)
          report "Error reading recoverdwords for txwordsB " & integer'image(i) severity Error;
      end loop;  -- i

      report "End of Simulation" severity Failure;
      
      wait; 
    end process;
    

end Behavioral;
