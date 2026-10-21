--------------------------------------------------------------------
-- Name:	Chris Coulston
-- Date:	Feb 3, 2015 
-- Modified:	Fall 2022
-- File:	lab2_fsm.vhdl
-- HW:	Lab2
--	Crs:	ECE 383
--
-- Purp: The control unit for the audio O'scope
--
-- Documentation:	No help, though I used an example from my Digital
--						Design text book.
--
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
------------------------------------------------------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.signalAcquire_Package.all;			-- include your library here with added components ac97, ac97cmd

entity signalAcquire_Fsm is
    PORT (  clk : in  STD_LOGIC;
            resetn : in  STD_LOGIC;
            sw: in STD_LOGIC_VECTOR(SW_WIDTH - 1 downto 0);
            cw: out STD_LOGIC_VECTOR (CW_WIDTH - 1 downto 0));
end signalAcquire_Fsm;

architecture Behavioral of signalAcquire_Fsm is

	signal state: state_type;
	
	signal SHORT_DELAY_DONE_SW, LONG_DELAY_DONE_SW, RF_FULL_SW, BUTTON_PRESSED_SW, BUSY_SW : STD_LOGIC;

begin

    -- defining intuitive names for the status word bits to make interperting the
    -- logic in the state_process much easier and thus, you'll make fewer errors.
    SHORT_DELAY_DONE_SW <= sw(SHORT_DELAY_DONE_SW_BIT_INDEX);
    LONG_DELAY_DONE_SW <= sw(LONG_DELAY_DONE_SW_BIT_INDEX);
    RF_FULL_SW <= sw(ALL_CHANNELS_HAVE_BEEN_READ_SW_BIT_INDEX);
    BUTTON_PRESSED_SW <= sw(START_CONV_SW_BIT_INDEX);
    BUSY_SW <= sw(BUSY_SW_BIT_INDEX);
    
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	state_proces: process(clk)  
	begin
		if (rising_edge(clk)) then
			if (resetn = '0') then 
				state <= RESET_STATE;
			else 
				case state is 
                    
                    when RESET_STATE => 
                        state <= LONG_DELAY_STATE;
                    
                    when LONG_DELAY_STATE =>
                        if (LONG_DELAY_DONE_SW = '1') then
                            state <= RESET_AD7606_STATE;
                        else
                            state <= LONG_DELAY_STATE;
                        end if;
                        
                    when RESET_AD7606_STATE =>
                        if (SHORT_DELAY_DONE_SW = '1') then
                            state <= WAIT_TRIGGER_STATE;
                        else
                            state <= RESET_AD7606_STATE;
                        end if;
                        
                    when WAIT_TRIGGER_STATE =>
                        if (BUTTON_PRESSED_SW = '1') then
                            state <= ASSERT_CONVST_STATE;
                        else
                            state <= WAIT_TRIGGER_STATE;
                       end if;
                       
                    when ASSERT_CONVST_STATE =>
                        if (SHORT_DELAY_DONE_SW = '1') then
                            state <= WAIT_BUSY_0_STATE;
                        else
                            state <= ASSERT_CONVST_STATE;
                        end if;
                        
                    when WAIT_BUSY_0_STATE =>
                        if (BUSY_SW = '1') then
                            state <= WAIT_BUSY_1_STATE;
                        else
                            state <= WAIT_BUSY_0_STATE;
                        end if;
                        
                    when WAIT_BUSY_1_STATE =>
                        if (BUSY_SW = '0') then
                            state <= WAIT_VALID_DATA_STATE;
                        else
                            state <= WAIT_BUSY_1_STATE;
                        end if;
                        
                    when WAIT_VALID_DATA_STATE =>
                        if (SHORT_DELAY_DONE_SW = '1') then
                            state <= LATCH_STATE;
                        else
                            state <= WAIT_VALID_DATA_STATE;
                        end if;
                        
                    when LATCH_STATE =>
                        state <= PAUSE_BETWEEN_CHANNELS_STATE;
                        
                    when PAUSE_BETWEEN_CHANNELS_STATE =>
                        if (SHORT_DELAY_DONE_SW = '1') then
                            state <= CLEAR_SHORT_COUNTER_STATE;
                        else
                            state <= PAUSE_BETWEEN_CHANNELS_STATE;
                        end if;
                        
                    when CLEAR_SHORT_COUNTER_STATE =>
                        if (RF_FULL_SW = '1') then
                            state <= WAIT_TRIGGER_STATE;
                        else
                            state <= WAIT_VALID_DATA_STATE;
				        end if;
				        
				end case;
			end if;
		end if;
	end process;

    -------------------------------------------------------------------------------
    -- LPT: List all the bits of your control word and define their purpose.
    --      cw              Purpose
    --
    -- LPT: Add the truth table for any BBB which are used in the datapath
    --  counter control     Function
    -------------------------------------------------------------------------------
	output_process: process (state)
	begin
	    case state is
-- control word follows wr_addr_1, wr_addr_0, short_addr_1, short_addr_0, long_addr_1, long_addr_0
-- write reg, convst (for ad7606), rd (for ad7606), cs (for ad7606), reset (for ad7606) 
                -- bits 5-10: counter control, see each state for more details
                -- bit 4: only write to reg on latch state
                -- bit 3: only start convst on assert const state (looks at rising edge -> only 0 at that state)
                -- bit 2: only read in the wait for valid data state (active low, only 0 in the wait for valid data state)
                -- bit 1: only reset ad7606 on its designated state
                -- bit 0: only set cs when interacting with ad7606, active low <- ?????
                
                -- reset all counters
                when RESET_STATE =>                  cw <= "11111101110";
                -- hold addr, short, inc long 
                when LONG_DELAY_STATE =>             cw <= "00001001110";
                -- hold addr, inc short, load long
                when RESET_AD7606_STATE =>           cw <= "00100101111";
                -- load addr, short, hold long
                when WAIT_TRIGGER_STATE =>           cw <= "01010001110";
                -- hold addr, inc short, hold long
                when ASSERT_CONVST_STATE =>          cw <= "00100000110";
                -- hold addr, load short, hold long
                when WAIT_BUSY_0_STATE =>            cw <= "00010001110";
                -- hold addr, short, long
                when WAIT_BUSY_1_STATE =>            cw <= "00000001110";
                -- hold addr, inc short, hold long
                when WAIT_VALID_DATA_STATE =>        cw <= "00100001000";
                -- inc addr, load short, hold long
                when LATCH_STATE =>                  cw <= "10010011100";
                -- hold addr, inc short, hold long
                when PAUSE_BETWEEN_CHANNELS_STATE => cw <= "00100001100";
                -- hold addr, load short, hold long
                when CLEAR_SHORT_COUNTER_STATE =>    cw <= "00010001100";
		end case;
	end process;

end Behavioral;



