
--------------------------------
--  Subset of C Processor     --
--                            --
--       (c) Keishi SAKANUSHI --
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
 
entity Controler is
    port (
    selMuxDIn : out std_logic;

    loadhMB   : out std_logic;
    loadlMB   : out std_logic;
    loadhIX   : out std_logic;
    loadlIX   : out std_logic;

    loadIR    : out std_logic;
    IRout     : in  std_logic_vector (7 downto 0);

    loadIP    : out std_logic;
    incIP     : out std_logic;
    inc2IP    : out std_logic;
    clearIP   : out std_logic;

    selMuxAddr: out std_logic;
    ZeroF     : in  std_logic;
    CarryF    : in  std_logic;

    loadRegB  : out std_logic;
    loadRegA  : out std_logic;
    loadID    : out std_logic;

    modeALU   : out std_logic_vector (3 downto 0);
    loadFZ    : out std_logic;
    loadFC    : out std_logic;
    
    selMuxDOut: out std_logic_vector (1 downto 0);

    read      : out std_logic;
    write     : out std_logic;

    clock     : in  std_logic;
    reset     : in  std_logic
  );
end Controler;

architecture logic of Controler is

component Johnson1L0 
  port (
    cond0 : in  std_logic;
    clock : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic
  );
end component;

component Johnson1L1 
  port (
    cond1 : in  std_logic;
    clock : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic
  );
end component;

component Johnson1L01 
  port (
    cond0 : in  std_logic;
    cond1 : in  std_logic;
    clock : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic
  );
end component;

component Johnson2L0 
  port (
    cond0 : in  std_logic;
    clock : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic_vector(1 downto 0)
  );
end component;

component Johnson3L0 
  port (
    cond0 : in  std_logic;
    clock : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic_vector(2 downto 0)
  );
end component;

--------------------------------
--  
--  Signals from/ot Johnson Counters for External Signals
--  
--------------------------------
signal qJCextA : std_logic;
signal qJCextB : std_logic;
signal qJCextC : std_logic_vector(1 downto 0);
signal qJCextD : std_logic_vector(1 downto 0);
signal qJCextE : std_logic_vector(2 downto 0);

signal cJCextA : std_logic;
signal cJCextB : std_logic;
signal cJCextC : std_logic;
signal cJCextD : std_logic;
signal cJCextE : std_logic;
signal cs1     : std_logic;
signal cs2     : std_logic;

--------------------------------
--  
--  Signals from/ot Johnson Counters for internal Signals
--  
--------------------------------
signal qJCintA : std_logic;
signal qJCintB : std_logic_vector(1 downto 0);
signal qJCintC : std_logic_vector(1 downto 0);
signal qJCintD : std_logic;
signal qJCintE : std_logic_vector(1 downto 0);
signal qJCintF : std_logic_vector(2 downto 0);

signal cact    : std_logic;
signal cJCintB : std_logic;
signal cJCintC : std_logic;
signal cJCintD : std_logic;
signal cJCintE : std_logic;
signal cJCintF : std_logic;
signal chalt   : std_logic;


--------------------------------

signal one     : std_logic;

begin    -- logic
one <= '1';

--------------------------------
--  
--  Johnson Counters for External Signals
--  
--------------------------------

----------------
--   JCextA   --
----------------
JCextA : Johnson1L01
  port map(
    cond0 => cJCextA,
    cond1 => cs1,
    clock => clock,
    reset => reset,
    q     => qJCextA
  );

----------------
--   JCextB   --
----------------
JCextB : Johnson1L01
  port map(
    cond0 => cJCextB,
    cond1 => cs2,
    clock => clock,
    reset => reset,
    q     => qJCextB
  );

----------------
--   JCextC   --
----------------
JCextC : Johnson2L0
  port map(
    cond0  => cJCextC,
    clock => clock,
    reset => reset,
    q     => qJCextC
  );
  
