library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity sportacqser is

  port (
    CLK       : in  std_logic;
    SERCLK    : out std_logic;
    SERFS     : out std_logic;
    SERDT     : out std_logic;
    SERDRA    : in  std_logic;
    SERDRB    : in  std_logic;
    START     : in  std_logic;
    DONE      : out std_logic;
    SAMPLEIN  : in  std_logic_vector(15 downto 0);
    SAMPLESEL : out  std_logic_vector(3 downto 0);
    CMDSTS    : in  std_logic_vector(3 downto 0);
    CMDID     : in  std_logic_vector(3 downto 0);
    DATAOUTA  : out std_logic_vector(63 downto 0);
    DATAOUTB  : out std_logic_vector(63 downto 0)
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

   signal dataoutaint, dataoutbint : std_logic_vector(63 downto 0) :=
     (others => '0');

--   signal dataoutaint, dataoutbint : std_logic_vector(255 downto 0) :=
--     (others => '0');


  signal ldone : std_logic := '0';

  signal cmdstsl, cmdidl : std_logic_vector(3 downto 0) := (others => '0');

  signal doutbit, ldoutbit  : std_logic                     := '0';
  signal doutword : std_logic_vector(15 downto 0) := (others => '0');

begin  -- Behavioral

  DATAOUTA <= dataoutaint(63 downto 0);
  DATAOUTB <= dataoutbint(63 downto 0);

  doutword <= "0000" & cmdidl & "0000" & cmdstsl when bitpos(7 downto 4) = "0000"
              else SAMPLEIN;

  ldoutbit <= doutword(0)  when bitpos(3 downto 0) = "0000" else
             doutword(1)  when bitpos(3 downto 0) = "0001" else
             doutword(2)  when bitpos(3 downto 0) = "0010" else
             doutword(3)  when bitpos(3 downto 0) = "0011" else
             doutword(4)  when bitpos(3 downto 0) = "0100" else
             doutword(5)  when bitpos(3 downto 0) = "0101" else
             doutword(6)  when bitpos(3 downto 0) = "0110" else
             doutword(7)  when bitpos(3 downto 0) = "0111" else
             doutword(8)  when bitpos(3 downto 0) = "1000" else
             doutword(9)  when bitpos(3 downto 0) = "1001" else
             doutword(10) when bitpos(3 downto 0) = "1010" else
             doutword(11) when bitpos(3 downto 0) = "1011" else
             doutword(12) when bitpos(3 downto 0) = "1100" else
             doutword(13) when bitpos(3 downto 0) = "1101" else
             doutword(14) when bitpos(3 downto 0) = "1110" else
             doutword(15);
  samplesel <= bitpos(7 downto 4) - 1;
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      -- outputs
      SERDT  <= ldoutbit; 
      SERCLK <= lsclk;
      SERFS  <= lfs;

      serdral <= SERDRA;
      serdrbl <= SERDRB;

       if inenll = '1' and bitpos(7 downto 4) <= X"3" then
         dataoutaint <= serdral & dataoutaint(63 downto 1);
         dataoutbint <= serdrbl & dataoutbint(63 downto 1);
       end if;

--       if inenll = '1'then
--         dataoutaint <= serdral & dataoutaint(255 downto 1);
--         dataoutbint <= serdrbl & dataoutbint(255 downto 1);
--       end if;

      if cs = none and START = '1' then
        cmdstsl   <= CMDSTS;
        cmdidl    <= CMDID;
      else
        --if cs = clkh then
        --doutbit <= ldoutbit; 
        --end if;
      end if;

      if cs = dones then                -- add latency to compensate
        ldone <= '1';                   -- for serial input pipeline
      else
        ldone <= '0';
      end if;
      DONE    <= ldone;

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
