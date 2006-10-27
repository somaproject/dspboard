library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity devicemuxtx is

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

end devicemuxtx;

architecture Behavioral of devicemuxtx is

  signal bpos         : integer range 0 to 1023      := 0;
  signal ddout, edout : std_logic_vector(7 downto 0) := (others => '0');
  signal dkout, ekout : std_logic                    := '0';

  signal osel : integer range 0 to 1 := 0;


  -- data grant signals
  signal dstart, ddone : std_logic                    := '0';
  signal ddata         : std_logic_vector(7 downto 0) := (others => '0');

  signal dgrant   : std_logic_vector(3 downto 0) := (others => '0');
  signal curgrant : integer range 0 to 3         := 0;

  -- event grant signals
  signal edata         : std_logic_vector(7 downto 0) := (others => '0');
  signal estart, edone : std_logic                    := '0';
  signal esend         : std_logic_vector(1 downto 0);

  type states is (none, hdrw, dvalidch, dsend,
                  echk1, esend1, echk2, esend2,
                  echk3, esend3, echk4, esend4);
  signal cs, ns : states := none;

  component senddata
    port (
      CLK   : in  std_logic;
      DIN   : in  std_logic_vector(7 downto 0);
      ADDR  : out std_logic_vector(9 downto 0);
      DOUT  : out std_logic_vector(7 downto 0);
      KOUT  : out std_logic;
      START : in  std_logic;
      DONE  : out std_logic
      );
  end component;

  component sendevent
    port (
      CLK   : in  std_logic;
      ESEND : in  std_logic_vector(1 downto 0);
      DIN   : in  std_logic_vector(7 downto 0);
      ADDR  : out std_logic_vector(4 downto 0);
      DOUT  : out std_logic_vector(7 downto 0);
      KOUT  : out std_logic;
      START : in  std_logic;
      DONE  : out std_logic
      );
  end component;


begin  -- Behavioral

  senddata_inst : senddata
    port map (
      CLK   => CLK,
      DIN   => ddata,
      ADDR  => daddr,
      DOUT  => ddout,
      KOUT  => dkout,
      START => dstart,
      DONE  => ddone);

  sendevent_inst: sendevent
    port map (
      CLK   => CLK,
      ESEND => esend,
      DIN   => edata,
      ADDR  => EADDR,
      DOUT  => edout,
      KOUT  => ekout,
      START => estart,
      DONE  => edone); 
    

  -- muxes
  ddata <= DDATAA when curgrant = 0 else
           DDATAB when curgrant = 1 else
           DDATAC when curgrant = 2 else
           DDATAD;

  edata <= EDATAA when esend = "00" else
           EDATAB when esend = "01" else
           EDATAC when esend = "10" else
           EDATAD;

  DOUT <= ddout when osel = 0 else edout;
  KOUT <= ekout when osel = 0 else ekout;


  curgrant <= 0 when dgrant(0) = '1' else
              1 when dgrant(1) = '1' else
              2 when dgrant(2) = '1' else
              3 when dgrant(3) = '1' else
              0;

  enext(0) <= '1' when edone = '1' and esend = "00" else '0';
  enext(1) <= '1' when edone = '1' and esend = "01" else '0';
  enext(2) <= '1' when edone = '1' and esend = "10" else '0';
  enext(3) <= '1' when edone = '1' and esend = "11" else '0';
  
  dnext(0) <= '1' when ddone = '1' and curgrant = 0 else '0';
  dnext(1) <= '1' when ddone = '1' and curgrant = 1 else '0';
  dnext(2) <= '1' when ddone = '1' and curgrant = 2 else '0';
  dnext(3) <= '1' when ddone = '1' and curgrant = 3 else '0';
  

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      -- main count
      if ECYCLE = '1' then
        bpos <= 0;
      else
        bpos <= bpos + 1;
      end if;

      if bpos = 0 then
        dgrant(0) <= TXDIN(0);
      end if;

      if bpos = 11 then
        dgrant(1) <= TXDIN(0);
      end if;

      if bpos = 22 then
        dgrant(2) <= TXDIN(0);
      end if;

      if bpos = 33 then
        dgrant(3) <= TXDIN(0);
      end if;


    end if;

  end process main;


  fsm : process(cs, ecycle, bpos, dvalid, ddone,
                curgrant, evalid, edone)
  begin
    case cs is
      when none =>
        dstart <= '0';
        estart <= '0';
        osel   <= 0;
        esend  <= "00";
        estart <= '0';
        if ecycle = '1' then
          ns   <= hdrw;
        else
          ns   <= none;
        end if;

      when hdrw =>
        dstart <= '0';
        estart <= '0';
        osel   <= 0;
        esend  <= "00";
        estart <= '0';
        if bpos = 48 then
          ns   <= dvalidch;
        else
          ns   <= hdrw;
        end if;


      when dvalidch =>
        dstart <= '0';
        estart <= '0';
        osel   <= 0;
        esend  <= "00";
        estart <= '0';
        if dvalid(curgrant) = '1' then
          ns   <= dsend;
        else
          if bpos = 200 then
            ns <= echk1;
          else
            ns <= dvalidch;
          end if;
        end if;

      when dsend =>
        dstart <= '1';
        estart <= '0';
        osel   <= 0;
        esend  <= "00";
        estart <= '0';
        if ddone = '1' then
          ns   <= echk1;
        else
          ns   <= dsend;
        end if;

      when echk1 =>
        dstart <= '0';
        estart <= '0';
        osel   <= 1;
        esend  <= "00";
        estart <= '0';
        if evalid(0) = '1' then
          ns   <= esend1;
        else
          ns   <= echk2;
        end if;

      when esend1 =>
        dstart <= '0';
        estart <= '0';
        osel   <= 1;
        esend  <= "00";
        estart <= '1';
        if edone = '1' then
          ns   <= echk2;
        else
          ns   <= esend1;
        end if;

      when echk2 =>
        dstart <= '0';
        estart <= '0';
        osel   <= 1;
        esend  <= "01";
        estart <= '0';
        if evalid(1) = '1' then
          ns   <= esend2;
        else
          ns   <= echk3;
        end if;

      when esend2 =>
        dstart <= '0';
        estart <= '1';
        osel   <= 1;
        esend  <= "01";
        estart <= '1';
        if edone = '1' then
          ns   <= echk3;
        else
          ns   <= esend2;
        end if;



      when echk3 =>
        dstart <= '0';
        estart <= '0';
        osel   <= 1;
        esend  <= "10";
        estart <= '0';
        if evalid(2) = '1' then
          ns   <= esend3;
        else
          ns   <= echk4;
        end if;

      when esend3 =>
        dstart <= '0';
        estart <= '0';
        osel   <= 1;
        esend  <= "10";
        estart <= '1';
        if edone = '1' then
          ns   <= echk4;
        else
          ns   <= esend3;
        end if;



      when echk4 =>
        dstart <= '0';
        estart <= '0';
        osel   <= 1;
        esend  <= "11";
        estart <= '0';
        if evalid(3) = '1' then
          ns   <= esend4;
        else
          ns   <= none;
        end if;

      when esend4 =>
        dstart <= '0';
        estart <= '0';
        osel   <= 1;
        esend  <= "11";
        estart <= '1';
        if edone = '1' then
          ns   <= none;
        else
          ns   <= esend4;
        end if;


      when others =>
        dstart <= '0';
        estart <= '0';
        osel   <= 1;
        esend  <= "00";
        estart <= '0';
        ns     <= none;
    end case;

  end process fsm;



end Behavioral;
