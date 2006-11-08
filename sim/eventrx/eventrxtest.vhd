library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
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
      SCLK     : in  std_logic;
      SDIN     : in  std_logic;
      SCS      : in  std_logic;
      DOUT     : out std_logic_vector(7 downto 0);
      ADDROUT  : in  std_logic_vector(4 downto 0);
      NEXTFIFO : in  std_logic;
      VALID    : out std_logic);
  end component;


  signal CLK      : std_logic                    := '0';
  signal SCLK     : std_logic                    := '0';
  signal SDIN     : std_logic                    := '0';
  signal SCS      : std_logic                    := '0';
  signal DOUT     : std_logic_vector(7 downto 0) := (others => '0');
  signal ADDROUT  : std_logic_vector(4 downto 0) := (others => '0');
  signal NEXTFIFO : std_logic                    := '0';
  signal VALID    : std_logic                    := '0';


  signal dataword : std_logic_vector(15 downto 0) := (others => '0');
  signal sendword : std_logic                     := '0';

  signal expected  : std_logic_Vector(7 downto 0) := (others => '0');

  
begin  -- Behavioral


  CLK <= not CLK after 10 ns;

  eventrx_uut : eventrx
    port map (
      CLK      => CLK,
      SCLK     => SCLK,
      SDIN     => SDIN,
      SCS      => SCS,
      DOUT     => DOUT,
      ADDROUT  => ADDROUT,
      NEXTFIFO => NEXTFIFO,
      VALID    => VALID);

  writedata : process
  begin
    while true loop
      SCS    <= '1';
      wait until rising_edge(CLK) and sendword = '1';
      SCS    <= '0';
      wait until rising_edge(CLK);
      for i in 15 downto 0 loop
        SCLK <= '0';
        SDIN <= dataword(i);
        wait until rising_edge(CLK);
        SCLK <= '1';
        SDIN <= dataword(i);
        wait until rising_edge(CLK);
      end loop;  -- i
      wait until rising_edge(CLK);
      SCS    <= '1';
      wait until rising_edge(CLK);
    end loop;
  end process writedata;

  main : process
  begin
    for j in 0 to 7 loop


      wait for 10 us;
      wait until rising_edge(CLK);
      -- send word
      for i in 0 to 21 loop
        wait until rising_edge(CLK);
        dataword <= std_logic_vector(TO_UNSIGNED(i, 8))
                    & std_logic_vector(TO_UNSIGNED(j, 3))
                    & std_logic_vector(TO_UNSIGNED(i, 5));
        sendword <= '1';
        wait until rising_edge(CLK);
        sendword <= '0';
        wait until rising_edge(CLK);
        wait until rising_edge(SCS);

      end loop;  -- i

      wait until rising_edge(CLK);
      dataword <= X"8000";
      sendword <= '1';
      wait until rising_edge(CLK);
      sendword <= '0';

    end loop;  -- j

  end process main;


  -- readout
  validate : process
  begin
    for j in 0 to 7 loop

      wait until rising_edge(CLK) and VALID = '1';
      for i in 0 to 21 loop
        ADDROUT <= std_logic_vector(TO_UNSIGNED(i, 5));
        wait until rising_edge(CLK);
        wait for 1 ns;
        
        expected <= 
          (std_logic_vector(TO_UNSIGNED(j, 3)) &
           std_logic_vector(TO_UNSIGNED(i, 5)));
        wait for 2 ns;
        assert expected = dout report "Error reading byte" severity Error;
      end loop;  -- i
      wait until rising_edge(CLK) and VALID = '1';
      NExTFIFO <= '1' ;
      wait until rising_edge(CLK);
      NEXTFIFO <= '0'; 
      
    end loop;  -- j

    report "End of Simulation" severity Failure;
    

  end process validate; 

end Behavioral;
