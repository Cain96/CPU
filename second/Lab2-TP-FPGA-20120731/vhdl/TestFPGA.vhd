--------------------------------
--  Testbench for All Circuit
--
--  RAM ‚Í 8000-8004‚Ü‚ÅŽg‚¦‚é
--
--  2011/11/11 Yoshiaki TANIGUCHI
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity TestFPGA is
  port (
    LED        : out   std_logic_vector(7 downto 0);   -- LED
    SEG_A      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED A
    SEG_B      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED B
    SEG_C      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED C
    SEG_D      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED D
    SEG_E      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED E
    SEG_F      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED F
    SEG_G      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED G
    SEG_H      : out   std_logic_vector(7 downto 0)    -- 7 Segment LED H
  );
end TestFPGA;

architecture behavior of TestFPGA is
  
  component CPUCircuit
  port (
    clock      : in    std_logic;
    reset      : in    std_logic;
    DIP_A      : in    std_logic_vector(7 downto 0);   -- Dip Switch A
    DIP_B      : in    std_logic_vector(7 downto 0);   -- Dip Switch B
    KEY_A      : in    std_logic_vector(4 downto 0);   -- Key Switch A
    KEY_B      : in    std_logic_vector(4 downto 0);   -- Key Switch B
    KEY_C      : in    std_logic_vector(4 downto 0);   -- Key Switch C
    KEY_D      : in    std_logic_vector(4 downto 0);   -- Key Switch D
    HEX_A      : in    std_logic_vector(3 downto 0);   -- Hex Switch A
    HEX_B      : in    std_logic_vector(3 downto 0);   -- Hex Switch B
    MemData    : inout std_logic_vector (7 downto 0);  -- Memory (data)
    MemAddr    : out   std_logic_vector (15 downto 0); -- Memory (address)
    MemRead    : out   std_logic;                      -- Memory (read)
    MemWrite   : out   std_logic;                      -- Memory (write)
    MemCS      : out   std_logic;                      -- Memory (cs)
    ROMData    : in    std_logic_vector(7 downto 0);   -- ROM (data)
    ROMAddr    : out   std_logic_vector(15 downto 0);  -- ROM (address)
    ROMRead    : out   std_logic;                      -- ROM (read)
    ROMCS      : out   std_logic;                      -- ROM (cs)
    ROMReset   : out   std_logic;                      -- ROM (reset)
    LED        : out   std_logic_vector(7 downto 0);   -- LED
    SEG_A      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED A
    SEG_B      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED B
    SEG_C      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED C
    SEG_D      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED D
    SEG_E      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED E
    SEG_F      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED F
    SEG_G      : out   std_logic_vector(7 downto 0);   -- 7 Segment LED G
    SEG_H      : out   std_logic_vector(7 downto 0)    -- 7 Segment LED H
  );
  end component;

  component ROM
  port (
    address   : in  std_logic_vector(15 downto 0);
    read      : in  std_logic;
    cs        : in  std_logic;
    reset     : in  std_logic;
    data      : out std_logic_vector(7 downto 0)
  );
  end component;

  component RAM
  port (
    address   : in    std_logic_vector(15 downto 0);
    read      : in    std_logic;
    write     : in    std_logic;
    cs        : in    std_logic;
    data      : inout std_logic_vector(7 downto 0)
  );
  end component;

  -- constant
  constant clk_cycle : time := 10 ns;   -- frequency 100 MHz

  -- signal
  signal clock    : std_logic;
  signal reset    : std_logic;
  signal dip_a    : std_logic_vector(7 downto 0);
  signal dip_b    : std_logic_vector(7 downto 0);
  signal key_a    : std_logic_vector(4 downto 0);
  signal key_b    : std_logic_vector(4 downto 0);
  signal key_c    : std_logic_vector(4 downto 0);
  signal key_d    : std_logic_vector(4 downto 0);
  signal hex_a    : std_logic_vector(3 downto 0);
  signal hex_b    : std_logic_vector(3 downto 0);
  signal memdata  : std_logic_vector(7 downto 0);
  signal memaddr  : std_logic_vector(15 downto 0);
  signal memread  : std_logic;
  signal memwrite : std_logic;
  signal memcs    : std_logic;
  signal romdata  : std_logic_vector(7 downto 0);
  signal romaddr  : std_logic_vector(15 downto 0);
  signal romread  : std_logic;
  signal romcs    : std_logic;
  signal romreset : std_logic;

