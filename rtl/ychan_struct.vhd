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
USE ieee.std_logic_arith.all;

USE work.fernpack.all;

ENTITY ychan IS
   PORT( 
      X      : IN     std_logic_vector (15 DOWNTO 0);
      clk    : IN     std_logic;
      dbus   : IN     std_logic_vector (15 DOWNTO 0);
      enable : IN     std_logic;
      load   : IN     std_logic;
      mapsel : IN     std_logic_vector (1 DOWNTO 0);
      reset  : IN     std_logic;
      sel    : IN     std_logic_vector (4 DOWNTO 0);
      Y      : BUFFER std_logic_vector (15 DOWNTO 0));
END ychan ;

ARCHITECTURE struct OF ychan IS

   -- Architecture declarations
   signal dmap0_s   : std_logic_vector (15 DOWNTO 0);
   signal dmap1_s   : std_logic_vector (15 DOWNTO 0);
   signal dmap2_s   : std_logic_vector (15 DOWNTO 0);
   signal dmap3_s   : std_logic_vector (15 DOWNTO 0);
   
   signal cmap0_s   : std_logic_vector (15 DOWNTO 0);
   signal cmap1_s   : std_logic_vector (15 DOWNTO 0);
   signal cmap2_s   : std_logic_vector (15 DOWNTO 0);
   signal cmap3_s   : std_logic_vector (15 DOWNTO 0);
   
   signal fmap0_s   : std_logic_vector (15 DOWNTO 0);
   signal fmap1_s   : std_logic_vector (15 DOWNTO 0);
   signal fmap2_s   : std_logic_vector (15 DOWNTO 0);
   signal fmap3_s   : std_logic_vector (15 DOWNTO 0);

   -- Internal signal declarations
   SIGNAL cmap    : std_logic_vector(15 DOWNTO 0);
   SIGNAL dmap    : std_logic_vector(15 DOWNTO 0);
   SIGNAL dout3   : std_logic_vector(15 DOWNTO 0);
   SIGNAL dout4   : std_logic_vector(15 DOWNTO 0);
   SIGNAL fmap    : std_logic_vector(15 DOWNTO 0);
   SIGNAL result  : std_logic_vector(15 DOWNTO 0);
   SIGNAL result1 : std_logic_vector(15 DOWNTO 0);


   -- ModuleWare signal declarations(v1.6) for instance 'I0' of 'adff'
   SIGNAL mw_I0reg_cval : std_logic_vector(15 DOWNTO 0);

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
   -- HDL Embedded Text Block 2 eb2
   -- eb1 1       
   
   process (clk,reset) 
       begin
           if (reset='1') then      
              cmap0_s<=cmap0_c;      -- Default to Fern
              cmap1_s<=cmap1_c;               
              cmap2_s<=cmap2_c;               
              cmap3_s<=cmap3_c;               
           elsif (rising_edge(clk)) then 
              if (load='1') then
                 case sel is              -- sel=0, 1, 2, 3
                    when "00000" => cmap0_s<=dbus;
                    when "00001" => cmap1_s<=dbus;
                    when "00010" => cmap2_s<=dbus;
                    when "00011" => cmap3_s<=dbus;
                    when others  => NULL;
                 end case;      
              end if;   
         end if;
   end process;
   
   process(mapsel,cmap0_s,cmap1_s,cmap2_s,cmap3_s)
      begin
         case mapsel is
            when "00"    => cmap <= cmap0_s;   
            when "01"    => cmap <= cmap1_s;   
            when "10"    => cmap <= cmap2_s;   
            when  others => cmap <= cmap3_s;
         end case;      
   end process;

   -- HDL Embedded Text Block 3 eb3
   -- eb1 1                                        
   
   process (clk,reset) 
       begin
           if (reset='1') then      
              dmap0_s<=dmap0_c;      -- Default to Fern
              dmap1_s<=dmap1_c;               
              dmap2_s<=dmap2_c;               
              dmap3_s<=dmap3_c;               
           elsif (rising_edge(clk)) then 
              if (load='1') then
                 case sel is              -- sel=0, 1, 2, 3
                    when "00000" => dmap0_s<=dbus;
                    when "00001" => dmap1_s<=dbus;
                    when "00010" => dmap2_s<=dbus;
                    when "00011" => dmap3_s<=dbus;
                    when others  => NULL;
                 end case;      
              end if;   
         end if;
   end process;
   
   process(mapsel,dmap0_s,dmap1_s,dmap2_s,dmap3_s)
      begin
         case mapsel is
            when "00"   => dmap <= dmap0_s;   
            when "01"   => dmap <= dmap1_s;   
            when "10"   => dmap <= dmap2_s;   
            when others => dmap <= dmap3_s;
         end case;      
   end process;

   -- HDL Embedded Text Block 4 eb4
   -- eb1 1  
   process (clk,reset) 
       begin
           if (reset='1') then      
              fmap0_s<=fmap0_c;      -- Default to Fern
              fmap1_s<=fmap1_c;               
              fmap2_s<=fmap2_c;               
              fmap3_s<=fmap3_c;               
           elsif (rising_edge(clk)) then 
              if (load='1') then
                 case sel is              -- sel=0, 1, 2, 3
                    when "00000" => fmap0_s<=dbus;
                    when "00001" => fmap1_s<=dbus;
                    when "00010" => fmap2_s<=dbus;
                    when "00011" => fmap3_s<=dbus;
                    when others  => NULL;
                 end case;      
              end if;   
         end if;
   end process;
   
   process(mapsel,fmap0_s,fmap1_s,fmap2_s,fmap3_s)
      begin
         case mapsel is
            when "00"   => fmap <= fmap0_s;   
            when "01"   => fmap <= fmap1_s;   
            when "10"   => fmap <= fmap2_s;   
            when others => fmap <= fmap3_s;
         end case;      
   end process;


   -- ModuleWare code(v1.6) for instance 'I3' of 'add'
   i3combo_proc: PROCESS (fmap, dout3)
   VARIABLE temp_din0 : std_logic_vector(16 DOWNTO 0);
   VARIABLE temp_din1 : std_logic_vector(16 DOWNTO 0);
   VARIABLE temp_sum : unsigned(16 DOWNTO 0);
   VARIABLE temp_carry : std_logic;
   BEGIN
      temp_din0 := '0' & fmap;
      temp_din1 := '0' & dout3;
      temp_carry := '0';
      temp_sum := unsigned(temp_din0) + unsigned(temp_din1) + temp_carry;
      dout4 <= conv_std_logic_vector(temp_sum(15 DOWNTO 0),16);
   END PROCESS i3combo_proc;

   -- ModuleWare code(v1.6) for instance 'I4' of 'add'
   i4combo_proc: PROCESS (result1, result)
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
   END PROCESS i4combo_proc;

   -- ModuleWare code(v1.6) for instance 'I0' of 'adff'
   Y <= mw_I0reg_cval;
   i0seq_proc: PROCESS (clk, reset)
   BEGIN
      IF (reset = '1' OR reset = 'H') THEN
         mw_I0reg_cval <= "0000000000000000";
      ELSIF (clk'EVENT AND clk='1') THEN
         IF (enable = '1' OR enable = 'H') THEN
            mw_I0reg_cval <= dout4;
         END IF;
      END IF;
   END PROCESS i0seq_proc;

   -- Instance port mappings.
   I1 : multiplier
      GENERIC MAP (
         MWIDTH => 16
      )
      PORT MAP (
         inputa => Y,
         inputb => dmap,
         result => result1
      );
   I2 : multiplier
      GENERIC MAP (
         MWIDTH => 16
      )
      PORT MAP (
         inputa => X,
         inputb => cmap,
         result => result
      );

END struct;
