--------------------------------------------------------------------
-- Name:	Chris Coulston
-- Date:	Feb 3, 2015
-- File:	acquireToHDMI_fsm.vhdl
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
use work.acquireToHDMI_package.all;					-- include your library here with added components ac97, ac97cmd


entity acquireToHDMI_fsm is
    PORT (  clk : in  STD_LOGIC;
            resetn : in  STD_LOGIC;
            sw: in STD_LOGIC_VECTOR(SW_WIDTH - 1 downto 0);
            cw: out STD_LOGIC_VECTOR (CW_WIDTH - 1 downto 0));
end acquireToHDMI_fsm;

architecture Behavioral of acquireToHDMI_fsm is

	signal state: state_type;	-- define the state_type in your package file	
	signal FORCED_MODE_SW, SINGLE_SW, BUSY_SW, FULL_SW, STORE_SW: STD_LOGIC;
	signal CHANNEL2_TRIG_SW, CHANNEL1_TRIG_SW, SAMPLE_SW, LONG_SW: STD_LOGIC;
	signal SHORT_SW: STD_LOGIC;
begin

    FORCED_MODE_SW <= sw(FORCED_MODE_SW_BIT_INDEX);
    SINGLE_SW <= sw(SINGLE_SW_BIT_INDEX);
    BUSY_SW <= sw(BUSY_SW_BIT_INDEX);
    FULL_SW <= sw(FULL_SW_BIT_INDEX);
    STORE_SW <= sw(STORE_SW_BIT_INDEX);
    CHANNEL2_TRIG_SW <= sw(CHANNEL2_TRIG_SW_BIT_INDEX);
    CHANNEL1_TRIG_SW <= sw(CHANNEL1_TRIG_SW_BIT_INDEX);
    SAMPLE_SW <= sw(SAMPLE_SW_BIT_INDEX);
    LONG_SW <= sw(LONG_SW_BIT_INDEX);
    SHORT_SW <= sw(SHORT_SW_BIT_INDEX);
    
    
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	state_process: process(clk)  
	begin
		if (rising_edge(clk)) then
			if (resetn = '0') then 
				state <= RESET_STATE;
			else 
				case state is				
					when RESET_STATE =>
				        state <= LONG_DELAY_STATE;
				    when LONG_DELAY_STATE =>
				        if (LONG_SW = '1') then
				            state <= RESET_ADC_STATE;
				        end if;
				    when RESET_ADC_STATE =>
				        if (SHORT_SW = '1') then
				            state <= WAIT_FORCED_STATE;
				        end if;
				    when WAIT_FORCED_STATE =>
				        if (SINGLE_SW = '1') then
				            state <= SET_STORE_STATE;
				        end if;
				    when SET_STORE_STATE =>
				        state <= BEGIN_CONV_STATE;
				    when CLEAR_STORE_STATE =>
				        state <= BEGIN_CONV_STATE;
				    when BEGIN_CONV_STATE =>
				        state <= ASSERT_CONVST_STATE;
				    when ASSERT_CONVST_STATE =>
				        if (SHORT_SW = '1') then
				            state <= BUSY0_STATE;
				        end if;
				    when BUSY0_STATE =>
				        if (BUSY_SW = '1') then
				            state <= BUSY1_STATE;
				        end if;
				    when BUSY1_STATE =>
				        if (BUSY_SW = '0') then
				            state <= READ_CH1_LOW_STATE;
				        end if;
				    when READ_CH1_LOW_STATE =>
				        if (SHORT_SW = '1' and STORE_SW = '0') then
				            state <= WRITE_CH1_TRIG_STATE;
				        elsif (SHORT_SW = '1' and STORE_SW = '1') then
				            state <= WRITE_CH1_BRAM_STATE;
				        end if;
				    when WRITE_CH1_TRIG_STATE =>
				        state <= READ_CH1_HIGH_STATE;
				    when WRITE_CH1_BRAM_STATE =>
				        state <= READ_CH1_HIGH_STATE;
				    when READ_CH1_HIGH_STATE =>
				        if (SHORT_SW = '1') then
				            state <= RESET_SHORT_STATE;
				        end if;
				    when RESET_SHORT_STATE =>
				        state <= READ_CH2_LOW_STATE;
				    when READ_CH2_LOW_STATE =>
				        if (SHORT_SW = '1' and STORE_SW = '0') then
				            state <= WRITE_CH2_TRIG_STATE;
				        elsif (SHORT_SW = '1' and STORE_SW = '1') then
				            state <= WRITE_CH2_BRAM_STATE;
				        end if;
				    when WRITE_CH2_TRIG_STATE =>
				        state <= READ_CH2_HIGH_STATE;
				    when WRITE_CH2_BRAM_STATE =>
				        state <= READ_CH2_HIGH_STATE;
				    when READ_CH2_HIGH_STATE =>
				        state <= WAIT_INTERVAL_STATE;
				    when WAIT_INTERVAL_STATE =>
				        if (FULL_SW = '1' and SAMPLE_SW = '1') then
				            state <= BRAM_FULL_STATE;
				        elsif (FULL_SW = '0' and SAMPLE_SW = '1' and 
				        (FORCED_MODE_SW = '1' or CHANNEL1_TRIG_SW = '0' or STORE_SW = '1')) then
				            state <= BEGIN_CONV_STATE;
				        elsif (FULL_SW = '0' and SAMPLE_SW = '1' and
				        FORCED_MODE_SW = '0' and CHANNEL1_TRIG_SW = '1' and STORE_SW = '0') then
				            state <= SET_STORE_STATE;
				        end if;
				    when BRAM_FULL_STATE =>
				        if (FORCED_MODE_SW = '1') then
				            state <= WAIT_FORCED_STATE;
				        else
				            state <= CLEAR_STORE_STATE;
				        end if;
				end case;
			end if;
		end if;
	end process;

	-------------------------------------------------------------------------------
    -- Dedicated Control Word spreadsheet
    -------------------------------------------------------------------------------
	output_process: process (state)
	begin
		case state is		
            when RESET_STATE  =>  cw <= '1'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"11"&"11"&"00"&"11"&"11";
            when LONG_DELAY_STATE  =>  cw <= '0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"00"&"00"&"00"&"10"&"11";
            when RESET_ADC_STATE  =>  cw <= '0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'1'&"00"&"00"&"00"&"00"&"10";
            when WAIT_FORCED_STATE  =>  cw <= '0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"00"&"00"&"00"&"00"&"00";
            when SET_STORE_STATE  =>  cw <= '0'&'1'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"11"&"00"&"00"&"00"&"00";
            when CLEAR_STORE_STATE  =>  cw <= '1'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"11"&"00"&"00"&"00"&"00";
            when BEGIN_CONV_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'1'&'0'&'0'&'1'&'1'&'1'&'0'&"00"&"11"&"00"&"00"&"11";
            when ASSERT_CONVST_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'0'&'1'&'1'&'0'&"00"&"10"&"00"&"00"&"10";
            when BUSY0_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"00"&"10"&"00"&"00"&"00";
            when BUSY1_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"00"&"10"&"00"&"00"&"11";
            when READ_CH1_LOW_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&"00"&"10"&"00"&"00"&"10";
            when WRITE_CH1_TRIG_STATE  =>  cw <= '0'&'0'&'0'&'1'&'1'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&"00"&"10"&"00"&"00"&"11";
            when WRITE_CH1_BRAM_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'1'&'1'&'0'&'0'&'0'&"00"&"10"&"00"&"00"&"11";
            when READ_CH1_HIGH_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'1'&'0'&'0'&"00"&"10"&"00"&"00"&"10";
            when RESET_SHORT_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'1'&'0'&'0'&"00"&"10"&"00"&"00"&"11";
            when READ_CH2_LOW_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&"00"&"10"&"00"&"00"&"10";
            when WRITE_CH2_TRIG_STATE  =>  cw <= '0'&'0'&'1'&'0'&'1'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&"00"&"10"&"00"&"00"&"11";
            when WRITE_CH2_BRAM_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'1'&'0'&'1'&'0'&'0'&'0'&"00"&"10"&"00"&"00"&"11";
            when READ_CH2_HIGH_STATE  =>  cw <= '0'&'0'&'0'&'0'&'1'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"10"&"10"&"00"&"00"&"00";
            when WAIT_INTERVAL_STATE  =>  cw <= '0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"00"&"10"&"00"&"00"&"00";
            when BRAM_FULL_STATE  =>  cw <= '0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'1'&'1'&'1'&'0'&"11"&"00"&"00"&"00"&"00";
		end case;
	end process;	                       

end Behavioral;



