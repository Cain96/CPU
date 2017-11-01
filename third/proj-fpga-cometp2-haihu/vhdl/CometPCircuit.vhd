--------------------------------
--  Interface between FPGA and CometP
--
--  2012/1/24 Yoshiaki TANIGUCHI
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity CometPCircuit is
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
    HEX_B      : in    std_logic_vector(3 downto 0);   -- Hex Switch B // NOT USED
--    MemData    : inout std_logic_vector (7 downto 0);  -- RAM (data)
--    MemAddr    : out   std_logic_vector (15 downto 0); -- RAM (address)
--    MemRead    : out   std_logic;                      -- RAM (read)
--    MemWrite   : out   std_logic;                      -- RAM (write)
--    MemCS      : out   std_logic;                      -- RAM (cs)
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
end CometPCircuit;

architecture logic of CometPCircuit is

  component CometPipeline
  port (
    CLK               : in std_logic;
    Reset             : in std_logic;
    InstMemAddressBus : out std_logic_vector(15 downto 0);
    InstMemDataBus    : in std_logic_vector(31 downto 0);
    DataMemAddressBus : out std_logic_vector(15 downto 0);
    DataMemDataBusIn  : in std_logic_vector(15 downto 0);
    DataMemDataBusOut : out std_logic_vector(15 downto 0);
    DataMemReq        : out std_logic;
    DataMemAck        : in std_logic;
    DataWireMode      : out std_logic
--    DataExtMode       : out std_logic;
--    DataWriteMode     : out std_logic
    );
  end component;

  component CometPMux4x16 
  port (
    sel : in  std_logic_vector(1 downto 0);
    a   : in  std_logic_vector(15 downto 0);
    b   : in  std_logic_vector(15 downto 0);
    c   : in  std_logic_vector(15 downto 0);
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0)
    );
  end component;

  component PSWEnc16
  port (
    clock  : in std_logic;
    reset  : in std_logic;
    swin   : in std_logic_vector(15 downto 0);
    swout  : out std_logic_vector(15 downto 0)
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

  component CometPInCtrl is
  port (
    address : in  std_logic_vector(15 downto 0);
    sel     : out std_logic_vector(1 downto 0)
  );
  end component;

  component CometPLBuf is
  port (
    address : in  std_logic_vector(15 downto 0);
    data    : in  std_logic_vector(15 downto 0);
    cs      : in  std_logic;
    write   : in  std_logic;
    ledout  : out std_logic_vector(15 downto 0)
  );
  end component;

--  component CometPMCtrl is
--  port (
--    address   : in    std_logic_vector(15 downto 0);
--    dataout   : in    std_logic_vector(15 downto 0);
--    datain    : out   std_logic_vector(15 downto 0);
--    cs        : in    std_logic;
--    mode      : in    std_logic;
--    extmode   : in    std_logic;
--    writemode : in    std_logic;
--    RAMDataIn : in    std_logic_vector(15 downto 0);
--    RAMDataOut: out   std_logic_vector(15 downto 0)
--  );
--  end component;

  component CometPRAM is
  port(
    clock     : in    std_logic;
    address   : in    std_logic_vector(15 downto 0);
    read      : in    std_logic;
    write     : in    std_logic;
    cs        : in    std_logic;
    ack       : out   std_logic;
    datain    : in    std_logic_vector(15 downto 0);
    dataout   : out   std_logic_vector(15 downto 0)
  );
  end component;

signal    ROMAddress         : std_logic_vector(15 downto 0);
signal    DMEMDataIn         : std_logic_vector(15 downto 0);
signal    DMEMDataOut        : std_logic_vector(15 downto 0);
signal    DMEMAddress        : std_logic_vector(15 downto 0);
signal    DMEMReq            : std_logic;
signal    DMEMAck            : std_logic;
signal    DMEMRWMode         : std_logic;
--signal    DMEMExtMode        : std_logic;
--signal    DMEMWriteMode      : std_logic;
signal    MemDataIn          : std_logic_vector(15 downto 0);
signal    MemDataOut         : std_logic_vector(15 downto 0);
signal    MemWrite           : std_logic;
signal    MemCS              : std_logic;
signal    cpu_reset          : std_logic;
signal    dip_a_in           : std_logic_vector(7 downto 0);
signal    dip_b_in           : std_logic_vector(7 downto 0);
signal    qInputCtrl         : std_logic_vector(1 downto 0);
signal    qSelOutput         : std_logic_vector(15 downto 0);
signal    qLEDBuf            : std_logic_vector(15 downto 0);
signal    qKeyEnc16          : std_logic_vector(15 downto 0);
signal    MemCtrlDataIn      : std_logic_vector(15 downto 0);
signal    zero16             : std_logic_vector(15 downto 0);

begin    -- logic

zero16 <= x"0000";

Processor : CometPipeline
  port map(
    CLK               => clock,
    Reset             => cpu_reset,
    InstMemAddressBus => ROMAddress,
    InstMemDataBus    => ROMData,
    DataMemAddressBus => DMEMAddress,
    DataMemDataBusIn  => DMEMDataIn,
    DataMemDataBusOut => DMEMDataOut,
    DataMemReq        => DMEMReq,
    DataMemAck        => DMEMAck,
    DataWireMode      => DMEMRWMode
--    DataExtMode       => DMEMExtMode,
--    DataWriteMode     => DMEMWriteMode
  );

SelInput : CometPMux4x16
  port map (
    sel              => qInputCtrl,
    a                => MemCtrlDataIn,
    b                => qKeyEnc16,
    c(15 downto 8)   => dip_b_in,
    c(7 downto 0)    => dip_a_in,
    d                => zero16,
    q                => DMEMDataIn
  );

SelOutput : CometPMux4x16
  port map (
    sel            => HEX_A(1 downto 0),
    a              => ROMAddress,
    b              => ROMData(15 downto 0),
    c              => DMEMAddress,
    d              => DMEMDataOut,
    q              => qSelOutput
  );

KeyEnc16 : PSWEnc16
  port map (
    clock              => clock,
    reset              => reset,
    swin(15 downto 12) => KEY_A(3 downto 0),
    swin(11 downto 8)  => KEY_B(3 downto 0),
    swin(7 downto 4)   => KEY_C(3 downto 0),
    swin(3 downto 0)   => KEY_D(3 downto 0),
    swout              => qKeyEnc16
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

InputCtrl : CometPInCtrl
  port map (
    address => DMEMAddress,
    sel     => qInputCtrl
  );

LEDBuf : CometPLBuf
  port map (
    address => DMEMAddress,
    data    => DMEMDataOut,
    cs      => MemCS,
    write   => MemWrite,
    ledout  => qLEDBuf
  );

--MemCtrl : CometPMCtrl
--  port map (
--    address   => DMEMAddress,
--    dataout   => DMEMDataOut,
--    datain    => MemCtrlDataIn,
--    cs        => DMEMReq,
--    mode      => DMEMRWMode,
--    extmode   => DMEMExtMode,
--    writemode => DMEMWriteMode,
--    RAMDataIn  => MemDataIn,
--    RAMDataOut => MemDataOut
--  );

RAM : CometPRAM
  port map (
    clock   => clock,
    address => DMEMAddress,
    read    => DMEMRWMode,
    write   => MemWrite,
    cs      => MemCS,
    ack     => DMEMAck,
    datain  => DMEMDataOut,
    dataout => MemCtrlDataIn
  );

cpu_reset <= not reset;

-- DMEMRWMode=0 -> read,  DMEMRWMode=1 -> write
MemWrite <= not DMEMRWMode;
MemCS <= not DMEMReq;
ROMReset <= not reset;
ROMAddr <= ROMAddress;

end logic;

--------------------------------
-- 16bit Multiplexer in 4
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity CometPMux4x16 is
  port (
    sel : in  std_logic_vector(1 downto 0);
    a   : in  std_logic_vector(15 downto 0);
    b   : in  std_logic_vector(15 downto 0);
    c   : in  std_logic_vector(15 downto 0);
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0)
  );
end CometPMux4x16;

architecture logic of CometPMux4x16 is
begin
  q <= a when sel = "00" else
       b when sel = "01" else
       c when sel = "10" else
       d;
end logic;

--------------------------------
-- 16 bit PSW Encorder (for chattering)
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity PSWEnc16 is
  port (
    clock  : in std_logic;
    reset  : in std_logic;
    swin   : in std_logic_vector(15 downto 0);
    swout  : out std_logic_vector(15 downto 0)
  );
end PSWEnc16;

architecture rtl of PSWEnc16 is

signal clock_count  : std_logic_vector(3 downto 0);
signal swin_buf     : std_logic_vector(15 downto 0);
signal swout_buf    : std_logic_vector(15 downto 0);

begin
  process (clock, reset)
  begin
    if (reset = '0') then
      clock_count <= "0000";
      swin_buf <= x"0000";
      swout_buf <= x"0000";
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

entity CometPInCtrl is
  port (
    address : in  std_logic_vector(15 downto 0);
    sel     : out std_logic_vector(1 downto 0)
  );
end CometPInCtrl;

architecture logic of CometPInCtrl is
begin
  sel <= "01" when address = x"FFFC" else -- Key Switch A, B, C, D
         "10" when address = x"FFFD" else -- DIP Switch B, A
         "00";
end logic;

--------------------------------
-- LED Buffer
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity CometPLBuf is
  port (
    address : in  std_logic_vector(15 downto 0);
    data    : in  std_logic_vector(15 downto 0);
    cs      : in  std_logic;
    write   : in  std_logic;
    ledout  : out std_logic_vector(15 downto 0)
  );
end CometPLBuf;

architecture rtl of CometPLBuf is
begin
  process (address, cs, write)
  begin
    if (address = x"FFFF" and cs = '0' and write = '0') then
      ledout <= data;
    end if;
  end process;
end rtl;

--------------------------------
-- Memory Control
--------------------------------
--library IEEE;
--use IEEE.std_logic_1164.all;
--
--entity CometPMCtrl is
--  port (
--    address   : in    std_logic_vector(15 downto 0);
--    dataout   : in    std_logic_vector(15 downto 0);
--    datain    : out   std_logic_vector(15 downto 0);
--    cs        : in    std_logic;
--    mode      : in    std_logic;
--    extmode   : in    std_logic;
--    writemode : in    std_logic;
--    RAMDataIn : in    std_logic_vector(15 downto 0);
--    RAMDataOut: out   std_logic_vector(15 downto 0)
--  );
--end CometPMCtrl;
--
--architecture rtl of CometPMCtrl is
--begin
--
--  -- write (do not use addresses which is after 0xFFF0)
--  RAMDataOut <= dataout when (address(15 downto 4) /= x"FFF" and cs = '0' and mode = '1'); -- else "ZZZZZZZZZZZZZZZZ";
--
--  -- read (do not use addresses which is after 0xFFF0)
--  datain <= RAMDataIn when (address(15 downto 4) /= x"FFF" and cs = '0' and mode = '0'); -- else "ZZZZZZZZZZZZZZZZ";
--end rtl;


--------------------------------
-- RAM
--------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CometPRAM is
  port(
    clock     : in    std_logic;
    address   : in    std_logic_vector(15 downto 0);
    read      : in    std_logic;
    write     : in    std_logic;
    cs        : in    std_logic;
    ack       : out   std_logic;
    datain    : in    std_logic_vector(15 downto 0);
    dataout   : out   std_logic_vector(15 downto 0)
  );
end CometPRAM;

architecture RTL of CometPRAM is
  type ram_type is array (0 to 255) of std_logic_vector (15 downto 0); 
  signal RAM : ram_type; 
  signal tmp : std_logic;

begin
  process(clock) begin
    if (clock'event and clock = '1' and read='0' and write='1' and cs='0' and address(15 downto 4)=x"000") then
      dataout <= RAM( CONV_INTEGER(address) );
    elsif (clock'event and clock = '1' and read='1' and write='0' and cs='0' and address(15 downto 4)=x"000") then
      RAM( CONV_INTEGER(address) ) <= datain;
    end if;
    ack <= cs;
  end process;
end RTL;
