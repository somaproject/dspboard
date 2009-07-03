library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library eproc;
use eproc.all;

entity encodemuxtest is
end encodemuxtest;


architecture Behavioral of encodemuxtest is

  signal pos : integer range 0 to 999 := 950;

  component encodemux
    port (
      CLK        : in  std_logic;
      ECYCLE     : in  std_logic;
      DOUT       : out std_logic_vector(7 downto 0);
      KOUT       : out std_logic;
      -- data interface
      DREQ       : in  std_logic;
      DGRANT     : out std_logic;
      DDONE      : in  std_logic;
      DDATA      : in  std_logic_vector(7 downto 0);
      DKIN : in std_logic;
      DATAEN : out std_logic; 
      -- event interface for DSPs
      EDSPREQ    : in  std_logic_vector(3 downto 0);
      EDSPGRANT  : out std_logic_vector(3 downto 0);
      EDSPDONE   : in  std_logic_vector(3 downto 0);
      EDSPDATAEN : out std_logic;

      EDSPDATAA   : in  std_logic_vector(7 downto 0);
      EDSPDATAB   : in  std_logic_vector(7 downto 0);
      EDSPDATAC   : in  std_logic_vector(7 downto 0);
      EDSPDATAD   : in  std_logic_vector(7 downto 0);
      -- event interface for EPROCs
      EPROCREQ    : in  std_logic_vector(3 downto 0);
      EPROCGRANT  : out std_logic_vector(3 downto 0);
      EPROCDONE   : in  std_logic_vector(3 downto 0);
      EPROCDATAEN : out std_logic;

      EPROCDATAA : in std_logic_vector(7 downto 0);
      EPROCDATAB : in std_logic_vector(7 downto 0);
      EPROCDATAC : in std_logic_vector(7 downto 0);
      EPROCDATAD : in std_logic_vector(7 downto 0));
  end component;

  signal CLK   : std_logic := '0';
  signal CLKHI : std_logic := '0';

  signal ECYCLE      : std_logic                    := '0';
  signal DOUT        : std_logic_vector(7 downto 0) := (others => '0');
  signal KOUT        : std_logic                    := '0';
  -- data interface
  signal DREQ        : std_logic                    := '0';
  signal DGRANT      : std_logic                    := '0';
  signal DDONE       : std_logic                    := '0';
  signal DDATA       : std_logic_vector(7 downto 0) := (others => '0');
  signal DKIN : std_logic := '0';
  signal DATAEN : std_logic := '0';
    
  -- event interface for DSPs
  signal EDSPREQ     : std_logic_vector(3 downto 0) := (others => '0');
  signal EDSPGRANT   : std_logic_vector(3 downto 0) := (others => '0');
  signal EDSPDONE    : std_logic_vector(3 downto 0) := (others => '0');
  signal EDSPDATAEN  : std_logic;
  signal EDSPDATAA   : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSPDATAB   : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSPDATAC   : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSPDATAD   : std_logic_vector(7 downto 0) := (others => '0');
  -- event interface for EPROCs
  signal EPROCREQ    : std_logic_vector(3 downto 0) := (others => '0');
  signal EPROCGRANT  : std_logic_vector(3 downto 0) := (others => '0');
  signal EPROCDONE   : std_logic_vector(3 downto 0) := (others => '0');
  signal EPROCDATAEN : std_logic;
  signal EPROCDATAA  : std_logic_vector(7 downto 0) := (others => '0');
  signal EPROCDATAB  : std_logic_vector(7 downto 0) := (others => '0');
  signal EPROCDATAC  : std_logic_vector(7 downto 0) := (others => '0');
  signal EPROCDATAD  : std_logic_vector(7 downto 0) := (others => '0');


  signal ecyclepos : integer := 0;

  constant KDATASTART : std_logic_vector(7 downto 0) := X"DC";
  constant KDATAEND   : std_logic_vector(7 downto 0) := X"FC";
  constant KEVENTA    : std_logic_vector(7 downto 0) := X"1C";
  constant KEVENTB    : std_logic_vector(7 downto 0) := X"3C";
  constant KEVENTC    : std_logic_vector(7 downto 0) := X"5C";
  constant KEVENTD    : std_logic_vector(7 downto 0) := X"7C";

  signal eproca_done, edspa_done : std_logic := '0';
  signal eprocb_done, edspb_done : std_logic := '0';
  signal data_done               : std_logic := '0';

  signal douten : std_logic := '0';

  signal eprocbuf_addr : std_logic_vector(2 downto 0)  := (others => '0');
  signal eprocbuf_we   : std_logic                     := '0';
  signal eprocbuf_data : std_logic_vector(15 downto 0) := (others => '0');
  
