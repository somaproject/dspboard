
-- VHDL Test Bench Created from source file dspboard.vhd -- 21:32:39 02/03/2004
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT dspboard
	PORT(
		CLKIN : IN std_logic;
		SYSCLKIN : IN std_logic;
		FIBERIN : IN std_logic;
		ADDRA : IN std_logic_vector(15 downto 0);
		WEA : IN std_logic;
		RDA : IN std_logic;
		ADDRB : IN std_logic_vector(15 downto 0);
		WEB : IN std_logic;
		RDB : IN std_logic;
		EVENT : IN std_logic;
		ECE : IN std_logic;
		DATAEN : IN std_logic;
		RESET : IN std_logic;    
		DATAA : INOUT std_logic_vector(15 downto 0);
		DATAB : INOUT std_logic_vector(15 downto 0);
		EADDR : INOUT std_logic_vector(7 downto 0);
		EDATA : INOUT std_logic_vector(15 downto 0);
		SYSDATA : INOUT std_logic_vector(15 downto 0);
		DATAACK : INOUT std_logic;      
		FIBEROUT : OUT std_logic;
		RESETA : OUT std_logic;
		SAMPLESA : OUT std_logic;
		EVENTSA : OUT std_logic;
		TINCA : OUT std_logic;
		TCLRA : OUT std_logic;
		RESETB : OUT std_logic;
		SAMPLESB : OUT std_logic;
		EVENTSB : OUT std_logic;
		TINCB : OUT std_logic;
		TCLRB : OUT std_logic
		);
	END COMPONENT;

	SIGNAL CLKIN :  std_logic := '0';
	SIGNAL SYSCLKIN :  std_logic := '0';
	SIGNAL FIBERIN :  std_logic := '0';
	SIGNAL FIBEROUT :  std_logic := '0';
	SIGNAL DATAA :  std_logic_vector(15 downto 0) := (others => 'Z');
	SIGNAL ADDRA :  std_logic_vector(15 downto 0) := (others => '0'); 
	SIGNAL WEA :  std_logic;
	SIGNAL RDA :  std_logic;
	SIGNAL RESETA :  std_logic;
	SIGNAL SAMPLESA :  std_logic;
	SIGNAL EVENTSA :  std_logic;
	SIGNAL TINCA :  std_logic;
	SIGNAL TCLRA :  std_logic;
	SIGNAL DATAB :  std_logic_vector(15 downto 0) := (others => 'Z');
	SIGNAL ADDRB :  std_logic_vector(15 downto 0) := (others => '0');
	SIGNAL WEB :  std_logic;
	SIGNAL RDB :  std_logic;
	SIGNAL RESETB :  std_logic;
	SIGNAL SAMPLESB :  std_logic;
	SIGNAL EVENTSB :  std_logic;
	SIGNAL TINCB :  std_logic;
	SIGNAL TCLRB :  std_logic;
	SIGNAL EVENT :  std_logic := '1';
	SIGNAL ECE :  std_logic;
	SIGNAL EADDR :  std_logic_vector(7 downto 0);
	SIGNAL EDATA :  std_logic_vector(15 downto 0);
	SIGNAL SYSDATA :  std_logic_vector(15 downto 0);
	SIGNAL DATAEN :  std_logic := '1';
	SIGNAL DATAACK :  std_logic;
	SIGNAL RESET :  std_logic := '1';

	component test_event is
	    Port ( CLK : in std_logic;
	           CMDIN : in std_logic_vector(15 downto 0);
	           DIN0 : in std_logic_vector(15 downto 0);
	           DIN1 : in std_logic_vector(15 downto 0);
	           DIN2 : in std_logic_vector(15 downto 0);
	           DIN3 : in std_logic_vector(15 downto 0);
	           DIN4 : in std_logic_vector(15 downto 0);
	           ADDRIN : in std_logic_vector(47 downto 0);
	           SENDEVENT : in std_logic;
	           QUERYEVENT : in std_logic;
	           DONE : out std_logic;
				  CMDOUT: out std_logic_vector(15 downto 0); 
	           DOUT0 : out std_logic_vector(15 downto 0);
	           DOUT1 : out std_logic_vector(15 downto 0);
	           DOUT2 : out std_logic_vector(15 downto 0);
	           DOUT3 : out std_logic_vector(15 downto 0);
	           DOUT4 : out std_logic_vector(15 downto 0);
				  EDATA : inout std_logic_vector(15 downto 0);
				  EADDR : inout std_logic_vector(7 downto 0);  
				  ECE : out std_logic;
				  EEVENT : out std_logic
				  );
	end component;
	
	signal ecmdin, edin0, edin1, edin2, edin3, edin4, ecmdout,
			edout0, edout1, edout2, edout3, edout4 : std_logic_vector(15 downto 0)
			 := (others => '0');
	signal eaddrin : std_logic_vector(47 downto 0) := (others => '0'); 
	signal sendevent, queryevent, eventdone : std_logic := '0';

	signal clk, sysclk : std_logic := '0'; 
	  
		

