---------------------------------------------------------------------------------------------------
-- Fern generator
--
-- https://github.com/htminuslab            
--  
---------------------------------------------------------------------------------------------------
-- Version   Author          Date          Changes
-- 0.1       Hans Tiggeler   17 Feb 2003   Tested on Modelsim SE 5.7b                                     
---------------------------------------------------------------------------------------------------
PACKAGE BODY fernpack IS

-- pragma synthesis_off

  procedure init_signal_spy (
                     source_signal      : IN string ;
                     destination_signal : IN string ;
                     verbose            : IN integer := 0) is
  begin
    assert false
    report "ERROR: builtin subprogram not called"
    severity note;
  end;

  function to_real( time_val : IN time ) return real is
  begin
    assert false 
    report "ERROR: builtin function not called" 
    severity note;
    return 0.0;
  end;     

  function to_time( real_val : IN real ) return time is
  begin
    assert false 
    report "ERROR: builtin function not called" 
    severity note;
    return 0 ns;
  end;     

  function get_resolution return real is
  begin
    assert false 
    report "ERROR: builtin function not called" 
    severity note;
    return 0.0;
  end;     

-- pragma synthesis_on

END fernpack;
