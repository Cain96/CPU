--------------------------------
--  Testbench for CometPCircuit
--
--  2012/1/26 Yoshiaki TANIGUCHI
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity TestFPGA is
  port (
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
  
  component CometPCircuit
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
--    MemData    : inout std_logic_vector (7 downto 0);  -- Memory (data)
--    MemAddr    : out   std_logic_vector (15 downto 0); -- Memory (address)
--    MemRead    : out   std_logic;                      -- Memory (read)
--    MemWrite   : out   std_logic;                      -- Memory (write)
--    MemCS      : out   std_logic;                      -- Memory (cs)
    ROMData    : in    std_logic_vector(31 downto 0);  -- ROM (data)
    ROMAddr    : out   std_logic_vector(15 downto 0);  -- ROM (address)
    ROMReset   : out   std_logic;                      -- ROM (reset)
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

  component CometPROM
  port (
--    clock     : in  std_logic;
    reset     : in  std_logic;
    address   : in  std_logic_vector(15 downto 0);
    data      : out std_logic_vector(31 downto 0)
  );
  end component;

--  component CometPRAM
--  port (
--    reset     : in    std_logic;
--    address   : in    std_logic_vector(15 downto 0);
--    read      : in    std_logic;
--    write     : in    std_logic;
--    cs        : in    std_logic;
--    data      : inout std_logic_vector(7 downto 0)
--  );
--  end component;

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
--  signal memdata  : std_logic_vector(7 downto 0);
--  signal memaddr  : std_logic_vector(15 downto 0);
--  signal memread  : std_logic;
--  signal memwrite : std_logic;
--  signal memcs    : std_logic;
  signal romdata  : std_logic_vector(31 downto 0);
  signal romaddr  : std_logic_vector(15 downto 0);
  signal romreset : std_logic;

begin

  FPGA_CPUCircuit : CometPCircuit
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
--    MemData  => memdata,
--    MemAddr  => memaddr,
--    MemRead  => memread,
--    MemWrite => memwrite,
--    MemCS    => memcs,
    RomData  => romdata,
    RomAddr  => romaddr,
    RomReset => romreset,
    SEG_A    => SEG_A,
    SEG_B    => SEG_B,
    SEG_C    => SEG_C,
    SEG_D    => SEG_D,
    SEG_E    => SEG_E,
    SEG_F    => SEG_F,
    SEG_G    => SEG_G,
    SEG_H    => SEG_H
  );

  FPGAROM : CometPROM
  port map (
--    clock   => clock,
    reset   => romreset,
    address => romaddr,
    data    => romdata
  );

--  FPGARAM : CometPRAM
--  port map (
--    reset   => reset,
--    address => memaddr,
--    read    => memread,
--    write   => memwrite,
--    cs      => memcs,
--    data    => memdata
--  );

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
    dip_a <= x"12"; dip_b <= x"34"; 
    hex_a <= "0000"; hex_b <= "0000";
    key_a <= "11111"; key_b <= "11111"; key_c <= "11111"; key_d <= "11111"; 

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

entity CometPRAMTest is
  port (
    reset     : in    std_logic;
    address   : in    std_logic_vector(16 downto 0);
    read      : in    std_logic;
    write     : in    std_logic;
    cs        : in    std_logic;
    data      : inout std_logic_vector(7 downto 0)
  );
end CometPRAMTest;

architecture rtl of CometPRAMTest is

signal  RAM0H : std_logic_vector(7 downto 0);
signal  RAM0L : std_logic_vector(7 downto 0);
signal  RAM1H : std_logic_vector(7 downto 0);
signal  RAM1L : std_logic_vector(7 downto 0);
signal  RAM2H : std_logic_vector(7 downto 0);
signal  RAM2L : std_logic_vector(7 downto 0);
signal  RAM3H : std_logic_vector(7 downto 0);
signal  RAM3L : std_logic_vector(7 downto 0);
signal  RAM4H : std_logic_vector(7 downto 0);
signal  RAM4L : std_logic_vector(7 downto 0);
signal  RAM5H : std_logic_vector(7 downto 0);
signal  RAM5L : std_logic_vector(7 downto 0);

begin

  process(reset) begin
    if(reset = '1') then
      -- default value
      RAM0H <= x"11";
      RAM0L <= x"22";
      RAM1H <= x"33";
      RAM1L <= x"44";
      RAM2H <= x"55";
      RAM2L <= x"66";
      RAM3H <= x"77";
      RAM3L <= x"88";
      RAM4H <= x"99";
      RAM4L <= x"AA";
      RAM5H <= x"BB";
      RAM5L <= x"CC";
    end if;
  end process;

    data <= RAM0H when (address = "00000000000000000" and cs ='0' and read = '0') else
            RAM0L when (address = "10000000000000000" and cs ='0' and read = '0') else
            RAM1H when (address = "00000000000000001" and cs ='0' and read = '0') else
            RAM1L when (address = "10000000000000001" and cs ='0' and read = '0') else
            RAM2H when (address = "00000000000000010" and cs ='0' and read = '0') else
            RAM2L when (address = "10000000000000010" and cs ='0' and read = '0') else
            RAM3H when (address = "00000000000000011" and cs ='0' and read = '0') else
            RAM3L when (address = "10000000000000011" and cs ='0' and read = '0') else
            RAM4H when (address = "00000000000000100" and cs ='0' and read = '0') else
            RAM4L when (address = "10000000000000100" and cs ='0' and read = '0') else
            RAM5H when (address = "00000000000000101" and cs ='0' and read = '0') else
            RAM5L when (address = "10000000000000101" and cs ='0' and read = '0') else
            "ZZZZZZZZ";

    RAM0H <= data when (address = "00000000000000000" and cs ='0' and write = '0');
    RAM0L <= data when (address = "10000000000000000" and cs ='0' and write = '0');
    RAM1H <= data when (address = "00000000000000001" and cs ='0' and write = '0');
    RAM1L <= data when (address = "10000000000000001" and cs ='0' and write = '0');
    RAM2H <= data when (address = "00000000000000010" and cs ='0' and write = '0');
    RAM2L <= data when (address = "10000000000000010" and cs ='0' and write = '0');
    RAM3H <= data when (address = "00000000000000011" and cs ='0' and write = '0');
    RAM3L <= data when (address = "10000000000000011" and cs ='0' and write = '0');
    RAM4H <= data when (address = "00000000000000100" and cs ='0' and write = '0');
    RAM4L <= data when (address = "10000000000000100" and cs ='0' and write = '0');
    RAM5H <= data when (address = "00000000000000101" and cs ='0' and write = '0');
    RAM5L <= data when (address = "10000000000000101" and cs ='0' and write = '0');

end rtl;

