--------------------------------
--  Interface between FPGA and CPU
--
--  2011/11/11 Yoshiaki TANIGUCHI
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity CPUCircuit is
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
end CPUCircuit;

architecture logic of CPUCircuit is

  component TinyProcessor
    port (
    clock     : in  std_logic;
    reset     : in  std_logic;
    DataIn    : in  std_logic_vector (7 downto 0);
    DataOut   : out std_logic_vector (7 downto 0);
    Address   : out std_logic_vector (15 downto 0);
    read      : out std_logic;
    write     : out std_logic;
    dbgIRout  : out std_logic_vector (7 downto 0);
    dbgZeroF  : out std_logic;
    dbgCarryF : out std_logic;
    dbgAout   : out std_logic_vector (7 downto 0);
    dbgBout   : out std_logic_vector (7 downto 0)
    );
  end component;

  component ccmux4x08
    port (
    sel : in  std_logic_vector(1 downto 0);
    a   : in  std_logic_vector(7 downto 0);
    b   : in  std_logic_vector(7 downto 0);
    c   : in  std_logic_vector(7 downto 0);
    d   : in  std_logic_vector(7 downto 0);
    q   : out std_logic_vector(7 downto 0)
    );
  end component;

  component ccmux4x16 
    port (
    sel : in  std_logic_vector(1 downto 0);
    a   : in  std_logic_vector(15 downto 0);
    b   : in  std_logic_vector(15 downto 0);
    c   : in  std_logic_vector(15 downto 0);
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0)
    );
  end component;

  component PSWEnc8
  port (
    clock  : in std_logic;
    reset  : in std_logic;
    swin   : in std_logic_vector(7 downto 0);
    swout  : out std_logic_vector(7 downto 0)
  );
  end component;

  component NRevA
  port (
    dip_in   : in  std_logic_vector(7 downto 0);
    dip_out  : out std_logic_vector(7 downto 0)
  );
  end component;

  component NRevB
  port (
    dip_in   : in  std_logic_vector(7 downto 0);
    dip_out  : out std_logic_vector(7 downto 0)
  );
  end component;

  component DecSeg is
  port (
    data  : in  std_logic_vector(3 downto 0);
    seg   : out std_logic_vector(7 downto 0)
  );
  end component;

  component InCtrl is
  port (
    address : in  std_logic_vector(15 downto 0);
    sel     : out std_logic_vector(1 downto 0)
  );
  end component;

  component LBuf is
  port (
    address : in  std_logic_vector(15 downto 0);
    data    : in  std_logic_vector(7 downto 0);
    write   : in  std_logic;
    ledout  : out std_logic_vector(15 downto 0)
  );
  end component;

  component MCtrl is
  port (
    address  : in    std_logic_vector(15 downto 0);
    dataout  : in    std_logic_vector(7 downto 0);
    datain   : out   std_logic_vector(7 downto 0);
    read     : in    std_logic;
    write    : in    std_logic;
    RAMAddr  : out   std_logic_vector(15 downto 0);
    RAMData  : inout std_logic_vector(7 downto 0);
    RAMRead  : out   std_logic;
    RAMWrite : out   std_logic;
    RAMCS    : out   std_logic;
    ROMAddr  : out   std_logic_vector(15 downto 0);
    ROMData  : in    std_logic_vector(7 downto 0);
    ROMRead  : out   std_logic;
    ROMCS    : out   std_logic
  );
  end component;

signal    DataIn       : std_logic_vector(7 downto 0);
signal    DataOut      : std_logic_vector(7 downto 0);
signal    Address      : std_logic_vector(15 downto 0);
signal    read         : std_logic;
signal    write        : std_logic;
signal    cpu_reset    : std_logic;
signal    dbgIRout     : std_logic_vector(7 downto 0);
signal    dbgAout      : std_logic_vector(7 downto 0);
signal    dbgBout      : std_logic_vector(7 downto 0);
signal    qInputCtrl   : std_logic_vector(1 downto 0);
signal    qSelOutput   : std_logic_vector(15 downto 0);
signal    qLEDBuf      : std_logic_vector(15 downto 0);
signal    MemCtrlDIn   : std_logic_vector(7 downto 0);
signal    qKeyEnc8     : std_logic_vector(7 downto 0);
signal    dip_a_in     : std_logic_vector(7 downto 0);
signal    dip_b_in     : std_logic_vector(7 downto 0);
signal    zero16       : std_logic_vector(15 downto 0);
signal    zero         : std_logic;

begin    -- logic

zero <= '0';
zero16 <= x"0000";

Processor : TinyProcessor
  port map(
    clock     => clock,
    reset     => cpu_reset,
    DataIn    => DataIn,
    DataOut   => DataOut,
    Address   => Address,
    read      => read,
    write     => write,
    dbgIRout  => dbgIRout,
    dbgZeroF  => LED(0),
    dbgCarryF => LED(1),
    dbgAout   => dbgAout,
    dbgBout   => dbgBout
  );

SelInput : ccmux4x08
  port map (
    sel => qInputCtrl,
    a   => MemCtrlDIn,
    b   => qKeyEnc8,
    c   => dip_a_in,
    d   => dip_b_in,
    q   => DataIn
  );

