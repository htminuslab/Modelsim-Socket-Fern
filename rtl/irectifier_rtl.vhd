---------------------------------------------------------------------------------------------------
-- Fern generator
--
-- https://github.com/htminuslab            
--  
---------------------------------------------------------------------------------------------------
-- Version   Author          Date          Changes
-- 0.1       Hans Tiggeler   17 Feb 2003   Tested on Modelsim SE 5.7b                                     
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


ENTITY irectifier IS
   GENERIC( 
      WIDTH : integer := 4
   );
   PORT( 
      din  : IN     std_logic_vector (WIDTH-1 DOWNTO 0);
      dout : OUT    std_logic_vector (WIDTH-1 DOWNTO 0);
      neg  : IN     std_logic);
END irectifier ;


-- hds interface_end
ARCHITECTURE rtl OF irectifier IS
BEGIN
	
dout <= din when neg='0' else (not(din) + '1');

END rtl;