begin  -- Behavioral

  encodemux_uut : encodemux
    port map (
      CLK    => CLK,
      ECYCLe => ECYCLE,
      DOUT   => DOUT,
      KOUT   => KOUT,
      DREQ   => DREQ,
      DGRANT => DGRANT,
      DDONE  => DDONE,
      DDATA  => DDATA,
      DKIN => DKIN,
      DATAEN => DATAEN, 

      EDSPREQ    => EDSPREQ,
      EDSPGRANT  => EDSPGRANT,
      EDSPDONE   => EDSPDONE,
      EDSPDATAEN => EDSPDATAEN,
      EDSPDATAA  => EDSPDATAA,
      EDSPDATAB  => EDSPDATAB,
      EDSPDATAC  => EDSPDATAC,
      EDSPDATAD  => EDSPDATAD,

      EPROCREQ    => EPROCREQ,
      EPROCGRANT  => EPROCGRANT,
      EPROCDONE   => EPROCDONE,
      EPROCDATAEN => EPROCDATAEN,
      EPROCDATAA  => EPROCDATAA,
      EPROCDATAB  => EPROCDATAB,
      EPROCDATAC  => EPROCDATAC,
      EPROCDATAD  => EPROCDATAD);

--  eprocbuf_inst : entity eproc.txreqbrambuffer
--    port map (
--      CLK       => CLKHI,
--      SRC       => X"20",
--      ADDRIN    => eprocbuf_addr,
--      WEIN      => eprocbuf_we,
--      DIN       => eprocbuf_data,
--      OUTCLK    => CLK,
--      SENDREQ   => EPROCREQ(0),
--      SENDGRANT => EPROCGRANT(0),
--      SENDDONE  => EPROCDONE(0),
--      DOUT      => EPROCDATAA,
--      DOUTEN    => EPROCDATAEN);

