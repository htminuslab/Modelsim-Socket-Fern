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

USE work.fernpack.all;

ENTITY xchan IS
   PORT( 
      Y      : IN     std_logic_vector (15 DOWNTO 0);
      clk    : IN     std_logic;
      dbus   : IN     std_logic_vector (15 DOWNTO 0);
      enable : IN     std_logic;
      load   : IN     std_logic;
      mapsel : IN     std_logic_vector (1 DOWNTO 0);
      reset  : IN     std_logic;
      sel    : IN     std_logic_vector (4 DOWNTO 0);
      X      : BUFFER std_logic_vector (15 DOWNTO 0));
END xchan ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;

USE work.fernpack.all;


ARCHITECTURE struct OF xchan IS

   -- Architecture declarations
   signal amap0_s   : std_logic_vector (15 DOWNTO 0);
   signal amap1_s   : std_logic_vector (15 DOWNTO 0);
   signal amap2_s   : std_logic_vector (15 DOWNTO 0);
   signal amap3_s   : std_logic_vector (15 DOWNTO 0);
   
   signal bmap0_s   : std_logic_vector (15 DOWNTO 0);
   signal bmap1_s   : std_logic_vector (15 DOWNTO 0);
   signal bmap2_s   : std_logic_vector (15 DOWNTO 0);
   signal bmap3_s   : std_logic_vector (15 DOWNTO 0);
   
   signal emap0_s   : std_logic_vector (15 DOWNTO 0);
   signal emap1_s   : std_logic_vector (15 DOWNTO 0);
   signal emap2_s   : std_logic_vector (15 DOWNTO 0);
   signal emap3_s   : std_logic_vector (15 DOWNTO 0);

   -- Internal signal declarations
   SIGNAL amap    : std_logic_vector(15 DOWNTO 0);
   SIGNAL bmap    : std_logic_vector(15 DOWNTO 0);
   SIGNAL dout3   : std_logic_vector(15 DOWNTO 0);
   SIGNAL dout4   : std_logic_vector(15 DOWNTO 0);
   SIGNAL emap    : std_logic_vector(15 DOWNTO 0);
   SIGNAL result  : std_logic_vector(15 DOWNTO 0);
   SIGNAL result1 : std_logic_vector(15 DOWNTO 0);


   -- ModuleWare signal declarations(v1.6) for instance 'I5' of 'adff'
   SIGNAL mw_I5reg_cval : std_logic_vector(15 DOWNTO 0);

   -- Component Declarations
   COMPONENT multiplier
   GENERIC (
      MWIDTH : integer := 16
   );
   PORT (
      inputa : IN     std_logic_vector (MWIDTH-1 DOWNTO 0);
      inputb : IN     std_logic_vector (MWIDTH-1 DOWNTO 0);
      result : OUT    std_logic_vector (MWIDTH-1 DOWNTO 0)
   );
   END COMPONENT;


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   -- eb1 1     
   process (clk,reset) 
       begin
           if (reset='1') then      
              amap0_s<=amap0_c;      -- Default to Fern
              amap1_s<=amap1_c;               
              amap2_s<=amap2_c;               
              amap3_s<=amap3_c;               
           elsif (rising_edge(clk)) then 
              if (load='1') then
                 case sel is              -- sel=0, 1, 2, 3
                    when "00000" => amap0_s<=dbus;
                    when "00001" => amap1_s<=dbus;
                    when "00010" => amap2_s<=dbus;
                    when "00011" => amap3_s<=dbus;
                    when others  => NULL;
                 end case;      
              end if;   
         end if;
   end process;
   
   process(mapsel,amap0_s,amap1_s,amap2_s,amap3_s)
      begin
         case mapsel is
            when "00"    => amap <= amap0_s;   
            when "01"    => amap <= amap1_s;   
            when "10"    => amap <= amap2_s;   
            when  others => amap <= amap3_s;
         end case;      
   end process;

   -- HDL Embedded Text Block 2 eb2
   -- eb1 1                                           
   process (clk,reset) 
       begin
           if (reset='1') then      
              bmap0_s<=bmap0_c;      -- Default to Fern
              bmap1_s<=bmap1_c;               
              bmap2_s<=bmap2_c;               
              bmap3_s<=bmap3_c;               
           elsif (rising_edge(clk)) then 
              if (load='1') then
                 case sel is              -- sel=0, 1, 2, 3
                    when "00000" => bmap0_s<=dbus;
                    when "00001" => bmap1_s<=dbus;
                    when "00010" => bmap2_s<=dbus;
                    when "00011" => bmap3_s<=dbus;
                    when others  => NULL;
                 end case;      
              end if;   
         end if;
   end process;
   
   process(mapsel,bmap0_s,bmap1_s,bmap2_s,bmap3_s)
      begin
         case mapsel is
            when "00"   => bmap <= bmap0_s;   
            when "01"   => bmap <= bmap1_s;   
            when "10"   => bmap <= bmap2_s;   
            when others => bmap <= bmap3_s;
         end case;      
   end process;

   -- HDL Embedded Text Block 3 eb3
   -- eb1 1    
   process (clk,reset) 
       begin
           if (reset='1') then      
              emap0_s<=emap0_c;      -- Default to Fern
              emap1_s<=emap1_c;               
              emap2_s<=emap2_c;               
              emap3_s<=emap3_c;               
           elsif (rising_edge(clk)) then 
              if (load='1') then
                 case sel is              -- sel=0, 1, 2, 3
                    when "00000" => emap0_s<=dbus;
                    when "00001" => emap1_s<=dbus;
                    when "00010" => emap2_s<=dbus;
                    when "00011" => emap3_s<=dbus;
                    when others  => NULL;
                 end case;      
              end if;   
         end if;
   end process;
   
   process(mapsel,emap0_s,emap1_s,emap2_s,emap3_s)
      begin
         case mapsel is
            when "00"   => emap <= emap0_s;   
            when "01"   => emap <= emap1_s;   
            when "10"   => emap <= emap2_s;   
            when others => emap <= emap3_s;
         end case;      
   end process;


   -- ModuleWare code(v1.6) for instance 'I2' of 'add'
   i2combo_proc: PROCESS (emap, dout3)
   VARIABLE temp_din0 : std_logic_vector(16 DOWNTO 0);
   VARIABLE temp_din1 : std_logic_vector(16 DOWNTO 0);
   VARIABLE temp_sum : unsigned(16 DOWNTO 0);
   VARIABLE temp_carry : std_logic;
   BEGIN
      temp_din0 := '0' & emap;
      temp_din1 := '0' & dout3;
      temp_carry := '0';
      temp_sum := unsigned(temp_din0) + unsigned(temp_din1) + temp_carry;
      dout4 <= conv_std_logic_vector(temp_sum(15 DOWNTO 0),16);
   END PROCESS i2combo_proc;

   -- ModuleWare code(v1.6) for instance 'I3' of 'add'
   i3combo_proc: PROCESS (result1, result)
   VARIABLE temp_din0 : std_logic_vector(16 DOWNTO 0);
   VARIABLE temp_din1 : std_logic_vector(16 DOWNTO 0);
   VARIABLE temp_sum : signed(16 DOWNTO 0);
   VARIABLE temp_carry : std_logic;
   BEGIN
      temp_din0 := result1(15) & result1;
      temp_din1 := result(15) & result;
      temp_carry := '0';
      temp_sum := signed(temp_din0) + signed(temp_din1) + temp_carry;
      dout3 <= conv_std_logic_vector(temp_sum(15 DOWNTO 0),16);
   END PROCESS i3combo_proc;

   -- ModuleWare code(v1.6) for instance 'I5' of 'adff'
   X <= mw_I5reg_cval;
   i5seq_proc: PROCESS (clk, reset)
   BEGIN
      IF (reset = '1' OR reset = 'H') THEN
         mw_I5reg_cval <= "0000000000000000";
      ELSIF (clk'EVENT AND clk='1') THEN
         IF (enable = '1' OR enable = 'H') THEN
            mw_I5reg_cval <= dout4;
         END IF;
      END IF;
   END PROCESS i5seq_proc;

   -- Instance port mappings.
   I0 : multiplier
      GENERIC MAP (
         MWIDTH => 16
      )
      PORT MAP (
         inputa => X,
         inputb => amap,
         result => result1
      );
   I1 : multiplier
      GENERIC MAP (
         MWIDTH => 16
      )
      PORT MAP (
         inputa => Y,
         inputb => bmap,
         result => result
      );

END struct;
