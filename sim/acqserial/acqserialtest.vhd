library IEEE;
use IEEE.STD_LOGIC_1164.all;
-- use IEEE.STD_LOGIC_ARITH.all;
-- use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

entity acqserialtest is

end acqserialtest;

architecture Behavioral of acqserialtest is

  component acqserial
    port (
      CLK        : in  std_logic;
      CLKHI      : in  std_logic;
      RESET      : in  std_logic;
      FIBERIN    : in  std_logic;
      FIBEROUT   : out std_logic;
      SERCLK     : in  std_logic;
      -- SPORT outputs
      DSPASERDT  : out std_logic;
      DSPASERTFS : out std_logic;
      DSPASERDR  : in  std_logic;
      DSPASERRFS : in  std_logic;

      DSPBSERDT  : out std_logic;
      DSPBSERTFS : out std_logic;
      DSPBSERDR  : in  std_logic;
      DSPBSERRFS : in  std_logic;
      -- link status
      DSPALINKUP : out std_logic;
      DSPBLINKUP : out std_logic
      );
  end component;

  signal CLK      : std_logic := '0';
  signal CLKHI    : std_logic := '0';
  signal RESET    : std_logic := '1';
  signal FIBERIN  : std_logic := '0';
  signal FIBEROUT : std_logic := '0';
  signal SERCLK   : std_logic := '0';

  -- SPORT outputs
  signal DSPASERDT  : std_logic := '0';
  signal DSPASERTFS : std_logic := '0';
  signal DSPASERDR  : std_logic := '0';
  signal DSPASERRFS : std_logic := '0';

  signal DSPBSERDT  : std_logic := '0';
  signal DSPBSERTFS : std_logic := '0';
  signal DSPBSERDR  : std_logic := '0';
  signal DSPBSERRFS : std_logic := '0';

  -- link status
  signal DSPALINKUP : std_logic := '0';
  signal DSPBLINKUP : std_logic := '0';

  signal dspadatain  : std_logic_vector(255 downto 0) := (others => '0');

  -- dspadataout : data the DSP sends to the FPGA
  signal dspadataout : std_logic_vector(63 downto 0) := (others => '0');
  signal dspadone    : std_logic                      := '0';
  signal dspabitposTx  : integer                        := 257;
  signal dspabitposrx  : integer                        := 257;

  signal dspacmdout   : std_logic_vector(3 downto 0) := (others => '0');
  signal dspacmdidout : std_logic_vector(3 downto 0) := (others => '0');
  signal dspadata0out : std_logic_vector(7 downto 0) := (others => '0');

  signal dspaserclk : std_logic := '0';
  signal dspbserclk : std_logic := '0';


  signal dspbdatain  : std_logic_vector(255 downto 0) := (others => '0');
  signal dspbdataout : std_logic_vector(63 downto 0) := (others => '0');
  signal dspbdone    : std_logic                      := '0';
  signal dspbbitposrx  : integer                        := 257;
  signal dspbbitpostx  : integer                        := 257;

  signal dspbcmdout   : std_logic_vector(3 downto 0) := (others => '0');
  signal dspbcmdidout : std_logic_vector(3 downto 0) := (others => '0');
  signal dspbdata0out : std_logic_vector(7 downto 0) := (others => '0');




  component acqboard
    port (
      CLKIN        : in  std_logic;
      RXDATA       : out std_logic_vector(31 downto 0) := (others => '0');
      RXCMD        : out std_logic_vector(3 downto 0);
      rxcmdid      : out std_logic_vector(3 downto 0);
      RXCHKSUM     : out std_logic_vector(7 downto 0);
      FIBEROUT     : out std_logic;
      FIBERIN      : in  std_logic;
      TXCMDSTS     : in  std_logic_vector(3 downto 0);
      TXCMDSUCCESS : in  std_logic;
      TXCHKSUM     : in  std_logic_vector(7 downto 0));
  end component;

  signal acqclk       : std_logic                    := '0';
  signal TXCMDDONE    : std_logic                    := '0';
  signal TXCMDSTS     : std_logic_vector(3 downto 0) := (others => '0');
  signal TXCMDID      : std_logic_vector(3 downto 0) := (others => '0');
  signal TXCMDSUCCESS : std_logic                    := '0';
  signal TXCHKSUM     : std_logic_vector(7 downto 0) := (others => '0');

  signal RXDATA   : std_logic_vector(31 downto 0) := (others => '0');
  signal RXCMD    : std_logic_vector(3 downto 0);
  signal RXNEWCMD : std_logic;
  signal RXCMDID  : std_logic_vector(3 downto 0);
  signal RXCHKSUM : std_logic_vector(7 downto 0);

  signal dspasend, dsbsend : std_logic := '0';

  
