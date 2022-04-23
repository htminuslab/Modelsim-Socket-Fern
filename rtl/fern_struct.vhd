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
USE ieee.std_logic_unsigned.ALL;

ENTITY fern IS
   PORT( 
      clk    : IN     std_logic;
      dbus   : IN     std_logic_vector (15 DOWNTO 0);
      enable : IN     std_logic;
      load   : IN     std_logic;
      loadxy : IN     std_logic;
      reset  : IN     std_logic;
      sel    : IN     std_logic_vector (4 DOWNTO 0);
      X      : OUT    std_logic_vector (15 DOWNTO 0);
      Y      : OUT    std_logic_vector (15 DOWNTO 0));

END fern ;

ARCHITECTURE struct OF fern IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL fern_enable : std_logic;
   SIGNAL mapsel      : std_logic_vector(1 DOWNTO 0);

   -- Implicit buffer signal declarations
   SIGNAL X_internal : std_logic_vector (15 DOWNTO 0);
   SIGNAL Y_internal : std_logic_vector (15 DOWNTO 0);


   -- Component Declarations
   COMPONENT random
   PORT (
      reset  : IN     std_logic ;
      clk    : IN     std_logic ;
      mapsel : OUT    std_logic_vector (1 DOWNTO 0);
      dbus   : IN     std_logic_vector (15 DOWNTO 0);
      load   : IN     std_logic ;
      enable : IN     std_logic ;
      sel    : IN     std_logic_vector (4 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT xchan
   PORT (
      Y      : IN     std_logic_vector (15 DOWNTO 0);
      clk    : IN     std_logic ;
      dbus   : IN     std_logic_vector (15 DOWNTO 0);
      enable : IN     std_logic ;
      load   : IN     std_logic ;
      mapsel : IN     std_logic_vector (1 DOWNTO 0);
      reset  : IN     std_logic ;
      sel    : IN     std_logic_vector (4 DOWNTO 0);
      X      : BUFFER std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT ychan
   PORT (
      X      : IN     std_logic_vector (15 DOWNTO 0);
      clk    : IN     std_logic ;
      dbus   : IN     std_logic_vector (15 DOWNTO 0);
      enable : IN     std_logic ;
      load   : IN     std_logic ;
      mapsel : IN     std_logic_vector (1 DOWNTO 0);
      reset  : IN     std_logic ;
      sel    : IN     std_logic_vector (4 DOWNTO 0);
      Y      : BUFFER std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   -- eb1 1 
   fern_enable <= enable and loadxy;


   -- Instance port mappings.
   I0 : random
      PORT MAP (
         reset  => reset,
         clk    => clk,
         mapsel => mapsel,
         dbus   => dbus,
         load   => load,
         enable => fern_enable,
         sel    => sel
      );
   I1 : xchan
      PORT MAP (
         Y      => Y_internal,
         clk    => clk,
         dbus   => dbus,
         enable => fern_enable,
         load   => load,
         mapsel => mapsel,
         reset  => reset,
         sel    => sel,
         X      => X_internal
      );
   I2 : ychan
      PORT MAP (
         X      => X_internal,
         clk    => clk,
         dbus   => dbus,
         enable => fern_enable,
         load   => load,
         mapsel => mapsel,
         reset  => reset,
         sel    => sel,
         Y      => Y_internal
      );

   -- Implicit buffered output assignments
   X <= X_internal;
   Y <= Y_internal;

END struct;
