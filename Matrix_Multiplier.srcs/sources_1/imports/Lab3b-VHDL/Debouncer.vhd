----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:19:13 02/06/2010 
-- Design Name: 
-- Module Name:    Debouncer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Debouncer is
    Port ( CLK : in  STD_LOGIC;
           Sig : in  STD_LOGIC;
           Deb_Sig : out  STD_LOGIC);
end Debouncer;

architecture Behavioral of Debouncer is

	signal Q0, Q1, Q2 : STD_LOGIC := '0';
	
begin

process (CLK) is
begin
	if (CLK'event and CLK = '1') then 
		Q0 <= Sig;
		Q1 <= Q0;
		Q2 <= Q1;
	end if;
end process;

Deb_Sig <= Q0 and Q1 and (not Q2);

end Behavioral;

