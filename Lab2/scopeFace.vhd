----------------------------------------------------------------------------------
-- Include proper comment header block
-- ***Do not use mod operator in this code***
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.scopeToHdmi_package.all;

entity scopeFace is
    PORT ( 	clk: in  STD_LOGIC;
         resetn : in  STD_LOGIC;
         pixelH : in  STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS - 1 downto 0);
         pixelV : in  STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS -1 downto 0);
         triggerVolt: in STD_LOGIC_VECTOR (VIDEO_WIDTH_IN_BITS - 1 downto 0);
         triggerTime: in STD_LOGIC_VECTOR (VIDEO_WIDTH_IN_BITS - 1 downto 0);
         red : out  STD_LOGIC_VECTOR(7 downto 0);
         green : out  STD_LOGIC_VECTOR(7 downto 0);
         blue : out  STD_LOGIC_VECTOR(7 downto 0);
         ch1: in STD_LOGIC;
         ch1Enb: in STD_LOGIC;
         ch2: in STD_LOGIC;
         ch2Enb: in STD_LOGIC);
end scopeFace;


architecture Behavioral of scopeFace is

    -- Set these signals to '1' when the features should be drawn at the current pixelHorz, pixelVert 
    -- cordinate.  These act like Feature Booleans which you will use in the process(clk) to set the 
    -- correct RGB for this pixel location. Finish and add more.
    signal borderH, borderV : STD_LOGIC;
    signal gridH : STD_LOGIC;
    signal gridV : STD_LOGIC;
    signal timeMarker : STD_LOGIC;
    signal voltMarker : STD_LOGIC;
    signal hatchH : STD_LOGIC;
    signal hatchV : STD_LOGIC;
    



begin

-- Left and Right edges
borderV <= '1' when ((pixelV < L_EDGE + BORDER_LINE_WIDTH and pixelV >= L_EDGE) or (pixelV > R_EDGE - BORDER_LINE_WIDTH and pixelV <= R_EDGE)) else '0';
-- Top and Bottom edges
borderH <= '1' when ((pixelH = T_EDGE) or (pixelH = B_EDGE)) else '0';

voltMarker <= '1' when (pixelH = L_EDGE + BORDER_LINE_WIDTH + 1 and pixelV <= triggerVolt + 7 and pixelV >= triggerVolt - 7)
or (pixelH = L_EDGE + BORDER_LINE_WIDTH + 2 and pixelV <= triggerVolt + 6 and pixelV >= triggerVolt - 6)
or (pixelH = L_EDGE + BORDER_LINE_WIDTH + 3 and pixelV <= triggerVolt + 5 and pixelV >= triggerVolt - 5)
or (pixelH = L_EDGE + BORDER_LINE_WIDTH + 4 and pixelV <= triggerVolt + 4 and pixelV >= triggerVolt - 4)
or (pixelH = L_EDGE + BORDER_LINE_WIDTH + 5 and pixelV <= triggerVolt + 3 and pixelV >= triggerVolt - 3)
or (pixelH = L_EDGE + BORDER_LINE_WIDTH + 6 and pixelV <= triggerVolt + 2 and pixelV >= triggerVolt - 2)
or (pixelH = L_EDGE + BORDER_LINE_WIDTH + 7 and pixelV <= triggerVolt + 1 and pixelV >= triggerVolt - 1)
or (pixelH = L_EDGE + BORDER_LINE_WIDTH + 8 and pixelV <= triggerVolt + 0 and pixelV >= triggerVolt - 0)
else '0';

timeMarker <= '1' when (pixelV = T_EDGE + BORDER_LINE_WIDTH + 1 and pixelH <= triggerTime + 7 and pixelH >= triggerTime - 7)
or (pixelV = T_EDGE + BORDER_LINE_WIDTH + 2 and pixelH <= triggerTime + 6 and pixelH >= triggerTime - 6)
or (pixelV = T_EDGE + BORDER_LINE_WIDTH + 3 and pixelH <= triggerTime + 5 and pixelH >= triggerTime - 5)
or (pixelV = T_EDGE + BORDER_LINE_WIDTH + 4 and pixelH <= triggerTime + 4 and pixelH >= triggerTime - 4)
or (pixelV = T_EDGE + BORDER_LINE_WIDTH + 5 and pixelH <= triggerTime + 3 and pixelH >= triggerTime - 3)
or (pixelV = T_EDGE + BORDER_LINE_WIDTH + 6 and pixelH <= triggerTime + 2 and pixelH >= triggerTime - 2)
or (pixelV = T_EDGE + BORDER_LINE_WIDTH + 7 and pixelH <= triggerTime + 1 and pixelH >= triggerTime - 1)
or (pixelV = T_EDGE + BORDER_LINE_WIDTH + 8 and pixelH <= triggerTime + 0 and pixelH >= triggerTime - 0)
else '0';

