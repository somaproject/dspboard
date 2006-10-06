library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

entity decodertest is

end decodertest;

architecture Behavioral of decodertest is


  component decoder
    port ( CLK      : in  std_logic;
           DIN      : in  std_logic;
           DATAOUT  : out std_logic_vector(7 downto 0);
           KOUT     : out std_logic;
           CODE_ERR : out std_logic;
           DISP_ERR : out std_logic;
           DATALOCK : out std_logic;
           RESET    : in  std_logic);
  end component;

  signal CLK      : std_logic                    := '0';
  signal DIN      : std_logic                    := '0';
  signal DATAOUT  : std_logic_vector(7 downto 0) := (others => '0');
  signal KOUT     : std_logic                    := '0';
  signal CODE_ERR : std_logic                    := '0';
  signal DISP_ERR : std_logic                    := '0';
  signal DATALOCK : std_logic                    := '0';
  signal RESET    : std_logic                    := '1';

  signal srcclk    : std_logic                    := '0';
  signal gendata   : std_logic_vector(7 downto 0) := (others => '0');
  signal kin       : std_logic                    := '0';
  signal encdatain : std_logic_vector(7 downto 0) := (others => '0');
  signal lencdataout,
    encdataout     : std_logic_vector(9 downto 0) := (others => '0');

  signal byteen  : std_logic := '0';
  signal sendpos : integer   := 0;


  component encode8b10b
    port (
      din  : in  std_logic_vector(7 downto 0);
      kin  : in  std_logic;
      clk  : in  std_logic;
      dout : out std_logic_vector(9 downto 0);
      ce   : in  std_logic);
  end component;


begin  -- Behavioral


  CLK <= not CLK after 10 ns;

  decoder_uut : decoder
    port map (
      CLK      => CLK,
      DIN      => DIN,
      DATAOUT  => DATAOUT,
      KOUT     => KOUT,
      CODE_ERR => CODE_ERR,
      DISP_ERR => DISP_ERR,
      DATALOCK => DATALOCK,
      RESET    => RESET);

  -- generate the input byte enable
  process(srcclk, encdataout)
    variable bpos : integer := 0;
  begin
    if rising_edge(srcclk) then
      if bpos = 9 then
        bpos                := 0;
      else
        bpos                := bpos + 1;
      end if;
      if bpos = 9 then
        byteen <= '1';
      else
        byteen <= '0';
      end if;

    end if;
    din <= encdataout(bpos);


  end process;


  -- generate the fake data
  srcclk          <= not srcclk after 63 ns;  -- 8 MHz
  senddata : process (srcclk, lencdataout)
  begin  -- process senddata
    if rising_edge(srcclk) then
      if byteen = '1' then
        if sendpos = 24 then
          sendpos <= 0;
        else
          sendpos <= sendpos + 1;
        end if;

        -- drive the encoder
        if sendpos = 0 then
          encdatain <= X"BC";
          kin       <= '1';
        else
          encdatain <= gendata;
          kin       <= '0';
          gendata   <= gendata + 1;
        end if;
        encdataout  <= lencdataout;

      end if;

    end if;
  end process senddata;

  encode8b10b_inst : encode8b10b
    port map (
      din  => encdatain,
      kin  => kin,
      clk  => srcclk,
      ce   => byteen,
      dout => lencdataout);

  -- output verification
  process
  begin
    wait for 20 us;
    for i in 0 to 1000 loop
      wait until rising_edge(CLK) and DATALOCK = '1';
      if code_err = '1' or disp_err = '1' then
        report "Error in decoding" severity error;
      end if;
    end loop;  -- i

    report "End of Simulation" severity failure;

  end process;

end Behavioral;

