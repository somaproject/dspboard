
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity eventrx is
  port (
    CLK      : in  std_logic;
    RESET    : in  std_logic;
    SCLK     : in  std_logic;
    MOSI     : in  std_logic;
    SCS      : in  std_logic;
    FIFOFULL : out std_logic;
    DOUTEN   : in  std_logic;
    DOUT     : out std_logic_vector(7 downto 0);
    REQ      : out std_logic;
    GRANT    : in  std_logic;
    DONE     : out std_logic;
    DEBUG    : out std_logic_vector(15 downto 0));
end eventrx;

architecture Behavioral of eventrx is
  -- Latched SPI signals
  signal scsl          : std_logic := '1';
  signal mosil         : std_logic := '0';
  signal sclkl, sclkll : std_logic := '0';

  -- debug
  signal debugEventCounter : std_logic_vector(3 downto 0) := (others => '0');

  -- INPUT SIGNALS

  signal din    : std_logic_vector(15 downto 0) := (others => '0');
  signal bitcnt : integer range 0 to 15         := 0;
  signal biten  : std_logic                     := '0';


  signal wcntin : std_logic_vector(3 downto 0) := (others => '0');

  signal wea    : std_logic := '0';
  signal web    : std_logic := '0';
  signal we     : std_logic := '0';
  signal isel   : std_logic := '0';
  signal armeda : std_logic := '0';
  signal armedb : std_logic := '0';

  type   instates is (startup, none, wordw, wordchk, bufarm, nextisel);
  signal ics, ins : instates := none;

  -- OUTPUT SIGNALS

  signal douta, doutb : std_logic_vector(15 downto 0) := (others => '0');

  signal wcntout : std_logic_vector(3 downto 0) := (others => '0');

  signal reqint : std_logic := '0';
  
  signal osel : std_logic := '0';
  signal dsel : std_logic := '0';

  signal doutsel : std_logic_vector(15 downto 0) := (others => '0');

  type outstates is (armaw, armareq, sendah, sendal, donea,
                     armbw, armbreq, sendbh, sendbl, doneb);
  signal ocs, ons : outstates := armaw;


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

begin  -- Behavioral

  biten <= '1' when sclkl = '0' and sclkll = '1' else '0';

  wea <= '1' when we = '1' and isel = '0' else '0';
  web <= '1' when we = '1' and isel = '1' else '0';

  we <= '1' when ics = wordchk else '0';

  doutsel <= douta                when osel = '0' else doutb;
  DOUT    <= doutsel(15 downto 8) when dsel = '0' else doutsel(7 downto 0);

  reqint <= '1' when ocs = armareq or ocs = armbreq else '0';
  REQ <= reqint;
  
--     FIFOFULL <= armeda and armedb;       -- causes race conditions
-- THE ABOVE MESSAGE WAS IN THE CODE BEFORE IT WAS CHANGED TO THIS:
--
--   FIFOFULL <= '1' when (armeda = '1' and armedb = '1' ) or
--               (armeda = '1' and ics = wordw) or
--               (armedb = '1' and ics = wordw) else
--               '0';
-- which is correct? I do not know! 
  FIFOFULL <= '1' when (armeda = '1' and armedb = '1') or
              (armeda = '1' and wcntin > 0) or
              (armedb = '1' and wcntin > 0) else
              '0';

  DEBUG(15) <= '0'; 
  regfile_a : regfile
    generic map (
      BITS => 16)
    port map (
      CLK   => CLK,
      DIA   => din,
      DOA   => open,
      ADDRA => wcntin,
      WEA   => wea,
      DOB   => douta,
      ADDRB => wcntout);

  regfile_b : regfile
    generic map (
      BITS => 16)
    port map (
      CLK   => CLK,
      DIA   => din,
      DOA   => open,
      ADDRA => wcntin,
      WEA   => web,
      DOB   => doutb,
      ADDRB => wcntout);

  main : process(clk)
  begin
    if RESET = '1' then
      ics    <= startup;
      ocs    <= armaw;
      armeda <= '0';
      armedb <= '0';
      wcntin <= (others => '0');
      wcntout <= (others => '0');
      isel <= '0'; 
                
    else
      if rising_edge(CLK) then
        ics                <= ins;
        ocs                <= ons;
        DEBUG(11 downto 8) <= wcntin; -- debugEventCounter;
        if ics = bufarm then
          debugEventCounter <= debugEventCounter + 1;
        end if;
        DEBUG(12) <= armeda;
        DEBUG(13) <= armedb;
        DEBUG(14) <= reqint; 

        scsl   <= SCS;
        mosil  <= MOSI;
        sclkl  <= SCLK;
        sclkll <= sclkl;

        if ics = none then
          bitcnt <= 0;
        else
          if biten = '1' then
            if bitcnt = 15 then
              bitcnt <= 0;
            else
              bitcnt <= bitcnt + 1;
            end if;
          end if;
        end if;

        -- shift register
        if biten = '1' then
          din <= din(14 downto 0) & mosil;
        end if;

        if ics = bufarm then
          wcntin <= (others => '0');
        else
          if ics = wordchk then
            wcntin <= wcntin + 1;
          end if;
        end if;

        -- arming regs
        if ics = bufarm and isel = '0' then
          armeda <= '1';
        else
          if ocs = donea then
            armeda <= '0';
          end if;
        end if;

        if ics = bufarm and isel = '1' then
          armedb <= '1';
        else
          if ocs = doneb then
            armedb <= '0';
          end if;
        end if;

        if ocs = armaw or ocs = armbw then
          wcntout <= (others => '0');
        else
          if (ocs = sendal or ocs = sendbl) and DOUTEN ='1'  then
            wcntout <= wcntout + 1;
          end if;
        end if;

        if ics = nextisel then
          isel <= not isel;
        end if;

        if ocs = donea or ocs = doneb then
          DONE <= '1';
        else
          DONE <= '0';
        end if;

        -- latch output
