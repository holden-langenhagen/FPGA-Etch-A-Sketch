----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/17/2026 06:33:12 PM
-- Design Name: 
-- Module Name: vga_controller_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity vga_controller_tb is
end vga_controller_tb;

architecture Behavioral of vga_controller_tb is

component vga_controller is
    Port (
		--timing:
			clk_port         : in std_logic;
		--to frame buffer
		    video_on_port    : out std_logic;
			addr_port		 : out std_logic_vector(18 downto 0);
		--to VGA display
            Hsync_port		 : out std_logic;
			Vsync_port		 : out std_logic;
	    --to frame updater
	        Vblank_port	     : out std_logic); --high when in vertical blanking region
end component vga_controller;


constant CLK_PERIOD : time := 40ns; -- 25 MHz
signal clk : std_logic := '0';

begin

uut : vga_controller
    port map (
        --timing:
			clk_port         => clk,
		--to frame buffer
		    video_on_port    => open,
			addr_port		 => open,
		--to VGA display
            Hsync_port		 => open,
			Vsync_port		 => open,
	    --to frame updater
	        Vblank_port	     => open); --high when in vertical blanking region

    

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


end Behavioral;
