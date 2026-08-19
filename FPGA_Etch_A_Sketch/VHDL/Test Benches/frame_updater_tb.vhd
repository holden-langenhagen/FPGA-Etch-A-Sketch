-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity frame_updater_tb is
end frame_updater_tb;

architecture testbench of frame_updater_tb is

    component frame_updater is
        Port (
          clk_port     : in std_logic; -- 25 MHz system clock

          cursorX_port : in std_logic_vector(9 downto 0); -- current coordinates of the cursor
          cursorY_port : in std_logic_vector(8 downto 0);
          clear_port   : in std_logic; -- if clear switch is enabled

          Vblank_port : in std_logic; -- flag if frame has reached the bottom vertical blanking region (aka time to update the frame buffer)

          write_en_port : out std_logic;
          data_in_port : out std_logic;
          addr_port    : out std_logic_vector(18 downto 0));
    end component frame_updater;

	constant CLK_PERIOD : time := 40 ns; -- 25 MHz clock
    signal clk,clear,vblank : std_logic := '0';
    signal cursorX : std_logic_vector(9 downto 0);
    signal cursorY : std_logic_vector(8 downto 0);


    begin

    uut : frame_updater
        Port Map (
            clk_port     => clk, -- 25 MHz system clock

            cursorX_port => cursorX, -- current coordinates of the cursor
            cursorY_port => cursorY,
            clear_port   => clear, -- if clear switch is enabled

            Vblank_port => vblank, -- flag if frame has reached the bottom vertical blanking region (aka time to update the frame buffer)

            write_en_port => open,
            data_in_port => open,
            addr_port    => open);
	
    clkGen : process -- Generate 25 MHz clk
    begin
    	clk <= '0';
        wait for (CLK_PERIOD)/2;
        
        clk <= '1';
        wait for (CLK_PERIOD)/2;
    end process clkGen;
    
    stimProc : process -- Send coordinates and inputs to study response
    begin
    	cursorX <= "0001000000"; -- coordinate (64,64)
        cursorY <= "001000000";
        vblank <= '0';
        wait for 15*CLK_PERIOD; -- tests brush writing cycle
        
        vblank <= '1';
        wait for 10*CLK_PERIOD;
        
        vblank <= '0';
        clear <= '1';
        wait for 5*CLK_PERIOD; -- test clear cycle
        clear <= '0';
        wait for 10*CLK_PERIOD;
        
        vblank <= '1';
        wait for 10*CLK_PERIOD;

        
    end process stimProc;
	
end testbench;