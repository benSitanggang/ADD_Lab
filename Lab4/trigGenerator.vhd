library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use work.basicBuildingBlocks_package.all;

entity trigGenerator is
    port(
        clk, resetn: in std_logic;
        an7606data: in std_logic_vector(15 downto 0);
        signedTrigVolt16: in signed(15 downto 0);
        regCtrl: in std_logic;
        slvData16: out std_logic_vector(15 downto 0);
        trigger: out std_logic
    );
end trigGenerator;

architecture structure of trigGenerator is
    signal reg1Out, reg2Out: std_logic_vector(15 downto 0);
    signal gtTrigger, ltTrigger: std_logic;
begin

    reg1: genericRegister
        generic map(16)
        port map(
            clk => clk,
            resetn => resetn,
            load => regCtrl,
            d => an7606data,
            q => reg1Out
        );
    
    reg2: genericRegister
        generic map(16)
        port map(
            clk => clk,
            resetn => resetn,
            load => regCtrl,
            d => reg1Out,
            q => reg2Out
        );
        
    gtCompare: genericSignedCompare
        generic map(16)
        port map(
            x => reg1Out,
            y => std_logic_vector(signedTrigVolt16),
            g => gtTrigger,
            l => open,
            e => open
        );
        
    ltCompare: genericSignedCompare
        generic map(16)
        port map(
            x => reg2Out,
            y => std_logic_vector(signedTrigVolt16),
            g => open,
            l => ltTrigger,
            e => open
        );
    
    trigger <= gtTrigger and ltTrigger;
    slvData16 <= reg1Out;
    
end structure;
