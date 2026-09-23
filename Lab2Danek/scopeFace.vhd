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
         ch1enb: in STD_LOGIC;
         ch2: in STD_LOGIC;
         ch2enb: in STD_LOGIC);
end scopeFace;


architecture Behavioral of scopeFace is

    -- Set these signals to '1' when the features should be drawn at the current pixelHorz, pixelVert 
    -- cordinate.  These act like Feature Booleans which you will use in the process(clk) to set the 
    -- correct RGB for this pixel location. Finish and add more.
    signal borderH, borderV : STD_LOGIC;
    signal gridH, gridV: STD_LOGIC;
    signal hatchH, hatchV: STD_LOGIC;
    signal timeMarker, voltMarker: STD_LOGIC;

begin
    -- Left and Right edges
    borderV <= '1' when ((pixelV < L_EDGE + BORDER_LINE_WIDTH and pixelV >= L_EDGE) or (pixelV > R_EDGE - BORDER_LINE_WIDTH and pixelV <= R_EDGE)) else '0';
    -- Top and Bottom edges
    borderH <= '1' when ((pixelH = T_EDGE) or (pixelH = B_EDGE)) else '0';
    -- every 100 horizontal bits draw the vertical hatch
    gridV <= '1' when ((pixelH > L_EDGE) and (pixelH < R_EDGE) and (unsigned(pixelH - L_EDGE) mod 100 = 0)) else '0';
    -- every 50 vertical bits draw the horizontal line
    gridH <= '1' when ((pixelV > T_EDGE) and (pixelV < B_EDGE) and (unsigned(pixelV - T_EDGE) mod 50 = 0)) else '0';
    -- On middle grid lines, every 20 horizontal bits draw the vertical hatch    
    hatchV <= '1' when ((pixelV = M_VERT) and (pixelH > L_EDGE) and (pixelH < R_EDGE) and (unsigned(pixelH - L_EDGE) mod 20 = 0)) else '0';
    -- On middle grid lines, every 20 horizontal bits draw the horizontal hatch    
    hatchH <= '1' when ((pixelH = M_HORZ) and (pixelV > T_EDGE) and (pixelV < B_EDGE) and (unsigned(pixelV - T_EDGE) mod 10 = 0)) else '0';

    -- For triggerTime and triggerVolt -> should we assume they are unitless and scale with the pixel count (also no changing the scale of our oscope?)
    -- Same for ch1 and ch2 centered on the centerline?

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
                elsif (ch1 = '1' and ch1enb = '1') then
                    red <= CH1_R;
                    green <= CH1_G;
                    blue <= CH1_B;
                elsif (ch2 = '1' and ch2enb = '1') then
                    red <= CH2_R;
                    green <= CH2_G;
                    blue <= CH2_B;
                elsif ((gridH = '1') or (gridV = '1')) then
                    red <= GRID_R;
                    green <= GRID_G;
                    blue <= GRID_B;
                elsif ((hatchH = '1') or (hatchV = '1')) then
                    red <= HATCH_R;
                    green <= HATCH_G;
                    blue <= HATCH_B;         
                else
                    red <= X"00";
                    green <= X"00";
                    blue <= X"00";
                end if;
            end if;
        end if;
    end process;
  

end Behavioral;


