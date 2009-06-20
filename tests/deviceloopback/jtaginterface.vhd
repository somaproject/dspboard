library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity jtaginterface is
  generic (
    JTAG1N : integer := 32;
    JTAG2N : integer := 32);
  port (
    CLK : in std_logic;
    DIN1 : in std_logic_vector(JTAG1N-1 downto 0);
    DOUT1 : out std_logic_vector(JTAG1N-1 downto 0);
    DOUT1EN : out std_logic; 
    DIN2 : in std_logic_vector(JTAG2N-1 downto 0);
    DOUT2 : out std_logic_vector(JTAG2N-1 downto 0);
    DOUT2EN : out std_logic
    );
end jtaginterface;

architecture Behavioral of jtaginterface is
  
  signal jtagcapture : std_logic := '0';
  signal jtagdrck1   : std_logic := '0';
  signal jtagdrck2   : std_logic := '0';
  signal jtagsel1    : std_logic := '0';
  signal jtagsel2    : std_logic := '0';
  signal jtagshift   : std_logic := '0';
  signal jtagtdi     : std_logic := '0';
  signal jtagtdo1    : std_logic := '0';
  signal jtagtdo2    : std_logic := '0';
  signal jtagupdate  : std_logic := '0';


  signal testout1 : std_logic_vector(JTAG1N-1 downto 0) := (others => '0');
  signal testout2 : std_logic_vector(JTAG2N-1 downto 0) := (others => '0');

  signal din1l : std_logic_vector(JTAG1N-1 downto 0) := (others => '0');
  signal din2l : std_logic_vector(JTAG2N-1 downto 0) := (others => '0');

  signal ldout1, lldout1 : std_logic_vector(JTAG1N -1 downto 0) := (others => '0');
  signal ldout2, lldout2 : std_logic_vector(JTAG2N -1 downto 0) := (others => '0');

  signal jtagsel1l, jtagsel1ll : std_logic := '0';
  signal jtagsel2l, jtagsel2ll : std_logic := '0';
  

begin  -- Behavioral


    BSCAN_SPARTAN3_inst : BSCAN_SPARTAN3
    port map (
      CAPTURE => jtagcapture,           -- CAPTURE output from TAP controller
      DRCK1   => jtagdrck1,             -- Data register output for USER1 functions
      DRCK2   => jtagDRCK2,             -- Data register output for USER2 functions
      SEL1    => jtagSEL1,              -- USER1 active output
      SEL2    => jtagSEL2,              -- USER2 active output
      SHIFT   => jtagSHIFT,             -- SHIFT output from TAP controller
      TDI     => jtagTDI,               -- TDI output from TAP controller
      UPDATE  => jtagUPDATE,            -- UPDATE output from TAP controller
      TDO1    => jtagtdo1,              -- Data input for USER1 function
      TDO2    => jtagtdo2               -- Data input for USER2 function
      );


  jtagtdo1         <= testout1(0);
  jtagtdo2         <= testout2(0);

  process(CLK)
    begin
      if rising_edge(CLK) then
        din1l <= DIN1;
        din2l <= DIN2;

        jtagsel1l <= jtagsel1;
        jtagsel1ll <= jtagsel1l;
        
        jtagsel2l <= jtagsel2;
        jtagsel2ll <= jtagsel2l;

        if jtagsel1ll = '1' and jtagsel1l = '0' then
          DOUT1EN <= '1';
          DOUT1 <= ldout1; 
        else
          DOUT1EN <= '0'; 
        end if;
        
        if jtagsel2ll = '1' and jtagsel2l = '0' then
          DOUT2EN <= '1';
          DOUT2 <= ldout2; 
        else
          DOUT2EN <= '0'; 
        end if;
        
      end if;
    end process; 
  process(jtagsel1, jtagsel2,  jtagdrck1, jtagdrck2,  jtagupdate)
  begin
    if jtagupdate = '1' then
      testout1     <= DIN1;
      testout2     <= DIN2;
      
      if jtagsel1 = '1'  then
        ldout1 <= lldout1;                
      end if;
      
      if jtagsel2 = '1' then
        ldout2 <= lldout2;        
      end if;

    else
      if rising_edge(jtagdrck1) then
        if jtagsel1 = '1' and jtagshift = '1' then
          testout1 <= testout1(0) & testout1(JTAG1N-1 downto 1);
          lldout1 <= jtagTDI & lldout1(JTAG1N-1 downto 1); 
        end if;
      end if;

      if rising_edge(jtagdrck2) then
        if jtagsel2 = '1' and jtagshift = '1' then
          testout2 <= testout2(0) & testout2(JTAG2N-1 downto 1);
          lldout2 <= jtagTDI & lldout2(JTAG1N-1 downto 1); 
        end if;
      end if;

      
    end if;
  end process;


  

end Behavioral;
