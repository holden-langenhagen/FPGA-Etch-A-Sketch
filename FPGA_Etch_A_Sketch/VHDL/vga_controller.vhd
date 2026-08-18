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
			clk_port         : in std_logic;
		--to frame buffer
		    video_on_port    : out std_logic;
			addr_port		 : out std_logic_vector(18 downto 0);
		--to VGA display
            Hsync_port		 : out std_logic;
			Vsync_port		 : out std_logic;
	    --to frame updater
	        Vblank_port	     : out std_logic); --high when in vertical blanking region
end vga_controller;

--Architecture Type:
architecture behavioral_architecture of vga_controller is

--Signal Declarations: 
--type state_type is (R1,R2,R3,L1,L2,L3, stall, hazardOn );
--signal current_state, next_state : state_type;


signal xcord, ycord : integer := 0; --xcord track of column, ycord track of row
signal video_on : std_logic := '0'; -- internal video on logic

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
        Hsync_port<='0';
    else
        --high when in visible space or porches
        Hsync_port<='1';
    end if;
    
    if(ycord>489) and (ycord<490) then
        Vsync_port<='0'; --low is the active sync pulse
    else
        Vsync_port<='1';
    end if;
    
    if(ycord>479) and (ycord<524) then
        Vblank_port<='1';
    else   
        Vblank_port<='0';
    end if;
end process setSyncs;

video_on <= '0' when xcord > 639 else '1';

-- logic to send dummy address to frame buffer after reaching video blank region
outputLogic : process(video_on,xcord,ycord)
begin
    if video_on = '0' then -- don't ask for memory out of range
        addr_port <= (others => '0');
    else
        addr_port <= std_logic_vector(to_unsigned(xcord+(640*ycord),19)); -- math to get address from x and y (frame buffer is structured left to right then top to bottom)
    end if;
end process outputLogic;


video_on_port <= std_logic(video_on);

end behavioral_architecture;
