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


ENTITY rectifier IS
   GENERIC( 
      WIDTH : integer := 4
   );
   PORT( 
      din  : IN     std_logic_vector (WIDTH-1 DOWNTO 0);
      dout : OUT    std_logic_vector (WIDTH-1 DOWNTO 0);
      neg  : OUT    std_logic);
END rectifier ;


-- hds interface_end
architecture rtl of rectifier is

signal ibus_s : std_logic_vector(WIDTH-1 downto 0);

begin
	
neg     <= din(WIDTH-1);		-- MSbit	
ibus_s 	<= not(din) when din(WIDTH-1)='1' else din;
dout 	<= ibus_s + din(WIDTH-1);

end rtl;

