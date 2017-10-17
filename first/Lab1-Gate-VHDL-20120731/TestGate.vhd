library IEEE;
use IEEE.std_logic_1164.all;

entity TestGate is
end TestGate;

architecture TestGate of TestGate is
  constant STEP : Time := 100 ns;
  signal IN_A     : std_logic;
  signal IN_B     : std_logic;
  signal OUT_AND  : std_logic;
  signal OUT_OR   : std_logic;
  signal OUT_NAND : std_logic;
  signal OUT_NOR  : std_logic;
  signal OUT_XOR  : std_logic;
  signal OUT_NOTA  : std_logic;
  signal OUT_NOTB  : std_logic;
  component Gate
    port(
      A        : in std_logic;
      B        : in std_logic;
      OUT_AND  : out std_logic;
      OUT_OR   : out std_logic;
      OUT_NAND : out std_logic;
      OUT_NOR  : out std_logic;
      OUT_XOR  : out std_logic;
      OUT_NOTA  : out std_logic;
      OUT_NOTB  : out std_logic
    );
  end component;

begin
  U0: Gate 
  port map(
    IN_A,
    IN_B,
    OUT_AND,
    OUT_OR, 
    OUT_NAND, 
    OUT_NOR, 
    OUT_XOR,
    OUT_NOTA,
    OUT_NOTB
  );
  process
    begin
      IN_A <= '0';  IN_B <= '0';
      wait for STEP;
      IN_A <= '0';  IN_B <= '1';
      wait for STEP;
      IN_A <= '1';  IN_B <= '0';
      wait for STEP;
      IN_A <= '1';  IN_B <= '1';
      wait for STEP;
      IN_A <= '0';  IN_B <= '0';
    wait;
  end process;
end TestGate;

