----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use work.scopeToHdmi_package.all;

entity scopeToHdmi is
    PORT ( sysClk : in  STD_LOGIC;
         resetn : in  STD_LOGIC;
         btn: in	STD_LOGIC_VECTOR(2 downto 0);
         tmdsDataP : out  STD_LOGIC_VECTOR (2 downto 0);
         tmdsDataN : out  STD_LOGIC_VECTOR (2 downto 0);
         tmdsClkP : out STD_LOGIC;
         tmdsClkN : out STD_LOGIC;
         hdmiOen:    out STD_LOGIC);
end scopeToHdmi;


architecture structure of scopeToHdmi is
    signal h_sync, v_sync, vde: STD_LOGIC;
    signal red, green, blue: STD_LOGIC_VECTOR(7 downto 0);
    signal triggerTime, triggerVolt: STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);
    signal pixelH, pixelV: STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);
    signal ch1Wave, ch2Wave: STD_LOGIC;
    signal videoClk, videoClk5x, clkLocked: STD_LOGIC;
    signal reset: STD_LOGIC;
begin


    vsg: videoSignalGenerator
        PORT MAP (
                    clk => videoClk,
                    resetn => resetn,
                    hs => h_sync,
                    vs => v_sync,
                    de => vde,
                    pixelHorz => pixelH,
                    pixelVert => pixelV
                    );
                 

    sf: scopeFace
        PORT MAP (
                    clk => videoClk,
                    resetn => resetn,
                    pixelH => pixelH,
                    pixelV => pixelV,
                    triggerTime => triggerTime,
                    triggerVolt => triggerVolt,
                    ch1 => ch1Wave,
                    ch1enb => '1',
                    ch2 => ch2Wave,
                    ch2enb => '1',
                    red => red,
                    green => green,
                    blue => blue
                    );
                 

    hdmi_inst: hdmi_tx_0
        PORT MAP (
            pix_clk => videoClk,
            pix_clkx5 => videoClk5x,
            rst => reset,
            hsync => h_sync,
            vsync => v_sync,
            vde => vde,
            pix_clk_locked => clkLocked,
            red => red,
            green => green,
            blue => blue,
            TMDS_DATA_P => tmdsDataP,
            TMDS_DATA_N => tmdsDataN,
            TMDS_CLK_P => tmdsClkP,
            TMDS_CLK_N => tmdsClkN,
            aux0_din => "0000",
            aux1_din => "0000",
            aux2_din => "0000",
            ade => '0'
            );
            

    vc: clk_wiz_0
	PORT MAP( 
	    clk_out1 => videoClk,
	    clk_out2 => videoClk5x,
	    resetn => resetn,
	    locked => clkLocked,
	    clk_in1 => sysClk);

    ------------------------------------------------------------------------------
    -- Create a process which generates a 3-bit vector which shows if button
    -- has change state.  Use this change vector to determine if you should 
    -- increment/decrement the triggerTime or triggerVolt values
    ------------------------------------------------------------------------------
 
    process(videoClk)
        constant STEP : STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0) := std_logic_vector(to_unsigned(10, VIDEO_WIDTH_IN_BITS));
        variable prevBtnState : STD_LOGIC_VECTOR(2 downto 0);
        -- 2: PL_KEY4, 1: PL_KEY3, 0: PL_KEY2
        -- When PL_KEY2 is held -> decrement, else increment
        variable currBtnState : STD_LOGIC_VECTOR(2 downto 0);
    begin
        if rising_edge (videoClk) then
            if (resetn = '0') then
                prevBtnState := (others => '1');
                currBtnState := (others => '1');
                triggerTime <= M_HORZ;
                triggerVolt <= M_VERT;
            else
                currBtnState := btn;
                -- decrement triggerTime
                if (prevBtnState(2) = '0' and currBtnState(2) = '1' and currBtnState(0) = '0') then
                    if (triggerTime - STEP > L_EDGE) then
                        triggerTime <= triggerTime - STEP;
                    end if;
                -- increment triggerTime
                elsif (prevBtnState(2) = '0' and currBtnState(2) = '1' and currBtnState(0) = '1') then
                    if (triggerTime + STEP < R_EDGE) then
                        triggerTime <= triggerTime + STEP;
                    end if;
                -- decrement triggerVolt
                elsif (prevBtnState(1) = '0' and currBtnState(1) = '1' and currBtnState(0) = '0') then
                    if (triggerVolt + Step < B_EDGE) then
                        triggerVolt <= triggerVolt + STEP;
                    end if;
                -- increment triggerVolt
                elsif (prevBtnState(1) = '0' and currBtnState(1) = '1' and currBtnState(0) = '1') then
                    if (triggerVolt - Step > T_EDGE) then
                        triggerVolt <= triggerVolt - STEP;
                    end if;
                end if;
                prevBtnState := currBtnState;
            end if;
        end if;
    end process;
    
    hdmiOen <= '1';
    reset <= not resetn;
    ch1Wave <= '1' when  (pixelH = pixelV) else '0';
    ch2Wave <= '1' when  (pixelV = triggerVolt) else '0';

end structure;