gridH <= '1' when pixelH >= L_EDGE and pixelH <= R_EDGE and (
    pixelV = 110
    or pixelV = 160
    or pixelV = 210
    or pixelV = 260
    or pixelV = 310
    or pixelV = 360
    or pixelV = 410
    or pixelV = 460
    or pixelV = 510
    or pixelV = 560
) else '0';

gridV <= '1' when pixelV >= T_EDGE and pixelV <= B_EDGE and (
    pixelH = 140
    or pixelH = 240
    or pixelH = 340
    or pixelH = 440
    or pixelH = 540
    or pixelH = 640
    or pixelH = 740
    or pixelH = 840
    or pixelH = 940
    or pixelH = 1040
) else '0';

hatchH <= '1' when (pixelV <= 363) and (pixelV >= 357) and
    (
        pixelH = 140
        or pixelH = 160
        or pixelH = 180
        or pixelH = 200
        or pixelH = 220
        or pixelH = 240
        or pixelH = 260
        or pixelH = 280
        or pixelH = 300
        or pixelH = 320
        or pixelH = 340
        or pixelH = 360
        or pixelH = 380
        or pixelH = 400
        or pixelH = 420
        or pixelH = 440
        or pixelH = 460
        or pixelH = 480
        or pixelH = 500
        or pixelH = 520
        or pixelH = 540
        or pixelH = 560
        or pixelH = 580
        or pixelH = 600
        or pixelH = 620
        or pixelH = 640
        or pixelH = 660
        or pixelH = 680
        or pixelH = 700
        or pixelH = 720
        or pixelH = 740
        or pixelH = 760
        or pixelH = 780
        or pixelH = 800
        or pixelH = 820
        or pixelH = 840
        or pixelH = 860
        or pixelH = 880
        or pixelH = 900
        or pixelH = 920
        or pixelH = 940
        or pixelH = 960
        or pixelH = 980
        or pixelH = 1000
        or pixelH = 1020
        or pixelH = 1040
        or pixelH = 1060
        or pixelH = 1080
        or pixelH = 1100
        or pixelH = 1120
    )
    else '0';

hatchV <= '1' when (pixelH <= 643) and (pixelH >= 637) and
    (
        pixelV = 110
        or pixelV = 120
        or pixelV = 130
        or pixelV = 140
        or pixelV = 150
        or pixelV = 160
        or pixelV = 170
        or pixelV = 180
        or pixelV = 190
        or pixelV = 200
        or pixelV = 210
        or pixelV = 220
        or pixelV = 230
        or pixelV = 240
        or pixelV = 250
        or pixelV = 260
        or pixelV = 270
        or pixelV = 280
        or pixelV = 290
        or pixelV = 300
        or pixelV = 310
        or pixelV = 320
        or pixelV = 330
        or pixelV = 340
        or pixelV = 350
        or pixelV = 360
        or pixelV = 370
        or pixelV = 380
        or pixelV = 390
        or pixelV = 400
        or pixelV = 410
        or pixelV = 420
        or pixelV = 430
        or pixelV = 440
        or pixelV = 450
        or pixelV = 460
        or pixelV = 470
        or pixelV = 480
        or pixelV = 490
        or pixelV = 500
        or pixelV = 510
        or pixelV = 520
        or pixelV = 530
        or pixelV = 540
        or pixelV = 550
        or pixelV = 560
        or pixelV = 570
        or pixelV = 580
        or pixelV = 590
        or pixelV = 600
    )
    else '0';


    ---------------------------------------------------------------------
    -- Use the Feature Booleans to set the RGB at this pixel location.
    -- The waveforms should sit "on top" of the grid.
    ---------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge (clk) then
            if resetn = '0' then
                red <= (others => '0');
                green <= (others => '0');
                blue <= (others => '0');
            else
                if ((borderH = '1') or (borderV = '1')) then
                    red <= BORDER_R;
                    green <= BORDER_G;
                    blue <= BORDER_B;
                elsif (ch1 = '1' and ch1Enb = '1') then
                    red <= CH1_R;
                    green <= CH1_G;
                    blue <= CH1_B;
                elsif (ch2 = '1' and ch2Enb = '1') then
                    red <= CH2_R;
                    green <= CH2_G;
                    blue <= CH2_B;
                elsif (voltMarker = '1' or timeMarker = '1') then
                    red <= TRIGGER_R;
                    green <= TRIGGER_G;
                    blue <= TRIGGER_B;
                elsif (hatchV = '1' or hatchH = '1') then
                    red <= GRID_R;
                    green <= GRID_G;
                    blue <= GRID_B;
                elsif (gridV = '1' or gridH = '1') then
                    red <= GRID_R;
                    green <= GRID_G;
                    blue <= GRID_B;
                else
                    red <= X"00";
                    green <= X"00";
                    blue <= X"00";
                end if;
            end if;
        end if;
    end process;
  

end Behavioral;


