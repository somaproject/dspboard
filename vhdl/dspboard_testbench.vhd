
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
USE ieee.std_logic_signed.all; 
-- use IEEE.STD_LOGIC_ARITH.ALL; 
use ieee.std_logic_textio.all;
use std.textio.all;

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
		TCLRB : OUT std_logic;
		FLAG0BINPUT : in std_logic 
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
	SIGNAL ECE :  std_logic := '1';
	SIGNAL EADDR :  std_logic_vector(7 downto 0);
	SIGNAL EDATA :  std_logic_vector(15 downto 0);
	SIGNAL SYSDATA :  std_logic_vector(15 downto 0);
	SIGNAL DATAEN :  std_logic := '1';
	SIGNAL DATAACK :  std_logic;
	SIGNAL RESET :  std_logic := '1';
	signal 	datapktlen:  integer := 0; 
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

	signal clk, sysclk, dspclk, clk8mhz : std_logic := '0'; 
	  
	component test_acqboard is
	    Port ( CLK : in std_logic;
	           FIBEROUT : out std_logic;
	           FIBERIN : in std_logic);
	end component;
		
	signal flag0binput: std_logic; 
BEGIN

	
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
		RESET => RESET,
		FLAG0BINPUT => flag0binput
	);

	acqtest: test_acqboard port map (
		clk => clk8Mhz,
		FIBERIN => FIBEROUT,
		FIBEROUT => FIBERIN); 

	clk8mhz <= not clk8mhz after 62.5 ns; 
	clk <= not clk after 7.8125 ns; -- 64 MHz
	sysclk <= not sysclk after 25 ns; -- 20 MHz; 
	dspclk <= not dspclk after 2.5 ns; -- 200 MHz (!!!!!)

	CLKIN <= CLK;
	SYSCLKIN <= sysclk; 

	RESET <= '0' after 100 ns; 

	 

