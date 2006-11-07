
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity eventfilter is
  port (
    CLK    : in  std_logic;
    ESEL   : in  std_logic_vector(9 downto 0);
    DIN    : in  std_logic_vector(7 downto 0);
    ESTART : in  std_logic;
    DEN    : out std_logic
    );
end eventfilter;

architecture Behavioral of eventfilter is

  -- input


  signal errl : std_logic := '0';

  signal eventen : std_logic_vector(79 downto 0) := (others => '0');

  signal ecnt : integer range 0 to 79 := 0;

  signal epos : std_logic_vector(9 downto 0) := (others => '0');

  signal bpos : std_logic_vector(3 downto 0) := (others => '0');

  signal bposrst      : std_logic := '0';
  signal forcebposrst : std_logic := '0';

  type states is (none, selwait, eventl, startw,
                  filterst, filterw, filterd);

  signal cs, ns : states := none;


begin  -- Behavioral

  bposrst <= '1' when (forcebposrst = '1' or bpos = "1011") else '0';

  main : process(CLK)
  begin
    if rising_edge(CLK) then

      cs <= ns;


      if ESTART = '1' then
        epos <= "0000000001";
      else
        epos <= epos + 1;
      end if;


      if bposrst = '1' then
        bpos   <= (others => '0');
      else
        if bpos = "1011" then
          bpos <= (others => '0');
        else
          bpos <= bpos + 1;
        end if;
      end if;

      -- latch enable bits
      if cs = eventl then
        if bpos = "0000" then
          eventen(7 downto 0) <= din;
        end if;

        if bpos = "0001" then
          eventen(15 downto 8) <= din;
        end if;

        if bpos = "0010" then
          eventen(23 downto 16) <= din;
        end if;

        if bpos = "0011" then
          eventen(31 downto 24) <= din;
        end if;

        if bpos = "0100" then
          eventen(39 downto 32) <= din;
        end if;

        if bpos = "0101" then
          eventen(47 downto 40) <= din;
        end if;

        if bpos = "0110" then
          eventen(55 downto 48) <= din;
        end if;

        if bpos = "0111" then
          eventen(63 downto 56) <= din;
        end if;

        if bpos = "1000" then
          eventen(71 downto 64) <= din;
        end if;

        if bpos = "1001" then
          eventen(79 downto 72) <= din;
        end if;
      end if;

      if eventen(ecnt) = '1' and cs = filterst then
        DEN <= '1';
      else
        DEN <= '0';
      end if;


      if cs = filterd then
        if ecnt = 77 then
          ecnt <= 0;
        else
          ecnt <= ecnt + 1;
        end if;
      end if;


    end if;
  end process main;

  fsm : process(cs, estart, epos, esel, bpos, epos, ecnt)
  begin
    case cs is
      when none =>
        forcebposrst <= '1';
        if estart = '1' then
          ns         <= selwait;
        else
          ns <= none; 
        end if;

      when selwait =>
        forcebposrst <= '1';
        if epos = esel then
          ns         <= eventl;
        else
          ns         <= selwait;
        end if;

      when eventl =>
        forcebposrst <= '0';
        if bpos = 9 then
          ns         <= startw;
        else
          ns         <= eventl;
        end if;

      when startw =>
        forcebposrst <= '1';
        if epos = "0000101111" then
          ns         <= filterst;
        else
          ns         <= startw;
        end if;

      when filterst =>
        forcebposrst <= '0';
        ns           <= filterw;

      when filterw =>
        forcebposrst <= '0';
        if bpos = X"A" then
          ns         <= filterd;
        else
          ns         <= filterw;
        end if;

      when filterd =>
        forcebposrst <= '0'; 
        if ecnt = 77 then
          ns         <= none;
        else
          ns         <= filterst;
        end if;
      when others  =>
        forcebposrst <= '1';
        ns           <= none;
    end case;
  end process fsm;

end Behavioral;
