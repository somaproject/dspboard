library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following lines to use the declarations that are
-- provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity framedis is
  port ( CLK        : in  std_logic;
         RESET      : in  std_logic;
         DIN        : in  std_logic_vector(7 downto 0);
         INWE       : in  std_logic;
         KIN        : in  std_logic;
         LINKUPIN : in std_logic; 
         LINKUP     : out std_logic;
         NEWSAMPLES : out std_logic;
         SAMPLE     : out std_logic_vector(15 downto 0);
         SAMPLESEL  : in  std_logic_vector(3 downto 0);
         CMDID      : out std_logic_vector(3 downto 0);
         CMDST      : out std_logic_vector(3 downto 0);
         VERSION : out std_logic_vector(7 downto 0); 
         SUCCESS : out std_logic);
end framedis;

architecture Behavioral of framedis is

  -- decode signals
  signal inwel : std_logic                    := '0';
  signal data  : std_logic_vector(7 downto 0) := (others => '0');

  -- pre-latch data signals

  signal incnt : integer range 0 to 25 := 0;

  --command status
  signal lcmdst, lcmdid : std_logic_vector(3 downto 0) := (others => '0');
  signal lsuccess : std_logic := '0';
  signal donef : std_logic := '0';

  -- tiny fsm!
  type states is (up, down);
  signal cs, ns : states := down;

  component regfile
    generic (
      BITS  :     integer := 16);
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

  signal samplein     : std_logic_vector(15 downto 0) := (others => '0');
  signal sampleinaddr : std_logic_vector(3 downto 0)  := (others => '0');
  signal we, wea, web : std_logic                     := '0';

  signal doba, dobb : std_logic_vector(15 downto 0) := (others => '0');

  signal bufsel : std_logic := '0';

begin

  regfile_a : regfile
    generic map (
      BITS  => 16)
    port map (
      CLK   => CLK,
      DIA   => samplein,
      DOA   => open,
      ADDRA => sampleinaddr,
      WEA   => wea,
      DOB   => doba,
      ADDRB => SAMPLESEL);

  regfile_b : regfile
    generic map (
      BITS  => 16)
    port map (
      CLK   => CLK,
      DIA   => samplein,
      DOA   => open,
      ADDRA => sampleinaddr,
      WEA   => web,
      DOB   => dobb,
      ADDRB => SAMPLESEL);

  SAMPLE <= doba when bufsel = '1'              else dobb;
  wea    <= '1'  when we = '1' and bufsel = '0' else '0';
  web    <= '1'  when we = '1' and bufsel = '1' else '0';


  donef        <= '1'    when inwel = '1' and incnt = 24 else '0';
  sampleinaddr <= "0000" when incnt = 3                  else
                  "0001" when incnt = 5                  else
                  "0010" when incnt = 7                  else
                  "0011" when incnt = 9                  else
                  "0100" when incnt = 11                 else
                  "0101" when incnt = 13                 else
                  "0110" when incnt = 15                 else
                  "0111" when incnt = 17                 else
                  "1000" when incnt = 19                 else
                  "1001" when incnt = 21                 else
                  "1010";

  we <= '1' when incnt = 3 or incnt = 5 or incnt = 7
        or incnt = 9 or incnt = 11 or incnt = 13 or incnt = 15
        or incnt = 17 or incnt = 19 or incnt = 21 or incnt = 23 else '0';



  clock : process(CLK, RESET)
  begin
    if RESET = '1' then
      cs   <= down;
    else
      if rising_edge(CLK) then
        cs <= ns;

        inwel <= inwe;

        if (kin = '1' and DIN = X"BC") or
          linkupin = '0' then
          incnt   <= 0;
        else
          if inwe = '1' and incnt /= 24 then
            incnt <= incnt + 1;
          end if;
        end if;

        NEWSAMPLES <= donef;

        if (incnt = 1 or incnt = 3 or incnt = 5 or
            incnt = 7 or incnt = 9 or incnt = 11 or incnt = 13
            or incnt = 15 or incnt = 17 or incnt = 19 ) and inwe = '1' then
          samplein(15 downto 8) <= DIN;
        end if;

        if (incnt = 2 or incnt = 4 or incnt = 6 or incnt = 8 or
            incnt = 10 or incnt = 12 or incnt = 14 or incnt = 16
            or incnt = 18 or incnt = 20) and inwe = '1' then
          samplein(7 downto 0) <= DIN;
        end if;

        
        -- COMMAND-STATUS related registers
        if incnt = 21 and inwe = '1' then
          lcmdid <= DIN(4 downto 1);
          lsuccess <= DIN(0); 
        end if;

        if incnt = 0 and inwe = '1' then
          lcmdst <= DIN(3 downto 0);
        end if;
        
         if incnt = 24 and inwel = '1' then
           VERSION <= DIN; 
         end if;

        --- final latching
        if donef = '1' then
          bufsel <= not bufsel;

          CMDID <= lcmdid(3 downto 0);
          SUCCESS <= lsuccess; 

          CMDST <= lcmdst;
        end if;
      end if;
    end if;
  end process clock;

  fsm : process(cs, linkupin, donef) is
  begin
    case cs is
      when up     =>
        LINKUP <= '1';
        if linkupin = '0' then
          ns   <= down;
        else
          ns   <= up;
        end if;
      when down   =>
        LINKUP <= '0';
        if donef = '1' then
          ns   <= up;
        else
          ns   <= down;
        end if;
      when others =>
        LINKUP <= '0';
        ns     <= down;
    end case;
  end process fsm;


end Behavioral;
