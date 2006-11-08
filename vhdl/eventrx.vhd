library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity eventrx is
  port (
    CLK      : in  std_logic;
    SCLK     : in  std_logic;
    SDIN     : in  std_logic;
    SCS      : in  std_logic;
    DOUT     : out std_logic_vector(7 downto 0);
    ADDROUT  : in  std_logic_vector(4 downto 0);
    NEXTFIFO : in  std_logic;
    VALID    : out std_logic);
end eventrx;

architecture Behavioral of eventrx is

  -- input latching
  signal sclkl, sclkll : std_logic := '0';
  signal sdinl         : std_logic := '0';
  signal scsl          : std_logic := '1';

  signal sreg  : std_logic_vector(15 downto 0) := (others => '0');
  signal bpcnt : std_logic_vector(5 downto 0)  := (others => '0');
  signal wea   : std_logic                     := '0';

  signal addra : std_logic_vector(10 downto 0) := (others => '0');

  -- 
  signal bpl   : std_logic_vector(5 downto 0)  := (others => '0');
  signal addrb : std_logic_vector(10 downto 0) := (others => '0');

  type states is (none, inwait, donechk, donebuf, donewd);  -- s
  signal cs, ns : states := none;


begin  -- Behavioral

  addra <= bpcnt & sreg(12 downto 8);

  addrb(4 downto 0) <= ADDROUT;

  VALID <= '1' when bpl /= addrb(10 downto 5) else '0';
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then

      cs <= ns;
      
      sclkl <= SCLK;
      sdinl <= SDIN;
      scsl  <= SCS;

      sclkll <= sclkl;

      if sclkll = '0' and sclkl = '1' then
        sreg <= sreg(14 downto 0) & sdinl;
      end if;

      if cs = donebuf then
        bpcnt <= bpcnt + 1;
      end if;

      -- output side
      bpl                  <= bpcnt;
      if NEXTFIFO = '1' then
        addrb(10 downto 5) <= addrb(10 downto 5) + 1;
      end if;


    end if;
  end process main;


  RAMB16_S9_S9_inst : RAMB16_S9_S9
    generic map (
      SIM_COLLISION_CHECK => "NONE")
      port map (
      DOA                 => open,     
      DOB                 => DOUT,     
      DOPA                => open,    
      DOPB                => open,    
      ADDRA               => addra,   
      ADDRB               => addrb,   
      CLKA                => CLK,    
      CLKB                => CLK,    
      DIA                 => sreg(7 downto 0),     
      DIB                 => X"00",     
      DIPA                => "0",    
      DIPB                => "0",    
      ENA                 => '1',     
      ENB                 => '1',     
      SSRA                => '0',    
      SSRB                => '0',    
      WEA                 => wea,     
      WEB                 => '0'      
      );

   fsm: process(cs, scsl, sreg)
     begin
       case cs is
         when none =>
           wea <= '0';
           if scsl = '0' then
             ns <= inwait;
           else
             ns <= none; 
           end if;

         when inwait =>
           wea <= '0';
           if scsl = '1' then
             ns <= donechk;
           else
             ns <= inwait; 
           end if;


         when donechk=>
           wea <= '0';
           if sreg(15) = '1' then
             ns <= donebuf; 
           else
             ns <= donewd; 
           end if;

         when donewd=>
           wea <= '1';
           ns <= none;

         when donebuf =>
           wea <= '0';
           ns <= none;

         when others =>
           wea <= '0';
           ns <= none;

       end case;
     end process fsm;
     
      
end Behavioral;