begin

  FPGA_CPUCircuit : CPUCircuit
  port map (
    clock    => clock,
    reset    => reset,
    DIP_A    => dip_a,
    DIP_B    => dip_b,
    KEY_A    => key_a,
    KEY_B    => key_b,
    KEY_C    => key_c,
    KEY_D    => key_d,
    HEX_A    => hex_a,
    HEX_B    => hex_b,
    MemData  => memdata,
    MemAddr  => memaddr,
    MemRead  => memread,
    MemWrite => memwrite,
    MemCS    => memcs,
    RomData  => romdata,
    RomAddr  => romaddr,
    RomRead  => romread,
    RomCS    => romcs,
    RomReset => romreset,
    LED      => LED,
    SEG_A    => SEG_A,
    SEG_B    => SEG_B,
    SEG_C    => SEG_C,
    SEG_D    => SEG_D,
    SEG_E    => SEG_E,
    SEG_F    => SEG_F,
    SEG_G    => SEG_G,
    SEG_H    => SEG_H
  );

  FPGAROM : ROM
  port map (
    address => romaddr,
    read    => romread,
    cs      => romcs,
    reset   => romreset,
    data    => romdata
  );

  FPGARAM : RAM
  port map (
    address => memaddr,
    read    => memread,
    write   => memwrite,
    cs      => memcs,
    data    => memdata
  );

  -- clock and reset

  process
  begin
    clock <= '1';
    wait for clk_cycle/2;
    clock <= '0';
    wait for clk_cycle/2;
  end process;

  -- reset <= '1',
  --          '0' after clk_cycle * 2;

  process 
  begin
    reset <= '0';
    dip_a <= x"00"; dip_b <= x"00"; 
    hex_a <= "0000"; hex_b <= "0000";
    key_a <= "11111"; key_b <= "01111"; key_c <= "11111"; key_d <= "11111"; 

    wait for clk_cycle * 2;
    reset <= '1';

    -- scenario begin

    wait for clk_cycle * 100;
    -- dip_a <= x"AB"; 
    key_d <= "11101"; -- KEY_D2 is pushed

    wait for clk_cycle * 100;
    key_d <= "11111";

    wait for clk_cycle * 100;
    key_d <= "11011"; -- KEY_D3 is pushed

    wait for clk_cycle * 100;
    key_d <= "11111";

    wait for clk_cycle * 100; -- KEY_D0 is pushed
    key_d <= "11110";

    wait for clk_cycle * 100;
    key_d <= "11111";

    wait for clk_cycle * 100;
    key_d <= "10111"; -- KEY_D4 is pushed

    wait for clk_cycle * 100;
    key_d <= "11111";

    -- scenario end

  end process;

end behavior;

--------------------------------
-- Simple RAM
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity RAM is
  port (
    address   : in    std_logic_vector(15 downto 0);
    read      : in    std_logic;
    write     : in    std_logic;
    cs        : in    std_logic;
    data      : inout std_logic_vector(7 downto 0)
  );
end RAM;

architecture rtl of RAM is

signal  RAM0 : std_logic_vector(7 downto 0);
signal  RAM1 : std_logic_vector(7 downto 0);
signal  RAM2 : std_logic_vector(7 downto 0);
signal  RAM3 : std_logic_vector(7 downto 0);
signal  RAM4 : std_logic_vector(7 downto 0);

begin
    data <= RAM0 when (address = x"8000" and cs ='0' and read = '0') else
            RAM1 when (address = x"8001" and cs ='0' and read = '0') else
            RAM2 when (address = x"8002" and cs ='0' and read = '0') else
            RAM3 when (address = x"8003" and cs ='0' and read = '0') else
            RAM4 when (address = x"8004" and cs ='0' and read = '0') else
            "ZZZZZZZZ";

    RAM0 <= data when (address = x"8000" and cs ='0' and write = '0');
    RAM1 <= data when (address = x"8001" and cs ='0' and write = '0');
    RAM2 <= data when (address = x"8002" and cs ='0' and write = '0');
    RAM3 <= data when (address = x"8003" and cs ='0' and write = '0');
    RAM4 <= data when (address = x"8004" and cs ='0' and write = '0');

end rtl;