----------------
--   JCextD   --
----------------
JCextD : Johnson2L0
  port map(
    cond0  => cJCextD,
    clock => clock,
    reset => reset,
    q     => qJCextD
  );

----------------
--   JCextE   --
----------------
JCextE : Johnson3L0
  port map(
    cond0  => cJCextE,
    clock => clock,
    reset => reset,
    q     => qJCextE
  );


--------------------------------
--  
--  Decode logic for External Signals
--  
--------------------------------
selMuxAddr <= '1' when qJCextB = '1'  else
              '1' when qJCextC = "01" else
	          '1' when qJCextC = "11" else
	          '1' when qJCextC = "10" else
              '1' when qJCextD = "01" else
	          '1' when qJCextD = "11" else
	          '1' when qJCextD = "10" else
              '1' when qJCextE = "111" else
	          '1' when qJCextE = "110" else
	          '1' when qJCextE = "100" else
	          '0' ;
              
selMuxDOut <= "01" when qJCextD = "01" else
	          "01" when qJCextD = "11" else
	          "01" when qJCextD = "10" else
              "10" when qJCextE = "111" else
	          "10" when qJCextE = "110" else
              "10" when qJCextE = "100" else
	          "00" ;

read  <= '0' when qJCextA = '1' else
         '0' when qJCextB = '1' else
         '0' when qJCextE = "001" else
         '0' when qJCextE = "011" else
         '1';

write <= '0' when qJCextC = "11" else
         '0' when qJCextD = "11" else
         '0' when qJCextE = "110" else
         '1';


--------------------------------
--  
--  Johnson Counters for Internal Signals
--  
--------------------------------
----------------
--   JCintA   --
----------------
JCintA : Johnson1L1
  port map(
    cond1 => cact,
    clock => clock,
    reset => reset,
    q     => qJCintA
  );


----------------
--   JCintB   --
----------------
JCintB : Johnson2L0
  port map(
    cond0 => cJCintB,
    clock => clock,
    reset => reset,
    q     => qJCintB
  );


----------------
--   JCintC   --
----------------
JCintC : Johnson2L0
  port map(
    cond0 => cJCintC,
    clock => clock,
    reset => reset,
    q     => qJCintC
  );


----------------
--   JCintD   --
----------------
JCintD : Johnson1L0
  port map(
    cond0 => cJCintD,
    clock => clock,
    reset => reset,
    q     => qJCintD
  );


----------------
--   JCintE   --
----------------
JCintE : Johnson2L0
  port map(
    cond0 => cJCintE,
    clock => clock,
    reset => reset,
    q     => qJCintE
  );


----------------
--   JCintF   --
----------------
JCintF : Johnson3L0
  port map(
    cond0  => cJCintF,
    clock => clock,
    reset => reset,
    q     => qJCintF
  );
  



--------------------------------
--  
--  Decode Logic for Control Signals
--   of Johnson Counters for External
--  
--------------------------------

cJCextA <= '1' when qJCintA = '0' else
           '1' when (qJCintB = "10" and irout(7 downto 4) = "1101") else -- SETIXH SETIXL LDIA LDIB
           '1' when (qJCintB = "10" and irout(7 downto 4) = "0110") else -- JP
           '1' when (qJCintB = "10" and irout(7 downto 4) = "0101" and ZeroF = '1') else -- JPZ(Z=1)
           '1' when (qJCintB = "10" and irout(7 downto 4) = "0100" and CarryF= '1') else -- JPC(C=1)
           '1' when (qJCintC = "11" and irout(7 downto 4) = "1110") else -- LDDA LDDB
           '1' when (qJCintD = '1')  else -- ALU
		   '1' when (qJCintE = "10") else -- STD
           '1' when (qJCintF = "100") else -- JP, STDI
           '0';

cJCextB <= '1' when (qJCintB = "10" and irout(7 downto 4) = "1110") else -- LDDA LDDB
           '0';

cJCextC <= '1' when (qJCintB = "10" and irout = "11110000") else -- STDA 
           '0';
           