--  eprocbuf_inst2 : entity eproc.txreqbrambuffer
--    port map (
--      CLK       => CLKHI,
--      SRC       => X"21",
--      ADDRIN    => eprocbuf_addr,
--      WEIN      => eprocbuf_we,
--      DIN       => eprocbuf_data,
--      OUTCLK    => CLK,
--      SENDREQ   => EPROCREQ(1),
--      SENDGRANT => EPROCGRANT(1),
--      SENDDONE  => EPROCDONE(1),
--      DOUT      => EPROCDATAB,
--      DOUTEN    => EPROCDATAEN);

  eprocbuf_inst3 : entity eproc.txreqbrambuffer
    port map (
      CLK       => CLKHI,
      SRC       => X"22",
      ADDRIN    => eprocbuf_addr,
      WEIN      => eprocbuf_we,
      DIN       => eprocbuf_data,
      OUTCLK    => CLK,
      SENDREQ   => EPROCREQ(2),
      SENDGRANT => EPROCGRANT(2),
      SENDDONE  => EPROCDONE(2),
      DOUT      => EPROCDATAC,
      DOUTEN    => EPROCDATAEN);

  eprocbuf_inst4 : entity eproc.txreqbrambuffer
    port map (
      CLK       => CLKHI,
      SRC       => X"23",
      ADDRIN    => eprocbuf_addr,
      WEIN      => eprocbuf_we,
      DIN       => eprocbuf_data,
      OUTCLK    => CLK,
      SENDREQ   => EPROCREQ(3),
      SENDGRANT => EPROCGRANT(3),
      SENDDONE  => EPROCDONE(3),
      DOUT      => EPROCDATAD,
      DOUTEN    => EPROCDATAEN);

  
  CLKHI <= not CLKHI after 5 ns;

  process (CLKHI)
  begin
    if rising_edge(CLKHI) then
      CLK <= not CLK;
    end if;
  end process;


  -- data sender
  datasend : process
  begin
    for datapkt in 0 to 10 loop

      wait until rising_edge(CLK) and ECYCLE = '1' and (ecyclepos mod 2 = 0);
      -- send an event
      DREQ <= '1';
      wait until rising_edge(CLK) and DGRANT = '1';
      DREQ <= '0';
      wait until rising_edge(CLK) and DATAEN = '1';
      DDATA <= KDATASTART;
      DKIN <= '1';
      wait until rising_edge(CLK) and DATAEN = '1'; 
      DKIN <= '0';
      for i in 0 to 239 loop
        DDATA <= std_logic_vector(TO_UNSIGNED((i + datapkt) mod 256, 8));
        wait until rising_edge(CLK) and DATAEN = '1'; 
      end loop;  -- i
      DDATA <= KDATAEND;
      DKIN <= '1';
      wait until rising_edge(CLK) and DATAEN = '1';
      DKIN <= '0';
      DDATA <= X"00";
      DDONE <= '1';
      wait until rising_edge(CLK) and DATAEN = '1';
      DDONE <= '0'; 
    end loop;  -- datapkt
    wait;
  end process datasend;


  eventsend_DSP_A : process
  begin
    for edspacnt in 0 to 10 loop
      wait until rising_edge(CLK) and ECYCLE = '1' and (ecyclepos mod 2) = 1;
      -- send an event
      EDSPREQ(0) <= '1';
      wait until rising_edge(CLK) and EDSPGRANT(0) = '1' and EDSPDATAEN = '1';
      EDSPREQ(0) <= '0';
      for i in 0 to 21 loop
        EDSPDATAA <= std_logic_vector(TO_UNSIGNED(i + 0 + edspacnt, 8));
        if i = 21 then
          EDSPDONE(0) <= '1';
        else
          EDSPDONE(0) <= '0';
        end if;
        wait until rising_edge(CLK) and EDSPDATAEN = '1';
      end loop;  -- i
      EDSPREQ(0) <= '0';
    end loop;  -- edspacnt
    wait;
  end process eventsend_DSP_A;

  eventsend_PROC_A : process
  begin
    for eprocacnt in 0 to 10 loop
      wait until rising_edge(CLK) and ECYCLE = '1' and (ecyclepos mod 2) = 1;
      -- send an event
      EPROCREQ(0) <= '1';
      wait until rising_edge(CLK) and EPROCGRANT(0) = '1' and EPROCDATAEN = '1';
      EPROCREQ(0) <= '0';
      for i in 0 to 21 loop
        EPROCDATAA <= std_logic_vector(TO_UNSIGNED(i + 128 + eprocacnt, 8));
        if i = 21 then
          EPROCDONE(0) <= '1';
        else
          EPROCDONE(0) <= '0';
        end if;
        wait until rising_edge(CLK) and EPROCDATAEN = '1';
      end loop;  -- i
      EPROCREQ(0) <= '0';
    end loop;
    wait;

  end process eventsend_PROC_A;




  eventsend_DSP_B : process
  begin
    for edspbcnt in 0 to 10 loop
      wait until rising_edge(CLK) and ECYCLE = '1';
      -- send an event
      EDSPREQ(1) <= '1';
      wait until rising_edge(CLK) and EDSPGRANT(1) = '1' and EDSPDATAEN = '1';
      EDSPREQ(1) <= '0';
      for i in 0 to 21 loop
        EDSPDATAB <= std_logic_vector(TO_UNSIGNED(i + 32 + edspbcnt, 8));
        if i = 21 then
          EDSPDONE(1) <= '1';
        else
          EDSPDONE(1) <= '0';
        end if;
        wait until rising_edge(CLK) and EDSPDATAEN = '1';
      end loop;  -- i
      EDSPREQ(1) <= '0';
    end loop;  -- edspacnt
    wait;
  end process eventsend_DSP_B;

  eventsend_PROC_B : process
  begin
    for eprocbcnt in 0 to 10 loop
      wait until rising_edge(CLK) and ECYCLE = '1';
      -- send an event
      EPROCREQ(1) <= '1';
      wait until rising_edge(CLK) and EPROCGRANT(1) = '1' and EPROCDATAEN = '1';
      EPROCREQ(1) <= '0';
      for i in 0 to 21 loop
        EPROCDATAB <= std_logic_vector(TO_UNSIGNED(i + 128 + 32 + eprocbcnt, 8));
        if i = 21 then
          EPROCDONE(1) <= '1';
        else
          EPROCDONE(1) <= '0';
        end if;
        wait until rising_edge(CLK) and EPROCDATAEN = '1';
      end loop;  -- i
      EPROCREQ(1) <= '0';
    end loop;
    wait;

  end process eventsend_PROC_B;



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

      douten <= not douten;
    end if;
  end process ecycle_generation;


  -----------------------------------------------------------------------------
  --EPROCBUF sender
  -----------------------------------------------------------------------------

  process

  begin
    wait for 100 us;
    wait until rising_edge(CLK) and ECYCLE = '1';


    eprocbuf_addr <= "001";
    eprocbuf_we   <= '1';
    eprocbuf_data <= X"1234";
    wait until rising_edge(CLKHI);
    eprocbuf_we   <= '0';

    eprocbuf_addr <= "101";
    eprocbuf_we   <= '1';
    eprocbuf_data <= X"5678";
    wait until rising_edge(CLKHI);
    eprocbuf_we   <= '0';

    eprocbuf_addr <= "110";
    eprocbuf_we   <= '1';
    eprocbuf_data <= X"0001";           -- broadcast! 
    wait until rising_edge(CLKHI);

    eprocbuf_addr <= "000";
    eprocbuf_we   <= '1';
    eprocbuf_data <= X"00AB";           -- command and send
    wait until rising_edge(CLKHI);

    eprocbuf_we <= '0';


    for i in 0 to 10 loop

      
      eprocbuf_addr <= "001";
      eprocbuf_we   <= '1';
      eprocbuf_data <= X"CCDD";
      wait until rising_edge(CLKHI);
      eprocbuf_we   <= '0';

      eprocbuf_addr <= "101";
      eprocbuf_we   <= '1';
      eprocbuf_data <= X"EEFF";
      wait until rising_edge(CLKHI);
      eprocbuf_we   <= '0';

      eprocbuf_addr <= "111";
      eprocbuf_we   <= '1';
      eprocbuf_data <= X"0004";         -- send to device 4
      wait until rising_edge(CLKHI);

      eprocbuf_addr <= "000";
      eprocbuf_we   <= '1';
      eprocbuf_data <= X"0068";         -- command and send
      wait until rising_edge(CLKHI);

      eprocbuf_we <= '0';
      wait until rising_edge(CLK) and ECYCLE = '1';
      
    end loop;  -- iwait until rising_edge(CLK) and  ECYCLE='1'

    wait;
    
  end process;


