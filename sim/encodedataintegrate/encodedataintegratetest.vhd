library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity encodedataintegratetest is

end encodedataintegratetest;

architecture Behavioral of encodedataintegratetest is

  component encodedata
    port (
      CLK          : in  std_logic;     -- '0'
      ECYCLE       : in  std_logic;
      ENCODEEN     : in  std_logic;
      HEADERDONE   : in  std_logic;
      -- encodemux interface
      DREQ         : out std_logic;
      DGRANT       : in  std_logic;
      DDONE        : out std_logic;
      DDATA        : out std_logic_vector(7 downto 0);
      DKIN         : out std_logic;
      -- datamux interface
      BSTARTCYCLE  : in  std_logic;
      ENCDOUT      : in  std_logic_vector(7 downto 0);
      ENCDNEXTBYTE : out std_logic;
      ENCDREQ      : in  std_logic;
      ENCDLASTBYTE : in  std_logic
      );
  end component;

  component encodemux
    port (
      CLK         : in  std_logic;
      ECYCLE      : in  std_logic;
      DOUT        : out std_logic_vector(7 downto 0);
      KOUT        : out std_logic;
      -- data interface
      DREQ        : in  std_logic;
      DGRANT      : out std_logic;
      DDONE       : in  std_logic;
      DDATA       : in  std_logic_vector(7 downto 0);
      DKIN        : in  std_logic;
      DATAEN      : out std_logic;
      -- event interface for DSPs
      EDSPREQ     : in  std_logic_vector(3 downto 0);
      EDSPGRANT   : out std_logic_vector(3 downto 0);
      EDSPDONE    : in  std_logic_vector(3 downto 0);
      EDSPDATAEN  : out std_logic;
      EDSPDATAA   : in  std_logic_vector(7 downto 0);
      EDSPDATAB   : in  std_logic_vector(7 downto 0);
      EDSPDATAC   : in  std_logic_vector(7 downto 0);
      EDSPDATAD   : in  std_logic_vector(7 downto 0);
      -- event interface for EPROCs
      EPROCREQ    : in  std_logic_vector(3 downto 0);
      EPROCGRANT  : out std_logic_vector(3 downto 0);
      EPROCDONE   : in  std_logic_vector(3 downto 0);
      EPROCDATAEN : out std_logic;
      EPROCDATAA  : in  std_logic_vector(7 downto 0);
      EPROCDATAB  : in  std_logic_vector(7 downto 0);
      EPROCDATAC  : in  std_logic_vector(7 downto 0);
      EPROCDATAD  : in  std_logic_vector(7 downto 0);
      DEBUG       : out std_logic_vector(63 downto 0));
  end component;

  component datamux
    port (
      CLK          : in  std_logic;
      ECYCLE       : in  std_logic;
      -- collection of grants
      DGRANTIN     : in  std_logic_vector(3 downto 0);
      -- datamux interface
      ENCDOUT      : out std_logic_vector(7 downto 0);
      ENCDNEXTBYTE : in  std_logic;
      ENCDREQ      : out std_logic;
      ENCDLASTBYTE : out std_logic;
      -- individual datasport interfaces
      DDATAA       : in  std_logic_vector(7 downto 0);
      DDATAB       : in  std_logic_vector(7 downto 0);
      DDATAC       : in  std_logic_vector(7 downto 0);
      DDATAD       : in  std_logic_vector(7 downto 0);
      DNEXTBYTE    : out std_logic_vector(3 downto 0);
      DREQ         : in  std_logic_vector(3 downto 0);
      DLASTBYTE    : in  std_logic_vector(3 downto 0)
      );
  end component;

  signal CLK         : std_logic                    := '0';  -- '0'
  signal ECYCLE      : std_logic                    := '0';
  signal ENCODEEN    : std_logic                    := '0';
  signal HEADERDONE  : std_logic                    := '0';
  -- encodemux interface
  signal DREQ        : std_logic                    := '0';
  signal DGRANT      : std_logic                    := '0';
  signal DDONE       : std_logic                    := '0';
  signal DDATA       : std_logic_vector(7 downto 0) := (others => '0');
  signal DKIN        : std_logic                    := '0';
  -- datamux interface
  signal BSTARTCYCLE : std_logic                    := '0';
  signal ENCDOUT     : std_logic_vector(7 downto 0) := (others => '0');

  signal ENCDNEXTBYTE : std_logic := '0';
  signal ENCDREQ      : std_logic := '0';
  signal ENCDLASTBYTE : std_logic := '0';

  signal linkdgrant : std_logic_vector(3 downto 0) := "1000";

  signal pos       : integer := 0;
  signal ecyclepos : integer := 0;

  constant PACKETCNT : integer := 12;
  type     packetlen_t is array (0 to PACKETCNT-1) of integer;
  constant packetlen : packetlen_t := (128, 200, 246, 247,
                                       248, 249, 250, 700,
                                       744, 1, 10, 128);

  constant K28_4 : std_logic_vector(7 downto 0) := X"9C";
  constant K28_6 : std_logic_vector(7 downto 0) := X"DC";
  constant K28_7 : std_logic_vector(7 downto 0) := X"FC";


  type   datamux_ddata_t is array (0 to 3) of std_logic_vector(7 downto 0);
  signal datamux_ddata : datamux_ddata_t := (others => (others => '0'));

  signal datamux_dnextbyte : std_logic_vector(3 downto 0) := (others => '0');
  signal datamux_dreq      : std_logic_vector(3 downto 0) := (others => '0');
  signal datamux_dlastbyte : std_logic_vector(3 downto 0) := (others => '0');

  signal data_validate_done : std_logic_vector(3 downto 0) := (others => '0');
  
  
