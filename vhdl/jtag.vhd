
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

  signal jtagout : std_logic_vector(63 downto 0) := (others => '0');
  signal cmdoutl : std_logic_vector(47 downto 0) := (others => '0');
  process(jtagDRCK1, clk)
  begin
    if rising_edge(CLK) then
      if sendcmd = '1' then
        cmdoutl <= cmdout; 
      end if;
    end if;
    if jtagupdate = '1' then
      jtagout   <= X"1234" & cmdoutl; 
    else
      if rising_edge(jtagDRCK1) then
        jtagout <= '0' & jtagout(63 downto 1);
        jtagtdo1      <= jtagout(0);       
      end if;

    end if;
  end process;

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
      TDO2    => jtagtdo2             -- Data input for USER2 function
      );

  fibertx_inst : fibertx
