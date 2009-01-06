library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity decodemuxtest is
end decodemuxtest;

architecture Behavioral of decodemuxtest is

  component decodemux
    port (
      CLK    : in std_logic;
      DIN    : in std_logic_vector(7 downto 0);
      KIN    : in std_logic;
      LOCKED : in std_logic;

      ECYCLE       : out std_logic;
      EDATA        : out std_logic_vector(7 downto 0);
      -- data interface
      DGRANTA      : out std_logic;
      EARXBYTEA    : out std_logic_vector(7 downto 0) := (others => '0');
      EARXBYTESELA : in  std_logic_vector(3 downto 0) := (others => '0');

      DGRANTB      : out std_logic;
      EARXBYTEB    : out std_logic_vector(7 downto 0) := (others => '0');
      EARXBYTESELB : in  std_logic_vector(3 downto 0) := (others => '0');

      DGRANTC      : out std_logic;
      EARXBYTEC    : out std_logic_vector(7 downto 0) := (others => '0');
      EARXBYTESELC : in  std_logic_vector(3 downto 0) := (others => '0');

      DGRANTD      : out std_logic;
      EARXBYTED    : out std_logic_vector(7 downto 0) := (others => '0');
      EARXBYTESELD : in  std_logic_vector(3 downto 0) := (others => '0')

      );
  end component;

  signal CLK    : std_logic                    := '0';
  signal DIN    : std_logic_vector(7 downto 0) := (others => '0');
  signal KIN    : std_logic                    := '0';
  signal LOCKED : std_logic                    := '1';
  signal ECYCLE : std_logic                    := '0';
  signal EDATA  : std_logic_vector(7 downto 0) := (others => '0');
  -- data interface

  signal EARXBYTEA    : std_logic_vector(7 downto 0) := (others => '0');
  signal EARXBYTESELA : std_logic_vector(3 downto 0) := (others => '0');

  signal EARXBYTEB    : std_logic_vector(7 downto 0) := (others => '0');
  signal EARXBYTESELB : std_logic_vector(3 downto 0) := (others => '0');

  signal EARXBYTEC    : std_logic_vector(7 downto 0) := (others => '0');
  signal EARXBYTESELC : std_logic_vector(3 downto 0) := (others => '0');

  signal EARXBYTED    : std_logic_vector(7 downto 0) := (others => '0');
  signal EARXBYTESELD : std_logic_vector(3 downto 0) := (others => '0');

  signal DGRANTA : std_logic                     := '0';
  signal EARXA   : std_logic_vector(79 downto 0) := (others => '0');
  signal DGRANTB : std_logic                     := '0';
  signal EARXB   : std_logic_vector(79 downto 0) := (others => '0');
  signal DGRANTC : std_logic                     := '0';
  signal EARXC   : std_logic_vector(79 downto 0) := (others => '0');
  signal DGRANTD : std_logic                     := '0';
  signal EARXD   : std_logic_vector(79 downto 0) := (others => '0');

  signal pos : integer range 0 to 999 := 950;



begin  -- Behavioral

  CLK <= not CLK after 10 ns;

  decodemux_inst : decodemux
    port map (
      CLK          => CLK,
      DIN          => DIN,
      KIN          => KIN,
      LOCKED       => LOCKED,
      ECYCLE       => ECYCLE,
      EDATA        => EDATA,
      DGRANTA => DGRANTA, 
      EARXBYTEA    => EARXBYTEA,
      EARXBYTESELA => EARXBYTESELA,
      DGRANTB => DGRANTB, 
      EARXBYTEB    => EARXBYTEB,
      EARXBYTESELB => EARXBYTESELB,
      DGRANTC => DGRANTC, 
      EARXBYTEC    => EARXBYTEC,
      EARXBYTESELC => EARXBYTESELC,
      DGRANTD => DGRANTD, 
      EARXBYTED    => EARXBYTED,
      EARXBYTESELD => EARXBYTESELD);


  ecycle_generation : process(CLK)
  begin
    if rising_edge(CLK) then
      if pos = 999 then
        pos <= 0;
      else
        pos <= pos + 1;
      end if;

    end if;
  end process ecycle_generation;

  -- input data
  process
  begin
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    for pkt in 0 to 8 loop

      wait until rising_edge(CLK) and pos = 999;
      KIN     <= '1';
      DIN     <= X"BC";
      for i in 0 to 3 loop
        wait until rising_edge(CLK);
        KIN   <= '0';
        DIN   <= std_logic_vector(TO_UNSIGNED(i + pkt, 8));
        --now the data
        for j in 0 to 9 loop
          wait until rising_edge(CLK);
          KIN <= '0';
          DIN <= std_logic_vector(TO_UNSIGNED(i * 20 + j + pkt, 8));
        end loop;  -- j 
      end loop;  -- i
      -- and now the packet data
      for eventnum in 0 to 77 loop
        for eventdata_pos in 0 to 11 loop
          wait until rising_edge(CLK);
          KIN <= '0';
          DIN <= std_logic_vector(TO_UNSIGNED(pkt + eventnum*2 + eventdata_pos, 8));
        end loop;  -- eventdata_pos
      end loop;  -- eventnum

    end loop;  -- pkt
    wait;
  end process;

  -- validate output
  process
  begin
    for pkt in 0 to 7 loop
      wait until rising_edge(CLK) and ECYCLE = '1';
    --   wait until the pos is such that we've clearly had time to read out
    -- all of the ecycle data
      wait until rising_edge(CLK) and pos = 50;
      -- extract and save all of the ecycle data
      for j in 0 to 9 loop
        EARXBYTESELA <= std_logic_vector(to_unsigned(j, 4)); 
        EARXBYTESELB <= std_logic_vector(to_unsigned(j, 4)); 
        EARXBYTESELC <= std_logic_vector(to_unsigned(j, 4)); 
        EARXBYTESELD <= std_logic_vector(to_unsigned(j, 4));
        wait until rising_edge(CLK);
        EARXA(j*8 + 7 downto j*8) <= EARXBYTEA;
        EARXB(j*8 + 7 downto j*8) <= EARXBYTEB;
        EARXC(j*8 + 7 downto j*8) <= EARXBYTEC;
        EARXD(j*8 + 7 downto j*8) <= EARXBYTED;
      
      end loop;  -- j
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      for j in 0 to 9 loop
        assert EARXA(j*8 + 7 downto j*8) =
          std_logic_vector(TO_UNSIGNED(j + 0 + pkt, 8))
          report "error reading EARXA, expecting" & integer'image(j+0+pkt)  severity error;

        assert EARXB(j*8 + 7 downto j*8) =
          std_logic_vector(TO_UNSIGNED(j + 20 + pkt, 8))
          report "error reading EARXB" severity error;

        assert EARXC(j*8 + 7 downto j*8) =
          std_logic_vector(TO_UNSIGNED(j + 40 + pkt, 8))
          report "error reading EARXC" severity error;

        assert EARXD(j*8 + 7 downto j*8) =
          std_logic_vector(TO_UNSIGNED(j + 60+ pkt, 8))
          report "error reading EARXD" severity error;

        assert "0000000" & DGRANTA = std_logic_vector(TO_UNSIGNED(pkt mod 2, 8))

          report "Error with DGRANTA" severity error;

      end loop;  -- j
    end loop;  -- pkt
    report "End of Simulation" severity failure;

    wait;
  end process;

end Behavioral;
