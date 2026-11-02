--------------------------------------------------------------------
-- Name:	Chris Coulston
-- Date:	Feb 3, 2015
-- Modified:	Sept 2022
-- File:	acquireToHDMI_Datapath.vhdl
-- HW:		Lab 3
-- Crs:		ECE 383 and EENG 484
--
-- Purp: The complete datapath for the audio O'scope
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
use IEEE.NUMERIC_STD.ALL;

use work.acquireToHDMI_package.all;	
use work.scopeToHdmi_package.all;		
use work.basicBuildingBlocks_package.all;

entity acquireToHDMI_datapath is
    PORT ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
		   cw : in STD_LOGIC_VECTOR(CW_WIDTH -1 downto 0);
		   sw : out STD_LOGIC_VECTOR(DATAPATH_SW_WIDTH - 1 downto 0);
		   an7606data: in STD_LOGIC_VECTOR(15 downto 0);

           triggerVolt16bitSigned: in SIGNED(15 downto 0);
		   triggerTimePixel: in STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0);
		   ch1Data16bitSLV, ch2Data16bitSLV: out STD_LOGIC_VECTOR(15 downto 0);
		   
		   tmdsDataP : out  STD_LOGIC_VECTOR (2 downto 0);
           tmdsDataN : out  STD_LOGIC_VECTOR (2 downto 0);
           tmdsClkP : out STD_LOGIC;
           tmdsClkN : out STD_LOGIC;
           hdmiOen:    out STD_LOGIC
		   );
end acquireToHDMI_datapath;

architecture behavior of acquireToHDMI_datapath is

    signal storeIntoBramFlag, bramFull, sample: STD_LOGIC;
    signal videoClk, videoClk5x, hs, vs, de, clkLocked: std_logic;
    signal ch1, ch2, ch1Trig, ch2Trig: std_logic;
    signal short, long, reset: std_logic;
    signal pixelH, pixelV, wrAddr: STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0);
    signal trigVscr: STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0);
    signal red, green, blue: STD_LOGIC_VECTOR(7 downto 0);
    signal ch1doutb, ch2doutb: std_logic_vector(15 downto 0);
    signal ch1pixel, ch2pixel: std_logic_vector(VIDEO_WIDTH_IN_BITS-1 downto 0);
    signal longCount: std_logic_vector(LONG_DELAY_50Mhz_CONST_WIDTH-1 downto 0);
    signal shortCount: std_logic_vector(SHORT_DELAY_50Mhz_CONST_WIDTH-1 downto 0);
    signal sampleCount, sampleRate: std_logic_vector(31 downto 0);
    
