library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library eproc;
use eproc.all;

entity encodemuxintegratetest is
end encodemuxintegratetest;


architecture Behavioral of encodemuxintegratetest is

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

  signal ECYCLE     : std_logic                    := '0';
  signal DOUT       : std_logic_vector(7 downto 0) := (others => '0');
  signal KOUT       : std_logic                    := '0';
  -- data interface
  signal DREQ       : std_logic                    := '0';
  signal DGRANT     : std_logic                    := '0';
  signal DDONE      : std_logic                    := '0';
  signal DDATA      : std_logic_vector(7 downto 0) := (others => '0');
  -- event interface for DSPs
  signal EDSPREQ    : std_logic_vector(3 downto 0) := (others => '0');
  signal EDSPGRANT  : std_logic_vector(3 downto 0) := (others => '0');
  signal EDSPDONE   : std_logic_vector(3 downto 0) := (others => '0');
  signal EDSPDATAEN : std_logic;
  type   edspdata_t is array (0 to 3) of std_logic_vector(7 downto 0);

  signal EDSPDATA : edspdata_t := (others => (others => '0'));

  -- event interface for EPROCs
  signal EPROCREQ    : std_logic_vector(3 downto 0) := (others => '0');
  signal EPROCGRANT  : std_logic_vector(3 downto 0) := (others => '0');
  signal EPROCDONE   : std_logic_vector(3 downto 0) := (others => '0');
  signal EPROCDATAEN : std_logic;

  type eprocdata_t is array (0 to 3) of std_logic_vector(7 downto 0);

  signal EPROCDATA : eprocdata_t := (others => (others => '0'));

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

  type   eprocbuf_addr_t is array (0 to 3) of std_logic_vector(2 downto 0);
  signal eprocbuf_addr : eprocbuf_addr_t := (others => (others => '0'));

  signal eprocbuf_we : std_logic_vector(3 downto 0) := (others => '0');

  type   eprocbuf_data_t is array (0 to 3) of std_logic_vector(15 downto 0);
  signal eprocbuf_data : eprocbuf_data_t := (others => (others => '0'));

  signal eproc_validated : std_logic_vector(3 downto 0) := (others => '0');

  -----------------------------------------------------------------------------
  -- DSP event source
  -----------------------------------------------------------------------------
  component eventrx
    port (
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      SCLK     : in  std_logic;
      MOSI     : in  std_logic;
      SCS      : in  std_logic;
      FIFOFULL : out std_logic;
      DOUTEN   : in  std_logic;
      DOUT     : out std_logic_vector(7 downto 0);
      REQ      : out std_logic;
      GRANT    : in  std_logic;
      DONE     : out std_logic);
  end component;


  signal SCLK     : std_logic_vector(3 downto 0) := (others => '0');
  signal MOSI     : std_logic_vector(3 downto 0) := (others => '0');
  signal SCS      : std_logic_vector(3 downto 0) := (others => '0');
  signal FIFOFULL : std_logic_vector(3 downto 0) := (others => '0');
  signal RESET    : std_logic                    := '0';

  type dspdataword_t is array (0 to 10) of std_logic_vector(15 downto 0);

  type   dspdatawords_t is array (0 to 3) of dspdataword_t;
  signal txwords : dspdatawords_t := (others => (others => (others => '0')));

  signal dsp_sendevent     : std_logic_vector(3 downto 0) := (others => '0');
  signal dsp_sendeventdone : std_logic_vector(3 downto 0) := (others => '0');

  signal dsp_validated : std_logic_vector(3 downto 0) := (others => '0');
  -----------------------------------------------------------------------------
  -- SRC 0 - 3 : eproc
  -- SRC 4 - 7 : DSP boards
  ----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- EVENT CAPTURE
  -----------------------------------------------------------------------------
  type edata_t is array (0 to 4) of std_logic_vector(15 downto 0);

  type event_t is record
    addr : std_logic_vector(79 downto 0);
    src  : std_logic_vector(7 downto 0);
    cmd  : std_logic_vector(7 downto 0);
    data : edata_t;
  end record;

  type eventbytes_t is array(0 to 21) of std_logic_vector(7 downto 0);

  type   eventsin_t is array (0 to 3) of event_t;
  signal eventsin : eventsin_t;


  signal newevent : std_logic_vector(3 downto 0) := (others => '0');


  -- event generation
  -- purpose: Create the canonical event 
  function create_canonical_event (
    constant src         : integer;
    constant index       : integer;
    constant isbroadcast : boolean)
    return event_t is

    variable outevent : event_t;
    
  begin  -- create_canonical_event

    -- first populate the data
    outevent.cmd := std_logic_vector(TO_UNSIGNED(index, 8));
    outevent.src := std_logic_vector(TO_UNSIGNED(src, 8));

    for i in 0 to 4 loop
      outevent.data(i) := std_logic_vector(TO_UNSIGNED(384 + i + index + src, 16));
    end loop;  -- i

    if isbroadcast then
      for i in 0 to 79 loop
        outevent.addr(i) := '1';
      end loop;  -- i
    else
      for i in 0 to 79 loop
        if i = index then
          outevent.addr(i) := '1';
        else
          outevent.addr(i) := '0';
        end if;
      end loop;  -- i
    end if;
    return outevent;
    
  end create_canonical_event;


  -----------------------------------------------------------------------------
  -- Turn events off the wire into an actual event
  -----------------------------------------------------------------------------
  function parse_eventbytes (
    constant ebin : eventbytes_t)
    return event_t is

    variable outevent : event_t;
  begin  -- parse_eventbytes
    
    for i in 0 to 9 loop
      outevent.addr(i*8+7 downto i*8) := ebin(i);
    end loop;  -- i

    outevent.cmd := ebin(10);
    outevent.src := ebin(11);
    for i in 0 to 4 loop
      outevent.data(i) := ebin(i * 2 + 12) & ebin(i*2 + 13);
    end loop;  -- i

    return outevent;
  end parse_eventbytes;


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

      EDSPREQ    => EDSPREQ,
      EDSPGRANT  => EDSPGRANT,
      EDSPDONE   => EDSPDONE,
      EDSPDATAEN => EDSPDATAEN,
      EDSPDATAA  => EDSPDATA(0),
      EDSPDATAB  => EDSPDATA(1),
      EDSPDATAC  => EDSPDATA(2),
      EDSPDATAD  => EDSPDATA(3),

      EPROCREQ    => EPROCREQ,
      EPROCGRANT  => EPROCGRANT,
      EPROCDONE   => EPROCDONE,
      EPROCDATAEN => EPROCDATAEN,
      EPROCDATAA  => EPROCDATA(0),
      EPROCDATAB  => EPROCDATA(1),
      EPROCDATAC  => EPROCDATA(2),
      EPROCDATAD  => EPROCDATA(3));

  -----------------------------------------------------------------------------
  -- EPROC event sources
  -----------------------------------------------------------------------------

  eprocbuffers : for i in 0 to 3 generate
    eprocbuf_inst : entity eproc.txreqbrambuffer
      port map (
        CLK       => CLKHI,
        SRC       => std_logic_vector(to_unsigned(i, 8)),
        ADDRIN    => eprocbuf_addr(i),
        WEIN      => eprocbuf_we(i),
        DIN       => eprocbuf_data(i),
        OUTCLK    => CLK,
        SENDREQ   => EPROCREQ(i),
        SENDGRANT => EPROCGRANT(i),
        SENDDONE  => EPROCDONE(i),
        DOUT      => EPROCDATA(i),
        DOUTEN    => EPROCDATAEN);    
  end generate eprocbuffers;


  -----------------------------------------------------------------------------
  -- DSP Event source
  -----------------------------------------------------------------------------

  dsp_eventrx : for i in 0 to 3 generate
    eventrx_uut : eventrx
      port map (
        CLK      => CLK,
        RESET    => RESET,
        SCLK     => SCLK(i),
        MOSI     => MOSI(i),
        SCS      => SCS(i),
        FIFOFULL => open,
        DOUT     => EDSPDATA(i),
        DOUTEN   => EDSPDATAEN,
        REQ      => EDSPREQ(i),
        GRANT    => EDSPGRANT(i),
        DONE     => EDSPDONE(i));

    dsp_writedata : process
    begin
      while true loop
        SCS(i) <= '1';
        wait until rising_edge(dsp_sendevent(i));
        for word in 0 to 10 loop
          SCS(i) <= '1';
          wait for 500 ns;
          wait until rising_edge(CLK);
          wait until rising_edge(CLK);
          SCS(i) <= '0';
          wait until rising_edge(CLK);
          wait until rising_edge(CLK);
          wait until rising_edge(CLK);
          for j in 15 downto 0 loop
            SCLK(i) <= '1';
            MOSI(i) <= txwords(i)(word)(j);
            wait until rising_edge(CLK);
            wait until rising_edge(CLK);
            wait until rising_edge(CLK);
            SCLK(i) <= '0';
            MOSI(i) <= txwords(i)(word)(j);
            wait until rising_edge(CLK);
            wait until rising_edge(CLK);
            wait until rising_edge(CLK);
          end loop;  -- i
          wait until rising_edge(CLK);
          wait until rising_edge(CLK);
          SCS(i) <= '1';
          wait until rising_edge(CLK);
        end loop;  -- word
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);

        dsp_sendeventdone(i) <= '1';
        wait until rising_edge(CLK);
        dsp_sendeventdone(i) <= '0';
      end loop;
    end process dsp_writedata;

  end generate dsp_eventrx;
  -----------------------------------------------------------------------------
  -- Generic clocks
  -----------------------------------------------------------------------------

  CLKHI <= not CLKHI after 5 ns;

  process (CLKHI)
  begin
    if rising_edge(CLKHI) then
      CLK <= not CLK;
    end if;
  end process;


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

  eprocbuf_sender : process
    variable event : event_t;

  begin
    wait for 150 us;
    for index in 0 to 10 loop
      wait until rising_edge(CLK) and ECYCLE = '1';

      for src in 0 to 3 loop
        event := create_canonical_event(src, index, false);

        -- the data
        for i in 0 to 4 loop
          eprocbuf_addr(src) <= std_logic_vector(to_unsigned(i+1, 3));
          eprocbuf_we(src)   <= '1';
          eprocbuf_data(src) <= event.data(i);
          wait until rising_edge(CLKHI);
        end loop;

        -- set a single dest
        if event.addr = X"FFFFFFFFFFFFFFFFFFFF" then
          -- FIXME Broadcast
        else
          eprocbuf_addr(src) <= "111";
          eprocbuf_we(src)   <= '1';
          for j in 0 to 79 loop
            if event.addr(j) = '1' then
              eprocbuf_data(src) <= std_logic_vector(to_unsigned(j, 16));
            end if;
          end loop;  -- j 
          wait until rising_edge(CLKHI);
          
        end if;

        eprocbuf_addr(src) <= "000";
        eprocbuf_we(src)   <= '1';
        eprocbuf_data(src) <= X"00" & event.cmd;  -- command and send
        wait until rising_edge(CLKHI);
        eprocbuf_we(src)   <= '0';
        
      end loop;
    end loop;
    wait;
  end process eprocbuf_sender;

  -----------------------------------------------------------------------------
  -- DSP sender
  -----------------------------------------------------------------------------

  dsp_sender : for i in 0 to 3 generate
    
    dsp_sender_proc : process
      variable event : event_t;

    begin
      for eventi in 0 to 10 loop
        wait for 30 us;
        event := create_canonical_event(i +4, eventi, false);

        for j in 0 to 4 loop
          txwords(i)(j) <= event.addr(j * 16 + 7 downto j*16 + 0)
                           & event.addr(j * 16 + 15 downto j * 16 + 8);
        end loop;
        txwords(i)(5) <= event.cmd & event.src;
        for j in 0 to 4 loop
          txwords(i)(j+6) <= event.data(j);
        end loop;  -- j

        wait until rising_edge(CLK);
        dsp_sendevent(i) <= '1';
        wait until rising_edge(CLK);
        dsp_sendevent(i) <= '0';
        wait until rising_edge(dsp_sendeventdone(i));
      end loop;  -- eventi


      wait;

    end process dsp_sender_proc;
  end generate dsp_sender;

  -----------------------------------------------------------------------------
  -- event capture
  -----------------------------------------------------------------------------
  event_capture : process(CLK)
    variable inpkt    : integer := 0;
    variable inpos    : integer := 23;
    variable eventbin : eventbytes_t;
    
  begin
    if rising_edge(CLK) then
      if EDSPDATAEN = '1' then
        if kout = '1' then
          inpos := 0;
          if DOUT = X"1C" then
            inpkt := 0;
          elsif DOUT = X"3C" then
            inpkt := 1;
          elsif DOUT = X"5C" then
            inpkt := 2;
          elsif DOUT = X"7C" then
            inpkt := 3;
          end if;
        else
          if inpos < 22 then
            eventbin(inpos) := DOUT;
            if inpos = 21 then
              eventsin(inpkt) <= parse_eventbytes(eventbin);
              newevent(inpkt) <= '1';
            end if;
            inpos := inpos + 1;
          end if;
        end if;
      else
        newevent <= (others => '0');
      end if;
    end if;
  end process event_capture;

  -----------------------------------------------------------------------------
  -- EVENT VERIFY
  -----------------------------------------------------------------------------
  -- Event verification is challenging as we don't want to restrict explicit
  -- ordering of events as they are transmitted. So we have each event source
  -- send events from a -unique- src, and then validate the within-src stream
  -----------------------------------------------------------------------------

  eproc_validators : for src in 0 to 3 generate
    
    eproc_validate : process
      variable event_template : event_t;
      variable index          : integer := 0;
    begin
      wait until rising_edge(newevent(src));
      if eventsin(src).src = src then
        event_template := create_canonical_event(src, index, false);
        assert event_template.src = eventsin(src).src
          report "Error reading eproc event source" severity error;

        for i in 0 to 4 loop
          assert event_template.data(i) = eventsin(src).data(i)
            report "Error reading eproc eventdata word " & integer'image(i)
            severity error;
        end loop;  -- i

        assert event_template.addr = eventsin(src).addr
          report "Error reading eproc event addr" severity error;

        index := index + 1;
      end if;

      if index = 10 then
        eproc_validated(src) <= '1';
        wait;
      end if;

    end process;
  end generate eproc_validators;

  edsp_validators : for src in 0 to 3 generate
    
    edsp_validate : process
      variable event_template : event_t;
      variable index          : integer := 0;
    begin
      wait until rising_edge(newevent(src));
      if eventsin(src).src = src + 4 then
        event_template := create_canonical_event(src + 4, index, false);
        assert event_template.src = eventsin(src).src
          report "Error reading dsp event  source" severity error;

        for i in 0 to 4 loop
          assert event_template.data(i) = eventsin(src).data(i)
            report "Error reading dsp event data word " & integer'image(i) severity error;
        end loop;  -- i
        assert event_template.addr = eventsin(src).addr
          report "Error reading dsp event addr" severity error;
        

        index := index + 1;
      end if;

      if index = 10 then
        dsp_validated(src) <= '1';
        wait;
      end if;

    end process;
  end generate edsp_validators;


  -- total verify
  process(eproc_validated, dsp_validated)
  begin
    if eproc_validated = "1111" and dsp_validated = "1111" then
      report "End of Simulation" severity failure;
    end if;
  end process;

end Behavioral;

