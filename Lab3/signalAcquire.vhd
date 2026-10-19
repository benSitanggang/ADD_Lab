--------------------------------------------------------------------
-- Name:	Chris Coulston
-- Date:	Fall 2022
-- File:	signalAcquire.vhd
--
-- Purp: Tie the datapath and control unit together
--
-- Documentation:	No help
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.basicBuildingBlocks_package.all;
use work.signalAcquire_Package.all;


entity signalAcquire is
    PORT ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
		   btn: in	STD_LOGIC_VECTOR(2 downto 0);
		   an7606data: in STD_LOGIC_VECTOR(15 downto 0);
		   an7606convst, an7606cs, an7606rd, an7606reset: out STD_LOGIC;
		   an7606od: out STD_LOGIC_VECTOR(2 downto 0);
		   an7606busy : in STD_LOGIC;
		   reg0Magnitude: out STD_LOGIC_VECTOR(3 downto 0));		   
end signalAcquire;

architecture behavior of signalAcquire is
	signal sw: STD_LOGIC_VECTOR(SW_WIDTH - 1 downto 0);
    signal cw: STD_LOGIC_VECTOR(CW_WIDTH - 1 downto 0);
    signal datapath_sw: STD_LOGIC_VECTOR(DATAPATH_SW_WIDTH - 1 downto 0);
    signal rfData: STD_LOGIC_VECTOR(15 downto 0);
    signal trigger, conversionButton, prevButton: STD_LOGIC;
begin
    
    sw(START_CONV_SW_BIT_INDEX) <= trigger;
    sw(BUSY_SW_BIT_INDEX) <= an7606busy;
    sw(DATAPATH_SW_WIDTH - 1 downto 0) <= datapath_sw;
    conversionButton <= btn(0);
    an7606convst <= cw(CONVST_CW_BIT_INDEX);
    an7606rd <= cw(RD_CW_BIT_INDEX);
    an7606cs <= cw(CS_CW_BIT_INDEX);
    an7606reset <= cw(RESET_AD7606_CW_BIT_INDEX);
    an7606od <= "000";
    
    controlUnit: signalAcquire_Fsm
	   port map(
	       clk => clk,
	       resetn => resetn,
	       sw => sw,
	       cw => cw
	   );
	   
    datapath: signalAcquire_Datapath
        port map(
            clk => clk,
            resetn => resetn,
            cw => cw,
            sw => datapath_sw,
            an7606data => an7606data,
            rfAddr => "000",
            rfData => rfData
        );
    
    buttonProcess: process(clk)
    begin
        if (rising_edge(clk)) then
            prevButton <= conversionButton;
            if (prevButton = '0' and conversionButton = '1') then
                trigger <= '1';
            else
                trigger <= '0';
            end if;
        end if;
    end process;
    
    compare1: genericCompare
        generic map(16)
        port map(
            x => rfData,
            y => FIRST_THRESHOLD_CONSTANT,
            g => open,
            l => reg0Magnitude(0),
            e => open
        );
        
    compare2: genericCompare
        generic map(16)
        port map(
            x => rfData,
            y => SECOND_THRESHOLD_CONSTANT,
            g => open,
            l => reg0Magnitude(1),
            e => open
        );
        
    compare3: genericCompare
        generic map(16)
        port map(
            x => rfData,
            y => THIRD_THRESHOLD_CONSTANT,
            g => open,
            l => reg0Magnitude(2),
            e => open
        );
        
    compare4: genericCompare
        generic map(16)
        port map(
            x => rfData,
            y => FOURTH_THRESHOLD_CONSTANT,
            g => open,
            l => reg0Magnitude(3),
            e => open
        );
 
end behavior;
