--VGA controller

--Library Declarations:
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

--Entity Declaration:
entity vga_controller is
    Port (
		--timing:
			clk_port 		             : in std_logic;
		--to frame buffer
		    video_on       	             : out std_logic;
			vga_controller_address       : out std_logic;
			pixelx			             : out std_logic;
			pixely			             : out std_logic;
		--to VGA display
            Hsync			             : out std_logic;
			Vsync			             : out std_logic;
	    --to frame updater
	        Vblank			              : out std_logic; --high when in vertical blanking region
end VGA_test;

--Architecture Type:
architecture behavioral_architecture of vga_controller is

--Signal Declarations: 
--type state_type is (R1,R2,R3,L1,L2,L3, stall, hazardOn );
--signal current_state, next_state : state_type;


signal xcord, ycord : integer := 0; --xcord track of column, ycord track of row
--xcord 0 to 799 and ycord 0 to 524
-- xcord: 
-- 0-639 Visible        640-655 front porch         656-751 Hsync       75
-- ycord:
-- 0-479 Visible    480-489 front porch     490-491 Vsync             

--=============================================================================
--Processes: 	
begin                
incrementcords : process(clk_port)
begin
    if rising_edge(clk_port) then
        if(xcord=799) then
            xcord<=0;
            if(ycord=524) then
                ycord<=0;
            else
                ycord<=ycord+1;
            end if;
        else
            xcord<=xcord+1;
        end if;
    end if;
end process incrementcords;
        
setSyncs : process(ycord,xcord) 
begin
    --hsync and vsync update process
    if(xcord>=656) and (xcord<=751) then
        --low when in Hsync area from diagram in slides
        Hsync<='0';
    else
        --high when in visible space or porches
        Hsync<='1';
    end if;
    if(ycord>489) and (ycord<490) then
        Vsync<='0'; --low is the active sync pulse
    else
        Vsync<='1';
    end if;
    if(xcord>639) and (xcord<799) then
        video_on<='0';
    else   
        video_on<='1';
    end if;
    if(ycord>479) and (ycord<524) then
        video_on<='0';
        Vblank<='1';
    else   
        video_on<='1';
        Vblank<='0';
    end if;
    
    
end process setSyncs;

colorDisplay : process(ycord,xcord)
begin
-- large vertical color bands, evenly spaced horizontally, 320px vertically
-- Gray, yellow, cyan, green, purple, red, blue
    vgaR <= '0';
    vgaG <='0';
    vgaB <='0';
    
    if (xcord >= 0) and (xcord < 92) and (ycord >= 0) and (ycord < 320) then
        vgaR <= '1';
        vgaG <='1';
        vgaB <='1';
    elsif (xcord >= 92) and (xcord < 184) and (ycord >= 0) and (ycord < 320) then
        vgaR <= '0';
        vgaG <='1';
        vgaB <='1';
    elsif (xcord >= 184) and (xcord < 276) and (ycord >= 0) and (ycord < 320) then
        vgaR <= '0';
        vgaG <='0';
        vgaB <='1';     
    end if;
end process colorDisplay;
end behavioral_architecture;
