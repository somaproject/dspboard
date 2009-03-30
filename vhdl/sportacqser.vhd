library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity sportacqser is
  port (
    CLK         : in  std_logic;
    SERCLK      : in  std_logic;
    SERTFS      : out std_logic;
    SERDT       : out std_logic;
    START       : in  std_logic;
    DONE        : out std_logic;
    SAMPLEIN    : in  std_logic_vector(15 downto 0);
    SAMPLESEL   : out std_logic_vector(3 downto 0);
    CMDSTS      : in  std_logic_vector(3 downto 0);
    CMDID       : in  std_logic_vector(3 downto 0);
    SUCCESS : in std_logic;
    VERSION : in std_logic_vector(7 downto 0)
    );

end sportacqser;

architecture Behavioral of sportacqser is

  signal dinsreg          : std_logic_vector(255 downto 0) := (others => '0');
  signal lsclk, lfs, fsl  : std_logic                      := '0';
  signal serdral, serdrbl : std_logic                      := '0';

  signal serclkl : std_logic := '0';


  signal inenl, inenll : std_logic := '0';

  signal bitpos : std_logic_vector(7 downto 0) := (others => '0');

  type states is (none, serclksync, extralow,
                  tfs1, tfs2, tfs3, clkl, clkh, clkl2, dones);
  signal cs, ns : states := none;


  signal ldone : std_logic := '0';

  signal cmdstsl, cmdidl : std_logic_vector(3 downto 0) := (others => '0');

  signal successl : std_logic := '0';
  
  signal doutbit, ldoutbit : std_logic                     := '0';
  signal doutword          : std_logic_vector(15 downto 0) := (others => '0');

  signal versionl : std_logic_vector(7 downto 0);
  
begin  -- Behavioral

  doutword <= successl & "000" & cmdidl & "0000" & cmdstsl when bitpos(7 downto 4) = X"0"
              else X"00" & versionl when bitpos(7 downto 4) = X"C"
              else SAMPLEIN;

  ldoutbit  <= doutword(0)  when bitpos(3 downto 0) = "0000" else
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
      serclkl <= SERCLK;

      SERDT <= ldoutbit;
      SERTFS <= lfs;

--       serdral <= SERDRA;
--       serdrbl <= SERDRB;

-- if inenll = '1'then
-- dataoutaint <= serdral & dataoutaint(255 downto 1);
-- dataoutbint <= serdrbl h& dataoutbint(255 downto 1);
-- end if;

      if cs = none and START = '1' then
        cmdstsl <= CMDSTS;
        cmdidl  <= CMDID;
        successl <= SUCCESS; 
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

      if cs = clkl2 then                --  and SERCLK = '1' then
        bitpos <= bitpos + 1;
      end if;

      if cs = clkh then
        inenl <= '1';
      else
        inenl <= '0';
      end if;

      inenll <= inenl;
      versionl <= VERSION;
      
    end if;
  end process main;

  fsm : process(cs, SERCLKl, START, bitpos)
  begin
    case cs is
      when none =>
        lfs  <= '0';
        if START = '1' then
          ns <= serclksync;
        else
          ns <= none;
        end if;

      when serclksync =>                -- syncrhonized to external clk
        lfs  <= '0';
        if serclkl = '0' then
          ns <= serclksync;
        else
          ns <= tfs1;
        end if;

      when tfs1 =>
        lfs <= '1';
        ns  <= tfs2;

      when tfs2 =>
        lfs <= '1';

        ns <= tfs3;

      when tfs3 =>
        lfs <= '1';

        ns <= clkl;

      when clkl =>
        lfs <= '0';
        ns  <= clkh;

      when clkh =>
        lfs <= '0';
        ns  <= clkl2;


      when clkl2 =>
        lfs  <= '0';
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
