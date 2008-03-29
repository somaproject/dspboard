library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;



entity acqcmdmux is
  
  port (
    CLK : in std_logic;
    CMDIDRX : in std_logic_vector(3 downto 0); 
    CMDINTXA : in std_logic_vector(47 downto 0);
    CMDINTXB : in std_logic_vector(47 downto 0);
    NEWCMDS : in std_logic;
    LINKUP : in std_logic; 
    CMDOUT : out std_logic_vector(47 downto 0);
    SENDCMD : out std_logic
  ); 
    
end acqcmdmux;

architecture Behavioral of acqcmdmux is
  signal cmdinal, cmdinbl : std_logic_vector(47 downto 0) := (others => '0');
  signal cmdidaold, cmdidbold : std_logic_vector(3 downto 0) := (others => '0');

  signal newcmda, newcmdb : std_logic := '0';

  signal newcmdal, newcmdbl : std_logic := '0';

  type states is (none, linkwait, sendsync,
                  checka, senda, waita, donea,
                checkb, sendb, waitb, doneb);

  signal osel : integer range 0 to 2 := 0;
  
  signal cs, ns : states := none;

  signal lsendcmd : std_logic := '0';
  

begin  -- Behavioral

--  CMDOUT <= CMDINTXA when linkup = '1' else CMDINTXB;  -- total hack debugging
    main: process(CLK, LINKUP)
      begin
        if LINKUP = '0'  then
          -- global reset
          cmdinal <= (others => '0');
          cmdinbl <= (others => '0');
          newcmdal <= '0';
          newcmdbl <= '0';
          cs <= linkwait; 
        else
          if rising_edge(CLK) then
            cs <= ns;

            SENDCMD <= lsendcmd;
          
            if osel = 0 then
              CMDOUT <= cmdinal;
            elsif osel = 1 then
              CMDOUT <=cmdinbl;
            end if;
          
            if NEWCMDS = '1' then
              cmdinal <= CMDINTXA;
              cmdinbl <= CMDINTXB; 
            end if;

            if cmdidaold  /= cmdinal(7 downto 4) then
              cmdidaold <= cmdinal(7 downto 4); 
              newcmdal <= '1';
            else
              if cs = donea then
                newcmdal <= '0'; 
              end if;
            end if;
          
            if cmdidbold  /= cmdinbl(7 downto 4) then
              cmdidbold <= cmdinbl(7 downto 4); 
              newcmdbl <= '1';
            else
              if cs = doneb then
                newcmdbl <= '0'; 
              end if;
            end if;


          end if;
        end if;

      end process main; 
  
      fsm: process(cs, newcmdal, LINKUP,
                   CMDIDRX, cmdidaold, cmdidbold, newcmdbl)
        begin
          case cs is
            when none =>
              osel <= 0;
              lsendcmd <= '0';
              if LINKUP = '0' then
                ns <= linkwait;
              else
                ns <= checka; 
              end if;
             
            when linkwait =>
              osel <= 2;
              lsendcmd <= '0';
              if LINKUP = '1' then
                ns <= sendsync;
              else
                ns <= linkwait;
              end if;
            
            when sendsync =>
              osel <= 2;
              lsendcmd <= '1';
              ns <= none;
            
            when checka =>
              osel <= 0;
              lsendcmd <= '0';
              if newcmdal = '1' then
                ns <= senda;
              else
                ns <= checkb; 
              end if;

            when senda =>
              osel <= 0;
              lsendcmd <= '1';
              ns <= waita;

            when waita =>
              osel <= 0;
              lsendcmd <= '0';
              if CMDIDRX = cmdidaold  then
                ns <= donea;
              else
                ns <= waita;
              end if;

            when donea =>
              osel <= 0;
              lsendcmd <= '0';
              ns <= checkb; 
            
            when checkb =>
              osel <= 1;
              lsendcmd <= '0';
              if newcmdbl = '1' then
                ns <= sendb;
              else
                ns <= none; 
              end if;

            when sendb =>
              osel <= 1;
              lsendcmd <= '1';
              ns <= waitb;

            when waitb =>
              osel <= 1;
              lsendcmd <= '0';
              if CMDIDRX = cmdidbold  then
                ns <= doneb;
              else
                ns <= waitb;
              end if;

            when doneb =>
              osel <= 1;
              lsendcmd <= '0';
              ns <= none; 
            
            when others =>
              osel <= 0;
              lsendcmd <= '0';
              ns <= none; 
            
          end case;

        end process fsm;

      
end Behavioral;
