library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity bootser is
  port (CLK       : in  std_logic;
         DIN      : in  std_logic_vector(15 downto 0);
         ADDRIN   : in  std_logic_vector(15 downto 0);
         WE       : in  std_logic;
         START    : in  std_logic;
         STARTLEN : in  std_logic_vector(15 downto 0);
         DONE     : out std_logic;
         MOSI     : out std_logic;
         HOLD     : in  std_logic;
         SCLK     : out std_logic
         );
end bootser;

architecture Behavioral of bootser is

  signal addrb : std_logic_vector(9 downto 0) := (others => '0');
  signal web   : std_logic                    := '0';

  signal startlenl       : std_logic_vector(15 downto 0) := (others => '0');
  signal anydatainbuffer : std_logic                     := '0';
  signal dib             : std_logic_vector(15 downto 0) := (others => '0');

  signal doa, doainv : std_logic_vector(7 downto 0)  := (others => '0');
  signal addra       : std_logic_vector(10 downto 0) := (others => '0');

  signal doabit : std_logic := '0';

  signal doasel : integer range 0 to 7  := 0;
  signal clkcnt : integer range 0 to 63 := 0;

  signal holdl, lsclk : std_logic := '0';

  type states is (none, rstcnt,
                  clkl1, clkh1, clkh2, clkl2, clkl3, cntrinc,
                  holdchk, cntrcomp, dones);

  signal cs, ns : states := none;


begin  -- Behavioral

  web <= WE;

  buffer_inst : RAMB16_S9_S18
    generic map (
      SIM_COLLISION_CHECK => "NONE")
    port map (
      DOA   => doa,
      DOB   => open,
      ADDRA => addra,
      ADDRB => addrb,
      CLKA  => clk,
      CLKB  => clk,
      DIA   => X"00",
      DIB   => dib,
      ENA   => '1',
      ENB   => '1',
      SSRA  => '0',
      SSRB  => '0',
      DIPA  => "0",
      DIPB  => "00",
      WEA   => '0',
      WEB   => web);

  dib <= DIN(7 downto 0) & DIN(15 downto 8);

  doainv(7) <= doa(0);
  doainv(6) <= doa(1);
  doainv(5) <= doa(2);
  doainv(4) <= doa(3);
  doainv(3) <= doa(4);
  doainv(2) <= doa(5);
  doainv(1) <= doa(6);
  doainv(0) <= doa(7);

  doabit <= doainv(doasel);
  addrb  <= addrin(9 downto 0);

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      if cs = clkl2 then
        if doasel = 7 then
          doasel <= 0;
        else
          doasel <= doasel + 1;
        end if;
      end if;

      if cs = dones then
        DONE <= '1';
      else
        if WE = '1' then
          DONE <= '0';
        end if;
      end if;

      if cs = rstcnt then
        addra <= (others => '0');
      else
        if cs = cntrinc then
          addra <= addra + 1;
        end if;
      end if;

      if clkcnt = 63 then
        clkcnt <= 0;
      else
        clkcnt <= clkcnt + 1;
      end if;

      MOSI  <= doabit;
      holdl <= HOLD;
      SCLK  <= lsclk;

      if START = '1' then
        startlenl <= STARTLEN;
      end if;

      if we = '1' then
        anydatainbuffer <= '1';
      else
        if cs = dones then
          anydatainbuffer <= '0';
        end if;
      end if;
    end if;
  end process main;



  fsm : process(cs, START, addra, addrb, holdl, doasel, clkcnt, anydatainbuffer)
  begin
    case cs is
      when none =>
        lsclk <= '0';
        if START = '1' and anydatainbuffer = '1' then
          ns <= rstcnt;
        else
          ns <= none;
        end if;

      when rstcnt =>
        lsclk <= '0';
        if clkcnt = 63 then
          ns <= clkl1;
        else
          ns <= rstcnt;
        end if;


      when clkl1 =>
        lsclk <= '0';
        if clkcnt = 63 then
          ns <= clkh1;
        else
          ns <= clkl1;
        end if;

      when clkh1 =>
        lsclk <= '1';
        if clkcnt = 63 then
          ns <= clkl3;
        else
          ns <= clkh1;
        end if;

      when clkl3 =>
        lsclk <= '0';
        if clkcnt = 63 then
          ns <= clkl2;
        else
          ns <= clkl3;
        end if;


      when clkl2 =>
        lsclk <= '0';
        if doasel = 7 then
          ns <= cntrinc;
        else
          ns <= clkl1;
        end if;

      when cntrinc =>
        lsclk <= '0';
        ns    <= holdchk;

      when holdchk =>
        lsclk <= '0';
        if holdl = '0' and clkcnt = 63 then
          ns <= cntrcomp;
        else
          ns <= holdchk;
        end if;

      when cntrcomp =>
        lsclk <= '0';
        if addra(10 downto 1) = startlenl(9 downto 0) then
          ns <= dones;
        else
          ns <= clkl1;
        end if;

      when dones =>
        lsclk <= '0';
        ns    <= none;

      when others =>
        lsclk <= '0';
        ns    <= none;
    end case;
  end process fsm;


end Behavioral;
