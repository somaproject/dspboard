library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity evtendianrevtest is

end evtendianrevtest;

architecture Behavioral of evtendianrevtest is

  signal CLK : std_logic := '0';

  component evtendianrev
    port (
      CLK    : in  std_logic;
      DIN    : in  std_logic_vector(7 downto 0);
      DINEN  : in  std_logic;
      DOUT   : out std_logic_vector(7 downto 0);
      DOUTEN : out std_logic);
  end component;

  signal DIN    : std_logic_vector(7 downto 0) := (others => '0');
  signal DINEN  : std_logic                    := '0';
  signal DOUT   : std_logic_vector(7 downto 0) := (others => '0');
  signal DOUTEN : std_logic                    := '0';

  signal pos : integer range 0 to 999 := 990;
begin  -- Behavioral

  
  CLK <= not CLK after 10 ns;

  evtendianrev_uut: evtendianrev
    port map (
      CLK    => CLK,
      DIN    => DIN,
      DINEN  => DINEN,
      DOUT   => DOUT,
      DOUTEN => DOUTEN); 
    

  process(CLK)
    begin
      if rising_edge(CLK) then
        if pos = 999 then
          pos <= 0;
        else
          pos <= pos + 1; 
        end if;

        if pos = 999 then
          DINEN <= '1';
          DIN <= X"00"; 
        else
          DINEN <= '0';
          DIN <= std_logic_vector(TO_UNSIGNED(pos+1 mod 256, 8)); 
        end if;
        
      end if;
      
    end process;

 processverify : process
   begin
     wait until rising_edge(CLK) and DOUTEN = '1';
     for i in 0 to 499 loop
       assert DOUT = std_logic_vector(TO_UNSIGNED((i*2 + 1 )mod 256, 8))
          report "Error in high byte" severity Error;
       wait until rising_edge(CLK);

       assert DOUT = std_logic_vector(TO_UNSIGNED((i*2) mod 256, 8))
          report "Error in low byte" severity Error;
       wait until rising_edge(CLK);
     end loop;  -- i

     report "End of Simulation" severity Failure;

   end process processverify; 
    
end Behavioral;
