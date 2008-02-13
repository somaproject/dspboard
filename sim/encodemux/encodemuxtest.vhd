library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

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
      -- event interface for DSPs
      EDSPREQ    : in  std_logic_vector(3 downto 0);
      EDSPGRANT  : out std_logic_vector(3 downto 0);
      EDSPDONE   : in  std_logic_vector(3 downto 0);
      EDSPDATAA  : in  std_logic_vector(7 downto 0);
      EDSPDATAB  : in  std_logic_vector(7 downto 0);
      EDSPDATAC  : in  std_logic_vector(7 downto 0);
      EDSPDATAD  : in  std_logic_vector(7 downto 0);
      -- event interface for EPROCs
      EPROCREQ   : in  std_logic_vector(3 downto 0);
      EPROCGRANT : out std_logic_vector(3 downto 0);
      EPROCDONE  : in  std_logic_vector(3 downto 0);
      EPROCDATAA : in  std_logic_vector(7 downto 0);
      EPROCDATAB : in  std_logic_vector(7 downto 0);
      EPROCDATAC : in  std_logic_vector(7 downto 0);
      EPROCDATAD : in  std_logic_vector(7 downto 0));
  end component;

  signal CLK        : std_logic                    := '0';
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
  signal EDSPDATAA  : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSPDATAB  : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSPDATAC  : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSPDATAD  : std_logic_vector(7 downto 0) := (others => '0');
  -- event interface for EPROCs
  signal EPROCREQ   : std_logic_vector(3 downto 0) := (others => '0');
  signal EPROCGRANT : std_logic_vector(3 downto 0) := (others => '0');
  signal EPROCDONE  : std_logic_vector(3 downto 0) := (others => '0');
  signal EPROCDATAA : std_logic_vector(7 downto 0) := (others => '0');
  signal EPROCDATAB : std_logic_vector(7 downto 0) := (others => '0');
  signal EPROCDATAC : std_logic_vector(7 downto 0) := (others => '0');
  signal EPROCDATAD : std_logic_vector(7 downto 0) := (others => '0');


  signal ecyclepos : integer := 0;

  constant KDATASTART : std_logic_vector(7 downto 0) := X"DC";
  constant KDATAEND   : std_logic_vector(7 downto 0) := X"FC";
  constant KEVENTA    : std_logic_vector(7 downto 0) := X"1C";
  constant KEVENTB    : std_logic_vector(7 downto 0) := X"3C";
  constant KEVENTC    : std_logic_vector(7 downto 0) := X"5C";
  constant KEVENTD    : std_logic_vector(7 downto 0) := X"7C";

  signal eproca_done, edspa_done : std_logic := '0';
  signal eprocb_done, edspb_done : std_logic := '0';
  signal data_done : std_logic := '0';
  
  
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

      EDSPREQ   => EDSPREQ,
      EDSPGRANT => EDSPGRANT,
      EDSPDONE  => EDSPDONE,
      EDSPDATAA => EDSPDATAA,
      EDSPDATAB => EDSPDATAB,
      EDSPDATAC => EDSPDATAC,
      EDSPDATAD => EDSPDATAD,

      EPROCREQ   => EPROCREQ,
      EPROCGRANT => EPROCGRANT,
      EPROCDONE  => EPROCDONE,
      EPROCDATAA => EPROCDATAA,
      EPROCDATAB => EPROCDATAB,
      EPROCDATAC => EPROCDATAC,
      EPROCDATAD => EPROCDATAD);


  CLK <= not CLK after 10 ns;

  -- data sender
  datasend : process
  begin
    for datapkt in 0 to 10 loop

      wait until rising_edge(CLK) and ECYCLE = '1' and (ecyclepos mod 2 = 0);
      -- send an event
      DREQ      <= '1';
      wait until rising_edge(CLK) and DGRANT = '1';
      DREQ      <= '0';
      for i in 0 to 600 loop
        DDATA   <= std_logic_vector(TO_UNSIGNED((i + datapkt) mod 256, 8));
        if i = 599 then
          DDONE <= '1';
        else
          DDONE <= '0';
        end if;
        wait until rising_edge(CLK);
      end loop;  -- i
      DREQ      <= '0';
    end loop;  -- datapkt
    wait;
  end process datasend;


  eventsend_DSP_A : process
  begin
    for edspacnt in 0 to 10 loop
      wait until rising_edge(CLK) and ECYCLE = '1' and (ecyclepos mod 2 ) = 1;
      -- send an event
      EDSPREQ(0)      <= '1';
      wait until rising_edge(CLK) and EDSPGRANT(0) = '1';
      EDSPREQ(0)      <= '0';
      for i in 0 to 21 loop
        EDSPDATAA     <= std_logic_vector(TO_UNSIGNED(i + 0 + edspacnt, 8));
        if i = 21 then
          EDSPDONE(0) <= '1';
        else
          EDSPDONE(0) <= '0';
        end if;
        wait until rising_edge(CLK);
      end loop;  -- i
      EDSPREQ(0)      <= '0';
    end loop;  -- edspacnt
    wait;
  end process eventsend_DSP_A;

  eventsend_PROC_A : process
  begin
    for eprocacnt in 0 to 10 loop
      wait until rising_edge(CLK) and ECYCLE = '1' and (ecyclepos mod 2 ) = 1;
      -- send an event
      EPROCREQ(0)      <= '1';
      wait until rising_edge(CLK) and EPROCGRANT(0) = '1';
      EPROCREQ(0)      <= '0';
      for i in 0 to 21 loop
        EPROCDATAA     <= std_logic_vector(TO_UNSIGNED(i + 128 + eprocacnt, 8));
        if i = 21 then
          EPROCDONE(0) <= '1';
        else
          EPROCDONE(0) <= '0';
        end if;
        wait until rising_edge(CLK);
      end loop;  -- i
      EPROCREQ(0)      <= '0';
    end loop;
    wait;

  end process eventsend_PROC_A;




  eventsend_DSP_B : process
  begin
    for edspbcnt in 0 to 10 loop
      wait until rising_edge(CLK) and ECYCLE = '1'; 
      -- send an event
      EDSPREQ(1)      <= '1';
      wait until rising_edge(CLK) and EDSPGRANT(1) = '1';
      EDSPREQ(1)      <= '0';
      for i in 0 to 21 loop
        EDSPDATAB     <= std_logic_vector(TO_UNSIGNED(i + 32 + edspbcnt, 8));
        if i = 21 then
          EDSPDONE(1) <= '1';
        else
          EDSPDONE(1) <= '0';
        end if;
        wait until rising_edge(CLK);
      end loop;  -- i
      EDSPREQ(1)      <= '0';
    end loop;  -- edspacnt
    wait;
  end process eventsend_DSP_B;

  eventsend_PROC_B : process
  begin
    for eprocbcnt in 0 to 10 loop
      wait until rising_edge(CLK) and ECYCLE = '1'; 
      -- send an event
      EPROCREQ(1)      <= '1';
      wait until rising_edge(CLK) and EPROCGRANT(1) = '1';
      EPROCREQ(1)      <= '0';
      for i in 0 to 21 loop
        EPROCDATAB     <= std_logic_vector(TO_UNSIGNED(i + 128 + 32 + eprocbcnt, 8));
        if i = 21 then
          EPROCDONE(1) <= '1';
        else
          EPROCDONE(1) <= '0';
        end if;
        wait until rising_edge(CLK);
      end loop;  -- i
      EPROCREQ(1)      <= '0';
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
        ECYCLE    <= '0' after 4 ns;
      end if;
    end if;
  end process ecycle_generation;

