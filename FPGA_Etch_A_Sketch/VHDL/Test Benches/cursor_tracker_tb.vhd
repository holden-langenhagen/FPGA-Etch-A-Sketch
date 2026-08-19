--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity cursor_tracker_tb is
end entity;

--=============================================================================
--Architecture
--=============================================================================
architecture testbench of cursor_tracker_tb is

  --=============================================================================
  --Component Declaration
  --=============================================================================
  component cursor_tracker is
      Port (
          --timing:
          clk_port	: in std_logic;

          --control inputs:
          up_port	      	: in std_logic;
          down_port   		: in std_logic;
          left_port			: in std_logic;
          right_port      	: in std_logic;
          vblank_port       : in std_logic;
                  
          --coordinate outputs
          x_port			: out std_logic_vector(9 downto 0);
          y_port			: out std_logic_vector(8 downto 0));
  end component cursor_tracker;

  --=============================================================================
  --Signals
  --=============================================================================
  
  constant CLK_PERIOD : time := 40ns; -- 25 MHz
  signal clk, up, down, left, right,vblank : std_logic := '0';
  
  begin

  --=============================================================================
  --Port Map
  --=============================================================================
  uut: cursor_tracker 
      port map(		
          --timing:
          clk_port	=> clk,

          --control inputs:
          up_port	      	=> up,
          down_port   		=> down,
          left_port			=> left,
          right_port      	=> right,
          vblank_port       => vblank,
                  
          --coordinate outputs
          x_port			=> open,
          y_port			=> open);
  
  --=============================================================================
  --25 MHz Clock Generation 
  --=============================================================================
  clkgen_proc: process
  begin
      clk <= '0';
      wait for CLK_PERIOD/2;

      clk <= '1';
      wait for CLK_PERIOD/2;
  end process clkgen_proc;
  
  --=============================================================================
  --Stimulus Process
  --=============================================================================
  Stimulus : process
  begin
  	right <= '1';
  	
  	vblank <= '1'; -- simulate a frame
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	vblank <= '1'; -- simulate frame 2
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	vblank <= '1'; -- simulate frame 3
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
    right <= '0';
    left <= '1';
    
    vblank <= '1'; -- simulate a frame
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	vblank <= '1'; -- simulate frame 2
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	vblank <= '1'; -- simulate frame 3
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	left <= '0';
    
    up <= '1';
    
    vblank <= '1'; -- simulate a frame
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	vblank <= '1'; -- simulate frame 2
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	vblank <= '1'; -- simulate frame 3
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	
  	up <= '0';
    down <= '1';
    
    vblank <= '1'; -- simulate a frame
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	vblank <= '1'; -- simulate frame 2
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	vblank <= '1'; -- simulate frame 3
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	
  	down <= '0';
    up <= '1';
    right <= '1';
    
    
    vblank <= '1'; -- simulate a frame
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	vblank <= '1'; -- simulate frame 2
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	vblank <= '1'; -- simulate frame 3
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	
  	up <= '0';
    right <= '0';
    down <= '1';
    left <= '1';
    
    vblank <= '1'; -- simulate a frame
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	vblank <= '1'; -- simulate frame 2
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	vblank <= '1'; -- simulate frame 3
  	wait for 4*CLK_PERIOD;
  	vblank <= '0';
  	wait for 4*CLK_PERIOD;
  	
  	
  	down <= '0';
    left <= '0';
    
  
  end process Stimulus;
  
  
end testbench;





