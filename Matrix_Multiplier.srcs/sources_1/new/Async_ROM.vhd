library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Async_ROM is
    Port ( Address : in UNSIGNED (3 downto 0);
           DataOut : out SIGNED (4 downto 0));
end Async_ROM;

architecture Behavioral of Async_ROM is

type ROM_Array is array (0 to 15) of signed (4 downto 0);
    constant Content: ROM_Array := (
        0 => B"00000",
        1 => B"00000",
        2 => B"00000",
        3 => B"00000",
        4 => B"00000",
        5 => B"00000",
        6 => B"00000",
        7 => B"00000",
        8 => B"00000",
        9 => B"00000",
        10 => B"00000",
        11 => B"00000",
        others => B"00000");
begin
        DataOut <= Content(to_integer(Address));

end Behavioral;
