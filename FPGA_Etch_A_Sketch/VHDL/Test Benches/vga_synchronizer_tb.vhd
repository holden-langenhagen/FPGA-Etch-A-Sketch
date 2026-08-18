----------------------------------------------------------------------------------
-- Holden Langenhagen

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity vga_synchronizer_tb is
end vga_synchronizer_tb;

architecture Behavioral of vga_synchronizer_tb is

component vga_synchronizer is
  Port (
    clk_port : in std_logic;
    dout_port : in std_logic; -- data from the frame buffer
    vsync_port : in std_logic;
    hsync_port : in std_logic;
    video_on_port   : in std_logic;
    
    vsync_out_port : out std_logic := '1';
    hsync_out_port : out std_logic := '1';
    vgaR_port : out std_logic;
    vgaG_port : out std_logic;
    vgaB_port : out std_logic
  );
end component vga_synchronizer;



constant CLK_PERIOD : time := 40ns; -- 25 MHz
signal clk : std_logic := '0';
signal dout,vsync,hsync,video_on : std_logic := '0';

begin

uut : vga_synchronizer
    port map (
        --timing:
			clk_port         => clk,
        dout_port   => dout, -- data from the frame buffer
        vsync_port  => vsync,
        hsync_port  => hsync,
        video_on_port   => video_on,
        
        vsync_out_port => open,
        hsync_out_port => open,
        vgaR_port => open,
        vgaG_port => open,
        vgaB_port => open);

    

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
    
    stimProc : process
    begin
        vsync <= '1';
        hsync <= '1';
        video_on <= '1';
        dout <= '0'; -- should be white
        wait for 10*CLK_PERIOD;
        
        video_on <= '0'; -- should turn it to black
        wait for 10*CLK_PERIOD;
        
        video_on <= '1';
        dout <= '1'; -- should be black
        vsync <= '1';
        hsync <= '1';
        wait for 10* CLK_PERIOD;
        dout <= '0';
        vsync <= '0';
        hsync <= '0';
        wait for 10* CLK_PERIOD;

    end process stimProc;

end Behavioral;
