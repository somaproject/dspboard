library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;
use ieee.numeric_std.all;



library UNISIM;
use UNISIM.VComponents.all;

entity eventtxtesttest is
end eventtxtesttest;

architecture Behavioral of eventtxtesttest is

  component eventtxtest
    port (
      REFCLKIN  : in  std_logic;
      DSPCLKOUT : out std_logic;
      DSPRESET  : out std_logic;
      LEDPOWER  : out std_logic;
      DIN       : in  std_logic_vector(7 downto 0);
      KIN       : in  std_logic;
      INTGEN    : in  std_logic;
      ERRIN     : in  std_logic;
      EVENTENA  : out std_logic;
      EVENTENB  : out std_logic;
      EVENTENC  : out std_logic;
      EVENTEND  : out std_logic;
      EVENTTXD  : out std_logic_vector(7 downto 0)
      );
  end component;

  signal REFCLKIN  : std_logic                    := '0';
  signal DSPCLKOUT : std_logic                    := '0';
  signal DSPRESET  : std_logic                    := '0';
  signal LEDPOWER  : std_logic                    := '0';
  signal DIN       : std_logic_vector(7 downto 0) := (others => '0');
  signal KIN       : std_logic                    := '0';
  signal INTGEN    : std_logic                    := '1';
  signal ERRIN     : std_logic                    := '0';
  signal EVENTENA  : std_logic                    := '0';
  signal EVENTENB  : std_logic                    := '0';
  signal EVENTENC  : std_logic                    := '0';
  signal EVENTEND  : std_logic                    := '0';
  signal EVENTTXD  : std_logic_vector(7 downto 0) := (others => '0');

  signal clk : std_logic := '0';
  
  signal epos : integer range 0 to 999 := 999;

  signal AEN, BEN, CEN, DEN : std_logic_vector(79 downto 0) := (others => '0');
  signal ecycle             : std_logic                     := '0';

  type rxevents_t is array(0 to 79) of integer;

  signal rxdeventsA    : rxevents_t := (others => 0);
  signal rxdeventsAcnt : integer    := 0;
  
  signal rxdeventsB    : rxevents_t := (others => 0);
  signal rxdeventsBcnt : integer    := 0;
  
  signal rxdeventsC    : rxevents_t := (others => 0);
  signal rxdeventsCcnt : integer    := 0;
  
  signal rxdeventsD    : rxevents_t := (others => 0);
  signal rxdeventsDcnt : integer    := 0;
  
