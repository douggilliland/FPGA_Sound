-- ------------------------------------------------------------------------------------------
-- Sound Generator Top Level Test Code
-- Implementations are in their own folders
-- FPGA card uses QMTECH Cyclone 10 - 10CL006YU256C8G
--		http://land-boards.com/blwiki/index.php?title=QMTECH_Cyclone_10CL006_FPGA_Card
-- Base board is:
--		http://land-boards.com/blwiki/index.php?title=RETRO-65C816
--	I/O on J1 connector
-- Separate outputs for each implementation
-- Squarewave
-- Sinewave
-- Sawtooth
-- ------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity FPGA_Sound is
	port(
		i_clk_50			: in std_logic;					-- 50 MHz osillator on FPGA card
		i_play_n			: in std_logic;					-- Play pushbutton on card
		
		o_Sq_Wave		: out		std_logic := '0';		-- Square wave
		o_Sine_Wave		: out		std_logic := '0';		-- Sine wave
		o_Saw_Wave		: out		std_logic := '0';		-- Sawtooth wave
		o_Tri_Wave		: out		std_logic := '0';		-- Triangle wave
		o_Square_Scale	: out		std_logic := '0'		-- Triangle scale
	);
end FPGA_Sound;

architecture struct of FPGA_Sound is

	signal w_reset_n			: std_logic;
	signal w_SQWave			: std_logic;
	signal w_PWMSineWave		: std_logic;
	signal w_Saw_Wave			: std_logic;
	signal w_Tri_Wave			: std_logic;
	signal w_Mute				: std_logic;
	signal w_NoteTC			: std_logic;
	signal w_1HzTC				: std_logic;
	signal w_NoteCounter		: std_logic_vector(6 downto 0);
	signal w_1HzCounter		: std_logic_vector(25 downto 0);

begin

-- Push play button to play on pin

w_Mute <= i_play_n;

o_Sq_Wave	<=  w_SQWave;
o_Sine_Wave	<= w_PWMSineWave;
o_Saw_Wave	<= w_Saw_Wave;
o_Tri_Wave	<= w_Tri_Wave;

-- Middle C square wave
SQWCounter : entity work.Sound_SQWave_Middle_C
	port map (
		i_clk_50			=> i_clk_50,
		i_Mute			=> w_Mute,
		o_sqOut			=> w_SQWave
	);

-- Middle C sine wave
SineWCounter : entity work.Sound_PWM_Middle_C
	port map (
		i_clk_50			=> i_clk_50,
		i_Mute			=> w_Mute,
		o_PWMOut			=> w_PWMSineWave
	);

-- Middle C sawtooth wave
SawWCounter : entity work.Sound_Sawtooth_Middle_C
	port map (
		i_clk_50			=> i_clk_50,
		i_Mute			=> w_Mute,
		o_PWMOut			=> w_Saw_Wave
	);

-- Middle C triangle wave
TriangleMiddleC : entity work.Sound_Triangle_Middle_C
	port map (
		i_clk_50			=> i_clk_50,
		i_Mute			=> w_Mute,
		o_PWMOut			=> w_Tri_Wave
	);

-- 1 Hz counter to cycle through notes
w_1HzTC <=  '1' when w_1HzCounter = "10"&x"faf07f" else  -- 1 Hz
--w_1HzTC <=  '1' when w_1HzCounter = "00"&x"faf07f" else 
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
w_NoteTC <= '1' when w_NoteCounter = "0110000" else
				'1' when w_NoteCounter = "0000000" else
				'0';
Note_Counter : entity work.counterLdInc
generic map (n => 7)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> "0100101",
	i_load		=> w_NoteTC,
	i_inc			=> w_1HzTC,
	o_dataOut	=> w_NoteCounter
);

-- Square wave4 generator with piano key index as input
SquareScale : entity work.Sound_Square_Scale
	port map (
		i_clk_50			=> i_clk_50,
		i_Mute			=> w_Mute,
		i_pianoNote		=> w_NoteCounter,	-- Piano key index
		o_PWMOut			=> o_Square_Scale
	);

end;
