-- ------------------------------------------------------------------------------------------
-- Sound Generator Top Level Test Code
-- Implementations are in their own folders
-- FPGA card uses QMTECH Cyclone 10 - 10CL006YU256C8G
--		http://land-boards.com/blwiki/index.php?title=QMTECH_Cyclone_10CL006_FPGA_Card
-- Base board is:
--		http://land-boards.com/blwiki/index.php?title=RETRO-65C816
--	I/O on J1 connector
-- Separate outputs for each implementation
-- Squarewave - Middle C
-- Sinewave - Middle C
-- Sawtooth - Middle C
-- Triangle - Middle C
-- Squarewave - Grand Piano scale
-- Sinewave - Grand Piano scale
-- ------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity FPGA_Sound is
	port(
		i_clk_50			: in std_logic;					-- 50 MHz osillator on FPGA card
		i_play_n			: in std_logic;					-- Play pushbutton on card (mute when not pressed)
		
		o_Sq_Wave		: out		std_logic := '0';		-- Square wave
		o_Sine_Wave		: out		std_logic := '0';		-- Sine wave
		o_Saw_Wave		: out		std_logic := '0';		-- Sawtooth wave
		o_Tri_Wave		: out		std_logic := '0';		-- Triangle wave
		o_Square_Scale	: out		std_logic := '0';		-- Square wave Grand Piano scale
		o_Sine_Scale	: out		std_logic := '0';		-- Sine wave Grand Piano scale
		o_PolyLeft		: out		std_logic := '0';		-- Polyphonic sound left
		o_PolyRight		: out		std_logic := '0'		-- Polyphonic sound right
	);
end FPGA_Sound;

architecture struct of FPGA_Sound is

	signal w_reset_n			: std_logic;
	signal w_SQWave			: std_logic;
	signal w_PWMSineWave		: std_logic;
	signal w_Saw_Wave			: std_logic;
	signal w_Tri_Wave			: std_logic;
	signal w_SqScale_Wave	: std_logic;
	signal w_SineScale_Wave	: std_logic;
	signal w_Mute				: std_logic;
	signal w_NoteCounterL1	: std_logic_vector(6 downto 0);
	signal w_NoteCounterL2	: std_logic_vector(6 downto 0);
	signal w_NoteCounterR1	: std_logic_vector(6 downto 0);
	signal w_NoteCounterR2	: std_logic_vector(6 downto 0);

begin

-- Push play button to play on pin

w_Mute <= i_play_n;

o_Sq_Wave		<=  w_SQWave;
o_Sine_Wave		<= w_PWMSineWave;
o_Saw_Wave		<= w_Saw_Wave;
o_Tri_Wave		<= w_Tri_Wave;
o_Square_Scale	<= w_SqScale_Wave;
o_Sine_Scale	<= w_SineScale_Wave;

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

-- Square wave4 generator with piano key index as input
SquareScale : entity work.Sound_Square_Scale
	port map (
		i_clk_50			=> i_clk_50,
		i_Mute			=> w_Mute,
		i_pianoNote		=> w_NoteCounterL1,	-- Piano key index
		o_PWMOut			=> w_SqScale_Wave
	);

-- Sine wave4 generator with piano key index as input
SineScale : entity work.Sound_Sine_Scale
	port map (
		i_clk_50			=> i_clk_50,
		i_Mute			=> w_Mute,
		i_pianoNoteL1	=> w_NoteCounterL1,	-- Piano key index
		o_PWMOut			=> w_SineScale_Wave
	);

-- Step through Grand Piano scale 1 note every second
--NoteStepsL1 : entity work.NoteStepper
--	port map (
--		i_clk_50			=> i_clk_50,
--		i_StartNote		=> "0100101",
--		i_EndNote		=> "0110100",
--		o_Note			=> w_NoteCounterL1	-- Piano key index
--	);

-- Step through Grand Piano scale 1 note every second
--NoteStepsL2 : entity work.NoteStepper
--	port map (
--		i_clk_50			=> i_clk_50,
--		i_StartNote		=> "0100110",
--		i_EndNote		=> "0110110",
--		o_Note			=> w_NoteCounterL2	-- Piano key index
--	);

-- Step through Grand Piano scale 1 note every second
--NoteStepsR1 : entity work.NoteStepper
--	port map (
--		i_clk_50			=> i_clk_50,
--		i_StartNote		=> "0100111",
--		i_EndNote		=> "0110001",
--		o_Note			=> w_NoteCounterR1	-- Piano key index
--	);

-- Step through Grand Piano scale 1 note every second
--NoteStepsR2 : entity work.NoteStepper
--	port map (
--		i_clk_50			=> i_clk_50,
--		i_StartNote		=> "0100100",
--		i_EndNote		=> "0110010",
--		o_Note			=> w_NoteCounterR2	-- Piano key index
--	);

Player : entity work.ROM_Player
	port map (
		i_clk_50			=> i_clk_50,
		o_NoteL1			=> w_NoteCounterL1,
		o_NoteL2			=> w_NoteCounterL2,
		o_NoteR1			=> w_NoteCounterR1,
		o_NoteR2			=> w_NoteCounterR2
	);	

PolySound : entity work.PolySound_Sine_Scale
port map (	
	i_clk_50			=> i_clk_50,
	i_Mute			=> w_Mute,
	i_pianoNoteL1	=> w_NoteCounterL1,
	i_pianoNoteL2	=> w_NoteCounterL2,
	i_pianoNoteR1	=> w_NoteCounterR1,
	i_pianoNoteR2	=> w_NoteCounterR2,
	o_PWMOutL		=> o_PolyLeft,
	o_PWMOutR		=> o_PolyRight
);
	
end;
