-- Holden Langenhagen 8/13/2026
-- Partner: Chase Hofmann
-- Etch-A-Sketch Final Project
-- Cursor Tracker Unit

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
entity cursor_tracker is
    Generic(
        CLK_DIVIDER : integer -- TC for ticker @60 Hz on hardware with 25 MHz clock input
    );
    Port (
        --timing:
        clk_port	: in std_logic;

        --control inputs:
        up_port	      	: in std_logic;
        down_port   	: in std_logic;
		left_port		: in std_logic;
        right_port      : in std_logic;
        
        --coordinate outputs
        x_port			: out std_logic_vector(9 downto 0);
        y_port			: out std_logic_vector(8 downto 0));
end cursor_tracker;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral of cursor_tracker is
    --=============================================================================
    --Signal Declarations: 
    --=============================================================================
    constant XMAX : integer := 639; -- 640x480 VGA Display
    constant YMAX : integer := 479;
    signal XEmpty,XFull : std_logic := '0';
    signal YEmpty,YFull : std_logic := '0';
    signal TickCount : unsigned(18 downto 0) := (others => '0'); -- room for CLK_DIVIDER
    signal TC : std_logic := '0'; -- terminal count for ticker
    signal XCount : unsigned(9 downto 0) := (others => '0'); -- UNCOMMENT FOR HARDWARE
    signal YCount : unsigned(8 downto 0) := (others => '0'); -- UNCOMMENT FOR HARDWARE
    --signal XCount : unsigned(9 downto 0) := to_unsigned(XMAX,10); -- SIMULATION FOR UPPER BOUNDS TESTING
    --signal YCount : unsigned(8 downto 0) := to_unsigned(YMAX,9); -- SIMULATION FOR UPPER BOUNDS TESTING

    
    begin
    --=============================================================================
    --Processes: 
    --=============================================================================
    -- Slow ticker to create a realistic cursor moving speed
    Ticker : process(clk_port)
    begin
        if rising_edge(clk_port) then
            TickCount <= TickCount + 1;
            if (TickCount = CLK_DIVIDER-1) then
                TickCount <= (others => '0');
            end if; 
        end if;
    end process Ticker;
    TC <= '1' when TickCount = CLK_DIVIDER-1 else '0'; -- Async TC Count
    
    -- Tick-synchronous button triggered X coordinate counter
    XCounter : process(clk_port,right_port,left_port,XFull,XEmpty)
    begin
    	if rising_edge(clk_port) then
        	if TC = '1' then
            	if (right_port = '1' and left_port = '0' and XFull = '0') then
                	XCount <= XCount + 1; -- INCREMENT X
                elsif (right_port = '0' and left_port = '1' and XEmpty = '0') then
                	XCount <= XCount - 1; -- DECREMENT X
                end if;
            end if;
        end if;
    end process XCounter;
    XFull <= '1' when XCount = XMAX else '0'; -- Bound cursor coordinates to screen
    XEmpty <= '1' when XCount = 0 else '0';
    
    -- Tick-synchronous button triggered Y coordinate counter
    YCounter : process(clk_port,right_port,left_port,YFull,YEmpty)
    begin
    	if rising_edge(clk_port) then
        	if TC = '1' then
            	if (up_port = '1' and down_port = '0' and YFull = '0') then
                	YCount <= YCount + 1; -- INCREMENT Y
                elsif (up_port = '0' and down_port = '1' and YEmpty = '0') then
                	YCount <= YCount - 1; -- DECREMENT Y
                end if;
            end if;
        end if;
    end process YCounter;
    YFull <= '1' when YCount = YMAX else '0'; -- Bound cursor coordinates to screen
    YEmpty <= '1' when YCount = 0 else '0';
    
    x_port <= std_logic_vector(XCount);
    y_port <= std_logic_vector(YCount);
    
end behavioral;