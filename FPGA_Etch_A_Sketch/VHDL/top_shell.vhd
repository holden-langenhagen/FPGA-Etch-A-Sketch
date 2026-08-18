----------------------------------------------------------------------------------
-- Holden Langenhagen
-- Top Shell
-- Currently Included Entities:
-- Everything
----------------------------------------------------------------------------------
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
entity top_shell is
    Generic (
        CLOCK_DIVIDER_CONSTANT : integer := 4; -- 25 MHz clock
        STABLE_CONSTANT : integer := 100; -- Adjustable debouncing constant
        TICKER_DIVIDER : integer := 416667 -- ticker divider to make cursor move at reasonable speed (default is about 60Hz) at system clk
    );
    Port (
			clk_ext_port		 : in std_logic;		-- mapped to external IO device (100 MHz Clock)		
			up_ext_port          : in std_logic;
			down_ext_port        : in std_logic;
			left_ext_port        : in std_logic;
			right_ext_port       : in std_logic;
			clear_ext_port       : in std_logic;
			Hsync_ext_port			: out std_logic;    -- ALL of the outs mapped to the VGA
			Vsync_ext_port			: out std_logic;    
			vgaR_ext_port			: out std_logic;    
			vgaG_ext_port			: out std_logic;    
			vgaB_ext_port			: out std_logic);    

    end top_shell;

architecture behavioral of top_shell is

--=============================================================================
--Sub-Component Declarations:
--=============================================================================
--System Clock Generation:
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

--Button Debouncer:
component button_interface is
    Generic( STABLE_TIME : integer := 100 );
    Port( clk_port            : in  std_logic;
         button_port         : in  std_logic;
         button_db_port      : out std_logic;
         button_mp_port      : out std_logic);
end component;

--Cursor Tracker:
component cursor_tracker is
    Generic(
        CLK_DIVIDER : integer);
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
end component;

-- FRAME BUFFER MEMORY BLOCK RAM
component frame_buffer_IP IS
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END component;

-- VGA CONTROLLER, sends pixel coordinates and sync signals
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

-- VGA Syncronizer, gets rgb from frame buffer dout and delays vsync and hsync
component vga_synchronizer is
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
end component vga_synchronizer;

-- Frame Updater, does memory writing logic given a cursor position, contains FSM
component frame_updater is
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
end component frame_updater;

signal system_clk: std_logic := '0'; -- internal 25MHz clock signal to be wired up
signal up,down,left,right,clear : std_logic := '0'; -- internal debounced input signals
signal cursorX : std_logic_vector(9 downto 0) := (others => '0');
signal cursorY : std_logic_vector(8 downto 0) := (others => '0');
signal video_on,hsync,vsync,vblank : std_logic := '0';
signal data_out,data_in,write_en : std_logic_vector(0 downto 0);
signal writeAddr : std_logic_vector(18 downto 0) := (others => '0');
signal readAddr : std_logic_vector(18 downto 0) := (others => '0');
signal bufAddr : std_logic_vector(18 downto 0) := (others => '0');

begin

-- CLOCK DIVIDER +++++++++++++++++++++++++++++++++++++++++++++++++
clocking : system_clock_generator
    generic map(
        CLOCK_DIVIDER_RATIO => CLOCK_DIVIDER_CONSTANT
    ) 
    port map(
    input_clk_port  => clk_ext_port,     -- External clock
    system_clk_port => system_clk,       -- System clock
    fwd_clk_port => OPEN);
    
 -- BUTTON DEBOUNCERS ++++++++++++++++++++++++++++++++++++++++++++++++++
 up_debounce : button_interface
    generic map(
        STABLE_TIME => STABLE_CONSTANT
    )
    port map(
        clk_port            => system_clk, -- system clock
        button_port         => up_ext_port,
        button_db_port      => up,
        button_mp_port      => open);
 
 down_debounce : button_interface
    generic map(
        STABLE_TIME => STABLE_CONSTANT
    )
    port map(
        clk_port            => system_clk, -- system clock
        button_port         => down_ext_port,
        button_db_port      => down,
        button_mp_port      => open);
 
 left_debounce : button_interface
    generic map(
        STABLE_TIME => STABLE_CONSTANT
    )
    port map(
        clk_port            => system_clk, -- system clock
        button_port         => left_ext_port,
        button_db_port      => left,
        button_mp_port      => open);
 
 right_debounce : button_interface
    generic map(
        STABLE_TIME => STABLE_CONSTANT
    )
    port map(
        clk_port            => system_clk, -- system clock
        button_port         => right_ext_port,
        button_db_port      => right,
        button_mp_port      => open);
  
 clear_debounce : button_interface
    generic map(
        STABLE_TIME => STABLE_CONSTANT
    )
    port map(
        clk_port            => system_clk, -- system clock
        button_port         => clear_ext_port,
        button_db_port      => clear,
        button_mp_port      => open);
 
 -- CURSOR TRACKER ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tracker : cursor_tracker
    generic map(
        CLK_DIVIDER => TICKER_DIVIDER
    )
    port map(
        --timing:
        clk_port	=> system_clk,

        --control inputs:
        up_port	      	=> up,
        down_port   	=> down,
		left_port		=> left,
        right_port      => right,
        
        --coordinate outputs
        x_port			=> cursorX,
        y_port			=> cursorY);
 
-- Frame Updater ++++++++++++++++++++++++++++++++++++++++++++++++++++++
frame_update : frame_updater
  PORT MAP (
    clk_port     => system_clk, -- 25 MHz system clock
  
    cursorX_port => cursorX, -- current coordinates of the cursor
    cursorY_port => cursorY,
    clear_port   => clear, -- if clear switch is enabled
    
    Vblank_port => vblank, -- flag if frame has reached the bottom vertical blanking region (aka time to update the frame buffer)
    
    write_en_port => write_en(0),
    data_in_port => data_in(0),
    addr_port    => writeAddr
  );
 
 bufAddr <= readAddr when video_on = '1' else writeAddr; -- Mux to choose correct address
 
-- FRAME BUFFER MEMORY BLOCK RAM +++++++++++++++++++++++++++++++++++++++++++++++
frame_buf : frame_buffer_IP
  PORT MAP(
    clka => system_clk,
    ena => '1',
    wea => write_en,
    addra => bufAddr,
    dina => data_in,
    douta => data_out
  );
  
-- VGA Timing Controller +++++++++++++++++++++++++++++++++++++++++++++++
vga_control : vga_controller
    port map (
		--timing:
			clk_port        => system_clk,
		--to frame buffer and syncronizer
		    video_on_port   => video_on,
			addr_port       => readAddr,
		--to syncronizer
            Hsync_port      => hsync,
			Vsync_port      => vsync,
	    --to frame updater
	        Vblank_port     => vblank);
	        
-- VGA Syncronizer +++++++++++++++++++++++++++++++++++++++++++++++++++
vga_sync : vga_synchronizer
  port map (
    clk_port => system_clk,
    dout_port => data_out(0), -- data from the frame buffer
    vsync_port => vsync,
    hsync_port => hsync,
    video_on_port => video_on,
    
    vsync_out_port => vsync_ext_port,
    hsync_out_port => hsync_ext_port,
    vgaR_port => vgaR_ext_port,
    vgaG_port => vgaG_ext_port,
    vgaB_port => vgaB_ext_port
  );
        
end behavioral;