begin

    -- Simple SR Latch to assist FSM
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(resetn ='0') then
                storeIntoBramFlag <= '0';
            elsif (cw(SET_STORE_FLAG_CW_BIT_INDEX) = '1') then
                storeIntoBramFlag <= '1';
            elsif (cw(CLEAR_STORE_FLAG_CW_BIT_INDEX) = '1') then
                storeIntoBramFlag <= '0';
            end if;
        end if;
    end process;

    sw(STORE_SW_BIT_INDEX) <= storeIntoBramFlag;
    
    vsg: videoSignalGenerator
        port map(
            clk => videoClk,
            resetn => resetn,
            hs => hs,
            vs => vs,
            de => de,
            pixelHorz => pixelH,
            pixelVert => pixelV
        );
    
    scopeFace_inst: scopeFace
        port map(
            clk => videoClk,
            resetn => resetn,
            pixelH => pixelH,
            pixelV => pixelV,
            triggerTime => triggerTimePixel,
            triggerVolt => trigVscr,
            ch1 => ch1,
            ch1enb => '1',
            ch2 => ch2,
            ch2enb => '1',
            red => red,
            green => green,
            blue => blue
        );
   
    -- BRAM Write Address Counter
    wrAddrCounter: genericCounter
        generic map(VIDEO_WIDTH_IN_BITS)
        port map(
            clk => clk,
            resetn => resetn,
            c => cw(DATA_STORAGE_COUNTER_CW_MSB_INDEX downto DATA_STORAGE_COUNTER_CW_MSB_INDEX-1),
            d => (others => '0'),
            q => wrAddr
        );
     
    -- BRAM Full Compare
    fullCompare: genericCompare
        generic map(VIDEO_WIDTH_IN_BITS)
        port map(
            x => wrAddr,
            y => WIDTH,
            g => bramFull,
            l => open,
            e => open
        );
    
    sw(FULL_SW_BIT_INDEX) <= bramFull;
    
    -- Trigger generators
    ch1TrigGen: trigGenerator
        port map(
            clk => clk,
            resetn => resetn,
            an7606data => an7606data,
            signedTrigVolt16 => triggerVolt16bitSigned,
            regCtrl => cw(TRIG_CH1_WRITE_CW_BIT_INDEX),
            slvData16 => ch1Data16bitSLV,
            trigger => ch1Trig
        );
        
    sw(CHANNEL1_TRIG_SW_BIT_INDEX) <= ch1Trig;
    
    ch2TrigGen: trigGenerator
        port map(
            clk => clk,
            resetn => resetn,
            an7606data => an7606data,
            signedTrigVolt16 => triggerVolt16bitSigned,
            regCtrl => cw(TRIG_CH2_WRITE_CW_BIT_INDEX),
            slvData16 => ch2Data16bitSLV,
            trigger => ch2Trig
        );
        
    sw(CHANNEL2_TRIG_SW_BIT_INDEX) <= ch2Trig;
   
    -- signedToPixel & pixel compare instances
    ch1SignedToPix: signedToPixelV
        port map(
            signedValue => ch1doutb,
            vertPixel => ch1pixel
        );
        
    ch1Generator: genericCompare
        generic map(VIDEO_WIDTH_IN_BITS)
        port map(
            x => ch1pixel,
            y => pixelV,
            g => open,
            l => open,
            e => ch1
        );
        
    ch2SignedToPix: signedToPixelV
        port map(
            signedValue => ch2doutb,
            vertPixel => ch2pixel
        );
    
    ch2Generator: genericCompare
        generic map(VIDEO_WIDTH_IN_BITS)
        port map(
            x => ch2pixel,
            y => pixelV,
            g => open,
            l => open,
            e => ch2
        );
        
    trigSignedToPix: signedToPixelV
        port map(
            signedValue => std_logic_vector(triggerVolt16bitSigned),
            vertPixel => trigVscr
        );
      
    -- clock wizard
    vc: clk_wiz_0
        PORT MAP (
            clk_in1 => clk,
            clk_out1 => videoClk,
            resetn => resetn,
            clk_out2 => videoClk5x,
            locked => clkLocked
        );
        
    -- HDMI instantiation
    reset <= not resetn;
    
    hdmi_inst: hdmi_tx_0
        port map(
            pix_clk => videoClk,
            pix_clkx5 => videoClk5x,
            pix_clk_locked => clkLocked,
            rst => reset,
            red => red,
            green => green,
            blue => blue,
            hsync => hs,
            vsync => vs,
            vde => de,
            aux0_din => "0000",
            aux1_din => "0000",
            aux2_din => "0000",
            ade => '0',
            TMDS_CLK_P => tmdsClkP,
            TMDS_CLK_N => tmdsClkN,
            TMDS_DATA_P => tmdsDataP,
            TMDS_DATA_N => tmdsDataN
        );
     
    hdmiOen <= '1';

    -- long counter/compare pair
    longCounter: genericCounter
        generic map(LONG_DELAY_50Mhz_CONST_WIDTH)
        port map(
            clk => clk,
            resetn => resetn,
            c => cw(LONG_DELAY_COUNTER_CW_MSB_INDEX downto LONG_DELAY_COUNTER_CW_MSB_INDEX-1),
            d => x"000000",
            q => longCount
        );
    
    longCompare: genericCompare
        generic map(LONG_DELAY_50Mhz_CONST_WIDTH)
        port map(
            x => longCount,
            y => LONG_DELAY_50Mhz_COUNTS,
            g => open,
            l => open,
            e => long
        );
    
    sw(LONG_SW_BIT_INDEX) <= long;
    
    -- short counter/compare pair
    shortCounter: genericCounter
        generic map(SHORT_DELAY_50Mhz_CONST_WIDTH)
        port map(
            clk => clk,
            resetn => resetn,
            c => cw(SHORT_DELAY_COUNTER_CW_MSB_INDEX downto SHORT_DELAY_COUNTER_CW_MSB_INDEX-1),
            d => x"00",
            q => shortCount
        );
    
    shortCompare: genericCompare
        generic map(SHORT_DELAY_50Mhz_CONST_WIDTH)
        port map(
            x => shortCount,
            y => SHORT_DELAY_50Mhz_COUNTS,
            g => open,
            l => open,
            e => short
        );
        
    sw(SHORT_SW_BIT_INDEX) <= short;
    
    -- Sample rate generator blocks
    sampleCounter: genericCounter
        generic map(32)
        port map(
            clk => clk,
            resetn => resetn,
            c => cw(SAMPLING_COUNTER_CW_MSB_INDEX downto SAMPLING_COUNTER_CW_MSB_INDEX-1),
            d => (others => '0'),
            q => sampleCount
        );
    
    rateMux: genericMux4x1
        generic map(32)
        port map(
            y3 => LOWEST_RATE,
            y2 => LOW_RATE,
            y1 => HIGH_RATE,
            y0 => HIGHEST_RATE,
            s => cw(SAMPLING_RATE_SELECT_CW_MSB_INDEX downto SAMPLING_RATE_SELECT_CW_MSB_INDEX-1),
            f => sampleRate
        );
    
    sampleCompare: genericCompare
        generic map(32)
        port map(
            x => sampleCount,
            y => sampleRate,
            g => open,
            l => open,
            e => sample
        );
    
    sw(SAMPLE_SW_BIT_INDEX) <= sample;    

end behavior;