begin  -- Behavioral

  acqboard_inst : acqboard
    port map (
      CLKIN        => acqclk,
      FIBEROUT     => FIBERIN,
      FIBERIN      => FIBEROUT,
      RXDATA       => RXDATA,
      RXCMD        => RXCMD,
      RXCMDID      => RXCMDID,
      RXCHKSUM     => RXCHKSUM,
      TXCMDSTS     => TXCMDSTS,
      TXCMDSUCCESS => TXCMDSUCCESS,
      TXCHKSUM     => TXCHKSUM);

  -- clocks
  CLK    <= not CLK    after 10 ns;     -- 50 MHz
  CLKHI  <= not CLKHI  after 6.25 ns;   -- 80 MHz
  acqclk <= not acqclk after 13.88888 ns;

  RESET <= '0' after 100 ns;
  acqserial_uut : acqserial
    port map (
      CLK        => CLK,
      CLKHI      => CLKHI,
      RESET      => RESET,
      FIBERIN    => FIBERIN,
      FIBEROUT   => FIBEROUT,
      SERCLK     => SERCLK,
      DSPASERDT  => DSPASERDT,
      DSPASERTFS => DSPASERTFS,
      DSPASERDR  => DSPASERDR,
      DSPASERRFS => DSPASERRFS,
      DSPBSERDT  => DSPBSERDT,
      DSPBSERTFS => DSPBSERTFS,
      DSPBSERDR  => DSPBSERDR,
      DSPBSERRFS => DSPBSERRFS,
      DSPALINKUP => DSPALINKUP,
      DSPBLINKUP => DSPBLINKUP
      );

  process(CLK)
    variable scnt : integer range 0 to 2 := 0;
  begin
    if rising_edge(CLK) then

      if scnt = 2 then
        scnt := 0;
      else
        scnt := scnt + 1;
      end if;

      if scnt = 2 then
        SERCLK <= '1';
      else
        SERCLK <= '0';
      end if;

      DSPASERCLK <= SERCLK;
      DSPBSERCLK <= SERCLK;

    end if;
  end process;
  -----------------------------------------------------------------------------
  -- DSP A MODEL 
  -----------------------------------------------------------------------------
  process(DSPASERCLK)
  begin
    if rising_edge(DSPASERCLK) then
      if DSPASERTFS = '1' then
        dspabitposrx               <= 0;
      else
        if dspabitposrx < 256 then
          dspabitposrx             <= dspabitposrx + 1;
          dspadatain(dspabitposrx) <= DSPASERDT;
        end if;

      end if;

      -- bit rx
    end if;
  end process;

  process
    begin
      wait until rising_edge(DSPASEND);
      wait until falling_edge(DSPASERCLK);
      DSPASERRFS <= '1';
      wait until falling_edge(DSPASERCLK);
      DSPASERRFS <= '0'; 
      for i in 0 to 63 loop
        DSPASERDR <= dspadataout(i);
        wait until falling_edge(DSPASERCLK);
        
      end loop;  -- i
    end process; 

  -- dspa transmit test
  dspadataout(19 downto 16) <= dspacmdout;
  dspadataout(23 downto 20) <= dspacmdidout;
  dspadataout(39 downto 32) <= dspadata0out;

