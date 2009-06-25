library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

entity devicemuxtxtest is

end devicemuxtxtest;

architecture Behavioral of devicemuxtxtest is

  component devicemuxtx
    port (
      CLK    : in  std_logic;
      TXDIN  : in  std_logic_vector(7 downto 0);
      TXKIN  : in  std_logic;
      DOUT   : out std_logic_vector(7 downto 0);
      KOUT   : out std_logic;
      ECYCLE : in  std_logic;
      -- data interface
      DVALID : in  std_logic_vector(3 downto 0);
      DNEXT  : out std_logic_vector(3 downto 0);
      DADDR  : out std_logic_vector(9 downto 0);
      DDATAA : in  std_logic_vector(7 downto 0);
      DDATAB : in  std_logic_vector(7 downto 0);
      DDATAC : in  std_logic_vector(7 downto 0);
      DDATAD : in  std_logic_vector(7 downto 0);

      -- event interface
      EVALID : in  std_logic_vector(3 downto 0);
      ENEXT  : out std_logic_vector(3 downto 0);
      EADDR  : out std_logic_vector(4 downto 0);
      EDATAA : in  std_logic_vector(7 downto 0);
      EDATAB : in  std_logic_vector(7 downto 0);
      EDATAC : in  std_logic_vector(7 downto 0);
      EDATAD : in  std_logic_vector(7 downto 0)
      );

  end component;


  signal CLK    : std_logic                    := '0';
  signal TXDIN  : std_logic_vector(7 downto 0) := (others => '0');
  signal TXKIN  : std_logic                    := '0';
  signal DOUT   : std_logic_vector(7 downto 0) := (others => '0');
  signal KOUT   : std_logic                    := '0';
  signal ECYCLE : std_logic                    := '0';
  -- data interface
  signal DVALID : std_logic_vector(3 downto 0) := (others => '0');
  signal DNEXT  : std_logic_vector(3 downto 0) := (others => '0');
  signal DADDR  : std_logic_vector(9 downto 0) := (others => '0');
  signal DDATAA : std_logic_vector(7 downto 0) := (others => '0');
  signal DDATAB : std_logic_vector(7 downto 0) := (others => '0');
  signal DDATAC : std_logic_vector(7 downto 0) := (others => '0');
  signal DDATAD : std_logic_vector(7 downto 0) := (others => '0');

  -- event interface
  signal EVALID : std_logic_vector(3 downto 0) := (others => '0');
  signal ENEXT  : std_logic_vector(3 downto 0) := (others => '0');
  signal EADDR  : std_logic_vector(4 downto 0) := (others => '0');
  signal EDATAA : std_logic_vector(7 downto 0) := (others => '0');
  signal EDATAB : std_logic_vector(7 downto 0) := (others => '0');
  signal EDATAC : std_logic_vector(7 downto 0) := (others => '0');
  signal EDATAD : std_logic_vector(7 downto 0) := (others => '0');

  signal epos : integer := 900;

  signal ecnt : std_logic_vector(7 downto 0) := (others => '0');


  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to 77) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal dlgrant : std_logic_vector(3 downto 0) := (others => '0');
  signal evalidl : std_logic_vector(3 downto 0) := (others => '0');

  signal douten : std_logic := '0';
  
