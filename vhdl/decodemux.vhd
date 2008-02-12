library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity decodemux is
  port (
    CLK    : in std_logic;
    DIN    : in std_logic_vector(7 downto 0);
    KIN    : in std_logic;
    LOCKED : in std_logic;

    ECYCLE : out std_logic;
    EDATA  : out std_logic_vector(7 downto 0);

    -- data interface
    DGRANTA : out std_logic;
    EARXA   : out std_logic_vector(79 downto 0) := (others => '0');
    DGRANTB : out std_logic;
    EARXB   : out std_logic_vector(79 downto 0) := (others => '0');
    DGRANTC : out std_logic;
    EARXC   : out std_logic_vector(79 downto 0)  := (others => '0');
    DGRANTD : out std_logic;
    EARXD   : out std_logic_vector(79 downto 0) := (others => '0')
    );
end decodemux;

architecture Behavioral of decodemux is

  signal hdrpos : integer range 0 to 10 := 0;
  signal hdrnum : integer range 0 to 4  := 0;

  type states is (none, hdrst, hdrwait, hdrnext, hdrdone);
  signal cs, ns : states := none;

begin  -- Behavioral

  ECYCLE <= '1' when KIN = '1' and DIN = X"BC" else '0';
  
  EDATA <= DIN; 
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      if locked = '1' then
        cs <= ns;
      else
        cs <= none;
      end if;

      -- HDRPOS 
      if cs = none then
        hdrpos <= 0;
      else
        if cs = hdrnext  then
          hdrpos <= 0;
        else
          if cs = hdrst or cs = hdrwait then
            hdrpos <= hdrpos + 1;
          end if;
        end if;
      end if;

      -- HDRNUM
      if cs = none then
        hdrnum <= 0;
      else
        if cs = hdrnext  then
          hdrnum <= hdrnum + 1; 
        end if;
      end if;

      if hdrnum = 0 and cs = hdrst then
        DGRANTA <= DIN(0); 
      end if;
      
      if hdrnum = 1 and cs = hdrst then
        DGRANTB <= DIN(0); 
      end if;
      
      if hdrnum = 2 and cs = hdrst then
        DGRANTC <= DIN(0); 
      end if;
      
      if hdrnum = 3 and cs = hdrst then
        DGRANTD <= DIN(0); 
      end if;

    end if;
  end process main;

  earxcapture: for i in 1 to 10 generate
    hdrcap : process(CLK)
      begin
        if rising_edge(CLK) then
          if hdrnum = 0 and hdrpos = i then
            EARXA(i *8 - 1 downto i*8-8) <= DIN; 
          end if;
          
          if hdrnum = 1 and hdrpos = i then
            EARXB(i *8 - 1 downto i*8-8) <= DIN; 
          end if;
          
          if hdrnum = 2 and hdrpos = i then
            EARXC(i *8 - 1 downto i*8-8) <= DIN; 
          end if;
          
          if hdrnum = 3 and hdrpos = i then
            EARXD(i *8 - 1 downto i*8-8) <= DIN; 
          end if;
        end if;
      end process hdrcap; 
  end generate earxcapture;

  fsm: process(cs, KIN, DIN, hdrpos, hdrnum)
    begin
      case cs is
        when none =>
          if KIN = '1' and DIN = X"BC" then
            ns <= hdrst;
          else
            ns <= none; 
          end if;

        when hdrst =>
          ns <= hdrwait;

        when hdrwait =>
          if hdrpos = 9 then
            ns <= hdrnext;
          else
            ns <= hdrwait; 
          end if;

        when hdrnext =>
          if hdrnum = 3 then
            ns <= hdrdone;
          else
            ns <= hdrst; 
          end if;

        when hdrdone =>
          ns <= none;

        when others =>
          ns <= none;
      end case;
    end process fsm;
    
end Behavioral;
