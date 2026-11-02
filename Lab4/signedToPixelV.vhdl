-------
-- Convert signed 16 bit value to a vertical pixel value
-------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.scopeToHdmi_package.all;

entity signedToPixelV is
    port(
        signedValue: in std_logic_vector(15 downto 0);
        vertPixel: out STD_LOGIC_VECTOR(VIDEO_WIDTH_IN_BITS-1 downto 0)
    );
end signedToPixelV;

architecture structure of signedToPixelV is

    signal aSigned16, bSigned16, pixelSigned16: signed(15 downto 0);
    signal xSigned32, ySigned32, zSigned32: signed(31 downto 0);
    
begin
    aSigned16 <= signed(signedValue);
    bSigned16 <= to_signed(-500, 16); -- replace this value
    xSigned32 <= aSigned16 * bSigned16;
    ySigned32 <= shift_right(xSigned32, 16);
    zSigned32 <= ySigned32 + to_signed(360, 32); -- replace this value
    vertPixel <= std_logic_vector(zSigned32(VIDEO_WIDTH_IN_BITS-1 downto 0));
end structure;