cJCextD <= '1' when (qJCintB = "10" and irout = "11110100") else -- STDB 
           '0';
           
cJCextE <= '1' when (qJCintB = "10" and irout = "11111000") else -- STDI 
           '0';

cs1     <= '1' when qJCintB = "11"  else
           '1' when (qJCintF = "110" and irout(7 downto 4) = "0110") else -- JP
           '1' when (qJCintF = "110" and irout(7 downto 4) = "0101" and ZeroF = '1') else -- JPZ(Z=1)
           '1' when (qJCintF = "110" and irout(7 downto 4) = "0100" and CarryF= '1') else -- JPC(C=1)
		   '0';

cs2     <= '1' when (qJCintC = "11" and irout(7 downto 4) = "1110") else -- LDDA LDDB
           '0';


--------------------------------
--  
--  Decode Logic for Control Signals
--   of Johnson Counters for Inernal
--  
--------------------------------
cact    <= '0';

cJCintB <= '1' when qJCintA = '0'   else
           '1' when qJCintC = "11"  else
           '1' when qJCintD = '1'   else
           '1' when qJCintE = "10"  else
           '1' when qJCintF = "100" else
           '0';

cJCintC <= '1' when (qJCintB = "10" and irout(7 downto 5) = "110") else -- SETIXH SETIXL LDIA LDIB
           '1' when (qJCintB = "10" and irout(7 downto 4) = "1110") else -- LDDA LDDB
           '0';

cJCintD <= '1' when (qJCintB = "10" and irout(7 downto 5) = "100") else -- ADD SUB AND OR NOT INC DEC
           '1' when (qJCintB = "10" and irout(7 downto 5) = "101") else -- CMP
           '1' when (qJCintB = "10" and irout(7 downto 4) = "0100" and ZeroF = '0') else -- JPZ(Z=0)
           '1' when (qJCintB = "10" and irout(7 downto 4) = "0101" and CarryF = '0') else -- JPC(C=0)
           '0';

cJCintE <= '1' when (qJCintB = "10" and irout(7 downto 3) = "11110") else -- STDA STDB
           '0';
    
cJCintF <= '1' when (qJCintB = "10" and irout(7 downto 3) = "11111") else -- STDI
           '1' when (qJCintB = "10" and irout(7 downto 4) = "0110") else -- JP
           '1' when (qJCintB = "10" and irout(7 downto 4) = "0100" and ZeroF = '1') else -- JPZ(Z=1)
           '1' when (qJCintB = "10" and irout(7 downto 4) = "0101" and CarryF= '1') else -- JPC(C=1)
           '0';

--------------------------------
--  
--  Decode logic for Internal Signals
--  
--------------------------------
clearIP   <= '1' when qJCintA='0' else
		     '0';

loadIR    <= '1' when qJCintB = "11" else
	         '0';

modeALU   <= irout(3 downto 0) when (qJCintD = '1' and irout(7 downto 6) = "10") else
             "0000";

loadFZ    <= '1' when ( qJCintD = '1' and irout(7 downto 6) = "10") else
             '1' when ( qJCintD = '1' and irout(7 downto 4) = "0101") else
             '0';
             
loadFC    <= '1' when ( qJCintD = '1' and irout(7 downto 6) = "10" and irout(2 downto 0) = "000") else -- ADD
             '1' when ( qJCintD = '1' and irout(7 downto 6) = "10" and irout(2 downto 0) = "001") else -- SUB
             '1' when ( qJCintD = '1' and irout(7 downto 6) = "10" and irout(2 downto 0) = "101") else -- INC
             '1' when ( qJCintD = '1' and irout(7 downto 6) = "10" and irout(2 downto 0) = "110") else -- DEC
             '0';