SelOutput : ccmux4x16
  port map (
    sel            => HEX_A(1 downto 0),
    a              => Address,
    b(7 downto 0)  => DataOut,
    b(15 downto 8) => dbgIRout,
    c(7 downto 0)  => dbgBout,
    c(15 downto 8) => dbgAout,
    d              => zero16,   -- not used
    q              => qSelOutput
  );

KeyEnc8 : PSWEnc8
  port map (
    clock            => clock,
    reset            => reset,
    swin(7 downto 4) => KEY_C(3 downto 0),
    swin(3 downto 0) => KEY_D(3 downto 0),
    swout            => qKeyEnc8
  );

NotRevA : NRevA
  port map (
    dip_in  => DIP_A(7 downto 0),
    dip_out => dip_a_in
  );

NotRevB : NRevB 
  port map (
    dip_in  => DIP_B(7 downto 0),
    dip_out => dip_b_in
  );

DecSegA : DecSeg
  port map (
   data => qLEDBuf(15 downto 12), 
    seg  => SEG_A
  );

DecSegB : DecSeg
  port map (
    data => qLEDBuf(11 downto 8),
    seg  => SEG_B
  );

DecSegC : DecSeg
  port map (
    data => qLEDBuf(7 downto 4),
    seg  => SEG_C
  );

DecSegD : DecSeg
  port map (
    data => qLEDBuf(3 downto 0),
    seg  => SEG_D
  );

DecSegE : DecSeg
  port map (
    data => qSelOutput(15 downto 12),
    seg  => SEG_E
  );

DecSegF : DecSeg
  port map (
    data => qSelOutput(11 downto 8),
    seg  => SEG_F
  );

DecSegG : DecSeg
  port map (
    data => qSelOutput(7 downto 4),
    seg  => SEG_G
  );

DecSegH : DecSeg
  port map (
    data => qSelOutput(3 downto 0),
    seg  => SEG_H
  );

InputCtrl : InCtrl
  port map (
    address => Address,
    sel     => qInputCtrl
  );

LEDBuf : LBuf
  port map (
    address => Address,
    data    => DataOut,
    write   => write,
    ledout  => qLEDBuf
  );

MemCtrl : MCtrl
  port map (
    address  => Address,
    dataout  => DataOut,
    datain   => MemCtrlDIn,
    read     => read,
    write    => write,
    RAMAddr  => MemAddr,
    RAMData  => MemData,
    RAMRead  => MemRead,
    RAMWrite => MemWrite,
    RAMCS    => MemCS,
    ROMAddr  => ROMAddr,
    ROMData  => ROMData,
    ROMRead  => ROMRead,
    ROMCS    => ROMCS
  );

LED(2) <= zero; -- not used
LED(3) <= zero; -- not used
LED(4) <= zero; -- not used
LED(5) <= zero; -- not used
LED(6) <= zero; -- not used
LED(7) <= zero; -- not used


cpu_reset <= not reset;
ROMReset <= not reset;

end logic;


--------------------------------
-- 8bit Multiplexer in 4
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity ccmux4x08 is
  port (
    sel : in  std_logic_vector(1 downto 0);
    a   : in  std_logic_vector(7 downto 0);
    b   : in  std_logic_vector(7 downto 0);
    c   : in  std_logic_vector(7 downto 0);
    d   : in  std_logic_vector(7 downto 0);
    q   : out std_logic_vector(7 downto 0)
  );
end ccmux4x08;

architecture logic of ccmux4x08 is
begin
  q <= a when sel = "00" else
       b when sel = "01" else
       c when sel = "10" else
       d;
end logic;

--------------------------------
-- 16bit Multiplexer in 4
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity ccmux4x16 is
  port (
    sel : in  std_logic_vector(1 downto 0);
    a   : in  std_logic_vector(15 downto 0);
    b   : in  std_logic_vector(15 downto 0);
    c   : in  std_logic_vector(15 downto 0);
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0)
  );
end ccmux4x16;

architecture logic of ccmux4x16 is
begin
  q <= a when sel = "00" else
       b when sel = "01" else
       c when sel = "10" else
       d;
end logic;

--------------------------------
-- 8 bit PSW Encorder (for chattering)
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity PSWEnc8 is
  port (
    clock  : in std_logic;
    reset  : in std_logic;
    swin   : in std_logic_vector(7 downto 0);
    swout  : out std_logic_vector(7 downto 0)
  );
end PSWEnc8;
 
architecture rtl of PSWEnc8 is

signal clock_count  : std_logic_vector(3 downto 0);
signal swin_buf     : std_logic_vector(7 downto 0);
signal swout_buf    : std_logic_vector(7 downto 0);

