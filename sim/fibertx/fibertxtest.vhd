library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

entity fibertxtest is

end fibertxtest;

architecture Behavioral of fibertxtest is

  component fibertx
    port ( CLK      : in  std_logic;
           CMDIN    : in  std_logic_vector(47 downto 0);
           SENDCMD  : in  std_logic;
           FIBEROUT : out std_logic);

  end component;

  component fiberrx
    port ( CLK      : in  std_logic;
           DIN      : in  std_logic;
           DATAOUT  : out std_logic_vector(7 downto 0);
           KOUT     : out std_logic;
           CODE_ERR : out std_logic;
           DISP_ERR : out std_logic;
           DATALOCK : out std_logic;
           RESET    : in  std_logic);
  end component;

  signal CLK      : std_logic                     := '0';
  signal CMDIN    : std_logic_vector(47 downto 0) := (others => '0');
  signal SENDCMD  : std_logic                     := '0';
  signal FIBEROUT : std_logic                     := '0';

  signal rxclk              : std_logic                    := '0';
  signal rxdataout          : std_logic_vector(7 downto 0) := (others => '0');
  signal rxkout               : std_logic                    := '0';
  signal rxcode_err, rxdisp_err : std_logic                    := '0';

  signal rxdatalock : std_logic := '0';
  signal rxreset     : std_logic := '0';

  signal cmdreceived : std_logic_vector(47 downto 0) := (others => '0');
  

begin  -- Behavioral
  
  CLK <= not CLK after 6.25 ns;
  rxclk <= not rxclk after 10 ns;
  
  fibertx_uut : fibertx
    port map (
      CLK      => CLK,
      CMDIN    => CMDIN,
      SENDCMD  => SENDCMD,
      FIBEROUT => FIBEROUT);


  fiberrx_inst: fiberrx
    port map (
      CLK       => rxclk,
      DIN       => FIBEROUT,
      DATAOUT   => rxdataout,
      KOUT      => rxkout, 
      CODE_ERR  => rxcode_err,
      DISP_ERR  => rxdisp_err,
      DATALOCK => rxdatalock,
      RESET     => rxreset); 
    

  -- receive commands
  process(rxclk)
    begin
      if rising_edge(rxclk) then
        if rxdatalock = '1' then
          if rxcode_err = '0' and rxdisp_err = '0' then
            if rxkout = '1' and rxdataout = X"BC" then
              cmdreceived <= (others => '0');
            else
              cmdreceived <= rxdataout & cmdreceived(47 downto 8) ; 
            end if;
          end if;
        end if;
      end if;

    end process; 
  -- send test commands
  process
  begin
    wait for 10 us;

    -- this is a dummy send
    wait until rising_edge(rxclk);
    CMDIN   <= X"000000000000";
    SENDCMD <= '1';
    wait until rising_edge(rxclk);
    CMDIN   <= (others => '0');
    SENDCMD <= '0';
    wait for 20 us;
    
        
    wait until rising_edge(rxclk);
    CMDIN   <= X"554433221100";
    SENDCMD <= '1';
    wait until rising_edge(rxclk);
    CMDIN   <= (others => '0');
    SENDCMD <= '0';

    wait until rising_edge(rxclk) and cmdreceived = X"554433221100";
    report "End of Simulation" severity Failure;
    
    
    
  end process;



end Behavioral;

