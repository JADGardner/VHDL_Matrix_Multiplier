library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- This is a ROM component to be used within the Paramatizeable Matrix-Multiplier.
-- It is made up of an array of integers for ease of reading. This is converted 
-- to signed binary numbers in synthesis.
entity Async_ROM_12x5 is
    Port ( Address : in UNSIGNED (3 downto 0);
           DataOut : out SIGNED (4 downto 0));
end Async_ROM_12x5;

architecture Behavioral of Async_ROM_12x5 is

type ROM_Array is array (0 to 11) of integer;
    constant Content: ROM_Array := (
        -- This is used as Matrix A. So to test functionality 
        -- of the Matrix-Multiplier the first three numbers 
        -- are set to -16. This will correspond to values chosen 
        -- in the other ROM to test the limits of the design.
        0 => -16,
        1 => -16,
        2 => -16,
        3 => 4,
        4 => 5,
        5 => 6,
        6 => 7,
        7 => 8,
        8 => 9,
        9 => 10,
        10 => 11,
        11 => 12,
        others => 0);
begin
        -- Converting the integers used above to signed binary values.
        DataOut <= TO_SIGNED(Content(TO_INTEGER(Address)),5);

end Behavioral;