begin  -- Behavioral

  CLK <= not CLK after 10 ns;

  ecycle_generation : process(CLK)
  begin
    if rising_edge(CLK) then
      if pos = 999 then
        pos <= 0;
      else
        pos <= pos + 1;
      end if;

      if pos = 999 then
        ECYCLE    <= '1' after 4 ns;
        ecyclepos <= ecyclepos + 1;
      else
        ECYCLE <= '0' after 4 ns;
      end if;

      ENCODEEN <= not ENCODEEN;

      if pos = 49 then
        HEADERDONE <= '1';
      else
        HEADERDONE <= '0';
      end if;

      if pos = 49 then
        if ecyclepos mod 4 = 3 then
          BSTARTCYCLE <= '1';
          linkdgrant  <= linkdgrant(2 downto 0) & linkdgrant(3);
        else
          BSTARTCYCLE <= '0';
        end if;

      end if;
      
    end if;
  end process ecycle_generation;

  encodedata_uut : encodedata
    port map (
      CLK          => CLK,
      ECYCLE       => ECYCLE,
      ENCODEEN     => ENCODEEN,
      HEADERDONE   => HEADERDONE,
      DREQ         => DREQ,
      DGRANT       => DGRANT,
      DDONE        => DDONE,
      DDATA        => DDATA,
      DKIN         => DKIN,
      BSTARTCYCLE  => BSTARTCYCLE,
      ENCDOUT      => ENCDOUT,
      ENCDNEXTBYTE => ENCDNEXTBYTE,
      ENCDREQ      => ENCDREQ,
      ENCDLASTBYTE => ENCDLASTBYTE);


  datamux_uut : datamux
    port map (
      CLK          => CLK,
      ECYCLE       => ECYCLE,
      DGRANTIN     => linkdgrant,
      ENCDOUT      => ENCDOUT,
      ENCDNEXTBYTE => ENCDNEXTBYTE,
      ENCDREQ      => ENCDREQ,
      ENCDLASTBYTE => ENCDLASTBYTE,
      DDATAA       => datamux_ddata(0),
      DDATAB       => datamux_ddata(1),
      DDATAC       => datamux_ddata(2),
      DDATAD       => datamux_ddata(3),
      DNEXTBYTE    => datamux_dnextbyte,
      DREQ         => datamux_dreq,
      DLASTBYTE    => datamux_dlastbyte);


  -----------------------------------------------------------------------------
  -- DATAMUX proc -- the process that sends the data, emulating the
  -- data sources
  -----------------------------------------------------------------------------
  datamux_src_gen : for src in 0 to 3 generate
    datamux_proc : process
    begin
      for i in 0 to PACKETCNT-1 loop
        wait until rising_edge(BSTARTCYCLE);
        if packetlen(i) = 0 then
          null;
        else
          datamux_dreq(src) <= '1';
          for bpos in 0 to packetlen(i)-1 loop
            datamux_ddata(src) <= std_logic_vector(TO_UNSIGNED((bpos + 16) mod 256, 8));
            if bpos = packetlen(i) - 1 then
              datamux_dlastbyte(src) <= '1';
            else
              datamux_dlastbyte(src) <= '0';
            end if;
            wait until rising_edge(CLK) and datamux_dnextbyte(src) = '1';
          end loop;  -- bpos
          datamux_dreq(src) <= '0';
        end if;
      end loop;  -- i
      report "Done sending data for " & integer'image(src) severity note;
      wait;
    end process datamux_proc;
    
  end generate datamux_src_gen;


  -----------------------------------------------------------------------------
  -- Encodemux interface
  ---------------------------------------------------------------------------
  encodemux_proc : process
  begin
    wait until rising_edge(CLK) and DREQ = '1' and pos = 50;
    DGRANT <= '1';
    wait until rising_edge(CLK);
    DGRANT <= '0';
    wait until rising_edge(CLK) and DDONE = '1';
    
  end process encodemux_proc;

  ---------------------------------------------------------------------------
  -- Data validate, there's one of these for each dgrant setting
  -- 
  ---------------------------------------------------------------------------
  dgrant_validate : for src in 0 to 3 generate
    
    data_validate : process
      variable bpos   : integer := 0;
      variable pktcnt : integer := 0;
      
    begin
      for i in 0 to PACKETCNT-1 loop
        wait until rising_edge(CLK) and linkdgrant(src) = '1' and BSTARTCYCLE = '1';
        if packetlen(i) = 0 then
          null;
        else
          -- Verify that we get the exact correct byte sequence
          pktcnt := (packetlen(i) / 249) + 1;
          bpos   := 0;

          for pi in 1 to pktcnt loop
            wait until rising_edge(CLK) and ENCODEEN = '1' and DKIN = '1' and DDATA = K28_6;
            for j in 0 to 247 loop
              wait until rising_edge(CLK) and ENCODEEN = '1';

              assert DKIN = '0' report "KIN high when it should not be" severity error;
              assert DDATA = std_logic_vector(to_unsigned((bpos + 16) mod 256, 8))
                report "incorrect data" severity error;
              bpos := bpos + 1;
              if bpos = packetlen(i) then
                exit;
              end if;
            end loop;  -- j
            wait until rising_edge(CLK) and ENCODEEN = '1';
            assert DKIN = '1' and DDATA = K28_7;
          end loop;

          wait until rising_edge(CLK) and ENCODEEN = '1' and DKIN = '1' and DDATA = K28_4;
        end if;
      end loop;  -- i


      wait for 50 us;
      data_validate_done(src) <= '1';
      wait;
    end process data_validate;
  end generate dgrant_validate;


  
end Behavioral;

