
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity eventin is
  port (
    CLK  : in std_logic;
    ESEL : in std_logic_vector(9 downto 0);
    DIN : in std_logic_vector(7 downto 0);
    KIN : in std_logic;
    ERRIN : in std_logic;
    DEN: out std_logic
    );
end eventin;

architecture Behavioral of eventin is

  -- input
  signal esell : std_logic_vector(9 downto 0) := (others => '0');
  signal dinl : std_logic_vector(7 downto 0) := (others => '0');
  signal kinl : std_logic := '0';

  signal errl : std_logic := '0';

  signal eventen : std_logic_vector(79 downto 0) := (others => '0');

  signal ecnt : integer range 0 to 79;

  signal epos : std_logic_vector(9 downto 0) := (others => '0');
  signal bpos : std_logic_vector(3 downto 0) := (others => '0');

  signal bposrst : std_logic := '0';

  type states is (none, selwait, eventl, startw, loadbits);
  
  signal cs, ns : states := none;

  
begin  -- Behavioral

  main: process(CLK)
    begin
      if rising_edge(CLK) then

        cs <= ns;

        
        esell <= ESEL;
        dinl <= DIN;
        kinl <= KIN;

        errl <= ERRIN;


        if estart = '1' then
          epos <= (others => '0');
        else
          epos <= epos + 1; 
        end if;
        

        if bposrst = '1' then
          bpos <= (others => '0');
        else
          if bpos = "1011" then
            bpos <= (others => '0'); 
          end if;       
        end if; 

        -- latch enable bits
        if cs = loadbits then
          if bpos = "0000" then
            eventen(7 downto 0) <= dinl;
          end if;

          if bpos = "0001" then
            eventen(15 downto 8) <= dinl;
          end if;

          if bpos = "0010" then
            eventen(23 downto 16) <= dinl;
          end if;

          if bpos = "0011" then
            eventen(31 downto 24) <= dinl;
          end if;

          if bpos = "0100" then
            eventen(39 downto 32) <= dinl;
          end if;

          if bpos = "0101" then
            eventen(47 downto 40) <= dinl;
          end if;

          if bpos = "0110" then
            eventen(55 downto 48) <= dinl;
          end if;

          if bpos = "0111" then
            eventen(63 downto 56) <= dinl;
          end if;

          if bpos = "1000" then
            eventen(71 downto 63) <= dinl;
          end if;

          if bpos = "1001" then
            eventen(79 downto 72) <= dinl;
          end if;

          DEN <= eventen(ecnt);
          
        end if;
      end if;
    end process main ;

  type states is (none, selwait, eventl, startw, loadbits);
  
  signal cs, ns : states := none;


  fsm: process(cs, estart, epos, ssel, bpos, epos)
    begin
      case cs is
        when none =>
          forcebposrst <= '1';
          if estart = '1' then
            ns <= selwait; 
          end if;

        when selwait =>
          forcebposrst <= '1';
          if epos then
            sss
          end if;
        when others => null;
      end case;
    end process fsm; 
end Behavioral;
