library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Async_ROM_136x4 is
    Port ( Address : in UNSIGNED (7 downto 0);
           DataOut : out SIGNED (3 downto 0));
end Async_ROM_136x4;

architecture Behavioral of Async_ROM_136x4 is

type ROM_Array is array (0 to 135) of integer;
    constant Content: ROM_Array := (
        0 => -8,
        1 => 7,
        2 => 0,
        8 => -8,
        9 => 7,
        10 => 0,
        16 => -8,
        17 => 7,
        18 => 0,
        24 => -8,
        25 => 7,
        26 => 0,
        32 => -8,
        33 => 7,
        34 => 0,
        40 => -8,
        41 => 7,
        42 => 0,
        48 => -8,
        49 => 7,
        50 => 0,
        56 => -8,
        57 => 7,
        58 => 0,
        64 => -8,
        65 => 7,
        66 => 0,
        72 => -8,
        73 => 7,
        74 => 0,
        80 => -8,
        81 => 7,
        82 => 0,
        88 => -8,
        89 => 7,
        90 => 0,
        96 => -8,
        97 => 7,
        98 => 0,
        104 => -8,
        105 => 7,
        106 => 0,
        112 => -8,
        113 => 7,
        114 => 0,
        120 => -8,
        121 => 7,
        122 => 0,
        128 => -8,
        129 => 7,
        130 => 0,
        others => 1);
begin
        DataOut <= TO_SIGNED(Content(TO_INTEGER(Address)),4);

end Behavioral;