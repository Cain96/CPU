-------------------------------------------
-- Testbench for Control of C-Processor  --
--                                       --
--                   (c) Yosuke Kakiuchi --
--                            2010/10/01 --
-------------------------------------------
-- [Caution!!]
-- * Replace the following signal names with your signal names 
-- 1) loadRegC - "load" + the name of register which you added
-- 2) selMuxDOut - "sel" + the name of MUX4x08 which you added
-- 3) CarryF, loadFC - the output and the load signal of the carry flag which you added

library IEEE;
use IEEE.std_logic_1164.all;

entity TestControl is
end TestControl;

architecture behavior of TestControl is
    signal selMuxDIn : std_logic;

    signal loadhMB   : std_logic;
    signal loadlMB   : std_logic;
    signal loadhIX   : std_logic;
    signal loadlIX   : std_logic;

    signal loadIR    : std_logic;
    signal IRout     : std_logic_vector (7 downto 0);

    signal loadIP    : std_logic;
    signal incIP     : std_logic;
    signal inc2IP    : std_logic;
    signal clearIP   : std_logic;

    signal selMuxAddr: std_logic;
    signal ZeroF     : std_logic;
    signal CarryF    : std_logic;

    signal loadRegC  : std_logic;
    signal loadRegB  : std_logic;
    signal loadRegA  : std_logic;

    signal modeALU   : std_logic_vector (3 downto 0);
    signal loadFZ    : std_logic;
    signal loadFC    : std_logic;

    signal read      : std_logic;
    signal write     : std_logic;

    signal selMuxDOut: std_logic_vector (1 downto 0);
	
    signal clock     : std_logic;
    signal reset     : std_logic;


component Controler is
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

    loadRegC  : out std_logic;
    loadRegB  : out std_logic;
    loadRegA  : out std_logic;

    modeALU   : out std_logic_vector (3 downto 0);
    loadFZ    : out std_logic;
    loadFC    : out std_logic;

    read      : out std_logic;
    write     : out std_logic;

    selMuxDOut: out std_logic_vector (1 downto 0);
	
    clock     : in  std_logic;
    reset     : in  std_logic
  );
end component;

	constant clk_cycle : time := 10 ns;   -- frequency 100 MHz
	
begin

	control: Controler
    port map(
    selMuxDIn => selMuxDIn,

    loadhMB   => loadhMB,
    loadlMB   => loadlMB,
    loadhIX   => loadhIX,
    loadlIX   => loadlIX,

    loadIR    => loadIR,
    IRout     => IRout,

    loadIP    => loadIP,
    incIP     => incIP,
    inc2IP    => inc2IP,
    clearIP   => clearIP,

    selMuxAddr=> selMuxAddr,
    ZeroF     => ZeroF,
    CarryF    => CarryF,

    loadRegC  => loadRegC,
    loadRegB  => loadRegB,
    loadRegA  => loadRegA,

    modeALU   => modeALU,
    loadFZ    => loadFZ,
    loadFC    => loadFC,

    read      => read,
    write     => write,

    selMuxDOut=> selMuxDOut,
	
    clock     => clock,
    reset     => reset
  );

  
process begin
  clock <= '1';
  wait for clk_cycle/2;
  clock <= '0';
  wait for clk_cycle/2;
end process;
  

process begin
  reset <= '1';
  IRout <= X"00";
  ZeroF <= '0';   CarryF <= '0';
wait for clk_cycle*2;  -- Reset
  reset <= '0';
wait for clk_cycle*2;  -- Fetch
  IRout <= X"e1";      
  ZeroF <= '0';   CarryF <= '0';
wait for clk_cycle*2;  -- LDIB
wait for clk_cycle*3;  -- Fetch
  IRout <= X"92";      
  ZeroF <= '0';   CarryF <= '0';
wait for clk_cycle*1;  -- ANDB
wait for clk_cycle*3;  -- Fetch
  IRout <= X"f0";      
  ZeroF <= '0';   CarryF <= '0';
wait for clk_cycle*3;  -- STDA
wait for clk_cycle*3;  -- Fetch
  IRout <= X"f4";      
  ZeroF <= '0';   CarryF <= '0';
wait for clk_cycle*3;  -- STDB
wait for clk_cycle*3;  -- Fetch
  IRout <= X"f8";      
  ZeroF <= '0';   CarryF <= '0';
wait for clk_cycle*5;  -- STDI
wait for clk_cycle*3;  -- Fetch
  IRout <= X"40";      
  ZeroF <= '0';   CarryF <= '1';
wait for clk_cycle*5;  -- JPC (C=1)
wait for clk_cycle*3;  -- Fetch
  reset <= '1';
wait for clk_cycle*100;  
end process;

end behavior;
