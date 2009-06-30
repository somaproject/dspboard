library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity encodedata is
  port (
    CLK          : in  std_logic;       -- '0'
    ECYCLE       : in  std_logic;
    ENCODEEN     : in  std_logic;
    HEADERDONE   : in  std_logic;
    -- encodemux interface
    DREQ         : out std_logic;
    DGRANT       : in  std_logic;
    DDONE        : out std_logic;
    DDATA        : out std_logic_vector(7 downto 0);
    DKIN         : out std_logic;
    -- datamux interface
    BSTARTCYCLE  : in  std_logic;
    ENCDOUT      : in  std_logic_vector(7 downto 0);
    ENCDNEXTBYTE : out std_logic;
    ENCDREQ      : in  std_logic;
    ENCDLASTBYTE : in  std_logic
    );
end encodedata;


architecture Behavioral of encodedata is

  signal dgrantl : std_logic_vector(3 downto 0) := (others => '0');

  signal lastbytel : std_logic := '0';

  type states is (none, hdrwait, sendchk, setactive, checkreq,
                  grantw, startbpre,
                  startb, sendbdat, ddone1, ddone2);

  signal llddone : std_logic := '0';
  signal lddone  : std_logic := '0';

  signal cs, ns : states := none;

  constant BURSTCNTMAX : integer := 3;
  constant BURSTPOSMAX : integer := 247;

  signal burstcnt : integer range 0 to BURSTCNTMAX := 0;
  signal bpos     : integer range 0 to BURSTPOSMAX := 0;

  constant K28_4 : std_logic_vector(7 downto 0) := X"9C";
  constant K28_6 : std_logic_vector(7 downto 0) := X"DC";
  constant K28_7 : std_logic_vector(7 downto 0) := X"FC";

  constant K_BSTART : std_logic_vector(7 downto 0) := K28_6;
  constant K_BEND   : std_logic_vector(7 downto 0) := K28_7;
  constant K_COMMIT : std_logic_vector(7 downto 0) := K28_4;
  
begin  -- Behavioral


  DDATA <= K_BSTART when cs = startb else
           ENCDOUT  when cs = sendbdat else
           K_BEND   when cs = ddone1   else
           K_COMMIT when cs = ddone2   else
           X"00";

  DKIN <= '1' when cs = startb else
          '1' when cs = ddone1 else
          '1' when cs = ddone2 else '0';

  ENCDNEXTBYTE <= ENCODEEN when cs = sendbdat else '0';


  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      if cs = grantw then
        lastbytel <= '0';
      else
        if ENCODEEN = '1' then
          lastbytel <= ENCDLASTBYTE;
        end if;
      end if;

      if ENCODEEN = '1' then
        if cs = ddone1 then
          llddone <= '1';
        else
          llddone <= '0';
        end if;

        lddone <= llddone;
        DDONE  <= lddone;
      end if;

      if cs = grantw then
        DREQ <= '1';
      else
        DREQ <= '0';
      end if;

      if ENCODEEN = '1' then
        if cs = ddone1 then
          if burstcnt /=  BURSTCNTMAX then
            burstcnt <= burstcnt + 1;
          end if;
        else
          if cs = none then
            burstcnt <= 0; 
          end if;
        end if;
      end if;

      if ENCODEEN = '1'  then
        if cs = sendbdat then
          if bpos /= BURSTPOSMAX then
            bpos <= bpos + 1;
          end if;
        elsif cs = grantw then
          bpos <= 0; 
        end if;
      end if;
      
    end if;
  end process main;

  fsm : process(cs, ECYCLE, HEADERDONE, DGRANT, ENCODEEN, lastbytel,
                bpos)
  begin
    case cs is
      when none =>
        if ECYCLE = '1' then
          ns <= hdrwait;
        else
          ns <= none;
        end if;

      when hdrwait =>
        if HEADERDONE = '1' then
          ns <= sendchk;
        else
          ns <= hdrwait;
        end if;

      when sendchk =>
        if BSTARTCYCLE = '1' then
          ns <= checkreq;
        else
          ns <= none;
        end if;

      when checkreq =>
        if ENCDREQ = '1' then
          ns <= grantw;
        else
          ns <= none;
        end if;
        
      when grantw =>
        if DGRANT = '1' then
          ns <= startbpre;
        else
          ns <= grantw;
        end if;

      when startbpre =>
        if encodeen = '1' then
          ns <= startb;
        else
          ns <= startbpre;
        end if;

      when startb =>
        if encodeen = '1' then
          ns <= sendbdat;
        else
          ns <= startb;
        end if;

      when sendbdat =>
        if encodeen = '1' then
          if ENCDLASTBYTE = '1' or bpos = BURSTPOSMAX then
            ns <= ddone1;
          else
            ns <= sendbdat;
          end if;
        else
          ns <= sendbdat;
        end if;
        
      when ddone1 =>
        if encodeen = '1' then
          if lastbytel = '1' or (bpos = burstposmax and burstcnt = BURSTCNTMAX) then
            ns <= ddone2;
          else
            ns <= grantw;
          end if;
        else
          ns <= ddone1;
        end if;

      when ddone2 =>
        if encodeen = '1' then
          ns <= none;
        else
          ns <= ddone2;
        end if;
        
      when others =>
        ns <= none;
        
    end case;

  end process fsm;

end Behavioral;
