---------------------------------------------------------------------------------------------------
-- Fern generator
--
-- https://github.com/htminuslab            
--  
---------------------------------------------------------------------------------------------------
-- Version   Author          Date          Changes
-- 0.1       Hans Tiggeler   17 Feb 2003   Tested on Modelsim SE 5.7b                                     
---------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY load_fern IS
   PORT( 
      clk    : IN     std_logic;
      reset  : IN     std_logic;
      dbus   : OUT    std_logic_vector (15 DOWNTO 0);
      enable : OUT    std_logic;
      load   : OUT    std_logic;
      sel    : OUT    std_logic_vector (4 DOWNTO 0));
END load_fern ;

ARCHITECTURE rtl OF load_fern IS
BEGIN

process
	begin
		dbus  	<= (others => '0');
		enable 	<= '1';
		load   	<= '0';
		sel    	<= (others => '0');			
		wait;
end process;		
END rtl;
