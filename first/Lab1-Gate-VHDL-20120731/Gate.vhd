library IEEE;
use IEEE.std_logic_1164.all;

entity Gate is
  port(
    A        : in std_logic;
    B        : in std_logic;
    OUT_AND  : out std_logic;
    OUT_OR   : out std_logic;
    OUT_NAND : out std_logic;
    OUT_NOR  : out std_logic;
    OUT_XOR  : out std_logic;
    OUT_NOTA : out std_logic;
    OUT_NOTB : out std_logic
  );
end Gate;

architecture Gate of Gate is
begin
	OUT_AND  <= A and B;
	OUT_OR   <= A or B;
	OUT_NAND <= A nand B;
	OUT_NOR  <= A nor B;
	OUT_XOR  <= A xor B;
	OUT_NOTA <= not A;
	OUT_NOTB <= not B;
end Gate;
