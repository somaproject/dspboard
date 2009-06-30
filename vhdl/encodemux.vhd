library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity encodemux is
  port (
    CLK         : in  std_logic;
    ECYCLE      : in  std_logic;
    DOUT        : out std_logic_vector(7 downto 0);
    KOUT        : out std_logic;
    -- data interface
    DREQ        : in  std_logic;
    DGRANT      : out std_logic;
    DDONE       : in  std_logic;
    DDATA       : in  std_logic_vector(7 downto 0);
    DKIN        : in  std_logic;
    DATAEN      : out std_logic;
    -- event interface for DSPs
    EDSPREQ     : in  std_logic_vector(3 downto 0);
    EDSPGRANT   : out std_logic_vector(3 downto 0);
    EDSPDONE    : in  std_logic_vector(3 downto 0);
    EDSPDATAEN  : out std_logic;
    EDSPDATAA   : in  std_logic_vector(7 downto 0);
    EDSPDATAB   : in  std_logic_vector(7 downto 0);
    EDSPDATAC   : in  std_logic_vector(7 downto 0);
    EDSPDATAD   : in  std_logic_vector(7 downto 0);
    -- event interface for EPROCs
    EPROCREQ    : in  std_logic_vector(3 downto 0);
    EPROCGRANT  : out std_logic_vector(3 downto 0);
    EPROCDONE   : in  std_logic_vector(3 downto 0);
    EPROCDATAEN : out std_logic;
    EPROCDATAA  : in  std_logic_vector(7 downto 0);
    EPROCDATAB  : in  std_logic_vector(7 downto 0);
    EPROCDATAC  : in  std_logic_vector(7 downto 0);
    EPROCDATAD  : in  std_logic_vector(7 downto 0);
    DEBUG       : out std_logic_vector(63 downto 0));
end encodemux;

architecture Behavioral of encodemux is

  signal edataa : std_logic_vector(7 downto 0) := (others => '0');
  signal edatab : std_logic_vector(7 downto 0) := (others => '0');
  signal edatac : std_logic_vector(7 downto 0) := (others => '0');
  signal edatad : std_logic_vector(7 downto 0) := (others => '0');

  signal ereq : std_logic_vector(3 downto 0) := (others => '0');

  signal esel : std_logic_vector(3 downto 0) := (others => '0');

  signal edone : std_logic_vector(3 downto 0) := (others => '0');

  signal sentthiscycle : std_logic_vector(3 downto 0) := (others => '0');

  signal   databurstpos : integer range 0 to 3       := 0;
  constant DPOSMAX      : integer                    := 247;
  signal   datapos      : integer range 0 to DPOSMAX := 0;


  -- data mux control
  signal kdout, kd : std_logic_vector(7 downto 0) := (others => '0');
  signal edout     : std_logic_vector(7 downto 0) := (others => '0');

  signal ken   : std_logic := '0';
  signal kdsel : std_logic := '0';

  signal osel : integer range 0 to 4 := 0;

  constant KEVENTA : std_logic_vector(7 downto 0) := X"1C";
  constant KEVENTB : std_logic_vector(7 downto 0) := X"3C";
  constant KEVENTC : std_logic_vector(7 downto 0) := X"5C";
  constant KEVENTD : std_logic_vector(7 downto 0) := X"7C";


  type states is (none, dcheck, dstart, dwait, ddones,
                  echecka, esenda, esendaw, enexta,
                  echeckb, esendb, esendbw, enextb,
                  echeckc, esendc, esendcw, enextc,
                  echeckd, esendd, esenddw, enextd,
                  timechk);

  signal cs, ns : states := none;

  signal epos : integer range 0 to 1023 := 0;


  -- debugging counters
  constant CNTSIZE             : integer   := 8;
  type     cnt_array is array (0 to 3) of std_logic_vector(CNTSIZE-1 downto 0);
  signal   eproc_cnt, edsp_cnt : cnt_array := (others => (others => '0'));

  signal douten : std_logic := '0';
  
