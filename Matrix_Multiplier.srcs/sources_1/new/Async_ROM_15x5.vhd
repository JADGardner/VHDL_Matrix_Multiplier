library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- This is a ROM component to be used within the Paramatizeable Matrix-Multiplier.
-- It is made up of an array of integers for ease of reading. This is converted 
-- to signed binary numbers in synthesis.
entity Async_ROM_15x5 is
    Port ( Address : in UNSIGNED (3 downto 0);
           DataOut : out SIGNED (4 downto 0));
end Async_ROM_15x5;

architecture Behavioral of Async_ROM_15x5 is

type ROM_Array is array (0 to 14) of integer;
    constant Content: ROM_Array := (
        -- This is used as Matrix B. So to test functionality 
        -- of the Matrix-Multiplier locations 0, 5 and 10 contain the value
        -- -16. This will correspond to values chosen  in the other ROM to 
        -- produce the largest positive number possible. Locations 1, 6 and 11
        -- contain 15 to be multiplied with -16 within the other ROM to produce the
        -- largest negative number.
        0 => -16,
        1 => 15,
        2 => 0,
        3 => 4,
        4 => 5,
        5 => -16,
        6 => 15,
        7 => 0,
        8 => 9,
        9 => 10,
        10 => -16,
        11 => 15,
        12 => 0,
        13 => 14,
        14 => 15,
        others => 0);
begin
        -- Converting the integers used above to signed binary values.
        DataOut <= TO_SIGNED(Content(TO_INTEGER(Address)),5);

end Behavioral;
