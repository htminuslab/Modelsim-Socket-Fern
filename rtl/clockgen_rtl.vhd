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


ENTITY clockgen IS
   GENERIC( 
      PERIOD : time := 67.8168403 ns
   );
   PORT( 
      clk         : OUT    std_logic;
      async_reset : OUT    std_logic;
      sync_reset  : OUT    std_logic);
END clockgen ;

ARCHITECTURE rtl OF clockgen IS
BEGIN

process      
    variable c:std_logic :='0';
	begin
      	c := not c;
      	clk <= c;  
      	wait for PERIOD/2;
    end process;	

process      
	begin
     	async_reset <= '1';	 -- assert async reset
		wait for PERIOD*6;
		wait for PERIOD+ 63 ns; -- (change to random number generator)
		async_reset <= '0';
		wait;
    end process;	

process      
	begin
     	sync_reset <= '1';	 -- assert synchronous reset
		wait for PERIOD*6;
		sync_reset <= '0';
		wait;
    end process;		

END rtl;


