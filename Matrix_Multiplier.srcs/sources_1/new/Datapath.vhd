library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL; 
-- This is datapath of the paramatizeable matrix-multiplier.
-- It connects the ROMs, MACC and RAM together.
-- It contains the combiniational logic of the MACC contraining:
-- the multiplication, addition and registers.
entity Datapath is -- The generics state the size of each matrix to be multilied. 
    Generic ( data_size : integer := 5; -- Number of bits per coefficient of the input matricies 
              Matrix_A_Height : integer := 4; -- {H} The number of rows within input matrix A
              Matrix_B_Width : integer := 5; -- {N} The number of collumns within input matrix B
              Matrix_Common : integer := 3; -- {M} The number of collumns within input matrix A
                                            -- and number of rows withing input matrix B
              output_size : integer := 7); -- The number of bits per coefficient of the output matrix
                      
    Port ( CLK : in STD_LOGIC; -- Global clock input
           -- Address sizes of both ROMs determined by the log2 function of generic variables
           Address_ROM_A : in UNSIGNED (log2(Matrix_A_Height*Matrix_Common)-1 downto 0);
           Address_ROM_B : in UNSIGNED (log2(Matrix_B_Width*Matrix_Common)-1 downto 0);
           MACC_RST : in STD_LOGIC; -- Reset output of multiply-accumulate unit to zero
           MACC_EN : in STD_LOGIC; -- Enable of multiply-accumulate unit
           -- Address size of RAM determined by the log2 function of generic variables
           Address_RAM : in UNSIGNED (log2(Matrix_A_Height*Matrix_B_Width) -1 downto 0);
           Write_EN : in STD_LOGIC; -- Enabling writing to the RAM
           Output : out SIGNED (output_size -1 downto 0)); -- The output of the RAM
end Datapath;

architecture Behavioral of Datapath is

-- Internal ROM outputs (data_size)-Bit data busses
signal ROM_A_Data_out, ROM_B_Data_out : SIGNED (data_size - 1 downto 0);
-- Internal output of MACC, size of bus is determind by largest 
-- possible output of the two signed inputs.
signal MACC_Data_out : SIGNED (output_size - 1 downto 0);



begin

-- Multiply-accumulate unit (MACC) consists of a multiplier coupled 
-- with an adder that accumulates the results by adding together the results of
-- the multiplication. Calculates data to be written to RAM.
MACC: process (CLK)
begin
   if (rising_edge(CLK)) then
      if (MACC_RST = '1') then -- synchronous reset
         MACC_Data_out <= (others => '0'); -- Sets output to 0
      elsif (MACC_EN = '1') then -- Enable signal
        -- Combinational logic for multiply-accumulate unit
        MACC_Data_out <= (ROM_A_Data_out * ROM_B_Data_out) + MACC_Data_out;
      end if;
   end if;
end process MACC;

-- Declaring the two ROMs and RAM
ROM_A: entity work.Async_ROM_12x5
    PORT MAP( Address => Address_ROM_A,
              DataOut => ROM_A_Data_out);

ROM_B: entity work.Async_ROM_15x5 
    PORT MAP( Address => Address_ROM_B,
              DataOut => ROM_B_Data_out);

RAM: entity work.Param_RAM 
    GENERIC MAP( Width => output_size,
                 -- The size of the RAM is determined by the generics 
                 Depth => Matrix_A_Height*Matrix_B_Width)
    PORT MAP( CLK => CLK,
              Write_EN => Write_EN,
              Data_In => MACC_Data_out,
              Address => Address_RAM,
              Data_Out => Output);



end Behavioral;
