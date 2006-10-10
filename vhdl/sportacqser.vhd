library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity sportacqser is

  port (
    CLK      : in  std_logic;
    SERCLK   : out std_logic;
    SERFS: out std_logic; 
    SERDT    : out std_logic;
    SERDRA   : in  std_logic;
    SERDRB   : in  std_logic;
    START    : in  std_logic;
    DONE     : out std_logic;
    DATAIN   : in  std_logic_vector(255 downto 0);
    DATAOUTA : out std_logic_vector(255 downto 0);
    DATAOUTB : out std_logic_vector(255 downto 0)
    );

end sportacqser;

architecture Behavioral of sportacqser is

  signal dinsreg          : std_logic_vector(255 downto 0) := (others => '0');
  signal lsclk, lfs       : std_logic                      := '0';
  signal serdral, serdrbl : std_logic                      := '0';

  signal inenl, inenll : std_logic := '0';

  signal bitpos : std_logic_vector(7 downto 0) := (others => '0');

  type states is (none, tfs1, tfs2, clkl, clkh, dones);
  signal cs, ns : states := none;

  signal dataoutaint, dataoutbint : std_logic_vector(255 downto 0) :=
    (others => '0');

  
  signal ldone : std_logic := '0';
  
begin  -- Behavioral

  DATAOUTA <= dataoutaint;
  DATAOUTB <= dataoutbint;


  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      -- outputs
      SERDT  <= dinsreg(0);
      SERCLK <= lsclk;
      SERFS  <= lfs;

      serdral <= SERDRA;
      serdrbl <= SERDRB;

      if inenll = '1' then
        dataoutaint <= serdral &  dataoutaint(255 downto 1); 
        dataoutbint <= serdrbl &  dataoutbint(255 downto 1); 
      end if;

      if cs = none and START = '1' then
        dinsreg   <= DATAIN;
      else
        if cs = clkh then
          dinsreg <= '0' &  dinsreg(255 downto 1); 
        end if;
      end if;

      if cs = dones then                -- add latency to compensate
        ldone <= '1';                   -- for serial input pipeline
      else
        ldone<= '0';
      end if;
      DONE <= ldone;
      
      if cs = clkh then
        bitpos <= bitpos + 1;
      end if;

      if cs = clkh then
        inenl <= '1';
      else
        inenl <= '0';
      end if;

      inenll <= inenl;

    end if;
  end process main;

  fsm : process(cs, START, bitpos)
  begin
    case cs is
      when none =>
        lsclk <= '0';
        lfs   <= '0';
        if START = '1' then
          ns  <= tfs1;
        else
          ns  <= none;
        end if;

      when tfs1 =>
        lsclk <= '0';
        lfs   <= '1';
        ns    <= tfs2;

      when tfs2 =>
        lsclk <= '1';
        lfs   <= '1';
        ns    <= clkl;

      when clkl =>
        lsclk <= '0';
        lfs   <= '0';
        ns    <= clkh;

      when clkh =>
        lsclk <= '1';
        lfs   <= '0';

        if bitpos = X"FF" then
          ns <= dones;
        else
          ns <= clkl;
        end if;

      when dones =>
        lsclk <= '0';
        lfs   <= '0';
        ns    <= none;

      when others =>
        lsclk <= '0';
        lfs   <= '0';
        ns    <= none;
    end case;
  end process fsm;

end Behavioral;
