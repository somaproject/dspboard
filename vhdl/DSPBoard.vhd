library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DSPBoard is
    Port ( CLKIN : in std_logic;
           SYSCLKIN : in std_logic;
			  FIBERIN : in std_logic; 
			  FIBEROUT : out std_logic; 
           DATAA : inout std_logic_vector(15 downto 0);
           ADDRA : in std_logic_vector(15 downto 0);
           WEA : in std_logic;
           RDA : in std_logic;
           RESETA : out std_logic;
           SAMPLESA : out std_logic;
           EVENTSA : out std_logic;
           TINCA : out std_logic;
           TCLRA : out std_logic;
           DATAB : inout std_logic_vector(15 downto 0);
           ADDRB : in std_logic_vector(15 downto 0);
           WEB : in std_logic;
           RDB : in std_logic;
           RESETB : out std_logic;
           SAMPLESB : out std_logic;
           EVENTSB : out std_logic;
           TINCB : out std_logic;
           TCLRB : out std_logic;
           EVENT : in std_logic;
           ECE : in std_logic;
           EADDR : inout std_logic_vector(7 downto 0);
           EDATA : inout std_logic_vector(15 downto 0);
           SYSDATA : inout std_logic_vector(15 downto 0);
           DATAEN : in std_logic;
           DATAACK : inout std_logic;
           RESET : in std_logic);
end DSPBoard;