begin  -- Behavioral

  -- output muxes
  kdout <= DDATA when osel = 0 else
           KEVENTA when osel = 1 else
           KEVENTB when osel = 2 else
           KEVENTC when osel = 3 else
           KEVENTD;

  edout <= DDATA when osel = 0 else
           edataa when osel = 1 else
           edatab when osel = 2 else
           edatac when osel = 3 else
           edatad;

  EDATAA <= EPROCDATAA when esel(0) = '0' else EDSPDATAA;
  EDATAB <= EPROCDATAB when esel(1) = '0' else EDSPDATAB;
  EDATAC <= EPROCDATAC when esel(2) = '0' else EDSPDATAC;
  EDATAD <= EPROCDATAD when esel(3) = '0' else EDSPDATAD;

  ereq(0) <= EPROCREQ(0) when esel(0) = '0' else edspreq(0);
  ereq(1) <= EPROCREQ(1) when esel(1) = '0' else edspreq(1);
  ereq(2) <= EPROCREQ(2) when esel(2) = '0' else edspreq(2);
  ereq(3) <= EPROCREQ(3) when esel(3) = '0' else edspreq(3);

  edone(0) <= eprocdone(0) when esel(0) = '0' else edspdone(0);
  edone(1) <= eprocdone(1) when esel(1) = '0' else edspdone(1);
  edone(2) <= eprocdone(2) when esel(2) = '0' else edspdone(2);
  edone(3) <= eprocdone(3) when esel(3) = '0' else edspdone(3);

  DGRANT <= '1' when cs = dstart else '0';

  EDSPGRANT(0) <= '1' when (cs = esenda) and esel(0) = '1' else '0';
  EDSPGRANT(1) <= '1' when (cs = esendb) and esel(1) = '1' else '0';
  EDSPGRANT(2) <= '1' when (cs = esendc) and esel(2) = '1' else '0';
  EDSPGRANT(3) <= '1' when (cs = esendd)and esel(3) = '1'  else '0';

  EPROCGRANT(0) <= '1' when (cs = esenda and douten = '1') and esel(0) = '0' else '0';
  EPROCGRANT(1) <= '1' when (cs = esendb and douten = '1') and esel(1) = '0' else '0';
  EPROCGRANT(2) <= '1' when (cs = esendc and douten = '1') and esel(2) = '0' else '0';
  EPROCGRANT(3) <= '1' when (cs = esendd and douten = '1') and esel(3) = '0' else '0';

  DEBUG <= eproc_cnt(0) & edsp_cnt(0) &
           eproc_cnt(1) & edsp_cnt(1) &
           eproc_cnt(2) & edsp_cnt(2) &
           eproc_cnt(3) & edsp_cnt(3);
  
  EPROCDATAEN <= douten;
  EDSPDATAEN  <= douten;
  DATAEN      <= douten;


  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      if douten = '1' then
        KOUT <= ken;
        if ken = '1' then
          DOUT <= kdout;
        else
          DOUT <= edout;
        end if;
      end if;


      if ECYCLE = '1' then
        epos   <= 0;
        douten <= '0';
      else
        if epos = 1023 then
          epos <= 0;
        else
          epos <= epos + 1;
        end if;
        douten <= not douten;
      end if;


      if cs = enexta then
        esel(0) <= not esel(0);
      end if;

      if cs = enextb then
        esel(1) <= not esel(1);
      end if;

      if cs = enextc then
        esel(2) <= not esel(2);
      end if;

      if cs = enextd then
        esel(3) <= not esel(3);
      end if;

      if cs = esenda then
        sentthiscycle(0) <= '1';
      else
        if cs = none then
          sentthiscycle(0) <= '0';
        end if;
      end if;

      if cs = esendb then
        sentthiscycle(1) <= '1';
      else
        if cs = none then
          sentthiscycle(1) <= '0';
        end if;
      end if;

      if cs = esendc then
        sentthiscycle(2) <= '1';
      else
        if cs = none then
          sentthiscycle(2) <= '0';
        end if;
      end if;

      if cs = esendd then
        sentthiscycle(3) <= '1';
      else
        if cs = none then
          sentthiscycle(3) <= '0';
        end if;
      end if;

      -- debug_counters
      if eprocdone(0) = '1' then
        eproc_cnt(0) <= eproc_cnt(0) + 1;
      end if;

      if ecycle = '1' and cs /= none then
        edsp_cnt(0) <= edsp_cnt(0) + 1;
      end if;

      if eprocdone(1) = '1' then
        eproc_cnt(1) <= eproc_cnt(1) + 1;
      end if;

      if eprocdone(2) = '1' then
        eproc_cnt(2) <= eproc_cnt(2) + 1;
      end if;

      if eprocdone(3) = '1' then
        eproc_cnt(3) <= eproc_cnt(3) + 1;
      end if;


      if edspdone(0) = '1' then
        edsp_cnt(0) <= edsp_cnt(0) + 1;
      end if;

      if ecycle = '1' and cs /= none then
        edsp_cnt(0) <= edsp_cnt(0) + 1;
      end if;

      if edspdone(1) = '1' then
        edsp_cnt(1) <= edsp_cnt(1) + 1;
      end if;

      if edspdone(2) = '1' then
        edsp_cnt(2) <= edsp_cnt(2) + 1;
      end if;

      if edspdone(3) = '1' then
        edsp_cnt(3) <= edsp_cnt(3) + 1;
      end if;


    end if;
  end process main;


  fsm : process(cs, ECYCLE, sentthiscycle, ereq, edone, DREQ, DDONE, epos)
  begin
    case cs is
      when none =>
        osel <= 0;
        ken  <= '0';
        if epos = 53 then
          ns <= dcheck;
        else
          ns <= none;
        end if;
        -----------------------------------------------------------------------
        -- DATA SEND
        -----------------------------------------------------------------------
      when dcheck =>
        osel <= 0;
        ken  <= '0';
        if DREQ = '1' then              
          ns <= dstart;
        else
          ns <= echecka;
        end if;
        
      when dstart =>
        osel <= 0;
        ken  <= '0';
        ns <= dwait;
        
      when dwait =>
        osel <= 0;
        ken  <= DKIN;
        if ddone = '1' then
          ns <= ddones;
        else
          ns <= dwait;
        end if;

      when ddones =>
        osel <= 0;
        ken  <= '0';
        ns   <= echecka;

        -----------------------------------------------------------------------
        -- EVENT A SEND
        -----------------------------------------------------------------------
      when echecka =>
        osel <= 1;
        ken  <= '0';
        if sentthiscycle(0) = '1' then
          ns <= echeckb;
        else
          if ereq(0) = '1' then
            ns <= esenda;
          else
            ns <= enexta;
          end if;
        end if;

      when esenda =>
        osel <= 1;
        ken  <= '1';
        if douten = '1' then
          ns <= esendaw;
        else
          ns <= esenda;
        end if;

      when esendaw =>
        osel <= 1;
        ken  <= '0';
        if edone(0) = '1' then
          ns <= enexta;
        else
          ns <= esendaw;
        end if;

      when enexta =>
        osel <= 1;
        ken  <= '0';
        ns   <= echeckb;

        -----------------------------------------------------------------------
        -- EVENT B SEND
        -----------------------------------------------------------------------
      when echeckb =>
        osel <= 2;
        ken  <= '0';
        if sentthiscycle(1) = '1' then
          ns <= echeckc;
        else
          if ereq(1) = '1' then
            ns <= esendb;
          else
            ns <= enextb;
          end if;
        end if;


      when esendb =>
        osel <= 2;
        ken  <= '1';
        if douten = '1' then
          ns <= esendbw;
        else
          ns <= esendb;
        end if;

      when esendbw =>
        osel <= 2;
        ken  <= '0';
        if edone(1) = '1' then
          ns <= enextb;
        else
          ns <= esendbw;
        end if;

      when enextb =>
        osel <= 2;
        ken  <= '0';
        ns   <= echeckc;

        -----------------------------------------------------------------------
        -- EVENT C SEND
        -----------------------------------------------------------------------
      when echeckc =>
        osel <= 3;
        ken  <= '0';
        if sentthiscycle(2) = '1' then
          ns <= echeckd;
        else
          if ereq(2) = '1' then
            ns <= esendc;
          else
            ns <= enextc;
          end if;
        end if;

      when esendc =>
        osel <= 3;
        ken  <= '1';
        if douten = '1' then
          ns <= esendcw;
        else
          ns <= esendc;
        end if;


      when esendcw =>
        osel <= 3;
        ken  <= '0';
        if edone(2) = '1' then
          ns <= enextc;
        else
          ns <= esendcw;
        end if;

      when enextc =>
        osel <= 3;
        ken  <= '0';
        ns   <= echeckd;

        -----------------------------------------------------------------------
        -- EVENT D SEND
        -----------------------------------------------------------------------
      when echeckd =>
        osel <= 4;
        ken  <= '0';
        if sentthiscycle(3) = '1' then
          ns <= timechk;
        else
          if ereq(3) = '1' then
            ns <= esendd;
          else
            ns <= enextd;
          end if;
        end if;

      when esendd =>
        osel <= 4;
        ken  <= '1';
        if douten = '1' then
          ns <= esenddw;
        else
          ns <= esendd;
        end if;

      when esenddw =>
        osel <= 4;
        ken  <= '0';
        if edone(3) = '1' then
          ns <= enextd;
        else
          ns <= esenddw;
        end if;

      when enextd =>
        osel <= 4;
        ken  <= '0';
        ns   <= timechk;
        
      when timechk =>
        osel <= 0;
        ken  <= '0';
        if epos < 700 then
          ns <= echecka;
        else
          ns <= none;
        end if;

      when others =>
        osel <= 0;
        ken  <= '0';
        ns   <= none;
        
    end case;
  end process fsm;

end Behavioral;