begin  -- Behavioral

  CLK <= not CLK after 10 ns;


  devicemuxtx_uut : devicemuxtx
    port map (
      CLK    => CLK,
      TXDIN  => TXDIN,
      TXKIN  => TXKIN,
      DOUT   => DOUT,
      KOUT   => KOUT,
      ECYCLE => ECYCLE,
      DVALID => DVALID,
      DNEXT  => DNEXT,
      DADDR  => DADDR,
      DDATAA => DDATAA,
      DDATAB => DDATAB,
      DDATAC => DDATAC,
      DDATAD => DDATAD,
      EVALID => EVALID,
      ENEXT  => ENEXT,
      EADDR  => EADDR,
      EDATAA => EDATAA,
      EDATAB => EDATAB,
      EDATAC => EDATAC,
      EDATAD => EDATAD);


  ecycle_generation : process(CLK)
  begin
    if rising_edge(CLK) then
      if epos = 999 then
        epos <= 0;
      else
        epos <= epos + 1;
      end if;

      if epos = 999 then
        ECYCLE <= '1' after 4 ns;
      else
        ECYCLE <= '0' after 4 ns;
      end if;
    end if;
  end process ecycle_generation;

  event_packet_generation : process
  begin

    while true loop
      wait until rising_edge(CLK) and epos = 999;
      TXDIN <= X"BC";
      TXKIN <= '1';
      wait until rising_edge(CLK) and epos = 0;
      TXDIN <= "0000000" & dlgrant(0);
      TXKIN <= '0';
      wait until rising_edge(CLK);
      TXDIN <= (others => '0');

      wait until rising_edge(CLK) and epos = 11;
      TXDIN <= "0000000" & dlgrant(1);
      TXKIN <= '0';
      wait until rising_edge(CLK);
      TXDIN <= (others => '0');


      wait until rising_edge(CLK) and epos = 22;
      TXDIN <= "0000000" & dlgrant(2);
      TXKIN <= '0';
      wait until rising_edge(CLK);
      TXDIN <= (others => '0');


      wait until rising_edge(CLK) and epos = 33;
      TXDIN <= "0000000" & dlgrant(3);
      TXKIN <= '0';
      wait until rising_edge(CLK);
      TXDIN <= (others => '0');


      wait until rising_edge(CLK) and epos = 47;
      -- now we send the events
      for i in 0 to 77 loop
        -- output the event bytes
        for j in 0 to 5 loop
          TXDIN <= eventinputs(i)(j)(15 downto 8);
          wait until rising_edge(CLK);
          TXDIN <= eventinputs(i)(j)(7 downto 0);
          wait until rising_edge(CLK);
        end loop;  -- j
      end loop;  -- i
    end loop;

  end process;


  EDATAA <= X"00" when EADDR = "00000" else
            ecnt when EADDR = "00001" else
            "000" & EADDR;

  EDATAB <= X"01" when EADDR = "00000" else
            ecnt when EADDR = "00001" else
            "000" & EADDR;

  EDATAC <= X"02" when EADDR = "00000" else
            ecnt when EADDR = "00001" else
            "000" & EADDR;

  EDATAD <= X"03" when EADDR = "00000" else
            ecnt when EADDR = "00001" else
            "000" & EADDR;


  DDATAA <= ecnt when DADDR = "0000000000" else
            X"00" when DADDR = "0000000001" else
            DADDR(7 downto 0);

  DDATAB <= ecnt when DADDR = "0000000000" else
            X"01" when DADDR = "0000000001" else
            DADDR(7 downto 0);

  DDATAC <= ecnt when DADDR = "0000000000" else
            X"02" when DADDR = "0000000001" else
            DADDR(7 downto 0);

  DDATAD <= ecnt when DADDR = "0000000000" else
            X"03" when DADDR = "0000000001" else
            DADDR(7 downto 0);


  eventsend : process(CLK)
  begin
    if rising_edge(CLK) then
      if ECYCLE = '1' then
        EVALID  <= EVALID + 1;
        evalidl <= evalid;
      end if;
      douten <= not douten;
    end if;
  end process eventsend;

  testout : process
  begin
    wait for 1 us;
    dlgrant(0) <= '1';
    DVALID(0)  <= '1';
    wait until rising_edge(CLK) and ECYCLE = '1';

    wait until rising_edge(CLK) and DNEXT(0) = '1';
    DVALID(0) <= '0';
    wait;
  end process testout;

  -- event validate
  process
  begin
    for i in 0 to 15 loop
      wait until rising_edge(CLK) and ECYCLE = '1';

      if evalid(0) = '1' then
        wait until rising_edge(CLK) and DOUT = X"1C" and KOUT = '1' and douten = '1';
        for ei in 1 to 21 loop
          wait until rising_edge(CLK) and douten = '1';
          assert kout = '0' report "Error reading Event A kout" severity error;
          if ei = 1 then
            assert dout = ecnt report "Error reading first byte" severity error;
          else
            assert dout = std_logic_vector(TO_UNSIGNED(ei, 8))
              report "Error reading event A byte" severity error;
          end if;
        end loop;  -- ei
        --report "read event 0";
      end if;

      if evalid(1) = '1' then
        wait until rising_edge(CLK) and DOUT = X"3C" and KOUT = '1' and douten = '1';
        for ei in 1 to 21 loop
          wait until rising_edge(CLK) and douten = '1';
          assert kout = '0' report "Error reading Event B kout" severity error;
          if ei = 1 then
            assert dout = ecnt report "Error reading first byte" severity error;
          else
            assert dout = std_logic_vector(TO_UNSIGNED(ei, 8))
              report "Error reading event B byte" severity error;
          end if;
        end loop;  -- ei
--              report "read event 1";
      end if;

      if evalid(2) = '1' then
        wait until rising_edge(CLK) and DOUT = X"5C" and KOUT = '1' and douten = '1';
        for ei in 1 to 21 loop
          wait until rising_edge(CLK) and douten = '1';
          assert kout = '0' report "Error reading Event C kout" severity error;
          if ei = 1 then
            assert dout = ecnt report "Error reading first byte" severity error;
          else
            assert dout = std_logic_vector(TO_UNSIGNED(ei, 8))
              report "Error reading event C byte" severity error;
          end if;
        end loop;  -- ei
        --report "read event 2";
      end if;

      if evalid(3) = '1' then
        wait until rising_edge(CLK) and DOUT = X"7C" and KOUT = '1' and douten = '1';
        for ei in 1 to 21 loop
          wait until rising_edge(CLK) and douten = '1';
          assert kout = '0' report "Error reading Event D kout" severity error;
          if ei = 1 then
            assert dout = ecnt report "Error reading first byte" severity error;
          else
            assert dout = std_logic_vector(TO_UNSIGNED(ei, 8))
              report "Error reading event D byte" severity error;
          end if;
        end loop;  -- ei
        --report "read event 3";
      end if;


    end loop;  -- i

    report "End of Simulation" severity failure;
    
  end process;


end Behavioral;
