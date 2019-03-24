library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL; 
-- This is a Synchronous write / asynchrounous read paramatiseable single-port RAM
entity Param_RAM is
    Generic ( Width : integer := 4; -- Datasize in bits
              Depth : integer := 5); -- Matrix_A_Height * Matrix_B_Width 
    Port ( CLK : in  STD_LOGIC;
           Write_EN : in  STD_LOGIC;                
           Data_In : in  SIGNED (Width -1 downto 0);    
           Address : in  UNSIGNED (log2(Depth)-1 downto 0);     
           Data_Out : out  SIGNED (Width -1 downto 0)); 
end Param_RAM;

architecture Behavioral of Param_RAM is

type ram_type is array (0 to Depth -1) of SIGNED(Width -1 downto 0);
-- Initially setting all values within RAM to 0.
signal ram_inst: ram_type;

begin

  -- Asynchronous read
  Data_Out <= ram_inst(to_integer(Address)); 

  -- Synchronous write (write enable signal)
  process (CLK)
  begin
    if (rising_edge(CLK)) then 
       if (write_en='1') then
          ram_inst(to_integer(Address)) <= Data_In;
       end if;
    end if;
  end process;

end Behavioral;
