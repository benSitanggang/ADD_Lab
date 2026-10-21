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
		   cw : in STD_LOGIC_VECTOR(CW_WIDTH - 1 downto 0);
		   sw : out STD_LOGIC_VECTOR(DATAPATH_SW_WIDTH - 1 downto 0);
		   an7606data: in STD_LOGIC_VECTOR(15 downto 0);
		   rfAddr: in STD_LOGIC_VECTOR(2 downto 0);
		   rfData: out STD_LOGIC_VECTOR(15 downto 0) );
end signalAcquire_Datapath;

architecture behavior of signalAcquire_Datapath is
    signal longCtrl, shortCtrl, AddrCtrl : STD_LOGIC_VECTOR(1 downto 0);
    signal longStartValue, longCount : STD_LOGIC_VECTOR(LONG_DELAY_50Mhz_CONST_WIDTH - 1 downto 0);
    signal shortStartValue, shortCount : STD_LOGIC_VECTOR(SHORT_DELAY_50Mhz_CONST_WIDTH - 1 downto 0);
    signal rfWrite : STD_LOGIC;
    signal AddrCnt : STD_LOGIC_VECTOR(3 downto 0);

begin
    rfWrite <= cw(REG_FILE_WRITE_CW_BIT_INDEX);
    AddrCtrl <= cw(WR_ADDRESS_CW_INDEX_1 downto WR_ADDRESS_CW_INDEX_0);

    longCtrl <= cw(LONG_COUNTER_CW_INDEX_1 downto LONG_COUNTER_CW_INDEX_0);
    longStartValue <= (others => '0');
    
    shortCtrl <= cw(SHORT_COUNTER_CW_INDEX_1 downto SHORT_COUNTER_CW_INDEX_0);
    shortStartValue <= (others => '0');
    

    rfReg : generic8RegisterFile
    GENERIC MAP(16)
    PORT MAP (
                clk => clk,
                resetn => resetn,
                write => rfWrite,
                wrAddr => AddrCnt(2 downto 0),
                rdAddr => rfAddr,
                D => an7606data,
                Q => rfData
                );

    rfCount : genericCounter
    GENERIC MAP(4)
    PORT MAP(
                clk => clk,
                resetn => resetn,
                c => AddrCtrl,
                d => "0000",
                q => AddrCnt
                );
                
    rfCompare : genericCompare
    GENERIC MAP(4)
    PORT MAP (
               x => AddrCnt,
               y => "1000",
               g => open,
               l => open,
               e => sw(ALL_CHANNELS_HAVE_BEEN_READ_SW_BIT_INDEX)
               ); 

  	longDelayCounter : genericCounter
  	GENERIC MAP(LONG_DELAY_50Mhz_CONST_WIDTH)
    PORT MAP (
                clk => clk,
                resetn => resetn,
                c => longCtrl,
                d => longStartValue,
                q => longCount
                );	

    longDelayCompare : genericCompare
    GENERIC MAP(LONG_DELAY_50Mhz_CONST_WIDTH)
    PORT MAP (
                x => longCount,
                y => LONG_DELAY_50Mhz_COUNTS,
                g => open,
                l => open,
                e => sw(LONG_DELAY_DONE_SW_BIT_INDEX)
                );

    shortDelayCounter : genericCounter
    GENERIC MAP(SHORT_DELAY_50Mhz_CONST_WIDTH)
    PORT MAP (
                clk => clk,
                resetn => resetn,
                c => shortCtrl,
                d => shortStartValue,
                q => shortCount
                );
                
    shortDelayCompare : genericCompare
    GENERIC MAP(SHORT_DELAY_50Mhz_CONST_WIDTH)
    PORT MAP (
                x => shortCount,
                y => SHORT_DELAY_50Mhz_COUNTS,
                g => open,
                l => open,
                e => sw(SHORT_DELAY_DONE_SW_BIT_INDEX)
                );

end behavior;
