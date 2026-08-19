----------------------------------------------------------------------------------
-- Holden Langenhagen
-- Frame updater entity
-- Includes FSM and brush datapath

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity frame_updater is
  Port (
    clk_port     : in std_logic; -- 25 MHz system clock
  
    cursorX_port : in std_logic_vector(9 downto 0); -- current coordinates of the cursor
    cursorY_port : in std_logic_vector(8 downto 0);
    clear_port   : in std_logic; -- if clear switch is enabled
    
    Vblank_port : in std_logic; -- flag if frame has reached the bottom vertical blanking region (aka time to update the frame buffer)
    
    write_en_port : out std_logic;
    data_in_port : out std_logic;
    addr_port    : out std_logic_vector(18 downto 0));
end frame_updater;

architecture Behavioral of frame_updater is

	-- FSM SIGNALS
	type state is (IDLE,WAIT_VBLANK,WAIT_VIS_SCREEN,WRITE_CLR,WRITE_BRUSH);
    signal current_state,next_state : state := IDLE;
    signal brush_en,brush_done : std_logic := '0';
    signal brush_addr : std_logic_vector(18 downto 0) := (others => '0');
    
    -- DATAPATH SIGNALS
    constant DIAMETER : integer := 3; -- must be odd
    signal hcount,vcount : unsigned(3 downto 0) := (others => '0');
    signal cursorX : unsigned(9 downto 0) := (others => '0');
    signal cursorY : unsigned(8 downto 0) := (others => '0');
   	signal drawX : unsigned(9 downto 0) := (others => '0');
    signal drawY : unsigned(8 downto 0) := (others => '0');
    signal uns_addr : unsigned (18 downto 0) := (others => '0');

    

begin
	-- FSM +++++++++++++++++++++++++++++++++++++
    updateState : process(clk_port)
    begin
    	if rising_edge(clk_port) then
        	current_state <= next_state;
        end if;
    end process updateState;
    
    nextState : process(current_state,clear_port,Vblank_port,brush_done)
    begin
    	case current_state is
        	when IDLE => -- start brush write cycle or clear cycle
            	next_state <= WRITE_BRUSH when Vblank_port = '1'; 
                next_state <= WAIT_VBLANK when clear_port = '1';
            when WAIT_VBLANK => -- wait until the vertical blanking region
            	next_state <= WAIT_VIS_SCREEN when Vblank_port = '1';
            when WAIT_VIS_SCREEN => -- wait until address is back to top left
            	next_state <= WRITE_CLR when Vblank_port = '0';
            when WRITE_CLR => -- stop clear cycle when blanking segment reached again
            	next_state <= IDLE when Vblank_port = '1';
            when WRITE_BRUSH =>
            	next_state <= IDLE when brush_done = '1';
            when others =>
        end case;
    end process nextState;
    
    outputState : process(current_state,brush_addr)
    begin
    	write_en_port <= '0'; -- default outputs
        data_in_port <= '0';
        addr_port <= (others => '0');
        brush_en <= '0';
    	case current_state is
        	--when IDLE =>
            --when WAIT_VBLANK =>
            --when WAIT_VIS_SCREEN =>
            when WRITE_CLR =>
            	write_en_port <= '1'; -- write zeros to clear the screen         	
            when WRITE_BRUSH =>
            	write_en_port <= '1'; -- start the brush datapath and write the addresses it returns
                data_in_port <= '1';
                addr_port <= brush_addr;
                brush_en <= '1';
            when others =>
        end case;
    end process outputState;
    
    -- BRUSH DATAPATH +++++++++++++++++++++++++++++++++++++++++++++
    cursorX <= unsigned(cursorX_port); -- convert to allow for comparisons and math
	cursorY <= unsigned(cursorY_port);
    
    counters : process(clk_port) -- syncronous counters left to right top to bottom
    begin
        if rising_edge(clk_port) then
        	if brush_en = '1' then -- enable datapath counter
              if(hcount=DIAMETER-1) then
                  hcount<=(others => '0');
                  if(vcount=DIAMETER-1) then
                      vcount<=(others => '0');
                  else
                      vcount<=vcount+1;
                  end if;
              else
                  hcount<=hcount+1;
              end if;
            end if;
        end if;
    end process counters;
	brush_done <= '1' when vcount = DIAMETER-1 and hcount = DIAMETER-1 else '0'; -- done/TC signal for full brush stroke
    
    asyncDatapath : process(cursorX,cursorY,hcount,vcount)
    begin
    	drawX <= cursorX - (DIAMETER-1)/2 + hcount; -- default case
        drawY <= cursorY - (DIAMETER-1)/2 + vcount;
    	if cursorX > 639-(DIAMETER-1)/2 then -- set upper x bound
        	drawX <= "0000000000" + (639-(DIAMETER-1)/2) - (DIAMETER-1)/2 + hcount;
        elsif cursorX < (DIAMETER-1)/2 then -- set lower x bound
        	drawX <= "000000" & hcount;
        end if;
        if cursorY > 479-(DIAMETER-1)/2 then -- set upper y bound
        	drawY <= "000000000" + (479-(DIAMETER-1)/2) - (DIAMETER-1)/2 + vcount;
        elsif cursorY < (DIAMETER-1)/2 then -- set lower y bound
        	drawY <= "00000" & vcount;
        end if;
    end process asyncDatapath;
    brush_addr <= std_logic_vector("0000000000000000000" + 640*drawY+drawX); -- math to get address from x and y (frame buffer is structured left to right then top to bottom)

    
end Behavioral;