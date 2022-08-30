-- ------------------------------------------------------------------------------------------
-- Note Scale Counter
-- Steps through each note of the Grand Piano 
-- Increments one note every second
-- ------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity NoteStepper is
	port(
		i_clk_50			: in std_logic;									-- 50 MHz osillator on FPGA card
		o_Note			: out		std_logic_vector(6 downto 0)		-- Note Number
	);
end NoteStepper;

architecture struct of NoteStepper is

	signal w_NoteTC			: std_logic;
	signal w_1HzTC				: std_logic;
	
	signal w_1HzCounter		: std_logic_vector(25 downto 0);
	signal w_NoteCounter		: std_logic_vector(6 downto 0);

begin

-- 1 Hz counter to cycle through notes
w_1HzTC <=  '1' when w_1HzCounter = "10"&x"faf07f" else  -- 1 Hz
--w_1HzTC <=  '1' when w_1HzCounter = "00"&x"faf07f" else -- faster
				'0';
Note1Hz_Counter : entity work.counterLdInc
generic map (n => 26)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> "00"&x"000000",
	i_load		=> w_1HzTC,
	i_inc			=> '1',
	o_dataOut	=> w_1HzCounter
);

-- Count through octave around Middle C
w_NoteTC <= '1' when w_NoteCounter = "0110000" else		-- Top note to play
				'1' when w_NoteCounter = "0000000" else		-- start-up condition
				'0';
Note_Counter : entity work.counterLdInc
generic map (n => 7)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> "0100101",		-- pre-load with first not to play on scale
	i_load		=> w_NoteTC,
	i_inc			=> w_1HzTC,
	o_dataOut	=> w_NoteCounter
);

o_Note <= w_NoteCounter;

end;