-- now, verify output

  -------------------------------------------------
  -- verify DATA output
  -------------------------------------------------
  process
  begin
    for i in 0 to 10 loop

      wait until rising_edge(CLK) and KOUT = '1' and DOUT = KDATASTART;
      for j in 0 to 599 loop
        wait until rising_edge(CLK);

        assert DOUT = std_logic_vector(TO_UNSIGNED((i + j ) mod 256, 8))
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
    mainloop: while true loop
      wait until rising_edge(CLK) and KOUT = '1' and DOUT = KEVENTA;
      wait until rising_edge(CLK);
      if DOUT = std_logic_vector(TO_UNSIGNED(0 + current_eproca, 8)) then
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
    mainloop: while true loop
      wait until rising_edge(CLK) and KOUT = '1' and DOUT = KEVENTA;
      wait until rising_edge(CLK);
      if DOUT = std_logic_vector(TO_UNSIGNED(128 + current_edspa, 8)) then
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
    mainloop: while true loop
      wait until rising_edge(CLK) and KOUT = '1' and DOUT = KEVENTB;
      wait until rising_edge(CLK);
      if DOUT = std_logic_vector(TO_UNSIGNED(0 + current_eprocb + 32, 8)) then
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
    mainloop: while true loop
      wait until rising_edge(CLK) and KOUT = '1' and DOUT = KEVENTB;
      wait until rising_edge(CLK);
      if DOUT = std_logic_vector(TO_UNSIGNED(128 + 32 + current_edspb, 8)) then
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
  -- Final done chekc
  ------------------------------------------------
   process (CLK)
     begin
       if rising_edge(CLK) then
         if eproca_done = '1' and edspa_done = '1' and 
           eprocb_done = '1' and edspb_done = '1' and
           data_done = '1' then
           report "End of Simulation" severity Failure;
         end if;
       end if;
     end process; 
end Behavioral;
