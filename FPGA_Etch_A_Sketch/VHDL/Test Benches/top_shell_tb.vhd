----------------------------------------------------------------------------------
-- Holden Langenhagen
-- Currently implemented to test top shell

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
entity top_shell_tb is
end entity;

--=============================================================================
--Architecture
--=============================================================================
architecture testbench of top_shell_tb is

  --=============================================================================
  --Component Declaration
  --=============================================================================
    component top_shell is
    Generic (
        CLOCK_DIVIDER_CONSTANT : integer := 4; -- 25 MHz clock
        STABLE_CONSTANT : integer := 100; -- Adjustable debouncing constant
        TICKER_DIVIDER : integer := 5 -- ticker divider to make cursor move at reasonable speed (default is about 60Hz) at system clk
    );
    Port (
			clk_ext_port		 : in std_logic;		-- mapped to external IO device (100 MHz Clock)		
			up_ext_port          : in std_logic;
			down_ext_port        : in std_logic;
			left_ext_port        : in std_logic;
			right_ext_port       : in std_logic;
			clear_ext_port       : in std_logic;
			Hsync_ext_port			: out std_logic;    -- ALL of the outs mapped to the VGA
			Vsync_ext_port			: out std_logic;    
			vgaR_ext_port			: out std_logic;    
			vgaG_ext_port			: out std_logic;    
			vgaB_ext_port			: out std_logic);    

    end component top_shell;



  --=============================================================================
  --Signals
  --=============================================================================
  
  constant CLK_PERIOD : time := 10ns; -- 100 MHz
  signal clk, up, down, left, right,clear : std_logic := '0';
  
  begin

  --=============================================================================
  --Port Map
  --=============================================================================
  uut: top_shell 
      port map(		
            --timing:
            clk_ext_port	=> clk,
            
            --control inputs:
            up_ext_port	      	=> up,
            down_ext_port   		=> down,
            left_ext_port			=> left,
            right_ext_port      	=> right,
            clear_ext_port        => clear,
          
            Hsync_ext_port			=> open,    -- ALL of the outs mapped to the VGA
            Vsync_ext_port			=> open,    
            vgaR_ext_port			=> open,    
            vgaG_ext_port			=> open,   
            vgaB_ext_port			=> open);    

  --=============================================================================
  --Clock Generation 
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
    up <= '1';
    wait for 700*CLK_PERIOD;
    right <= '0';
    up <= '0';
    
  
  end process Stimulus;
  
  
end testbench;