-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

	dspclockl: process is

		-- SLV2HEX
		function slv2hex (
		  hex_in : std_logic_vector)
		  return string is
		  variable textline : line;
		  variable tmp_string : string(1 to hex_in'length / 4);
		    begin  -- function slv2hex
		      hwrite(textline,hex_in);
		      read(textline,tmp_string);
		      return(tmp_string);
		    end function slv2hex;


		-- WAITCLK
		procedure waitclk(duration : in integer) is
		begin
			for i in 0 to duration loop
				wait until rising_edge(dspclk);
			end loop; 
		end procedure waitclk;

		-- MEMR16
		procedure memr16(addr : in std_logic_vector(15 downto 0);
							  dataout : out std_logic_vector(15 downto 0)) is 
		begin
			DATAA <= (others => 'Z'); 
			wait until rising_edge(dspclk); 
			 
			ADDRA <= addr; 
			waitclk(3); 
			RDA <= '0'; 
			waitclk(12); 
		   dataout := DATAA; 
			wait until rising_edge(dspclk); 
			RDA <= '1'; 
			wait until rising_edge(dspclk); 
			DATAA <= (others => 'Z'); 	


		end memr16; 


		-- MEMW16
		procedure memw16(addr : in std_logic_vector(15 downto 0);
							  data : in std_logic_vector(15 downto 0)) is
		begin
			DATAA <= (others => 'Z'); 
			wait until rising_edge(dspclk); 
			 
			ADDRA <= addr; 
			waitclk(3); 
			WEA <= '0'; 
		   DATAA <= data; 
			waitclk(15); 
			wait until rising_edge(dspclk); 
			WEA <= '1'; 
			wait until rising_edge(dspclk); 
			DATAA <= (others => 'Z'); 	
		end memw16; 

		-- MEMR8
		procedure memr8(addr : in std_logic_vector(15 downto 0);
							 dataout: out std_logic_vector(7 downto 0)) is 
			variable result : std_logic_vector(7 downto 0) := (others => '0'); 
		begin
			DATAA <= (others => 'Z'); 
			wait until rising_edge(dspclk); 
			DATAA(15 downto 8) <= addr(7 downto 0); 
			ADDRA <= X"00" & addr(15 downto 8); 
			waitclk(3); 
			RDA <= '0'; 
			waitclk(20); 
		   dataout := DATAA(7 downto 0); 
			wait until rising_edge(dspclk); 
			RDA <= '1'; 
			wait until rising_edge(dspclk); 
			DATAA <= (others => 'Z'); 	

			 
		
		end memr8;  

		procedure dataw(len : in integer; base : in integer) is 
			variable outword: std_logic_vector(15 downto 0); 

		begin

			-- remember, len < 256 and > 30
			for i in 0 to (len -1) loop
				-- we start writing at... 
				if i = 0 then
					outword := std_logic_vector(TO_UNSIGNED(len, 8)) & X"00"; 
				else
					outword := std_logic_vector(TO_UNSIGNED(i + base * 256, 16)); 
				end if; 

				memw16(std_logic_vector(TO_UNSIGNED(i + 8192, 16)),
						 outword); 
			end loop; 
		end dataw; 


		variable loadbyte : std_logic_vector(7 downto 0);
		variable loadword : std_logic_vector(15 downto 0);
		variable loopbreak : std_logic := '0';
		  
	begin
		ADDRA <= (others => '0');
		RDA <= '1';
		WEA <= '1'; 
		DATAA <= (others => 'Z'); 

		wait until rising_edge(RESETA); -- wait until we can boot

		for i in 0 to 1023 loop  -- when we boot, we read 256 32-bit words
											-- in 8-bit mode. 
										
				
				memr8(std_logic_vector(TO_UNSIGNED(i, 16)), loadbyte);
				
					report  slv2hex(loadbyte)
					severity note; 
		end loop; 

		-- switch boot modes -- go into 8-bit interface
		memr16(X"F000", loadword); 

		-- write an event!
		memw16(X"4000", X"4718"); 
		memw16(X"4001", X"abc6"); 
		memw16(X"4002", X"2837"); 
		memw16(X"4003", X"0004"); -- BS event! 
		memw16(X"4004", X"0000"); 
		memw16(X"4005", X"0001"); 
		memw16(X"4006", X"0002"); 
		memw16(X"4007", X"0003"); 
		memw16(X"4008", X"0004"); 
		memw16(X"4009", X"0000"); 

 		memw16(X"4000", X"0123"); 
		memw16(X"4001", X"4567"); 
		memw16(X"4002", X"89AB"); 
		memw16(X"4003", X"0004"); -- BS event! 
		memw16(X"4004", X"aaaa"); 
		memw16(X"4005", X"bbbb"); 
		memw16(X"4006", X"cccc"); 
		memw16(X"4007", X"dddd"); 
		memw16(X"4008", X"eeee"); 
		memw16(X"4009", X"ffff"); 

 		memw16(X"4000", X"0123"); 
		memw16(X"4001", X"4567"); 
		memw16(X"4002", X"89AB"); 
		memw16(X"4003", X"0004"); -- BS event! 
		memw16(X"4004", X"aaaa"); 
		memw16(X"4005", X"bbbb"); 
		memw16(X"4006", X"cccc"); 
		memw16(X"4007", X"dddd"); 
		memw16(X"4008", X"eeee"); 
		memw16(X"4009", X"ffff"); 

 		memw16(X"4000", X"FFFF"); 
		memw16(X"4001", X"FFFF"); 
		memw16(X"4002", X"FFFF"); 
		memw16(X"4003", X"0005"); -- BS event! 
		memw16(X"4004", X"aaaa"); 
		memw16(X"4005", X"bbbb"); 
		memw16(X"4006", X"cccc"); 
		memw16(X"4007", X"dddd"); 
		memw16(X"4008", X"eeee"); 
		memw16(X"4009", X"ffff"); 


		-- now we poll and read events:
		loopbreak := '0'; 
		while(loopbreak = '0') loop
			if rising_edge(dspclk) and EVENTSA = '1' then
				memr16(X"6000", loadword); 
				if loadword = X"0006" then 
					report "DSP has read an 0x0006 event!";
					loopbreak := '1'; 
							
					
				end if;
				memr16(X"6006", loadword); 
			end if; 
			wait until rising_edge(dspclk); 

		end loop;   



		--- then we try and write three events!
		dataw(50, 0); 
		dataw(100, 1); 
		dataw(200, 2); 

		memw16(X"4000", X"0123"); 
		memw16(X"4001", X"4567"); 
		memw16(X"4002", X"89AB"); 
		memw16(X"4003", X"0008"); -- Event to say we're done writing data! 
		memw16(X"4004", X"0000"); 
		memw16(X"4005", X"0001"); 
		memw16(X"4006", X"0002"); 
		memw16(X"4007", X"0003"); 
		memw16(X"4008", X"0004"); 
		memw16(X"4009", X"0000"); 


		-- and then we wait for the 0x0009 event to say all pkts rxed
		loopbreak := '0'; 
		while(loopbreak = '0') loop
			if rising_edge(dspclk) and EVENTSA = '1' then
				memr16(X"6000", loadword); 
				if loadword = X"0009" then 
					report "DSP has read an 0x0009 event!";
					loopbreak := '1'; 
							
					
				end if;
				memr16(X"6006", loadword); 
			end if; 
			wait until rising_edge(dspclk); 

		end loop; 
		
		dataw(64, 3); 
		dataw(128, 4); 
		dataw(192, 5); 
		
		  

		wait;	



	end process dspclockl; 

	busclock: process is

			procedure waitclk(duration : in integer) is
			begin
				for i in 0 to duration loop
					wait until rising_edge(sysclk);
				end loop; 
			end procedure waitclk;


			procedure wevent(addr : in std_logic_vector(47 downto 0);
								  cmd : in std_logic_vector(15 downto 0); 
								  din0, din1, din2, din3, din4 
								  		: in std_logic_vector(15 downto 0)) is
			begin	
				  wait until rising_edge(sysclk); -- initial wait
				  ECE <= '1' after 20 ns;
				  EVENT <= '0' after 20 ns; 
				  wait until rising_edge(sysclk);
				  EVENT <= '1' after 20 ns; 
				  EDATA <= cmd after 20 ns; 
				  EADDR <= addr(7 downto 0) after 20 ns; 
				  wait until rising_edge(sysclk);
				  EDATA <= din0 after 20 ns; 
				  EADDR <= addr(7 downto 0) after 20 ns;
				  wait until rising_edge(sysclk);
				  EDATA <= din1 after 20 ns; 
				  EADDR <= addr(7 downto 0) after 20 ns; 
				  wait until rising_edge(sysclk);
				  EDATA <= din2 after 20 ns; 
				  EADDR <= addr(7 downto 0) after 20 ns; 
				  wait until rising_edge(sysclk);
				  EDATA <= din3 after 20 ns; 
				  EADDR <= addr(7 downto 0) after 20 ns; 
				  wait until rising_edge(sysclk);
				  EDATA <= din4 after 20 ns;
				  EADDR <= addr(7 downto 0) after 20 ns;
				  wait until rising_edge(sysclk);
				  EDATA <= (others => 'Z') after 20 ns; 
				  EADDR <= (others => 'Z') after 20 ns;
				  

				   
			end procedure wevent;  

			procedure revent(addr : out std_logic_vector(47 downto 0);
								  cmd : out std_logic_vector(15 downto 0); 
								  din0, din1, din2, din3, din4 
								  		: out std_logic_vector(15 downto 0)) is
			begin	
				  wait until rising_edge(sysclk); -- initial wait!

				  ECE <= '0' after 10 ns;
				  EVENT <= '0' after 10 ns;
				  wait until rising_edge(sysclk);
				  EVENT <= '1' after 10 ns;
				  ECE <= '1' after 10 ns;  
				  wait until rising_edge(sysclk);
				  cmd := EDATA;
				  addr(7 downto 0) := EADDR;
				  wait until rising_edge(sysclk);
				  din0 := EDATA; 
				  addr(7 downto 0) := EADDR; 
				  wait until rising_edge(sysclk);
				  din1 := EDATA; 
				  addr(7 downto 0) := EADDR; 
				  wait until rising_edge(sysclk);
				  din2 := EDATA; 
				  addr(7 downto 0) := EADDR; 
				  wait until rising_edge(sysclk);
				  din3 := EDATA; 
				  addr(7 downto 0) := EADDR; 
				  wait until rising_edge(sysclk);
				  din4 := EDATA; 
				  addr(7 downto 0) := EADDR;
				  wait until rising_edge(sysclk);

				  

				   
			end procedure revent;  

			procedure rdata(rxlen : out integer) is
				type databuffer is array(0 to 511) of integer;
				variable inbuf : databuffer := (others => 0);  
				variable pos, timetilack, len : integer := 0; 
			begin
				pos := 0; 
				timetilack := 6; 

				wait until rising_edge(sysclk); 
				wait until rising_edge(sysclk); 
				wait until rising_edge(sysclk); 
				wait until rising_edge(sysclk); 
				wait until rising_edge(sysclk); 
				dataen <= '0'; 
				wait until rising_edge(sysclk); 
				while pos < 1000 loop
					timetilack := timetilack - 1; 
					if dataack = '0' then
						inbuf(pos) := TO_INTEGER(UNSIGNED(SYSDATA)); 
						if pos = 0 then
							len := TO_INTEGER(UNSIGNED(SYSDATA(15 downto 8))); 
						end if; 


						pos := pos + 1; 
						
					end if;
					wait until rising_edge(sysclk); 
					if pos = 0 and timetilack < 0 then 
						-- whoa, not gonna send a frame, i guess
						pos := 1000;
					end if;

					if pos = (len - 1) then 
						pos := 1000; 
					end if;
				end loop; 
				dataen <= '1'; 

				rxlen := len; 
				
			end procedure rdata; 


			variable laddr :  std_logic_vector(47 downto 0);
			variable  lcmd, ldin0, ldin1, ldin2, ldin3, ldin4 
								  		: std_logic_vector(15 downto 0);
		
			variable pktlen : integer := 0; 
	begin
		wait until falling_edge(RESET); 
			ECE <= '1'; 
			EDATA <= (others => 'Z'); 
			waitclk(30); 
			-- boot, i.e. give IDs
			EDATA <= X"0010"; 
			ECE <= '0';
			wait until falling_edge(sysclk); 
			ECE <= '1';
			EDATA <= (others => '0'); 
			waitclk(20); 
			wevent(X"FFFFFFFFFFFF", X"0002", X"0001", X"0000", X"0000", X"0000", X"0000");
			wevent(X"FFFFFFFFFFFF", X"0001", X"0001", X"0000", X"0000", X"0000", X"0000");
			wevent(X"FFFFFFFFFFFF", X"0003", X"0000", X"0000", X"0001", X"0002", X"0003");
			for i in 0 to 127 loop
					
				wevent(X"FFFFFFFFFFFF", X"0003", std_logic_vector(TO_UNSIGNED(i*4, 16)),
															std_logic_vector(TO_UNSIGNED((i*8 + 1) mod 256, 8)) & 
															std_logic_vector(TO_UNSIGNED((i*8 + 0) mod 256, 8)), 
															std_logic_vector(TO_UNSIGNED((i*8 + 3) mod 256, 8)) & 
															std_logic_vector(TO_UNSIGNED((i*8 + 2) mod 256, 8)), 
															std_logic_vector(TO_UNSIGNED((i*8 + 5) mod 256, 8)) & 
															std_logic_vector(TO_UNSIGNED((i*8 + 4) mod 256, 8)), 
															std_logic_vector(TO_UNSIGNED((i*8 + 7) mod 256, 8)) & 
															std_logic_vector(TO_UNSIGNED((i*8 + 6) mod 256, 8)));
			end loop; 
			
			waitclk(30); 
				wevent(X"FFFFFFFFFFFF", X"0002", X"0000", X"0000", X"0001", X"0002", X"0003");

			-- now, we query for events until we read an 0x0005
			while (lcmd /= X"0005") loop
				revent(laddr, lcmd, ldin0, ldin1, ldin2, ldin3, ldin4); 
				if lcmd = X"0005" then
					report "0x0005 event was placed on bus successfully by dsp!";
				end if;

				waitclk(30); 

			end loop;

			for i in 0 to 3 loop
				wevent(X"FFFFFFFFFFFF", X"0003", 
							std_logic_vector(TO_UNSIGNED(i, 16)),
							std_logic_vector(TO_UNSIGNED(i, 16)),
							std_logic_vector(TO_UNSIGNED(i, 16)),
							std_logic_vector(TO_UNSIGNED(i, 16)),
							std_logic_vector(TO_UNSIGNED(i, 16)));
			end loop;  

				wevent(X"FFFFFFFFFFFF", X"0006", 
							X"0000",
							X"0000",
							X"0000",
							X"0000",
							X"0000"
							);

			-- now we wait for the completion of the 3 data writes:

			while (lcmd /= X"0008") loop
				revent(laddr, lcmd, ldin0, ldin1, ldin2, ldin3, ldin4); 
				if lcmd = X"0008" then
					report "DSP is done writing data events";
				end if;

				waitclk(30); 

			end loop;
			
			pktlen := 0; 
			while (pktlen = 0) loop
				rdata(pktlen); 
			end loop;		
			datapktlen <= pktlen;  

			pktlen := 0; 
			while (pktlen = 0) loop
				rdata(pktlen); 
			end loop;
			datapktlen <= pktlen;  

			pktlen := 0; 
			while (pktlen = 0) loop
				rdata(pktlen); 
			end loop;
			datapktlen <= pktlen;  
			
				wevent(X"FFFFFFFFFFFF", X"0009", 
							X"0000",
							X"0000",
							X"0000",
							X"0000",
							X"0000"
							);		


			pktlen := 0; 
			while (pktlen = 0) loop
				rdata(pktlen); 
			end loop;		
			datapktlen <= pktlen;  

			pktlen := 0; 
			while (pktlen = 0) loop
				rdata(pktlen); 
			end loop;
			datapktlen <= pktlen;  

			pktlen := 0; 
			while (pktlen = 0) loop
				rdata(pktlen); 
			end loop;
			datapktlen <= pktlen;  


	end process busclock; 

END;
