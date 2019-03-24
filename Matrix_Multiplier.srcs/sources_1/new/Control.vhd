library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.ALL; 
-- This is the control component for a fully parameterizable Matrix-Multiplier. 
-- It contains a Mealy finite state machine, 
-- combinational logic for the ROM/RAM addresses and counters. 
entity Control is -- The generics state the size of each matrix to be multilied. 
    Generic ( data_size : integer := 5; -- Number of bits per coefficient of the input matricies 
          Matrix_A_Height : integer := 4; -- {H} The number of rows within input matrix A
          Matrix_B_Width : integer := 5; -- {N} The number of collumns within input matrix B
          Matrix_Common : integer := 3); -- {M} The number of collumns within input matrix A
                                         -- and number of rows withing input matrix B

    Port ( CLK : in STD_LOGIC; -- Global clock input
           RST : in STD_LOGIC; -- User input debounced Reset
           NXT : in STD_LOGIC; -- User input debounced Next
           -- Address sizes of both ROMs determined by the log2 function of generic variables
           Address_ROM_A : out UNSIGNED (log2(Matrix_A_Height*Matrix_Common)-1 downto 0);
           Address_ROM_B : out UNSIGNED (log2(Matrix_B_Width*Matrix_Common)-1 downto 0);
           MACC_RST : out STD_LOGIC; -- Reset output of multiply-accumulate unit to zero
           MACC_EN : out STD_LOGIC; -- Enable of multiply-accumulate unit
           -- Address size of RAM determined by the log2 function of generic variables
           Address_RAM : out UNSIGNED(log2(Matrix_A_Height*Matrix_B_Width) -1 downto 0);
           Write_EN : out STD_LOGIC); -- Enabling writing to the RAM
end Control;

architecture Behavioral of Control is
    -- Defining a new type that contains all possible states of the FSM. 
    type fsm_states is (RESET_STATE, CALCULATE_COEFFICIENT, STORE, DISPLAY);
    -- Creating two new signals of newly created 'fsm_states' type.
    signal state, next_state: fsm_states; 
    -- Done is set high after final coefficient calculated.
    -- CNT_EM_M/N/H are the enables of each counter.
    signal done, CNT_EN_M, CNT_EN_N, CNT_EN_H : STD_LOGIC;
    -- Internal signals of clocks
    signal count_M_int : UNSIGNED (log2(Matrix_Common)-1 downto 0);
    signal count_N_int : UNSIGNED (log2(Matrix_B_Width)-1 downto 0);
    signal count_H_int : UNSIGNED (log2(Matrix_A_Height)-1 downto 0);
    

begin
    -- Declaring the three counters of variable sizes used for addressing RAM and ROM
    M_Counter: entity work.Param_Counter 
    -- M countewrs size depends on generic Matrix_Common
    GENERIC MAP (LIMIT => Matrix_Common)
    PORT MAP( CLK => CLK,
              RST => RST,
              EN => CNT_EN_M,
              Count_Out => count_M_int);
              
    N_Counter: entity work.Param_Counter 
    -- N countewrs size depends on generic Matrix_B_Width
    GENERIC MAP (LIMIT => Matrix_B_Width)
    PORT MAP( CLK => CLK,
              RST => RST,
              EN => CNT_EN_N,
              Count_Out => count_N_int);
              
    H_Counter: entity work.Param_Counter 
    -- H countewrs size depends on generic Matrix_A_Height
    GENERIC MAP (LIMIT => Matrix_A_Height)
    PORT MAP( CLK => CLK,
              RST => RST,
              EN => CNT_EN_H,
              Count_Out => count_H_int);
              

    -- This is the proccess for the state register
    state_assignment: process (CLK) is     
    begin
     if rising_edge(CLK) then
        if (RST = '1') then
            -- RESET_STATE is the reset state
            state <= RESET_STATE;
        else
            -- if reset is not pressed state gets next state
            state <= next_state;
        end if;
    end if;
    end process state_assignment;
    
    -- This is the process for the state transitions 
    transitions: process (state, NXT, done, count_M_int) is
    begin
        case state is
           when RESET_STATE => 
           -- STATE DESCRIPTION
           -- Reamins idle in this state until NXT is pressed
           -- Everthing initially set to 0.
               if NXT = '1' then
                   next_state <= CALCULATE_COEFFICIENT;
               else
                   next_state <= state;
               end if;
               
           when CALCULATE_COEFFICIENT =>
           -- STATE DESCRIPTION
           -- Cycles through ROMs, calculating one full
           -- coefficent of the output matrix.
               if count_M_int = Matrix_Common-1 then
                   next_state <= STORE;
               else
                   next_state <= state;
               end if;
               
           when STORE =>
           -- STATE DESCRIPTION
           -- Writes the calculated coefficent to the RAM
               next_state <= DISPLAY;
               
           when DISPLAY =>
           -- STATE DESCRIPTION
           -- Displays the output of current coefficent calculated.
           -- Remains in this state until user presses NXT if not 
           -- done. Else remains until RST.
               if NXT = '1' and done = '0' then
                   next_state <= CALCULATE_COEFFICIENT;
               else
                   next_state <= state;
               end if;
       end case;
   end process transitions;    


