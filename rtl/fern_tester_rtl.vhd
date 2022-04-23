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


ENTITY fern_tester IS
   PORT( 
      X     : IN     std_logic_vector (15 DOWNTO 0);
      Y     : IN     std_logic_vector (15 DOWNTO 0);
      clk   : IN     std_logic;
      reset : IN     std_logic);
END fern_tester ;

ARCHITECTURE rtl OF fern_tester IS

attribute foreign : string;
attribute foreign of rtl: architecture is "cif_init ./fli_fern.dll";

BEGIN
	
 	assert FALSE report "*** FLI Failure ***" severity failure; -- never called
	
END rtl;

