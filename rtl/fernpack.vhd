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

PACKAGE fernpack IS

-- 16 bits fixed point, format: [Sign-bit][4 integer bits][11 fraction bits]
constant amap0_c: std_logic_vector(15 downto 0) := X"0000";
constant amap1_c: std_logic_vector(15 downto 0) := X"06CC";
constant amap2_c: std_logic_vector(15 downto 0) := X"0199";
constant amap3_c: std_logic_vector(15 downto 0) := X"FECD";
constant bmap0_c: std_logic_vector(15 downto 0) := X"0000";
constant bmap1_c: std_logic_vector(15 downto 0) := X"0051";
constant bmap2_c: std_logic_vector(15 downto 0) := X"FDEC";
constant bmap3_c: std_logic_vector(15 downto 0) := X"023D";
constant cmap0_c: std_logic_vector(15 downto 0) := X"0000";
constant cmap1_c: std_logic_vector(15 downto 0) := X"FFAF";
constant cmap2_c: std_logic_vector(15 downto 0) := X"01D7";
constant cmap3_c: std_logic_vector(15 downto 0) := X"0214";
constant dmap0_c: std_logic_vector(15 downto 0) := X"0147";
constant dmap1_c: std_logic_vector(15 downto 0) := X"06CC";
constant dmap2_c: std_logic_vector(15 downto 0) := X"01C2";
constant dmap3_c: std_logic_vector(15 downto 0) := X"01EB";
constant emap0_c: std_logic_vector(15 downto 0) := X"0000";
constant emap1_c: std_logic_vector(15 downto 0) := X"0000";
constant emap2_c: std_logic_vector(15 downto 0) := X"0000";
constant emap3_c: std_logic_vector(15 downto 0) := X"0000";
constant fmap0_c: std_logic_vector(15 downto 0) := X"0000";
constant fmap1_c: std_logic_vector(15 downto 0) := X"0CCC";
constant fmap2_c: std_logic_vector(15 downto 0) := X"0CCC";
constant fmap3_c: std_logic_vector(15 downto 0) := X"0385";

--Note P adjusted for 0-32767 Random range, pmap0=(p0*32767), pmap1=(po+p1)*32767 etc
constant pmap0_c: std_logic_vector(15 downto 0) := X"0147";
constant pmap1_c: std_logic_vector(15 downto 0) := X"6E14";
constant pmap2_c: std_logic_vector(15 downto 0) := X"770A";
constant pmap3_c: std_logic_vector(15 downto 0) := X"8000";


--Note not in fix point format, sel=28..31
constant scalex_c : std_logic_vector(15 downto 0) := X"0062";
constant offsetx_c: std_logic_vector(15 downto 0) := X"00D5";
constant scaley_c : std_logic_vector(15 downto 0) := X"002F";
constant offsety_c: std_logic_vector(15 downto 0) := X"FFFD";

-- pragma synthesis_off
attribute builtin_subprogram : string;
    
procedure init_signal_spy (
                 source_signal      : IN string ;
                 destination_signal : IN string ;
                 verbose            : IN integer := 0) ;

attribute builtin_subprogram of init_signal_spy : procedure is "init_signal_spy_vhdl";

function to_real( time_val : IN time ) return real;
   attribute builtin_subprogram of to_real: function is "util_to_real";  

function to_time( real_val : IN real ) return time;
   attribute builtin_subprogram of to_time: function is "util_to_time";  

function get_resolution return real;
   attribute builtin_subprogram of get_resolution: function is "util_get_resolution";  
-- pragma synthesis_on

END fernpack;
