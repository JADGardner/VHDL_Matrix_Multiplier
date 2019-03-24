library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Async_ROM_68x4 is
    Port ( Address : in UNSIGNED (6 downto 0);
           DataOut : out SIGNED (3 downto 0));
end Async_ROM_68x4;

architecture Behavioral of Async_ROM_68x4 is

type ROM_Array is array (0 to 67) of integer;
    constant Content: ROM_Array := (
        0 => -8,
        1 => -8,
        2 => -8,
        3 => -8,
        4 => -8,
        5 => -8,
        6 => -8,
        7 => -8,
        8 => -8,
        9 => -8,
        10 => -8,
        11 => -8,
        12 => -8,
        13 => -8,
        14 => -8,
        15 => -8,
        16 => -8,
        17 => 7,
        18 => 7,
        19 => 7,
        20 => 7,
        21 => 7,
        22 => 7,
        23 => 7,
        24 => 7,
        25 => 7,
        26 => 7,
        27 => 7,
        28 => 7,
        29 => 7,
        30 => 7,
        31 => 7,
        32 => 7,
        33 => 7, 
        others => 1);
begin
        DataOut <= TO_SIGNED(Content(TO_INTEGER(Address)),4);

end Behavioral;
