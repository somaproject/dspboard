library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.numeric_std.all;

entity decodemux is
  port (
    CLK    : in std_logic;
    DIN    : in std_logic_vector(7 downto 0);
    KIN    : in std_logic;
    LOCKED : in std_logic;

    ECYCLE       : out std_logic;
    EDATA        : out std_logic_vector(7 downto 0);
    HEADERDONE   : out std_logic;
    BSTARTCYCLE  : out std_logic;
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
end decodemux;

architecture Behavioral of decodemux is

  signal hdrpos : integer range 0 to 10 := 0;
  signal hdrnum : integer range 0 to 4  := 0;

  type   states is (none, hdrst, hdrwait, hdrnext, hdrdone);
  signal cs, ns : states := none;

  signal dgrant       : std_logic_vector(3 downto 0) := (others => '0');
  signal bstartcycles : std_logic_vector(3 downto 0) := (others => '0');
  signal dgrantl      : std_logic_vector(3 downto 0) := (others => '0');

  component regfile
    generic (
      BITS : integer := 16);
    port (
      CLK   : in  std_logic;
      DIA   : in  std_logic_vector(BITS-1 downto 0);
      DOA   : out std_logic_vector(BITS -1 downto 0);
      ADDRA : in  std_logic_vector(3 downto 0);
      WEA   : in  std_logic;
      DOB   : out std_logic_vector(BITS -1 downto 0);
      ADDRB : in  std_logic_vector(3 downto 0)
      );
  end component;

  component regfilesingle
    generic (
      BITS : integer := 16);
    port (
      CLK  : in  std_logic;
      DI   : in  std_logic_vector(BITS-1 downto 0);
      DO   : out std_logic_vector(BITS -1 downto 0);
      ADDR : in  std_logic_vector(3 downto 0);
      WE   : in  std_logic
      );
  end component;


  signal regfileaddr   : std_logic_vector(3 downto 0) := (others => '0');
  signal regfileaddra  : std_logic_vector(3 downto 0) := (others => '0');
  signal regfileaddrb  : std_logic_vector(3 downto 0) := (others => '0');
  signal regfileaddrc  : std_logic_vector(3 downto 0) := (others => '0');
  signal regfileaddrd  : std_logic_vector(3 downto 0) := (others => '0');
  signal regfileinaddr : std_logic_vector(3 downto 0) := (others => '0');
  signal regfilewe     : std_logic_vector(3 downto 0) := (others => '0');

begin  -- Behavioral

  ECYCLE <= '1' when KIN = '1' and DIN = X"BC" else '0';

  HEADERDONE <= '1' when cs = hdrdone else '0';

  EDATA <= DIN;
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      if locked = '1' then
        cs <= ns;
      else
        cs <= none;
      end if;

      -- HDRPOS 
      if cs = none then
        hdrpos <= 0;
      else
        if cs = hdrnext then
          hdrpos <= 0;
        else
          if cs = hdrst or cs = hdrwait then
            hdrpos <= hdrpos + 1;
          end if;
        end if;
      end if;

      -- HDRNUM
      if cs = none then
        hdrnum <= 0;
      else
        if cs = hdrnext then
          hdrnum <= hdrnum + 1;
        end if;
      end if;

      if hdrnum = 0 and cs = hdrst then
        dgrant(0)       <= DIN(0);
        bstartcycles(0) <= DIN(1);
      end if;

      if hdrnum = 1 and cs = hdrst then
        dgrant(1)       <= DIN(0);
        bstartcycles(1) <= DIN(1);
      end if;

      if hdrnum = 2 and cs = hdrst then
        dgrant(2)       <= DIN(0);
        bstartcycles(2) <= DIN(1);
      end if;

      if hdrnum = 3 and cs = hdrst then
        dgrant(3)       <= DIN(0);
        bstartcycles(3) <= DIN(1);
      end if;

    end if;
  end process main;

  DGRANTA <= dgrant(0);
  DGRANTB <= dgrant(1);
  DGRANTC <= dgrant(2);
  DGRANTD <= dgrant(3);

  BSTARTCYCLE <= '0' when bstartcycles = "0000" else '1';

  regfileaddr <= "1111" when hdrpos = 0 else
                 std_logic_vector(TO_UNSIGNED(hdrpos-1, 4));

  regfilewegen : for i in 0 to 3 generate
    regfilewe(i) <= '1' when hdrnum = i else '0';
  end generate regfilewegen;

  regfile_a : regfile
    generic map (
      BITS => 8)
    port map (
      CLK   => clk,
      DIA   => DIN,
      DOA   => open,
      ADDRA => regfileaddr,
      WEA   => regfilewe(0),
      DOB   => EARXBYTEA,
      ADDRB => EARXBYTESELA);


  regfile_b : regfile
    generic map (
      BITS => 8)
    port map (
      CLK   => clk,
      DIA   => DIN,
      DOA   => open,
      ADDRA => regfileaddr,
      WEA   => regfilewe(1),
      DOB   => EARXBYTEB,
      ADDRB => EARXBYTESELB);


  regfile_c : regfile
    generic map (
      BITS => 8)
    port map (
      CLK   => clk,
      DIA   => DIN,
      DOA   => open,
      ADDRA => regfileaddr,
      WEA   => regfilewe(2),
      DOB   => EARXBYTEC,
      ADDRB => EARXBYTESELC);


  regfile_d : regfile
    generic map (
      BITS => 8)
    port map (
      CLK   => clk,
      DIA   => DIN,
      DOA   => open,
      ADDRA => regfileaddr,
      WEA   => regfilewe(3),
      DOB   => EARXBYTED,
      ADDRB => EARXBYTESELD);

  fsm : process(cs, KIN, DIN, hdrpos, hdrnum)
  begin
    case cs is
      when none =>
        if KIN = '1' and DIN = X"BC" then
          ns <= hdrst;
        else
          ns <= none;
        end if;

      when hdrst =>
        ns <= hdrwait;

      when hdrwait =>
        if hdrpos = 9 then
          ns <= hdrnext;
        else
          ns <= hdrwait;
        end if;

      when hdrnext =>
        if hdrnum = 3 then
          ns <= hdrdone;
        else
          ns <= hdrst;
        end if;

      when hdrdone =>
        ns <= none;

      when others =>
        ns <= none;
    end case;
  end process fsm;

end Behavioral;
