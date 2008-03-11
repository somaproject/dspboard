library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity eventtxtest is
  port (
    REFCLKIN  : in  std_logic;
    DSPCLKOUT : out std_logic;
    DSPRESET  : out std_logic;
    LEDPOWER  : out std_logic;
-- DIN : in std_logic_vector(7 downto 0);
-- KIN : in std_logic;
-- INTGEN : in std_logic;
    PFLAG0    : in  std_logic;
    EVENTCLK  : out std_logic;
    EVENTENA  : out std_logic;
    EVENTTXD  : out std_logic_vector(7 downto 0)
    );
end eventtxtest;


architecture Behavioral of eventtxtest is

-- component eventtx
-- port (
-- CLK : in std_logic;
-- DIN : in std_logic_vector(7 downto 0);
-- KIN : in std_logic;
-- ERRIN : in std_logic;
-- EVENTENA : out std_logic;
-- EVENTENB : out std_logic;
-- EVENTENC : out std_logic;
-- EVENTEND : out std_logic;
-- EVENTTXD : out std_logic_vector(7 downto 0));
-- end component;

  signal clk : std_logic := '0';

-- signal dint : std_logic_vector(7 downto 0) := (others => '0');
-- signal errint, kint : std_logic := '0';

-- signal eaddr : std_logic_vector(10 downto 0) := (others => '0');
-- signal dout : std_logic_vector(7 downto 0) := (others => '0');

  signal pos : integer range 0 to 1023 := 0;

  signal cnt  : std_logic_vector(7 downto 0) := (others => '0');
  signal word : std_logic_vector(7 downto 0) := (others => '0');

  signal dout : std_logic_vector(7 downto 0) := (others => '0');

  signal rstcnt : std_logic_vector(15 downto 0) := (others => '1');

  signal pflag0l : std_logic := '0';
begin  -- Behavioral

  EVENTCLK <= clk;
  clk      <= REFCLKIN;

  DSPCLKOUT <= clk;
  EVENTTXD  <= dout;

  LEDPOWER <= '1';

  -- first, the most simple of all interfaces
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      if pos = 11 then
        pos      <= 0;
      else
        pos      <= pos + 1;
      end if;
      pflag0l    <= PFLAG0;
      if pos = 0 then
        EVENTENA <= '1';
      else
        EVENTENA <= '0';
      end if;

      if pos = 11 then
        cnt <= (others => '0');
      else
        cnt <= cnt + 1;
      end if;

      if pos = 0 or pos = 2 or pos = 4 or pos = 6 or pos = 8 or pos = 10 then
        DOUT <= cnt;
      else
        DOUT <= word;
      end if;

      if pos = 11 then
        word <= word + 1; 
      end if;

      if rstcnt /= X"0000" then
        rstcnt   <= rstcnt -1;
        DSPRESET <= '0';
      else
        DSPRESET <= '1';
      end if;
    end if;
  end process main;

-- eventtx_inst : eventtx
-- port map (
-- CLK => CLK,
-- DIN => dint,
-- KIN => kint,
-- ERRIN => errint,
-- EVENTENA => EVENTENA,
-- EVENTENB => EVENTENB,
-- EVENTENC => EVENTENC,
-- EVENTEND => EVENTEND,
-- EVENTTXD => EVENTTXD);

-- main : process (CLK)
-- begin
-- if rising_edge(CLK) then
--  --       if INTGEN = '0' then
-- --         dint   <= DIN;
-- --         kint   <= KIN;
-- --         errint <= ERRIN;
-- --      else
--         if eaddr = "0000000001" then
--           kint <= '1';
--         else
--           kint <= '0';
--         end if;
--         errint <= '0';
--         dint   <= dout;
-- --      end if;

-- if eaddr = "1111100111" then
-- eaddr <= (others => '0');
-- else
-- eaddr <= eaddr + 1;
-- end if;


-- end if;
-- end process main;

-- LEDPOWER <= '1';
-- DSPRESET <= '1';

-- RAMB16_S9_inst : RAMB16_S9
-- generic map (
-- INIT => X"000",                      --  Value of output RAM registers at startup
--       SRVAL      => X"000",          --  Ouput value upon SSR assertion
--       write_mode => "WRITE_FIRST",   --  WRITE_FIRST, READ_FIRST or NO_CHANGE
--       -- The following INIT_xx declarations specify the initial contents of the RAM
--       -- Address 0 to 511
--       INIT_00    => X"00000000000000000000000000000000000000000000000000000000000100BC",
--       INIT_01    => X"0000FFEEDDCCBBAADEBC9A78563412FF00000000000000000000000000000000",
--       INIT_02    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_03    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_04    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_05    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_06    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_07    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_08    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_09    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_0A    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_0B    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_0C    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_0D    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_0E    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_0F    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       -- Address 512 to 1023
--       INIT_10    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_11    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_12    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_13    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_14    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_15    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_16    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_17    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_18    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_19    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_1A    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_1B    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_1C    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_1D    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_1E    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_1F    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       -- Address 1024 to 1535
--       INIT_20    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_21    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_22    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_23    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_24    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_25    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_26    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_27    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_28    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_29    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_2A    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_2B    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_2C    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_2D    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_2E    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_2F    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       -- Address 1536 to 2047
--       INIT_30    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_31    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_32    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_33    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_34    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_35    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_36    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_37    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_38    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_39    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_3A    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_3B    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_3C    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_3D    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_3E    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INIT_3F    => X"0000000000000000000000000000000000000000000000000000000000000000",
--       -- The next set of INITP_xx are for the parity bits
--       -- Address 0 to 511
--       INITP_00   => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INITP_01   => X"0000000000000000000000000000000000000000000000000000000000000000",
--       -- Address 512 to 1023
--       INITP_02   => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INITP_03   => X"0000000000000000000000000000000000000000000000000000000000000000",
--       -- Address 1024 to 1535
--       INITP_04   => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INITP_05   => X"0000000000000000000000000000000000000000000000000000000000000000",
--       -- Address 1536 to 2047
--       INITP_06   => X"0000000000000000000000000000000000000000000000000000000000000000",
--       INITP_07   => X"0000000000000000000000000000000000000000000000000000000000000000")
--     port map (
--       DO         => dout,            -- 8-bit Data Output
--       DOP        => open,            -- 1-bit parity Output
--       ADDR       => eaddr,           -- 11-bit Address Input
--       CLK        => CLK,             -- Clock
--       DI         => X"00",           -- 8-bit Data Input
--       DIP        => "0",             -- 1-bit parity Input
--       EN         => '1',             -- RAM Enable Input
--       SSR        => '0',             -- Synchronous Set/Reset Input
-- WE => '0'                            -- Write Enable Input
--       );
end Behavioral;
