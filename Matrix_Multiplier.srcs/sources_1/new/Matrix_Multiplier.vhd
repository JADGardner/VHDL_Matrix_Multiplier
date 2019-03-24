----------------------------------------------------------------------------------
-- Company: University of York
-- Engineers: James Gardner
-- 
-- Create Date:    21/11/2018
-- Design Name:    Parameterizable Matrix-Multiplier
-- Module Name:    Matrix-Multiplier
-- Project Name:   Final Project 
-- Tool versions:  Any (tested on ISE 2017.4)
-- Description: 
--  A fully parameterizable matrix-multiplier multiplies two pre-defined
--  ROMs and stores the output in a parameterizable RAM.
-- Dependencies: 
--   Requires DigEng.vhd package
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL; 
-- This is the top-level component of the paramatizeable matrix-multiplier. 
-- It generates to debouncers for user inputs and connects the control-logic to 
-- the datapath. 
entity Matrix_Multiplier is
    -- The generics state the size of each matrix to be multilied. 
    Generic ( data_size : integer := 5; -- Number of bits per coefficient of the input matricies 
          Matrix_A_Height : integer := 4; -- {H} The number of rows within input matrix A
          Matrix_B_Width : integer := 5; -- {N} The number of collumns within input matrix B
          Matrix_Common : integer := 3); -- {M} The number of collumns within input matrix A
                                         -- and number of rows withing input matrix B
    Port ( CLK : in STD_LOGIC; -- Global clock input
           RST : in STD_LOGIC; -- User input debounced Reset
           NXT : in STD_LOGIC; -- User input debounced Next
           -- The size of the output buss is determind by the maximum value possible to represent using a 
           -- binary number of data_size wide mulitplied by itself Matrix_Common times.
           Output : out SIGNED ((size(Matrix_Common * ((2**(data_size - 1))**2))) downto 0));
end Matrix_Multiplier;

architecture Behavioral of Matrix_Multiplier is

-- 
signal deb_rst, deb_nxt : STD_LOGIC;  -- debounced reset and "next" signals
-- Address sizes of both ROMs determined by the log2 function of generic variables
signal Address_ROM_A : UNSIGNED (log2(Matrix_A_Height*Matrix_Common)-1 downto 0);
signal Address_ROM_B : UNSIGNED (log2(Matrix_B_Width*Matrix_Common)-1 downto 0);
signal MACC_RST : STD_LOGIC; -- Reset output of multiply-accumulate unit to zero
signal MACC_EN : STD_LOGIC; -- Enable of multiply-accumulate unit
-- Address size of RAM determined by the log2 function of generic variables
signal Address_RAM : UNSIGNED(log2(Matrix_A_Height*Matrix_B_Width) -1 downto 0);
signal Write_EN : STD_LOGIC; -- Enabling writing to the RAM

-- The size of the output buss is determind by the maximum value possible to represent using a 
-- binary number of data_size wide mulitplied by itself Matrix_Common times. Here it is 
-- declared as a constant to be used throughout other components.
constant output_size : integer := size(Matrix_Common * ((2**(data_size - 1))**2)) +1;

begin

-- Debouncer for "RST" signal
Rst_Debouncer: entity work.Debouncer 
    PORT MAP(
 CLK => CLK,
              Sig => RST,
              Deb_Sig => deb_rst
);

-- Debouncer for "NXT" signal   
Next_Debouncer: entity work.Debouncer 
    PORT MAP(
 CLK => CLK,
              Sig => NXT,
              Deb_Sig => deb_nxt
);

-- Conneting the generics and ports for the control and the datapath.
Control: entity work.Control
    GENERIC MAP ( data_size => data_size,
                  Matrix_A_Height => Matrix_A_Height,
                  Matrix_B_Width => Matrix_B_Width,
                  Matrix_Common => Matrix_Common)

    PORT MAP ( CLK => CLK,
               RST => deb_rst,
               NXT => deb_nxt,
               Address_ROM_A => Address_ROM_A,
               Address_ROM_B => Address_ROM_B,
               MACC_RST => MACC_RST,
               MACC_EN => MACC_EN,
               Address_RAM => Address_RAM,
               Write_EN => Write_EN);


Datapath: entity work.Datapath 
    GENERIC MAP ( data_size => data_size,
                  Matrix_A_Height => Matrix_A_Height,
                  Matrix_B_Width => Matrix_B_Width,
                  Matrix_Common => Matrix_Common,
                  output_size => output_size)
                  
    PORT MAP ( CLK => CLK,
               Address_ROM_A => Address_ROM_A,
               Address_ROM_B => Address_ROM_B,
               MACC_RST => MACC_RST,
               MACC_EN => MACC_EN,
               Address_RAM => Address_RAM,
               Write_EN => Write_EN,
               Output => Output);

end Behavioral;
