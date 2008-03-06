library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;
use ieee.numeric_std.all;



library UNISIM;
use UNISIM.VComponents.all;

entity eventtxtesttest is
end eventtxtesttest;

architecture Behavioral of eventtxtesttest is

  component eventtxtest
    port (
      REFCLKIN  : in  std_logic;
      DSPCLKOUT : out std_logic;
      DSPRESET  : out std_logic;
      EVENTENA  : out std_logic;
      EVENTTXD  : out std_logic_vector(7 downto 0)
      );
  end component;

  signal REFCLKIN  : std_logic                    := '0';
  signal DSPCLKOUT : std_logic                    := '0';
  signal DSPRESET  : std_logic                    := '0';
  signal LEDPOWER  : std_logic                    := '0';
  signal DIN       : std_logic_vector(7 downto 0) := (others => '0');
  signal KIN       : std_logic                    := '0';
  signal INTGEN    : std_logic                    := '1';
  signal ERRIN     : std_logic                    := '0';
  signal EVENTENA  : std_logic                    := '0';
  signal EVENTENB  : std_logic                    := '0';
  signal EVENTENC  : std_logic                    := '0';
  signal EVENTEND  : std_logic                    := '0';
  signal EVENTTXD  : std_logic_vector(7 downto 0) := (others => '0');

  signal clk : std_logic := '0';
  
  signal epos : integer range 0 to 999 := 999;

  signal AEN, BEN, CEN, DEN : std_logic_vector(79 downto 0) := (others => '0');
  signal ecycle             : std_logic                     := '0';

  type rxevents_t is array(0 to 79) of integer;

  
begin  -- Behavioral

  INTGEN <= '1'; 
  REFCLKIN <= not REFCLKIN after 10 ns;

  eventtxtest_uut: eventtxtest
    port map (
      REFCLKIN  => REFCLKIN,
      DSPCLKOUT => DSPCLKOUT,
      DSPRESET  => DSPRESET,
      --LEDPOWER  => LEDPOWER,
      EVENTENA  => EVENTENA,
      EVENTTXD  => EVENTTXD);

  
end Behavioral;