--        if DOUTEN = '1' then
--          if dsel = '0' then
--            DOUT <= doutsel(15 downto 8);
--          else
--            DOUT <= doutsel(7 downto 0);
--          end if;
--        end if;

      end if;
    end if;

  end process main;

-----------------------------------------------------------------------------
-- input finite state machine
-----------------------------------------------------------------------------
  input_fsm : process(ics, scsl, biten, bitcnt, wcntin)
  begin
    case ics is
      when startup =>                   -- we wait for the dsp to bring the
                                        -- scsl out of reset
        DEBUG(3 downto 0) <= X"F";
        if scsl = '1' then
          ins <= none;
        else
          ins <= startup;
        end if;
        
      when none =>
        DEBUG(3 downto 0) <= X"0";
        if scsl = '0' then
          ins <= wordw;
        else
          ins <= none;
        end if;

      when wordw =>
        DEBUG(3 downto 0) <= X"1";
        if scsl = '1' then
          ins <= none;
        else
          if biten = '1' and bitcnt = 15 then
            ins <= wordchk;
          else
            ins <= wordw;
          end if;
        end if;

      when wordchk =>
        DEBUG(3 downto 0) <= X"2";
        if wcntin = "1010" then
          ins <= bufarm;
        else
          ins <= none;
        end if;

      when bufarm =>
        DEBUG(3 downto 0) <= X"3";
        ins               <= nextisel;

      when nextisel =>
        DEBUG(3 downto 0) <= X"4";
        ins               <= none;
      when others =>
        DEBUG(3 downto 0) <= X"5";
        ins               <= none;
    end case;

  end process input_fsm;

  -----------------------------------------------------------------------
  -- output finite state machine
  -----------------------------------------------------------------------
  output_fsm : process(ocs, armeda, armedB, grant, wcntout, DOUTEN)
  begin
    case ocs is
      when armaw =>
        DEBUG(7 downto 4) <= X"0";
        osel <= '0';
        dsel <= '0';
        if armeda = '1' then
          ons <= armareq;
        else
          ons <= armaw;
        end if;

      when armareq =>
        DEBUG(7 downto 4) <= X"1";
        osel <= '0';
        dsel <= '0';
        if GRANT = '1'  and DOUTEN = '1' then
          ons <= sendah;
        else
          ons <= armareq;
        end if;

      when sendah =>
        DEBUG(7 downto 4) <= X"2";
        osel <= '0';
        dsel <= '0';
        if DOUTEN = '1' then
          ons <= sendal;
        else

          ons <= sendah;
        end if;

      when sendal =>
        DEBUG(7 downto 4) <= X"3";
        osel <= '0';
        dsel <= '1';
        if douten = '1' then
          if wcntout = "1010" then
            ons <= donea;
          else
            ons <= sendah;
          end if;
        else
          ons <= sendal;
        end if;

      when donea =>
        DEBUG(7 downto 4) <= X"4";
        osel <= '0';
        dsel <= '0';
        ons  <= armbw;

      when armbw =>
        DEBUG(7 downto 4) <= X"5";
        osel <= '1';
        dsel <= '0';
        if armedb = '1' then
          ons <= armbreq;
        else
          ons <= armbw;
        end if;

      when armbreq =>
        DEBUG(7 downto 4) <= X"6";
        osel <= '1';
        dsel <= '0';
        if GRANT = '1' and DOUTEN = '1' then
          ons <= sendbh;
        else
          ons <= armbreq;
        end if;

      when sendbh =>
        DEBUG(7 downto 4) <= X"7";
        osel <= '1';
        dsel <= '0';
        if douten = '1'  then
          ons  <= sendbl;
        else

          ons <= sendbh; 
        end if;


      when sendbl =>
        DEBUG(7 downto 4) <= X"8";
        osel <= '1';
        dsel <= '1';
        if douten = '1' then
          
        if wcntout = "1010" then
          ons <= doneb;
        else
          ons <= sendbh;
        end if;
       else
         ons <= sendbl; 
        end if;

      when doneb =>
        DEBUG(7 downto 4) <= X"9";
        osel <= '1';
        dsel <= '0';
        ons  <= armaw;

      when others =>
        DEBUG(7 downto 4) <= X"A";
        osel <= '0';
        dsel <= '0';
        ons  <= armaw;

    end case;

  end process output_fsm;

end Behavioral;