loadhMB   <= '1' when (qJCintF = "011" and irout(7 downto 4) = "1000") else -- JP
             '1' when (qJCintF = "011" and irout(7 downto 4) = "0100" and ZeroF = '1') else -- JPZ(Z=1)
             '1' when (qJCintF = "011" and irout(7 downto 4) = "0101" and CarryF= '1') else -- JPC(C=1)
             '0';      
        
loadlMB   <= '1' when (qJCintF = "110" and irout(7 downto 4) = "1000") else -- JP
             '1' when (qJCintF = "110" and irout(7 downto 4) = "0100" and ZeroF = '1') else -- JPZ(Z=1)
             '1' when (qJCintF = "110" and irout(7 downto 4) = "0101" and CarryF= '1') else -- JPC(C=1)
             '0';                                

loadIP    <= '1' when (qJCintF = "100" and irout(7 downto 4) = "1000") else -- JP
             '1' when (qJCintF = "100" and irout(7 downto 4) = "0100" and ZeroF = '1') else -- JPZ(Z=1)
             '1' when (qJCintF = "100" and irout(7 downto 4) = "0101" and CarryF= '1') else -- JPC(C=1)
             '0'; 
		   
loadhIX <= '1' when (qJCintC = "11" and irout(7 downto 0) = "11010000") else -- SERIXH
           '0';
           
loadlIX <= '1' when (qJCintC = "11" and irout(7 downto 0) = "11010001") else -- SETIXL
           '0';
 
loadRegA <= '1' when (qJCintC = "11" and irout(7 downto 0) = "11011000") else -- LDIA
            '1' when (qJCintC = "11" and irout(7 downto 0) = "11100000") else -- LDDA
            '1' when (qJCintD = '1'  and irout(7 downto 4) = "1000")     else -- ADDA SUBA ANDA ORA NOTA INCA DECA
            '0';

loadRegB <= '1' when (qJCintC = "11" and irout(7 downto 0) = "11011001") else -- LDIB
            '1' when (qJCintC = "11" and irout(7 downto 0) = "11100001") else -- LDDB
            '1' when (qJCintD = '1'  and irout(7 downto 4) = "1001")     else -- ADDB SUBB ANDB ORB NOTB INCB DECB
            '0';

loadID  <=  '1' when (qJCintF = "011" and irout(7 downto 3) = "11111") else -- STDI
	        '0';

incIP   <=  '1' when qJCintB = "10"  else
            '1' when (qJCintC = "11" and irout(7 downto 5) = "110") else -- SETIXH SETIXL LDIA LDIB
            '1' when qJCintF = "011" else
            '0';
   
inc2IP   <= '1' when (qJCintD = '1' and irout(7 downto 5) = "010" and (ZeroF = '0' or CarryF = '0')) else -- JPZ(Z=0) JPC(C=0)
            '0';

selMuxDIn<= '1' when qJCintC = "01" and irout(7 downto 3) = "11011" else -- LDIA LDIB
            '1' when qJCintC = "01" and irout(7 downto 3) = "11100" else -- LDDA LDDB
            '1' when qJCintC = "11" and irout(7 downto 3) = "11011" else -- LDIA LDIB
            '1' when qJCintC = "11" and irout(7 downto 3) = "11100" else -- LDDA LDDB
            '1' when (qJCintF = "001" and irout(7 downto 3) = "11111") else -- STDI
            '1' when (qJCintF = "011" and irout(7 downto 3) = "11111") else -- STDI
            '0' ;

selMuxDOut <= "01" when (qJCintE = "01" and irout(7 downto 2) = "111101") else -- STDB
              "01" when (qJCintE = "11" and irout(7 downto 2) = "111101") else -- STDB
              "01" when (qJCintE = "10" and irout(7 downto 2) = "111101") else -- STDB
              "10" when (qJCintF = "111" and irout(7 downto 3) = "11111") else -- STDI
              "10" when (qJCintF = "110" and irout(7 downto 3) = "11111") else -- STDI
              "10" when (qJCintF = "100" and irout(7 downto 3) = "11111") else -- STDI
              "00" ;

end logic;