--   -----------------------------------------------------------------------------
--   -- DSP B MODEL
--   -----------------------------------------------------------------------------
--   process(DSPBSERCLK)
--   begin
--     if rising_edge(DSPBSERCLK) then
--       if DSPBSERTFS = '1' then
--         dspbbitpos               <= 0;
--       else
--         if dspbbitpos < 256 then
--           dspbbitpos             <= dspbbitpos + 1;
--           dspbdatain(dspbbitposrx) <= DSPBSERDT;
--         end if;
--       end if;
--     end if;
--   end process;

--   -- dspb transmit test
--   dspbdataout(19 downto 16) <= dspbcmdout;
--   dspbdataout(23 downto 20) <= dspbcmdidout;
--   dspbdataout(39 downto 32) <= dspbdata0out;

  -------------------------------------------------------------------------------
  --  A test
  -------------------------------------------------------------------------------                               

  process

  begin
    for i in 0 to 7 loop
      wait until rising_edge(clk) and dspabitposrx = 256;
      dspacmdout <= X"1";

      dspacmdidout <= std_logic_vector(TO_UNSIGNED(i*2+1, 4));
      dspadata0out <= X"FE";
      DSPASEND <= '1';
      wait until rising_edge(CLK);
      DSPASEND <= '0'; 
      wait until rising_edge(clk) and dspabitposrx = 256;
      wait until rising_edge(clk) and dspabitposrx = 256;
      wait until rising_edge(clk) and dspabitposrx = 256;

      wait until rising_edge(clk) and dspabitposrx = 256 and
        dspadatain(11 downto 8) = std_logic_vector(TO_UNSIGNED(i*2+1, 4));
      report "Successful read of A cmdid";
    end loop;  -- i

    report "end of simulation" severity failure;
    wait;

  end process;

  a_data_read        : process
    variable datacnt : integer := 0;
  begin
    wait until rising_edge(CLK) and dspabitposrx = 256;
    wait until rising_edge(CLK) and dspabitposrx = 0;

    for datacnt in 0 to 15 loop
      wait until rising_edge(CLK) and dspabitposrx = 256;
      for i in 0 to 9 loop
        assert dspadatain(i*16 + 19 downto i*16 + 16) =
          std_logic_vector(TO_UNSIGNED(i, 4))
          report "Error reading DSPA Data In channel" severity error;

        assert dspadatain(i*16 + 31 downto i*16 + 24) =
          std_logic_vector(TO_UNSIGNED(datacnt, 8))
          report "Error reading DSPA data In cycle count " &
          integer'image(to_integer(unsigned(dspadatain(i*16 +31 downto i*16 +24))))
          & " " & integer'image(datacnt)
          severity error;
      end loop;  -- i


      report "Done Reading data for A";
      wait until rising_edge(CLK) and dspabitposrx = 0;
    end loop;  -- datacnt

    wait;
  end process;


  -------------------------------------------------------------------------------
  --  b test
  -------------------------------------------------------------------------------                               

  process

  begin
    for i in 0 to 6 loop
      wait until rising_edge(clk) and dspbbitposrx = 256;
      dspbcmdout <= X"1";

      dspbcmdidout <= std_logic_vector(TO_UNSIGNED(i*2+2, 4));
      dspbdata0out <= X"FE";
      wait until rising_edge(clk) and dspbbitposrx = 0;
      wait until rising_edge(clk) and dspbbitposrx = 256;
      wait until rising_edge(clk) and dspbbitposrx = 256 and
        dspbdatain(11 downto 8) = std_logic_vector(TO_UNSIGNED(i*2+2, 4));
      report "Successful read a B event";
      wait for 3 us;


    end loop;  -- i


    wait;

  end process;

  -- generic output verify

end Behavioral;
