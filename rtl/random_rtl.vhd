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
use ieee.std_logic_unsigned.all;

USE work.fernpack.all;

ENTITY random IS
   PORT( 
      reset  : IN     std_logic;
      clk    : IN     std_logic;
      mapsel : OUT    std_logic_vector (1 DOWNTO 0);
      dbus   : IN     std_logic_vector (15 DOWNTO 0);
      load   : IN     std_logic;
      enable : IN     std_logic;
      sel    : IN     std_logic_vector (4 DOWNTO 0));
END random ;


-- hds interface_end
ARCHITECTURE rtl OF random IS

signal random_s : std_logic_vector (63 DOWNTO 0);
signal rand_s 	: std_logic_vector (15 DOWNTO 0);

signal p0		: std_logic_vector (15 DOWNTO 0);
signal p1		: std_logic_vector (15 DOWNTO 0);
signal p2		: std_logic_vector (15 DOWNTO 0);

BEGIN
	
process (clk,reset) 
    begin
        if (reset='1') then      
        	p0<=pmap0_c;		-- Default to Fern
        	p1<=pmap1_c;               
        	p2<=pmap2_c;               
        elsif (rising_edge(clk)) then 
        	if (load='1') then
        		case sel is			  	-- sel=24,25,26,27
        			when "11000" => p0<=dbus;
        			when "11001" => p1<=dbus;
        			when "11010" => p2<=dbus;
        			when others  => NULL;
        		end case;		
        	end if;	
		end if;
end process;

rand_s	<= '0'&random_s(30 downto 16);	-- '0'& to use X"...."

process (clk,reset) 
    begin
        if (reset='1') then                     
            random_s 	<= X"0000000000000001";
			mapsel		<="00";
        elsif (rising_edge(clk)) then  
        	if (enable='1') then
	            random_s 	<= (random_s(31 downto 0) * X"41C64E6D") + X"0000000000003039";

	            if (rand_s<=p0) then   	mapsel<="00";
	            elsif (rand_s<=p1) then	mapsel<="01";
	            elsif (rand_s<=p2) then	mapsel<="10";
				else					mapsel<="11";
	            end if;   
	        end if;                                       
        end if;   
end process;    

END rtl;
