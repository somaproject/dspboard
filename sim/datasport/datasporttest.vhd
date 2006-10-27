library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

entity datasporttest is

end datasporttest;

architecture Behavioral of datasporttest is

  component datasport
    port (
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      -- serial IO
      SDIN     : in  std_logic;
      STFS     : in  std_logic;
      SCLK     : in  std_logic;
      -- FiFO interface
      VALID    : out std_logic;
      DOUT     : out std_logic_vector(7 downto 0);
      ADDRIN   : in  std_logic_vector(9 downto 0);
      FIFONEXT : in  std_logic);
  end component;

  signal CLK      : std_logic                    := '0';
  signal RESET    : std_logic                    := '1';
  -- serial IO
  signal SDIN     : std_logic                    := '0';
  signal STFS     : std_logic                    := '0';
  signal SCLK     : std_logic                    := '0';
  -- FiFO interface
  signal VALID    : std_logic                    := '0';
  signal DOUT     : std_logic_vector(7 downto 0) := (others => '0');
  signal ADDRIN   : std_logic_vector(9 downto 0) := (others => '0');
  signal FIFONEXT : std_logic                    := '0';


  signal doutbyte : std_logic_vector(7 downto 0) := (others => '0');


begin

  CLK   <= not CLK after 10 ns;
  RESET <= '0'     after 100 ns;

  datasport_uut : datasport
    port map (
      CLK      => CLK,
      RESET    => RESET,
      SDIN     => SDIN,
      STFS     => STFS,
      SCLK     => SCLK,
      VALID    => VALID,
      DOUT     => DOUT,
      ADDRIN   => ADDRIN,
      FIFONEXT => FIFONEXT);

  -- input
  process
  begin

    wait for 1 us;
    wait until rising_edge(CLK);
    SCLK <= '0';
    STFS <= '0';

    wait until rising_edge(CLK);
    SCLK <= '1';
    STFS <= '0';

    wait until rising_edge(CLK);
    SCLK <= '0';
    STFS <= '1';

    wait until rising_edge(CLK);
    SCLK     <= '1';
    STFS     <= '1';
    for i in 0 to 599 loop
      for j in 0 to 7 loop
        wait until rising_edge(CLK);
        SCLK <= '0';
        STFS <= '0';
        SDIN <= doutbyte(j);

        wait until rising_edge(CLK);
        SCLK   <= '1';
      end loop;  -- j
      doutbyte <= doutbyte +1;

    end loop;  -- i

    wait for 1 us;

    wait until rising_edge(CLK) and VALID = '1';
    -- attempt readout
    addrin <= (others => '0');
    for i in 0 to 599 loop
      wait until rising_edge(CLK);
      wait for 1 ns;

      assert DOUT = addrin(7 downto 0)
        report "Error in byte read-back" severity error;
      wait for 3 ns;

      addrin <= addrin + 1;

    end loop;  -- i
    -- be done with the fifo
    wait until rising_edge(CLK);
    FIFONEXT <= '1';
    wait until rising_edge(CLK);
    FIFONEXT <= '0';
    

    -----------------------------------------------------------------------
    -- 3 buffer write
    -----------------------------------------------------------------------
    doutbyte <= (others => '0');

    for k in 0 to 2 loop


      wait for 1 us;
      wait until rising_edge(CLK);
      SCLK <= '0';
      STFS <= '0';

      wait until rising_edge(CLK);
      SCLK <= '1';
      STFS <= '0';

      wait until rising_edge(CLK);
      SCLK <= '0';
      STFS <= '1';

      wait until rising_edge(CLK);
      SCLK                 <= '1';
      STFS                 <= '1';
      doutbyte(5 downto 0) <= (others => '0');
      doutbyte(7 downto 6) <= doutbyte(7 downto 6) + 1;

      for i in 0 to 800 loop
        for j in 0 to 7 loop
          wait until rising_edge(CLK);
          SCLK <= '0';
          STFS <= '0';
          SDIN <= doutbyte(j);

          wait until rising_edge(CLK);
          SCLK               <= '1';
        end loop;  -- j
        doutbyte(5 downto 0) <= doutbyte(5 downto 0) +1;

      end loop;  -- i

      wait for 1 us;
    end loop;  -- k

    -------------------------------------------------------------------------
    --  3 packet read-out
    -------------------------------------------------------------------------
    doutbyte <= X"01";


    for k in 0 to 2 loop

      wait until rising_edge(CLK) and VALID = '1';
      -- attempt readout
      addrin <= (others => '0');
      for i in 0 to 599 loop
        wait until rising_edge(CLK);
        wait for 1 ns;

        assert DOUT(5 downto 0) = addrin(5 downto 0)
        report "Error in low-bits byte read-back" severity error;
        
        assert DOUT(7 downto 6) = doutbyte(1 downto 0)
        report "Error in high-bits byte read-back" severity error;

        wait for 3 ns;

        addrin <= addrin + 1;

      
      end loop;  -- i
      doutbyte <= doutbyte +1;
      wait until rising_edge(CLK);
      FIFONEXT <= '1';
      wait until rising_edge(CLK);
      FIFONEXT <= '0';
      
    end loop;  -- k

    report "End of Simulation" severity Failure;
    
      
  end process;


end Behavioral;
