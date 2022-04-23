---------------------------------------------------------------------------------------------------
-- Fern generator
--
-- https://github.com/htminuslab            
--  
---------------------------------------------------------------------------------------------------
-- Version   Author          Date          Changes
-- 0.1       Hans Tiggeler   17 Feb 2003   Tested on Modelsim SE 5.7b                                     
---------------------------------------------------------------------------------------------------
ENTITY fern_tb IS
END fern_tb ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.ALL;


ARCHITECTURE struct OF fern_tb IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL X      : std_logic_vector(15 DOWNTO 0);
   SIGNAL Y      : std_logic_vector(15 DOWNTO 0);
   SIGNAL clk    : std_logic;
   SIGNAL dbus   : std_logic_vector(15 DOWNTO 0);
   SIGNAL enable : std_logic;
   SIGNAL load   : std_logic;
   SIGNAL reset  : std_logic;
   SIGNAL sel    : std_logic_vector(4 DOWNTO 0);


   -- Component Declarations
   COMPONENT clockgen
   GENERIC (
      PERIOD : time := 67.8168403 ns
   );
   PORT (
      clk         : OUT    std_logic ;
      async_reset : OUT    std_logic ;
      sync_reset  : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT fern
   PORT (
      clk    : IN     std_logic ;
      dbus   : IN     std_logic_vector (15 DOWNTO 0);
      enable : IN     std_logic ;
      load   : IN     std_logic ;
      loadxy : IN     std_logic ;
      reset  : IN     std_logic ;
      sel    : IN     std_logic_vector (4 DOWNTO 0);
      X      : OUT    std_logic_vector (15 DOWNTO 0);
      Y      : OUT    std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT fern_tester
   PORT (
      X     : IN     std_logic_vector (15 DOWNTO 0);
      Y     : IN     std_logic_vector (15 DOWNTO 0);
      clk   : IN     std_logic ;
      reset : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT load_fern
   PORT (
      clk    : IN     std_logic ;
      reset  : IN     std_logic ;
      dbus   : OUT    std_logic_vector (15 DOWNTO 0);
      enable : OUT    std_logic ;
      load   : OUT    std_logic ;
      sel    : OUT    std_logic_vector (4 DOWNTO 0)
   );
   END COMPONENT;


BEGIN

   -- Instance port mappings.
   I3 : clockgen
      GENERIC MAP (
         PERIOD => 67.8168403 ns
      )
      PORT MAP (
         clk         => clk,
         async_reset => reset,
         sync_reset  => OPEN
      );
   I0 : fern
      PORT MAP (
         clk    => clk,
         dbus   => dbus,
         enable => enable,
         load   => load,
         loadxy => enable,
         reset  => reset,
         sel    => sel,
         X      => X,
         Y      => Y
      );
   I1 : fern_tester
      PORT MAP (
         X     => X,
         Y     => Y,
         clk   => clk,
         reset => reset
      );
   I2 : load_fern
      PORT MAP (
         clk    => clk,
         reset  => reset,
         dbus   => dbus,
         enable => enable,
         load   => load,
         sel    => sel
      );

END struct;
