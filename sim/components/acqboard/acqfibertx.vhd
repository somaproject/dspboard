library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following lines to use the declarations that are
-- provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity acqfibertx is
  port ( CLK        : in  std_logic;
         CLK8       : in  std_logic;
         RESET      : in  std_logic;
         OUTSAMPLE  : in  std_logic;
         FIBEROUT   : out std_logic;
         CMDDONE    : in  std_logic;
         Y          : in  std_logic_vector(15 downto 0);
         YEN        :     std_logic;
         CMDSTS     : in  std_logic_vector(3 downto 0);
         CMDID      : in  std_logic_vector(3 downto 0);
         CMDSUCCESS : in  std_logic;
         OUTBYTE    : in  std_logic;
         CHKSUM     : in  std_logic_vector(7 downto 0));
end Acqfibertx;

architecture Behavioral of Acqfibertx is

  -- input latches
  signal csl, csll : std_logic_vector(3 downto 0) := (others => '0');

  type samparray is array (0 to 9) of std_logic_vector(15 downto 0);
  signal yl, yout : samparray := (X"0000", X"1000", X"2000",
                                  X"3000", X"4000", X"5000",
                                  X"6000", X"7000", X"8000",
                                  X"9000");

  signal cl, cll   : std_logic_vector(7 downto 0)
 := (others => '0');
  signal ckl, ckll : std_logic_vector(7 downto 0)
 := (others => '0');

  -- counters
  signal incnt : integer range 0 to 9  := 0;
  signal bcnt  : integer range 0 to 24 := 0;

  -- output signals
  signal dmux, dmuxl : std_logic_vector(7 downto 0) := (others => '0');
  signal kin         : std_logic                    := '0';
  signal dout        : std_logic_vector(9 downto 0) := (others => '0');
  signal sout        : std_logic                    := '0';
  signal shiftreg    : std_logic_vector(9 downto 0) := (others => '0');


  --8b/10b encoder

  component encode8b10b
    port (
      din  : in  std_logic_vector(7 downto 0);
      kin  : in  std_logic;
      clk  : in  std_logic;
      dout : out std_logic_vector(9 downto 0);
      ce   : in  std_logic);
  end component;

begin


  encode : encode8b10b port map (
    din  => dmuxl,
    dout => dout,
    clk  => CLK,
    kin  => kin,
    ce   => outbyte);

  sout <= shiftreg(0);



  ylatches : for i in 0 to 9 generate
  begin
    process(clk)
    begin
      if rising_edge(CLK) then
        if incnt = i and YEN = '1' then
          yl(i)   <= Y;
        end if;
        if OUTSAMPLE = '1' then
          yout(i) <= yl(i);
        end if;
      end if;
    end process;
  end generate;

  dmux <= X"BC"                when bcnt = 0  else
          "0000" & CSLL        when bcnt = 1  else
          yout(0)(15 downto 8) when bcnt = 2  else
          yout(0)(7 downto 0)  when bcnt = 3  else
          yout(1)(15 downto 8) when bcnt = 4  else
          yout(1)(7 downto 0)  when bcnt = 5  else
          yout(2)(15 downto 8) when bcnt = 6  else
          yout(2)(7 downto 0)  when bcnt = 7  else
          yout(3)(15 downto 8) when bcnt = 8  else
          yout(3)(7 downto 0)  when bcnt = 9  else
          yout(4)(15 downto 8) when bcnt = 10 else
          yout(4)(7 downto 0)  when bcnt = 11 else
          yout(5)(15 downto 8) when bcnt = 12 else
          yout(5)(7 downto 0)  when bcnt = 13 else
          yout(6)(15 downto 8) when bcnt = 14 else
          yout(6)(7 downto 0)  when bcnt = 15 else
          yout(7)(15 downto 8) when bcnt = 16 else
          yout(7)(7 downto 0)  when bcnt = 17 else
          yout(8)(15 downto 8) when bcnt = 18 else
          yout(8)(7 downto 0)  when bcnt = 19 else
          yout(9)(15 downto 8) when bcnt = 20 else
          yout(9)(7 downto 0)  when bcnt = 21 else
          cll                  when bcnt = 22 else
          ckll                 when bcnt = 23 else
          X"57";                        -- fake version number


  main : process(clk, reset)
  begin
    if RESET = '1' then
      bcnt    <= 0;
      incnt   <= 0;
    else
      if rising_edge(clk) then

        csl <= CMDSTS;
                  
        if CMDDONE = '1' then
          cl  <= "000" & CMDID & CMDSUCCESS;
          ckl <= CHKSUM;
        end if;

        if OUTSAMPLE = '1' then
          csll <= csl;
          cll  <= cl;
          ckll <= ckl;
        end if;

        if OUTSAMPLE = '1' then
          incnt     <= 0;
        else
          if YEN = '1' then
            if incnt = 9 then
              incnt <= 0;
            else
              incnt <= incnt + 1;
            end if;

          end if;
        end if;

        if OUTBYTE = '1' then
          if bcnt = 24 then
            bcnt <= 0;
          else
            bcnt <= bcnt + 1;
          end if;
        end if;

        if OUTBYTE = '1' then
          dmuxl <= dmux;
          if bcnt = 0 then
            kin <= '1';
          else
            kin <= '0';
          end if;
        end if;

        -- shift register
        if OUTBYTE = '1' then
          shiftreg   <= dout;
        else
          if clk8 = '1' then
            shiftreg <= '0' & shiftreg(9 downto 1);
          end if;
        end if;

        if CLK8 = '1' then
          FIBEROUT <= sout;
        end if;




      end if;
    end if;


  end process main;

end Behavioral;
