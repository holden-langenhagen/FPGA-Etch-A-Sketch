

--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity vga_test_Shell is
    Generic(
        CLOCK_DIVIDER_RATIO : integer := 4
        );
    Port ( 	
			clk_ext_port		: in std_logic;		-- mapped to external IO device (100 MHz Clock)				
			Hsync_ext_port			: out std_logic;    -- ALL of the outs mapped to the VGA
			Vsync_ext_port			: out std_logic;    
			vgaR_ext_port			: out std_logic;    
			vgaG_ext_port			: out std_logic;    
			vgaB_ext_port			: out std_logic);    
end vga_test_Shell;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of vga_test_Shell is

--=============================================================================
--Sub-Component Declarations:
--=============================================================================
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--System Clock Generation:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component system_clock_generator is
    Generic(
        CLOCK_DIVIDER_RATIO : integer 
        );
    Port (
        --External Clock:
            input_clk_port		: in std_logic;
        --System Clock:
            system_clk_port		: out std_logic;
            fwd_clk_port		: out std_logic);
end component;

--vga test component i built
component VGA_test is
    Port ( 
		--timing:
			clk_port 		: in std_logic;
		--outputs to VGA monitor
			Hsync			: out std_logic;
			Vsync			: out std_logic;
			vgaR			: out std_logic;
			vgaG			: out std_logic;
			vgaB			: out std_logic);
end component;

--=============================================================================
--Signal Declarations: 
--=============================================================================
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Timing:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
signal system_clk: std_logic := '0';

--=============================================================================
--Port Mapping (wiring the component blocks together): 
--=============================================================================

begin

--Wire the system clock generator into the shell with a port map:
clocking: system_clock_generator
    generic map(
        CLOCK_DIVIDER_RATIO =>4
    ) 
    port map(
    input_clk_port  => clk_ext_port,     -- External clock
    system_clk_port => system_clk,       -- System clock
    fwd_clk_port => OPEN);
    

--Wire the vga_test into the shell with a port map:

-- All ports are mapped to the top level ports except clk_port and y_port
TEST: VGA_test port map(
    clk_port 		=> system_clk,           	-- mapped to clock divider
    Hsync	        => Hsync_ext_port,		
	Vsync			=> Vsync_ext_port,	
	vgaR			=> vgaR_ext_port,	
	vgaG			=> vgaG_ext_port,
	vgaB			=> vgaB_ext_port);
end behavioral_architecture;