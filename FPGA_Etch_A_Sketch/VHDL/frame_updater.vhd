----------------------------------------------------------------------------------
-- Holden Langenhagen
-- Empty Frame updater entity

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity frame_updater is
  Port (
    clk_port     : in std_logic; -- 25 MHz system clock
  
    cursorX_port : in std_logic_vector(9 downto 0); -- current coordinates of the cursor
    cursorY_port : in std_logic_vector(8 downto 0);
    clear_port   : in std_logic; -- if clear switch is enabled
    
    Vblank_port : in std_logic; -- flag if frame has reached the bottom vertical blanking region (aka time to update the frame buffer)
    
    write_en_port : out std_logic;
    data_in_port : out std_logic;
    addr_port    : out std_logic_vector(18 downto 0)
  );
end frame_updater;

architecture Behavioral of frame_updater is

begin
    write_en_port <= '0'; -- placeholder dummy logic
    data_in_port <= '0';
    addr_port <= (others => '0');
end Behavioral;
