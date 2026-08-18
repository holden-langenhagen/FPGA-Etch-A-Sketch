----------------------------------------------------------------------------------
-- Holden Langenhagen
-- Deciphers the frame buffer output into colors and syncronizes this with the vsync and hsync signals by delaying them two clock cycles

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity vga_synchronizer is
  Port (
    clk_port : in std_logic;
    dout_port : in std_logic; -- data from the frame buffer
    vsync_port : in std_logic;
    hsync_port : in std_logic;
    video_on_port   : in std_logic;
    
    vsync_out_port : out std_logic;
    hsync_out_port : out std_logic;
    vgaR_port : out std_logic;
    vgaG_port : out std_logic;
    vgaB_port : out std_logic
  );
end vga_synchronizer;

architecture Behavioral of vga_synchronizer is

constant BLACK : std_logic_vector(2 downto 0) := "000"; -- digits are R, G, and B respectively
constant WHITE : std_logic_vector(2 downto 0) := "111"; -- digits are R, G, and B respectively

signal vsync_onelate : std_logic := '0';
signal hsync_onelate : std_logic := '0';
signal color : std_logic_vector(2 downto 0) := BLACK;

begin

oneDelay : process(clk_port) -- first delay register
begin
    if rising_edge(clk_port) then
        vsync_onelate <= vsync_port;
        hsync_onelate <= hsync_port;
    end if;
end process oneDelay;

twoDelay : process(clk_port) -- second delay register
begin
    if rising_edge(clk_port) then
        vsync_out_port <= vsync_onelate;
        hsync_out_port <= hsync_onelate;
    end if;
end process twoDelay;

rgbDecipher : process(dout_port,video_on_port)
begin
    if dout_port = '0' then
        color <= WHITE;
    else
        color <= BLACK;
    end if;
    
    if video_on_port = '0' then -- blanking regions
        color <= BLACK;
    end if;
end process rgbDecipher;

vgaR_port <= color(2); -- set individual color channels from internal color signal
vgaB_port <= color(1);
vgaG_port <= color(0);

end Behavioral;