architecture Behavioral of DSPBoard is
-- DSPBOARD.VHD -- aggregation of all DSP code. 



	-- clocks
	signal clk, sysclk : std_logic := '0';

	-- common signals
	signal newsamples, timeinc, timeclr : std_logic := '0';
	signal cmdsts : std_logic_vector(3 downto 0) := (others => '0');
	signal status : std_logic := '0';

	-- DSP A signals
	signal sample1a, sample2a, sample3a, sample4a, sampleca :
			std_logic_vector(15 downto 0) := (others => '0'); 
	signal cmdida : std_logic_vector(2 downto 0) := (others => '0');
	signal cwea, dwea, ewea	: std_logic := '0';
	signal modea, deltarda : std_logic := '0';

	signal douta, addroa : std_logic_vector(15 downto 0) := (others => '0');
	signal eventdina : std_logic_vector(15 downto 0) := (others => '0');
	signal rdina : std_logic_vector(15 downto 0) := (others => '0');
	
	signal rdouta : std_logic_vector(7 downto 0) := (others => '0');
	signal raina : std_logic_vector(9 downto 0) := (others => '0'); 

	signal dspreseta, rwea : std_logic := '0';

	signal edia, edoa : std_logic_vector(15 downto 0) := (others => '0');
	signal eaia, eaoa : std_logic_vector(7 downto 0) := (others => '0');
	signal ecea, eoea, ea : std_logic := '0';

	signal dina : std_logic_vector(15 downto 0) := (others => '0');
	signal nexta, acka : std_logic := '0';

   signal ebufsela, neweventsa , modersta: std_logic := '0';
	
	signal raouta : std_logic_vector(10 downto 0) := (others => '0'); 
	signal maddra : std_logic_vector(7 downto 0) := (others => '0'); 
		
	
	-- DSP B signals
	signal sample1b, sample2b, sample3b, sample4b, samplecb :
			std_logic_vector(15 downto 0) := (others => '0'); 
	signal cmdidb : std_logic_vector(2 downto 0) := (others => '0');
	signal cweb, dweb, eweb	: std_logic := '0';
	signal modeb, deltardb : std_logic := '0';

	signal doutb, addrob : std_logic_vector(15 downto 0) := (others => '0');
	signal eventdinb  : std_logic_vector(15 downto 0) := (others => '0');
	signal rdinb : std_logic_vector(15 downto 0) := (others => '0');
	signal rdoutb : std_logic_vector(7 downto 0) := (others => '0');
	signal rainb : std_logic_vector(9 downto 0) := (others => '0'); 
	signal dspresetb,  rweb : std_logic := '0';

	signal edib, edob : std_logic_vector(15 downto 0) := (others => '0');
	signal eaib, eaob : std_logic_vector(7 downto 0) := (others => '0');
	signal eceb , eoeb, eb : std_logic := '0';

	signal dinb : std_logic_vector(15 downto 0) := (others => '0');
	signal nextb, ackb : std_logic := '0';

   signal ebufselb, neweventsb, moderstb : std_logic := '0';
	signal raoutb : std_logic_vector(10 downto 0) := (others => '0'); 

	signal maddrb : std_logic_vector(7 downto 0) := (others => '0'); 


	-- component declarations
	component FiberRX is
	    Port ( CLK : in std_logic;
	           RESET : in std_logic;
	           STATUS : out std_logic;
	           NEWSAMPLES : out std_logic;
	           SAMPLEA1 : out std_logic_vector(15 downto 0);
	           SAMPLEA2 : out std_logic_vector(15 downto 0);
	           SAMPLEA3 : out std_logic_vector(15 downto 0);
	           SAMPLEA4 : out std_logic_vector(15 downto 0);
	           SAMPLEAC : out std_logic_vector(15 downto 0);
	           SAMPLEB1 : out std_logic_vector(15 downto 0);
	           SAMPLEB2 : out std_logic_vector(15 downto 0);
	           SAMPLEB3 : out std_logic_vector(15 downto 0);
	           SAMPLEB4 : out std_logic_vector(15 downto 0);
	           SAMPLEBC : out std_logic_vector(15 downto 0);
	           CMDIDA : out std_logic_vector(2 downto 0);
	           CMDIDB : out std_logic_vector(2 downto 0);
	           CMDST : out std_logic_vector(3 downto 0);
	           FIBERIN : in std_logic);
	end component;

	component fibertx is
	    Port ( CLK : in std_logic;
		 		  RESET : in std_logic; 
	           DATAA : in std_logic_vector(15 downto 0);
	           ADDRA : in std_logic_vector(2 downto 0);
	           WRA : in std_logic;
	           DATAB : in std_logic_vector(15 downto 0);
	           ADDRB : in std_logic_vector(2 downto 0);
	           WRB : in std_logic;
	           FIBEROUT : out std_logic);
	end component;

	component DataMux is
	    Port ( SYSCLK : in std_logic;
	           DINA : in std_logic_vector(15 downto 0);
	           DINB : in std_logic_vector(15 downto 0);
	           DATAEN : in std_logic;
	           ACKA : in std_logic;
	           ACKB : in std_logic;
	           DATAACK : out std_logic;
	           SYSDATA : out std_logic_vector(15 downto 0);
	           NEXTA : out std_logic;
	           NEXTB : out std_logic);
	end component;

	component EventMux is
	    Port ( SYSCLK : in std_logic;
	           AIA : out std_logic_vector(7 downto 0);
	           AIB : out std_logic_vector(7 downto 0);
	           AOA : in std_logic_vector(7 downto 0);
	           AOB : in std_logic_vector(7 downto 0);
	           EADDR : inout std_logic_vector(7 downto 0);
	           OEA : in std_logic;
	           OEB : in std_logic;
	           DOA : in std_logic_vector(15 downto 0);
	           DOB : in std_logic_vector(15 downto 0);
	           DIA : out std_logic_vector(15 downto 0);
	           DIB : out std_logic_vector(15 downto 0);
	           EDATA : inout std_logic_vector(15 downto 0);
	           EB : out std_logic;
	           EA : out std_logic;
	           EVENT : in std_logic;
	           ECE : in std_logic;
	           CEA : out std_logic;
	           CEB : out std_logic;
				  MADDR : out std_logic_vector(7 downto 0));
	end component;



	component dspio is
	    Port ( CLK : in std_logic;
	           WE : in std_logic;
	           RD : in std_logic;
	           DATA : inout std_logic_vector(15 downto 0);
	           ADDR : in std_logic_vector(15 downto 0);
	           DELTARD : out std_logic;
	           DOUT : out std_logic_vector(15 downto 0);
	           ADDROUT : out std_logic_vector(15 downto 0);
	           EVENTDIN : in std_logic_vector(15 downto 0);
	           RDIN : in std_logic_vector(7 downto 0);
	           MODE : in std_logic;
	           DWE : out std_logic;
	           EWE : out std_logic;
	           CWE : out std_logic;
				  EBUFSEL : out std_logic; 
	           STATUS : in std_logic;
	           CMDID : in std_logic_vector(2 downto 0);
	           CMDSTS : in std_logic_vector(3 downto 0);
	           SAMPLE1 : in std_logic_vector(15 downto 0);
	           SAMPLE2 : in std_logic_vector(15 downto 0);
	           SAMPLE3 : in std_logic_vector(15 downto 0);
	           SAMPLE4 : in std_logic_vector(15 downto 0);
	           SAMPLEC : in std_logic_vector(15 downto 0);
				  DSPRESET : in std_logic;
				  RESET : out std_logic;
				  NEWSAMPLE : in std_logic;
				  SAMPLES : out std_logic;
				  NEWEVENTS : in std_logic;
				  EVENTS : out std_logic; 
				  TIMEINC : in std_logic;
				  TINC : out std_logic;
				  TIMECLR : in std_logic;
				  TCLR : out std_logic;
			      MADDR : in std_logic_vector(7 downto 0);
					MODERST : out std_logic);
	end component;

	component databuffer is
	    Port ( CLKA : in std_logic;
	           CLKB : in std_logic;
				  RESET : in std_logic; 
	           BUFWE : in std_logic;
	           BUFADDRIN : in std_logic_vector(7 downto 0);
	           BUFDIN : in std_logic_vector(15 downto 0);
	           BUFERROR : out std_logic;
	           BUFDOUT : out std_logic_vector(15 downto 0);
	           NEXTOUT : in std_logic;
	           BUFACKOUT : out std_logic;
	           RAIN : in std_logic_vector(9 downto 0);
	           RAOUT : in std_logic_vector(10 downto 0);
	           RDOUT : out std_logic_vector(7 downto 0);
	           RDIN : in std_logic_vector(15 downto 0);
	           RWE : in std_logic;
	           MODE : in std_logic;
				  DSPRESET : in std_logic);
	end component;

	component events is
	    Port ( CLK : in std_logic;
	           SYSCLK : in std_logic;
	           RESET : in std_logic;
	           DIN : in std_logic_vector(15 downto 0);
	           DOUT : out std_logic_vector(15 downto 0);
	           ADDR : in std_logic_vector(3 downto 0);
	           WR : in std_logic;
				  RD : in std_logic; 
				  MODE : out std_logic;
				  DSPRESET : out std_logic; 
	           RAIN : out std_logic_vector(9 downto 0);
	           RDIN : out std_logic_vector(15 downto 0);
				  RWE : out std_logic; 
	           EDATAO : out std_logic_vector(15 downto 0);
	           EADDRO : out std_logic_vector(7 downto 0);
	           EOE : out std_logic;
	           EEVENT : in std_logic;
	           ECE : in std_logic;
	           EDATAI : in std_logic_vector(15 downto 0);
	           EADDRI : in std_logic_vector(7 downto 0);
			  	  BUFWR : in std_logic;
			  	  NEWEVENTS : out std_logic;
				  MADDR : in std_logic_vector(7 downto 0);
				  MODERST : in std_logic);
	end component;


