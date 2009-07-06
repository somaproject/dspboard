library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity fiberrx is
  port (CLK      : in  std_logic;
        DIN      : in  std_logic;
        DATAOUT  : out std_logic_vector(7 downto 0);
        KOUT     : out std_logic;
        LINKUP : out std_logic; 
        DATAEN : out std_logic;
        RESET    : in  std_logic);
end fiberrx;

architecture Behavioral of fiberrx is


  signal curbit, lastbit       : std_logic := '0';
  signal dout, dout_en         : std_logic := '0';
  signal doutrdy, doutrdyl     : std_logic := '0';
  signal lldatalock, ldatalock : std_logic := '0';

  signal ticcnt : std_logic_vector(2 downto 0) := (others => '0');

  signal bitcnt : std_logic_vector(3 downto 0) := (others => '0');

  signal datareg, doutreg, dataregl :
    std_logic_vector(9 downto 0) := (others => '0');

  signal codeerr, disperr : std_logic := '0';
  signal nd               : std_logic := '0';


-- components
  component fiberdecode8b10b
    port (
      clk      : in  std_logic;
      din      : in  std_logic_vector(9 downto 0);
      dout     : out std_logic_vector(7 downto 0);
      kout     : out std_logic;
      ce       : in  std_logic;
      code_err : out std_logic;
      disp_err : out std_logic;
      sinit    : in  std_logic;
      nd       : out std_logic);
  end component;

  type   states is (down, up);
  signal cs, ns : states := down;
  
begin

  clocks : process(CLK, RESET)
  begin
    if RESET = '1' then
      cs <= down;
    else
      if rising_edge(CLK) then
        cs <= ns;

        -- input bits
        curbit  <= din;
        lastbit <= curbit;

        if lastbit = not curbit then
          ticcnt <= "000";
        else
          if ticcnt = "101" then
            ticcnt <= "000";
          else
            ticcnt <= ticcnt + 1;
          end if;

        end if;

        -- shift register, et. al.
        if dout_en = '1' then
          dout <= curbit;
        end if;

        if dout_en = '1' then
          datareg  <= dout & datareg(9 downto 1);
          dataregl <= datareg;
        end if;


        if dout_en = '1' then
          if datareg = "0101111100" or datareg = "1010000011" then
            bitcnt <= "0000";
          else
            if bitcnt = "1001" then
              bitcnt <= "0000";
            else
              bitcnt <= bitcnt + 1;
            end if;
          end if;
        end if;


        if bitcnt = "0000" and dout_en = '1' then
          doutreg <= dataregl;
        end if;

        doutrdyl  <= doutrdy;
        ldatalock <= lldatalock;
        if cs = up then
          DATAEN <= ldatalock;
        else
          DATAEN <= '0';
        end if;
      end if;
    end if;
  end process clocks;

  lldatalock <= '1' when doutrdyl = '0' and doutrdy = '1' else '0';

  LINKUP <= '1' when cs= up else '0';

  
  dout_en <= '1' when ticcnt = "011"  else '0';
  doutrdy <= '1' when bitcnt = "0011" else '0';

  -- instantiate decoder
  decode : fiberdecode8b10b
    port map (
      clk      => clk,
      din      => doutreg,
      dout     => DATAOUT,
      kout     => KOUT,
      code_err => codeerr,
      disp_err => disperr,
      ce       => lldatalock,
      nd       => nd,
      sinit    => '0');

  fsm : process(cs, codeerr, disperr, ldatalock, datareg)
  begin
    case cs is
      when down =>
        if datareg = "0101111100" or datareg = "1010000011" then
          ns <= up;
        else
          ns <= down;
        end if;
      when up =>
        if ldatalock = '1' then
          if codeerr = '0' and disperr = '0' then
            ns <= up;
          else
            ns <= down;
          end if;
        else
          ns <= up;
        end if;
        
      when others =>
        ns <= down;
        
    end case;
  end process fsm;


end Behavioral;
