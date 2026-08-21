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
    dout_port : in std_logic_vector(2 downto 0); -- data from the frame buffer coming in to vga synchronizer
    vsync_port : in std_logic;
    hsync_port : in std_logic;
    video_on_port   : in std_logic;
    
    vsync_out_port : out std_logic;
    hsync_out_port : out std_logic;
    vgaR_port : out std_logic_vector(3 downto 0);
    vgaG_port : out std_logic_vector(3 downto 0);
    vgaB_port : out std_logic_vector(3 downto 0)
  );
end vga_synchronizer;

architecture Behavioral of vga_synchronizer is

--not necessary anymore, but still nice to have shortcuts
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
    --color<=dout_port; --assigning dout_port to my color vector, just kind of for simplicity
    --old logic
    if dout_port = "000" then
        color <= WHITE;
    elsif dout_port="111" then
        color<= BLACK;
    else
        color <= dout_port;
    end if;
    if video_on_port = '0' then -- blanking regions
        color <= BLACK;
    end if;
end process rgbDecipher;

vgaR_port <= (others => color(2)); -- set individual color channels from internal color signal
vgaB_port <= (others => color(1)); --using others all set to value of color to ensure that I'm transmitting "1111" not "1000"
vgaG_port <= (others => color(0));

end Behavioral;