-- Below is all the combinational logic determining the control signals.
-- They are based on current states, counter outputs and user inputs.

-- Done is the flag for the final coefficient being calculated.
-- Based on when all counters have reached thier maximum values.                                       
done <= '1' when count_M_int = Matrix_Common-1 
            and count_N_int = Matrix_B_Width-1 
            and count_H_int = Matrix_A_Height-1 
            else '0';

-- Causes M_Counter to count to it's maximum value everytime the state is CALCULATE_COEFFICIENT
-- Is then incrmented back to start value when NXT is pressed and state is DISPLAY.
CNT_EN_M <= '1' when state = CALCULATE_COEFFICIENT and count_M_int < Matrix_Common-1
                else '1' when state = DISPLAY and done = '0' and NXT = '1'
                else '0';

-- Controlled by the user pressing NXT when in DISPLAY state. 
CNT_EN_N <= '1' when state = DISPLAY and done = '0' and NXT = '1'
                else '0';

-- Controlled by the user pressing NXT when in DISPLAY state and 
-- when other two counters are at maximum value.
CNT_EN_H <= '1' when state = DISPLAY and done = '0' and NXT = '1'
                and count_M_int = Matrix_Common-1 
                and count_N_int = Matrix_B_Width-1
                else '0';  

-- Used to remove previous data from the MACC output.
-- Needed prior to each new coefficent calculated or in RST.
MACC_RST <= '1' when state = RESET_STATE
                else '1' when state = DISPLAY
                else '0';

-- Enabling MACC to calculate values. Only in state CALCULATE_COEFFICIENT 
MACC_EN <= '1' when state = CALCULATE_COEFFICIENT 
               else '0';

-- Enabling writing of data to RAM, only in STORE state. 
Write_EN <= '1' when state = STORE 
                else '0';
      
-- All below address buses are calculated through combinatinal logic. As a function of counters and generic values.

-- Combinational logic of RAM
Address_RAM <= RESIZE(((TO_UNSIGNED(Matrix_B_Width, log2(Matrix_B_Width)))*count_H_int) + count_N_int, log2(Matrix_A_Height*Matrix_B_Width));

-- Combinational logic for addresses of A and B ROM
Address_ROM_A <= RESIZE(((TO_UNSIGNED(Matrix_Common, log2(Matrix_Common)))*count_H_int) + count_M_int, log2(Matrix_A_Height*Matrix_Common));
Address_ROM_B <= RESIZE(((TO_UNSIGNED(Matrix_B_Width, log2(Matrix_B_Width)))*count_M_int) + count_N_int, log2(Matrix_B_Width*Matrix_Common));  

            
end Behavioral;