BEGIN


	eventcontroller: test_event port map (
			CLK => SYSCLK,
			CMDIN => ecmdin,
			DIN0 => edin0,
			DIN1 => edin1, 
			DIN2 => edin2, 
			DIN3 => edin3, 
			DIN4 => edin4, 
			ADDRIN => eaddrin,
			SENDEVENT => sendevent,
			QUERYEVENT => queryevent,
			DONE => eventdone,
			CMDOUT => ecmdout, 
			DOUT0 => edout0,
			DOUT1 => edout1,
			DOUT2 => edout2,
			DOUT3 => edout3, 
			DOUT4 => edout4,
			EADDR => EADDR,  
			EDATA => EDATA,
			ECE => ECE,
			EEVENT => EVENT) ; 


	uut: dspboard PORT MAP(
		CLKIN => CLKIN,
		SYSCLKIN => SYSCLKIN,
		FIBERIN => FIBERIN,
		FIBEROUT => FIBEROUT,
		DATAA => DATAA,
		ADDRA => ADDRA,
		WEA => WEA,
		RDA => RDA,
		RESETA => RESETA,
		SAMPLESA => SAMPLESA,
		EVENTSA => EVENTSA,
		TINCA => TINCA,
		TCLRA => TCLRA,
		DATAB => DATAB,
		ADDRB => ADDRB,
		WEB => WEB,
		RDB => RDB,
		RESETB => RESETB,
		SAMPLESB => SAMPLESB,
		EVENTSB => EVENTSB,
		TINCB => TINCB,
		TCLRB => TCLRB,
		EVENT => EVENT,
		ECE => ECE,
		EADDR => EADDR,
		EDATA => EDATA,
		SYSDATA => SYSDATA,
		DATAEN => DATAEN,
		DATAACK => DATAACK,
		RESET => RESET
	);



	clk <= not clk after 7.8125 ns; -- 64 MHz
	sysclk <= not sysclk after 25 ns; -- 20 MHz; 

	CLKIN <= CLK;
	SYSCLKIN <= sysclk; 

	RESET <= '0' after 100 ns; 



-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

	busclock: process is
			procedure waitclk(duration : in integer) is
			begin
				for i in 0 to duration loop
					wait until rising_edge(clk);
				end loop; 
			end procedure waitclk;

			procedure wevent(addr : in std_logic_vector(47 downto 0);
								  cmd : in std_logic_vector(15 downto 0); 
								  din0, din1, din2, din3, din4 
								  		: in std_logic_vector(15 downto 0)) is
			begin
				  ecmdin <= cmd;
				  eaddrin <= addr; 
				  edin0 <= din0; 
				  edin1 <= din1; 
				  edin2 <= din2; 
				  edin3 <= din3; 
				  edin4 <= din4;
				  sendevent <= '1';
				  wait until rising_edge(sysclk);
				  sendevent <= '0';
			end procedure wevent;  

	begin
		wait until falling_edge(RESET); 
			waitclk(30); 
			wevent(X"FFFFFFFFFFFF", X"0002", X"0000", X"0000", X"0000", X"0000", X"0000");

		wait; 


	end process busclock; 

END;
