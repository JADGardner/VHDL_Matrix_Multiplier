library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL; 
-- This is the test-bench of the Matrix_Multiplier. It is a paramertiseable,
-- self checking test-bench. It uses a record containing pre-calculated expected 
-- outputs and their corresponding output-matrix locations. The test-bench will 
-- report when there are errors and also when the circuit works as expected.

entity Matrix_Multiplier_tb is

end Matrix_Multiplier_tb;

architecture Behavioral of Matrix_Multiplier_tb is

constant CLK_PERIOD : time := 10 ns; -- Defines the standard clock time
-- Constants that will be remapped to Matrix_Multiplier generics
constant data_size : integer := 5; -- Number of bits per coefficient of the input matricies 
constant Matrix_A_Height : integer := 4; -- {H} The number of rows within input matrix A 
constant Matrix_B_Width : integer := 5; -- {N} The number of collumns within input matrix B
constant Matrix_Common : integer := 3; -- {M} The number of collumns within input matrix A
                                       -- and number of rows withing input matrix B
                                       
-- The size of the output buss is determind by the maximum value possible to represent using a 
-- binary number of data_size wide mulitplied by itself Matrix_Common times. Here it is 
-- declared as a constant to be used throughout other components.
constant output_size : integer := (size(Matrix_Common * ((2**(data_size - 1))**2))) +1;

signal CLK : STD_LOGIC; -- Global clock input
signal RST : STD_LOGIC; -- User input debounced Reset
signal NXT : STD_LOGIC; -- User input debounced Next
signal Output : SIGNED (output_size -1 downto 0); -- Output of RAM

-- Record declared that contains Collumn/Row integers used to identify coefficient 
-- position within RAM and Output_rcd which is pre-calculated expected output of RAM.
-- These a grouped together under the name output_coefficient
type output_coefficient is record
    column : integer;
    row : integer;
    output_rcd : SIGNED (output_size-1 downto 0);
end record;

-- Declaring a type of array made up of the output_coefficient type called
-- results_array
type results_array is array
    (natural range <>) of output_coefficient;

-- Creating a results_array called results and filling it
-- with a comppleted output matrix of correct expected outputs
-- and thier corresponding positions within that matrix. These
-- were calculated using Matlab. It contains one erroneous output. 
constant results : results_array := (   
    -- Column, Row,     Output_RCD
    -- Testing maximum positive number.
    (0,         0,      TO_SIGNED(768, output_size)),
    -- Testing maximum negative number, uses MSB.
    (1,         0,      TO_SIGNED(-720, output_size)),
    -- Testing 0 output.
    (2,         0,      TO_SIGNED(0, output_size)),
    -- Further sets of inputs to check circuit is operating correctly
    (3,         0,      TO_SIGNED(-432, output_size)),
    (4,         0,      TO_SIGNED(-480, output_size)),
    (0,         1,      TO_SIGNED(-240, output_size)),
    (1,         1,      TO_SIGNED(225, output_size)),
    (2,         1,      TO_SIGNED(0, output_size)),
    (3,         1,      TO_SIGNED(145, output_size)),
    (4,         1,      TO_SIGNED(160, output_size)),
    (0,         2,      TO_SIGNED(-384, output_size)),
    (1,         2,      TO_SIGNED(360, output_size)),
    (2,         2,      TO_SIGNED(0, output_size)),
    (3,         2,      TO_SIGNED(226, output_size)),
    (4,         2,      TO_SIGNED(250, output_size)),
    (0,         3,      TO_SIGNED(-528, output_size)),
    (1,         3,      TO_SIGNED(495, output_size)),
    (2,         3,      TO_SIGNED(0, output_size)),
    (3,         3,      TO_SIGNED(307, output_size)),
    -- The final result is erroenous to test error checking 
    -- functonality of test-bench.
    (4,         3,      TO_SIGNED(342, output_size)));
        
    

begin
UUT: entity work.Matrix_Multiplier
    -- Remapping generic and port maps with testbench constants and signals
    GENERIC MAP ( data_size => data_size,
                  Matrix_A_Height => Matrix_A_Height,
                  Matrix_B_Width => Matrix_B_Width,
                  Matrix_Common => Matrix_Common)
    PORT MAP ( CLK => CLK,
               RST => RST,
               NXT => NXT,
               Output => Output);
               
-- Clock process
clk_process :process
begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
end process;


test : process
begin
    wait for 100 ns;
    wait until falling_edge(CLK);
    
    -- Needed for resetting debouncers
    -- All inputs need to last for 2*CLK_PERIOD's
    -- for the debouncer to accept them as inputs
    -- and outputs the signals to the counter.
    RST <= '0';
    NXT <= '0';
    wait for CLK_PERIOD*2;
    RST <= '1';
    NXT <= '1';
    wait for CLK_PERIOD*2;
    RST <= '0';
    NXT <= '0';
    wait for CLK_PERIOD*2;
    
    -- Looping through the results_array - results.
    for i in results'range loop
    NXT <= '1'; -- NXT is pressed to begin the calculation of a coefficient
    wait for CLK_PERIOD*2;
    NXT <= '0';
    
    wait for CLK_PERIOD*6; -- Waiting 6 Clock cycles between DISPLAY states.
    
    assert (output = results(i).output_rcd) -- compareing expected and actual values
    -- If assert not true report occurs displaying expected and actual values
    report "Test failed for column: {" & integer'image(results(i).column) 
            & "} and row: {" & integer'image(results(i).row) & 
           "} Expected output = {" & integer'image(to_integer(results(i).output_rcd)) & 
           "} Actual output = {" & integer'image(to_integer(Output)) & "}"
    severity error;
    
    -- If first report doesn't occur test was successful and this report occurs 
    -- displaying expected and actual value.
    assert (output /= results(i).output_rcd)
    report "Test, no errors for column: {" & integer'image(results(i).column) 
            & "} and row: {" & integer'image(results(i).row) & 
           "} Output = {" & integer'image(to_integer(Output)) & "}"
    severity note;
    end loop;
    
    -- Resetting after full matrix calculated
    RST <= '1';
    wait for CLK_PERIOD*2;
    RST <= '0';
    
    -- Running through loop again after reset
    for i in results'range loop
    NXT <= '1'; -- NXT is pressed to begin the calculation of a coefficient
    wait for CLK_PERIOD*2;
    NXT <= '0';
    
    wait for CLK_PERIOD*6; -- Waiting 6 Clock cycles between DISPLAY states.
    
    assert (output = results(i).output_rcd) -- compareing expected and actual values
    -- If assert not true report occurs displaying expected and actual values
    report "Test failed for column: {" & integer'image(results(i).column) 
            & "} and row: {" & integer'image(results(i).row) & 
           "} Expected output = {" & integer'image(to_integer(results(i).output_rcd)) & 
           "} Actual output = {" & integer'image(to_integer(Output)) & "}"
    severity error;
    
    -- If first report doesn't occur test was successful and this report occurs 
    -- displaying expected and actual value.
    assert (output /= results(i).output_rcd)
    report "Test, no errors for column: {" & integer'image(results(i).column) 
            & "} and row: {" & integer'image(results(i).row) & 
           "} Output = {" & integer'image(to_integer(Output)) & "}"
    severity note;
    end loop;
    
    
    wait; 
    
end process; 
end Behavioral;