begin
  process (clock, reset)
  begin
    if (reset = '0') then
      clock_count <= "0000";
      swin_buf <= "00000000";
      swout_buf <= "00000000";

    elsif (clock'event and clock = '1') then 

      if (clock_count = "1111") then
        swout_buf <= swin_buf;
        swin_buf <= swin;
      elsif (swin_buf = swin) then
        swout_buf <= swout_buf; 
        swin_buf <= swin;
        clock_count <= clock_count + 1;
      else
        swout_buf <= swout_buf; 
        swin_buf <= swin;
        clock_count <= "0000";
      end if;
    end if;
  end process;

  swout <= not swout_buf;  -- convert to positive logic

end rtl;

--------------------------------
-- NotRev
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity NRevA is
  port (
    dip_in    : in  std_logic_vector(7 downto 0);
    dip_out   : out std_logic_vector(7 downto 0)
  );
end NRevA;

architecture logic of NRevA is
begin
  dip_out(0) <= not dip_in(7);
  dip_out(1) <= not dip_in(6);
  dip_out(2) <= not dip_in(5);
  dip_out(3) <= not dip_in(4);
  dip_out(4) <= not dip_in(3);
  dip_out(5) <= not dip_in(2);
  dip_out(6) <= not dip_in(1);
  dip_out(7) <= not dip_in(0);
end logic;

library IEEE;
use IEEE.std_logic_1164.all;

entity NRevB is
  port (
    dip_in    : in  std_logic_vector(7 downto 0);
    dip_out   : out std_logic_vector(7 downto 0)
  );
end NRevB;

architecture logic of NRevB is
begin
  dip_out <= not dip_in;
end logic;

--------------------------------
-- 16bit 7Seg Decoder
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity DecSeg is
  port (
    data  : in  std_logic_vector(3 downto 0);
    seg   : out std_logic_vector(7 downto 0)
  );
end DecSeg;
 
architecture rtl of DecSeg is
 
begin
  process(data)
  begin 
    case data is
      when "0000" =>seg<= "11111100"  ;--0
      when "0001" =>seg<= "01100000"  ;--1
      when "0010" =>seg<= "11011010"  ;--2
      when "0011" =>seg<= "11110010"  ;--3
      when "0100" =>seg<= "01100110"  ;--4
      when "0101" =>seg<= "10110110"  ;--5
      when "0110" =>seg<= "10111110"  ;--6
      when "0111" =>seg<= "11100000"  ;--7
      when "1000" =>seg<= "11111110"  ;--8
      when "1001" =>seg<= "11110110"  ;--9
      when "1010" =>seg<= "11101110"  ;--A
      when "1011" =>seg<= "00111110"  ;--b
      when "1100" =>seg<= "00011010"  ;--c
      when "1101" =>seg<= "01111010"  ;--d
      when "1110" =>seg<= "10011110"  ;--e
      when "1111" =>seg<= "10001110"  ;--f
      when others =>seg<= "00000000"  ;--off
    end case;
  end process;
end rtl;

--------------------------------
-- Inuput Control
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity InCtrl is
  port (
    address : in  std_logic_vector(15 downto 0);
    sel     : out std_logic_vector(1 downto 0)
  );
end InCtrl;

architecture logic of InCtrl is
begin
  sel <= "01" when address = "1111111111111011" else -- Key Switch
         "10" when address = "1111111111111100" else -- DIP Switch A
         "11" when address = "1111111111111101" else -- DIP Switch B
         "00";
end logic;

--------------------------------
-- LED Buffer
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity LBuf is
  port (
    address : in  std_logic_vector(15 downto 0);
    data    : in  std_logic_vector(7 downto 0);
    write   : in  std_logic;
    ledout  : out std_logic_vector(15 downto 0)
  );
end LBuf;

architecture rtl of LBuf is
begin
  process (address, data, write)
  begin
    if (write = '0' and address = "1111111111111110") then
      ledout(15 downto 8) <= data;
    elsif (write = '0' and address = "1111111111111111") then
      ledout(7 downto 0) <= data;
    end if;
  end process;
end rtl;

--------------------------------
-- Memory Control
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity MCtrl is
  port (
    address  : in    std_logic_vector(15 downto 0);
    dataout  : in    std_logic_vector(7 downto 0);
    datain   : out   std_logic_vector(7 downto 0);
    read     : in    std_logic;
    write    : in    std_logic;
    RAMAddr  : out   std_logic_vector(15 downto 0);
    RAMData  : inout std_logic_vector(7 downto 0);
    RAMRead  : out   std_logic;
    RAMWrite : out   std_logic;
    RAMCS    : out   std_logic;
    ROMAddr  : out   std_logic_vector(15 downto 0);
    ROMData  : in    std_logic_vector(7 downto 0);
    ROMRead  : out   std_logic;
    ROMCS    : out   std_logic
  );
end MCtrl;

architecture rtl of MCtrl is
begin
  ROMAddr <= address;
  ROMRead <= read;
  ROMCS <= '0' when address(15) = '0' else 
           '1';
  RAMAddr <= address;
  RAMRead <= read;
  RAMWrite <= write;
  RAMCS <= '0' when address(15 downto 14) = "10" else
           '1';

  RAMData <= dataout when (address(15 downto 14) = "10" and write = '0') else "ZZZZZZZZ";

  datain <= ROMData when address(15) = '0' else 
            RAMData when (address(15 downto 14) = "10" and read = '0') else
            "ZZZZZZZZ";
end rtl;
