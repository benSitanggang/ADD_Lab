--------------------------------------------------------------------
-- Name:	Chris Coulston
-- Date:	Feb 3, 2015
-- Modified:	Sept 2022
-- File:	lab2_datapath.vhdl
-- HW:	Lab 2
--	Crs:	ECE 383 and EENG 498
--
-- Purp: The datapath for the audio O'scope
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
use work.basicBuildingBlocks_package.all;
use work.signalAcquire_Package.all;

entity signalAcquire_Datapath is
    PORT ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
		   cw : in STD_LOGIC_VECTOR(CW_WIDTH -1 downto 0);
		   sw : out STD_LOGIC_VECTOR(DATAPATH_SW_WIDTH - 1 downto 0);
		   an7606data: in STD_LOGIC_VECTOR(15 downto 0);
		   rfAddr: in STD_LOGIC_VECTOR(2 downto 0);
		   rfData: out STD_LOGIC_VECTOR(15 downto 0) );
end signalAcquire_Datapath;

architecture behavior of signalAcquire_Datapath is

  	signal rfWrite, rfFull, eqShort, eqLong: STD_LOGIC;
  	signal addrCnt: STD_LOGIC_VECTOR(3 downto 0);
  	signal addrCtrl, shortCtrl, longCtrl: STD_LOGIC_VECTOR(1 downto 0);
  	signal shortCnt: STD_LOGIC_VECTOR(SHORT_DELAY_50Mhz_CONST_WIDTH - 1 downto 0);
  	signal longCnt: STD_LOGIC_VECTOR(LONG_DELAY_50Mhz_CONST_WIDTH - 1 downto 0);

begin
    -- TODO: CSAs for cw and sw
    channelRF: generic8RegisterFile
        generic map(16)
        port map(
            clk => clk, 
            resetn => resetn,
            write => rfWrite,
            wrAddr => addrCnt(2 downto 0),
            rdAddr => rfAddr,
            D => an7606data,
            Q => rfData
        );
    
    addrCounter: genericCounter
        generic map(4)
        port map(
            clk => clk,
            resetn => resetn,
            c => addrCtrl,
            d => "0000",
            q => addrCnt
        );
        
    rfFullCompare: genericCompare
        generic map(4)
        port map(
            x => addrCnt,
            y => "0111",
            g => open,
            l => open,
            e => rfFull
        );

    shortCounter: genericCounter
        generic map(SHORT_DELAY_50Mhz_CONST_WIDTH)
        port map(
            clk => clk,
            resetn => resetn,
            c => shortCtrl,
            d => x"00",
            q => shortCnt
        );

    shortCompare: genericCompare
        generic map(SHORT_DELAY_50Mhz_CONST_WIDTH)
        port map(
            x => shortCnt,
            y => SHORT_DELAY_50Mhz_COUNTS,
            g => open,
            l => open,
            e => eqShort
        );

    longCounter: genericCounter
        generic map(LONG_DELAY_50Mhz_CONST_WIDTH)
        port map(
            clk => clk,
            resetn => resetn,
            c => longCtrl,
            d => x"00",
            q => longCnt
        );

    longCompare: genericCompare
        generic map(LONG_DELAY_50Mhz_CONST_WIDTH)
        port map(
            x => longCnt,
            y => LONG_DELAY_50Mhz_COUNTS,
            g => open,
            l => open,
            e => eqLong
        );

end behavior;
