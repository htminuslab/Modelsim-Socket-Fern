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

ENTITY multiplier IS
   GENERIC( 
      MWIDTH : integer := 16
   );
   PORT( 
      inputa : IN     std_logic_vector (MWIDTH-1 DOWNTO 0);
      inputb : IN     std_logic_vector (MWIDTH-1 DOWNTO 0);
      result : OUT    std_logic_vector (MWIDTH-1 DOWNTO 0));
END multiplier ;

ARCHITECTURE struct OF multiplier IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL d1_s    : std_logic_vector(MWIDTH-1 DOWNTO 0);
   SIGNAL d2_s    : std_logic_vector(MWIDTH-1 DOWNTO 0);
   SIGNAL dout4   : std_logic;
   SIGNAL mul16_s : std_logic_vector(MWIDTH-1 DOWNTO 0);
   SIGNAL mul_s   : std_logic_vector((MWIDTH*2)-1 DOWNTO 0);
   SIGNAL neg     : std_logic;
   SIGNAL neg1    : std_logic;


   -- Component Declarations
   COMPONENT irectifier
   GENERIC (
      WIDTH : integer := 4
   );
   PORT (
      din  : IN     std_logic_vector (WIDTH-1 DOWNTO 0);
      dout : OUT    std_logic_vector (WIDTH-1 DOWNTO 0);
      neg  : IN     std_logic 
   );
   END COMPONENT;
   COMPONENT rectifier
   GENERIC (
      WIDTH : integer := 4
   );
   PORT (
      din  : IN     std_logic_vector (WIDTH-1 DOWNTO 0);
      dout : OUT    std_logic_vector (WIDTH-1 DOWNTO 0);
      neg  : OUT    std_logic 
   );
   END COMPONENT;


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   -- eb1 1     
   mul_s <= d1_s * d2_s;

   -- HDL Embedded Text Block 2 eb2
   -- eb2 2   
   -- Shift 11 bits, truncate to 16 bits
   mul16_s <= mul_s(26 downto 11);


   -- ModuleWare code(v1.3) for instance 'I3' of 'xor'
   dout4 <= neg1 XOR neg;

   -- Instance port mappings.
   I2 : irectifier
      GENERIC MAP (
         WIDTH => MWIDTH
      )
      PORT MAP (
         din  => mul16_s,
         dout => result,
         neg  => dout4
      );
   I0 : rectifier
      GENERIC MAP (
         WIDTH => MWIDTH
      )
      PORT MAP (
         din  => inputa,
         dout => d1_s,
         neg  => neg1
      );
   I1 : rectifier
      GENERIC MAP (
         WIDTH => MWIDTH
      )
      PORT MAP (
         din  => inputb,
         dout => d2_s,
         neg  => neg
      );

END struct;