-- now, verify output

  -------------------------------------------------
  -- verify DATA output
  -------------------------------------------------
  process
  begin
    for i in 0 to 10 loop

      wait until rising_edge(CLK) and KOUT = '1' and DOUT = KDATASTART;
      wait until rising_edge(CLK);
      for j in 0 to 239 loop
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        assert DOUT = std_logic_vector(TO_UNSIGNED((i + j) mod 256, 8))
          report "Error in Data" severity error;
      end loop;  -- j
      wait until rising_edge(CLK);
      assert KOUT = '1' and DOUT = KDATAEND report "Error with KDATAEND" severity error;


    end loop;  -- i
    report "Done with Data RX" severity note;
    data_done <= '1';
    wait;
  end process;

  -------------------------------------------------
  -- verify EVENT A output
  -------------------------------------------------
  process
    variable current_eproca : integer := 0;
  begin
    mainloop : while true loop
      wait until rising_edge(CLK) and KOUT = '1' and
        DOUT = KEVENTA and douten = '1';
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      if DOUT = std_logic_vector(TO_UNSIGNED(128 + current_eproca, 8)) then
        wait until rising_edge(CLK);
        current_eproca := current_eproca + 1;
      end if;
      if current_eproca = 10 then
        exit mainloop;
      end if;
    end loop;

    report "done with eproca" severity note;
    eproca_done <= '1';
    wait;
  end process;


  process
    variable current_edspa : integer := 0;
  begin
    mainloop : while true loop
      wait until rising_edge(CLK) and KOUT = '1' and
        DOUT = KEVENTA and douten = '1';
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      if DOUT = std_logic_vector(TO_UNSIGNED(0 + current_edspa, 8)) then
        wait until rising_edge(CLK);
        current_edspa := current_edspa + 1;
      end if;
      if current_edspa = 10 then
        exit mainloop;
      end if;
    end loop;

    report "done with edspa" severity note;
    edspa_done <= '1';

    wait;

  end process;

  -------------------------------------------------
  -- verify EVENT B output (eventb tries to send every ecycle)
  -------------------------------------------------
  process
    variable current_eprocb : integer := 0;
  begin
    mainloop : while true loop
      wait until rising_edge(CLK) and KOUT = '1' and DOUT = KEVENTB and douten = '1';
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      if DOUT = std_logic_vector(TO_UNSIGNED(0 + current_eprocb + 128 + 32, 8)) then
        wait until rising_edge(CLK);
        current_eprocb := current_eprocb + 1;
      end if;
      if current_eprocb = 10 then
        exit mainloop;
      end if;
    end loop;

    report "done with eprocb" severity note;
    eprocb_done <= '1';
    wait;

  end process;


  process
    variable current_edspb : integer := 0;
  begin
    mainloop : while true loop
      wait until rising_edge(CLK) and KOUT = '1' and DOUT = KEVENTB and douten = '1';
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      if DOUT = std_logic_vector(TO_UNSIGNED(32 + current_edspb, 8)) then
        wait until rising_edge(CLK);
        current_edspb := current_edspb + 1;
      end if;
      if current_edspb = 10 then
        exit mainloop;
      end if;
    end loop;

    report "done with edspb" severity note;
    edspb_done <= '1';
    wait;
  end process;


--------------------------------------------------
  -- Final done check
  ------------------------------------------------
  process (CLK)
  begin
    if rising_edge(CLK) then
      if eproca_done = '1' and edspa_done = '1' and
        eprocb_done = '1' and edspb_done = '1' and
        data_done = '1' then
        report "End of Simulation" severity failure;
      end if;
    end if;
  end process;
end Behavioral;