begin  -- Behavioral

  INTGEN <= '1'; 
  REFCLKIN <= not REFCLKIN after 10 ns;

  eventtxtest_uut: eventtxtest
    port map (
      REFCLKIN  => REFCLKIN,
      DSPCLKOUT => DSPCLKOUT,
      DSPRESET  => DSPRESET,
      LEDPOWER  => LEDPOWER,
      DIN       => DIN,
      KIN       => KIN,
      INTGEN    => INTGEN,
      ERRIN     => ERRIN,
      EVENTENA  => EVENTENA,
      EVENTENB  => EVENTENB,
      EVENTENC  => EVENTENC,
      EVENTEND  => EVENTEND,
      EVENTTXD  => EVENTTXD);
  

  eventgen : process(CLK, epos)
  begin
    if rising_edge(CLK) then
      if epos = 999 then
        epos <= 0;
      else
        epos <= epos + 1;
      end if;
    end if;

    if epos = 0 then
      ecycle <= '1';
      kin    <= '1';
    else
      ecycle <= '0';
      kin    <= '0';
    end if;

    if epos = 0 then
      DIN <= X"BC";
    elsif epos > 1 and epos < 12 then
      DIN <= AEN(8*(epos -1) - 1 downto 8*(epos -2));
    elsif epos > 12 and epos < 23 then
      DIN <= BEN(8*(epos -12) - 1 downto 8*(epos -13));
    elsif epos > 23 and epos < 34 then
      DIN <= CEN(8*(epos -23) - 1 downto 8*(epos -24));
    elsif epos > 34 and epos < 45 then
      DIN <= DEN(8*(epos -34) - 1 downto 8*(epos -35));
    elsif epos > 47 then
      if ((epos - 48) mod 12) = 0 then

        DIN <= std_logic_vector(TO_UNSIGNED((epos - 48)/12, 8));
      elsif ((epos - 48) mod 12) = 1 then

        DIN <= X"FF";
      else
        DIN <= X"00";
      end if;


    end if;

  end process;

  clk <= DSPCLKOUT;
  
  process
  begin

    AEN(7 downto 0)   <= X"A1";
    AEN(15 downto 8)  <= X"A2";
    AEN(79 downto 72) <= X"0A";

    BEN(7 downto 0)   <= X"B1";
    BEN(15 downto 8)  <= X"B2";
    BEN(79 downto 72) <= X"0A";

    CEN(7 downto 0)   <= X"C1";
    CEN(15 downto 8)  <= X"C2";
    CEN(79 downto 72) <= X"0A";

    DEN(7 downto 0)   <= X"D1";
    DEN(15 downto 8)  <= X"D2";
    DEN(79 downto 72) <= X"0A";
    wait until rising_edge(CLK) and epos = 0;  -- wait for the first one

    for i in 0 to 10 loop

      
      wait until rising_edge(CLK) and epos = 0;
      AEN <= AEN(71 downto 0) & AEN(79 downto 72);
      BEN <= BEN(40 downto 0) & BEN(79 downto 41);
      CEN <= CEN(27 downto 0) & CEN(79 downto 28);
      DEN <= DEN(3 downto 0) & DEN(79 downto 4);
    end loop;  -- i in range 0 to 10
    wait for 20 us;

    report "End of Simulation" severity Failure;
    
    
  end process;
  acquire : process(CLK)
  begin
    if rising_edge(CLK) then
      if epos = 999 then
        rxdeventsAcnt               <= 0;
        rxdeventsBcnt               <= 0;
        rxdeventsCcnt               <= 0;
        rxdeventsDcnt               <= 0;
      else
        if eventena = '1' then
          rxdeventsA(rxdeventsAcnt) <= to_integer(unsigned(eventtxd));
          rxdeventsAcnt             <= rxdeventsAcnt + 1;
        end if;

        if eventenB = '1' then
          rxdeventsB(rxdeventsBcnt) <= to_integer(unsigned(eventtxd));
          rxdeventsBcnt             <= rxdeventsBcnt + 1;
        end if;

        if eventenC = '1' then
          rxdeventsC(rxdeventsCcnt) <= to_integer(unsigned(eventtxd));
          rxdeventsCcnt             <= rxdeventsCcnt + 1;
        end if;

        if eventenD = '1' then
          rxdeventsD(rxdeventsDcnt) <= to_integer(unsigned(eventtxd));
          rxdeventsDcnt             <= rxdeventsDcnt + 1;
        end if;
      end if;

    end if;
  end process acquire;

  Averify         : process
    variable pos : integer := 0;
  begin
    wait until rising_edge(CLK) and epos = 998;
      
    for i in 0 to 10 loop
      wait until rising_edge(CLK) and epos = 998;
      pos := 0;
      -- verify
      assert rxdeventsAcnt > 0 and rxdeventsA(0) = 0
        report "Ddd not receive heartbeat event" severity error;
      pos := pos + 1;

      for i in 0 to 77 loop
        if AEN(i) = '1' then
          assert rxdeventsA(pos) = i
            report "Error receiving A event " & integer'image(i) &
            "(instead had pos = " & integer'image(pos) & ", "
            & integer'image(rxdeventsA(pos)) & ")"
            severity error;

          pos := pos + 1;
        end if;
      end loop;  -- i
    end loop;  -- i 
  end process Averify;

  Bverify         : process
    variable pos : integer := 0;
  begin
      wait until rising_edge(CLK) and epos = 998;
    
    for i in 0 to 10 loop
      wait until rising_edge(CLK) and epos = 998;
      pos := 0;
      -- verify
      assert rxdeventsBcnt > 0 and rxdeventsB(0) = 0
        report "Did not receive heartbeat event" severity error;
      pos := pos + 1;

      for i in 0 to 77 loop
        if BEN(i) = '1' then
          assert rxdeventsB(pos) = i
            report "Error receiving B event " & integer'image(i) &
            "(instead had pos = " & integer'image(pos) & ", "
            & integer'image(rxdeventsB(pos)) & ")"
            severity error;

          pos := pos + 1;
        end if;
      end loop;  -- i
    end loop;  -- i 
  end process Bverify;

  Cverify         : process
    variable pos : integer := 0;
  begin
      wait until rising_edge(CLK) and epos = 998;

    for i in 0 to 10 loop
      wait until rising_edge(CLK) and epos = 998;
      pos := 0;
      -- verify
      assert rxdeventsCcnt > 0 and rxdeventsC(0) = 0
        report "Did not receive heartbeat event" severity error;
      pos := pos + 1;

      for i in 0 to 77 loop
        if CEN(i) = '1' then
          assert rxdeventsC(pos) = i
            report "Error receiving C event " & integer'image(i) &
            "(instead had pos = " & integer'image(pos) & ", "
            & integer'image(rxdeventsC(pos)) & ")"
            severity error;

          pos := pos + 1;
        end if;
      end loop;  -- i
    end loop;  -- i 
  end process Cverify;


  Dverify         : process
    variable pos : integer := 0;
  begin
      wait until rising_edge(CLK) and epos = 998;
    for i in 0 to 10 loop
      wait until rising_edge(CLK) and epos = 998;
      pos := 0;
      -- verify
      assert rxdeventsDcnt > 0 and rxdeventsD(0) = 0
        report "Did not receive heartbeat event" severity error;
      pos := pos + 1;

      for i in 0 to 77 loop
        if DEN(i) = '1' then
          assert rxdeventsD(pos) = i
            report "Error receiving D event " & integer'image(i) &
            "(instead had pos = " & integer'image(pos) & ", "
            & integer'image(rxdeventsD(pos)) & ")"
            severity error;

          pos := pos + 1;
        end if;
      end loop;  -- i
    end loop;  -- i 
  end process Dverify;

end Behavioral;