begin
	-- clocks
	clk <= CLKIN; 
	sysclk <= SYSCLKIN;
	
	-- signal aggregation
	raouta <= addroa(2 downto 0) & douta(15 downto 8);
	raoutb <= addrob(2 downto 0) & doutb(15 downto 8);

	maddrb <= maddra + 1; 

	FiberRX_inst: FiberRX port map (
		CLK => clk,
		RESET => RESET,
		STATUS => status,
		CMDST => cmdsts,
		FIBERIN => FIBERIN,
		NEWSAMPLES => newsamples,
		SAMPLEA1 => sample1a,
		SAMPLEA2 => sample2a,
		SAMPLEA3 => sample3a,
		SAMPLEA4 => sample4a,
		SAMPLEAC => sampleca,
		CMDIDA => cmdida,
		SAMPLEB1 => sample1b,
		SAMPLEB2 => sample2b,
		SAMPLEB3 => sample3b,
		SAMPLEB4 => sample4b,
		SAMPLEBC => samplecb,
		CMDIDB => cmdidb); 

	FiberTX_inst: fibertx port map (
		CLK => clk,
		RESET => RESET,
		DATAA => douta, 
		ADDRA => addroa(2 downto 0),
		WRA => cwea,
		DATAB => doutb, 
		ADDRB => addrob(2 downto 0),
		WRB => cweb,
		FIBEROUT => FIBEROUT);
		
	DataMux_inst : DataMux port map(
		SYSCLK => sysclk,
		DINA => dina,
		NEXTA => nexta,
		ACKA => acka,
		DINB => dinb,
		NEXTB => nextb,
		ACKB => ackb,
		DATAACK => DATAACK,
		SYSDATA => SYSDATA,
		DATAEN => DATAEN); 

	EventMux_inst : EventMux port map (
		SYSCLK => sysclk,
		DIA => edia,
		AIA => eaia,
		EA => ea,
		DOA => edoa,
		AOA => eaoa,
		CEA => ecea,
		OEA => eoea,
		DIB => edib,
		AIB => eaib,
		EB => eb,
		DOB => edob,
		AOB => eaob,
		CEB => eceb,
		OEB => eoeb,
		EVENT => EVENT,
		EDATA => EDATA,
		EADDR => EADDR,
		ECE => ECE,
		MADDR => maddra); 

	dspioa : dspio port map (
		CLK => clk,
		WE => WEA, 
		RD => RDA,
		DATA => DATAA,
		ADDR => ADDRA,
		DELTARD => deltarda,
		DOUT => douta,
		ADDROUT => addroa,
		EVENTDIN => eventdina,
		RDIN => rdouta,
		MODE => modea,
		DWE => dwea,
		EWE => ewea,
		CWE => cwea,
		EBUFSEL => ebufsela, 
		STATUS => status,
		CMDID => cmdida,
		CMDSTS => cmdsts,
		SAMPLE1 => sample1a,
		SAMPLE2 => sample2a,
		SAMPLE3 => sample3a,
		SAMPLE4 => sample4a,
		SAMPLEc => sampleca,
		DSPRESET => dspreseta,
		RESET => RESETA,
		NEWSAMPLE => newsamples,
		SAMPLES => SAMPLESA,
		NEWEVENTS => neweventsa,
		EVENTS => EVENTSA,
		TIMEINC => timeinc,
		TINC => TINCA,
		TIMECLR => timeclr,
		TCLR => tclra,
		MADDR => maddra,
		MODERST => modersta); 

	databuffera : databuffer port map (
		CLKA => clk,
		CLKB => sysclk,
		RESET => RESET,
		BUFWE => dwea, 
		BUFADDRIN => addroa(7 downto 0),
		BUFDIN => douta,
		BUFERROR => open,
		BUFDOUT => dina,
		NEXTOUT => nexta,
		BUFACKOUT => acka,
		RAIN => raina, 
		RAOUT => raouta, 
		RDOUT => rdouta, 
		RDIN => rdina,
		RWE => rwea,
		MODE => modea,
		DSPRESET => dspreseta); 


	eventsa_inst : events port map (
		CLK => clk,
		SYSCLK => sysclk,
		RESET => RESET,
		DIN => douta,
		DOUT => eventdina,
		ADDR => addroa(3 downto 0),
		WR => ewea,
		RD => deltarda,
		MODE => modea, 
		DSPRESET => dspreseta,
		RAIN => raina,
		RDIN => rdina,
		RWE => rwea,
		EDATAO => edoa,
		EADDRO => eaoa,
		EOE => eoea, 
		EEVENT => ea,
		ECE => ecea,
		EDATAI => edia,
		EADDRI => eaia,
		BUFWR => ebufsela,
		NEWEVENTS => neweventsa,
		MADDR => maddra,
		MODERST => modersta); 


	dspiob : dspio port map (
		CLK => clk,
		WE => WEB, 
		RD => RDB,
		DATA => DATAB,
		ADDR => ADDRB,
		DELTARD => deltardb,
		DOUT => doutb,
		ADDROUT => addrob,
		EVENTDIN => eventdinb,
		RDIN => rdoutb,
		MODE => modeb,
		DWE => dweb,
		EWE => eweb,
		CWE => cweb,
		EBUFSEL => ebufselb,
		STATUS => status,
		CMDID => cmdidb,
		CMDSTS => cmdsts,
		SAMPLE1 => sample1b,
		SAMPLE2 => sample2b,
		SAMPLE3 => sample3b,
		SAMPLE4 => sample4b,
		SAMPLEc => samplecb,
		DSPRESET => dspresetb,
		RESET => RESETB,
		NEWSAMPLE => newsamples,
		SAMPLES => SAMPLESB,
		NEWEVENTS => neweventsb,
		EVENTS => EVENTSB,
		TIMEINC => timeinc,
		TINC => TINCB,
		TIMECLR => timeclr,
		TCLR => TCLRB,
		MADDR => maddrb,
		MODERST => moderstb); 

	databufferb : databuffer port map (
		CLKA => clk,
		CLKB => sysclk,
		RESET => RESET,
		BUFWE => dweb, 
		BUFADDRIN => addrob(7 downto 0),
		BUFDIN => doutb,
		BUFERROR => open,
		BUFDOUT => dinb,
		NEXTOUT => nextb,
		BUFACKOUT => ackb,
		RAIN => rainb, 
		RAOUT => raoutb, 
		RDOUT => rdoutb, 
		RDIN => rdinb,
		RWE => rweb,
		MODE => modeb,
		DSPRESET => dspresetb); 


	eventsb_inst : events port map (
		CLK => clk,
		SYSCLK => sysclk,
		RESET => RESET,
		DIN => doutb,
		DOUT => eventdinb,
		ADDR => addrob(3 downto 0),
		WR => eweb,
		RD => deltardb,
		MODE => modeb, 
		DSPRESET => dspresetb,
		RAIN => rainb,
		RDIN => rdinb,
		RWE => rweb,
		EDATAO => edob,
		EADDRO => eaob,
		EOE => eoeb, 
		EEVENT => eb,
		ECE => eceb,
		EDATAI => edib,
		EADDRI => eaib,
		BUFWR => ebufselb,
		NEWEVENTS => neweventsb,
		MADDR => maddrb,
		MODERST => moderstb); 


end Behavioral;
