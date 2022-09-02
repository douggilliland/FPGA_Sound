----------------------------------------------------
--	PolyPolySound_Sine_Scale
-- VHDL code for Polyphonic Sine Wave Generator
--	Two channels
--	Two notes per channel
-- Creates Grand Piano scale frequencies
-- PWM
--		FPGA clock is 50 MHz
--		PWM runs at 50/4 = 12.5 MHz (clock divided by 4)
--		256 clocks at 12.5 MH = 48.8 KHz
-- Sine wave waveform 
-- 	Clock runs independently from PWM side
--		256 samples in the table - one full wave
--		50 MHz / 256 counts = 195.3125 KHz
--		Scaler runs at 195.3125 KHz divided by note frequency
--		Example
--			C4 (Middle C) is 261.5256 Hz with a divisor of 746.53
--			A0 is 27.5 Hs with a divisor of 7102.27
--			B7 is 3951.06 Hz with a divisor of 49.43
--	Sine wave table is sampled every PWM cycle (48.8 KHz)
-- output filter
--		https://github.com/douggilliland/FPGA_Sound/tree/main/Filter
--
--	Doug Gilliland, 2022
--
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

----------------------------------------------------

entity PolySound_Sine_Scale is
port (
	i_clk_50			:	in std_logic;
	i_Mute			:	in std_logic;
	i_pianoNoteL1	:	in std_logic_vector(6 downto 0);
	i_pianoNoteL2	:	in std_logic_vector(6 downto 0);
	i_pianoNoteR1	:	in std_logic_vector(6 downto 0);
	i_pianoNoteR2	:	in std_logic_vector(6 downto 0);
	o_PWMOutL		:	out std_logic;
	o_PWMOutR		:	out std_logic
);
end PolySound_Sine_Scale;

----------------------------------------------------

architecture behv of PolySound_Sine_Scale is		 	  

	signal w_NoteHoldReg				: std_logic;
	signal w_PWMUnlatchedL			: std_logic;
	signal w_PWMUnlatchedR			: std_logic;
	signal w_SineSampleLatchedL1	: std_logic_vector(7 downto 0);
	signal w_SineSampleLatchedL2	: std_logic_vector(7 downto 0);
	signal w_SineSampleLatchedL	: std_logic_vector(8 downto 0);
	signal w_SineSampleLatchedR1	: std_logic_vector(7 downto 0);
	signal w_SineSampleLatchedR2	: std_logic_vector(7 downto 0);
	signal w_SineSampleLatchedR	: std_logic_vector(8 downto 0);
	signal w_PWMCt						: std_logic_vector(7 downto 0);

begin

-- Generate sine wave scale outputs
sineCounterL1 : entity work.ScaleSineGen
port map (	
	i_clk_50			=> i_clk_50,
	i_SampleHold	=> w_NoteHoldReg,
	i_pianoNote		=> i_pianoNoteL1,
	o_SineWaveData	=> w_SineSampleLatchedL1
);

-- Generate sine wave scale outputs
sineCounterL2 : entity work.ScaleSineGen
port map (	
	i_clk_50			=> i_clk_50,
	i_SampleHold	=> w_NoteHoldReg,
	i_pianoNote		=> i_pianoNoteL2,
	o_SineWaveData	=> w_SineSampleLatchedL2
);

-- Generate sine wave scale outputs
sineCounterR1 : entity work.ScaleSineGen
port map (	
	i_clk_50			=> i_clk_50,
	i_SampleHold	=> w_NoteHoldReg,
	i_pianoNote		=> i_pianoNoteR1,
	o_SineWaveData	=> w_SineSampleLatchedR1
);

-- Generate sine wave scale outputs
sineCounterR2 : entity work.ScaleSineGen
port map (	
	i_clk_50			=> i_clk_50,
	i_SampleHold	=> w_NoteHoldReg,
	i_pianoNote		=> i_pianoNoteR2,
	o_SineWaveData	=> w_SineSampleLatchedR2
);

PWM : entity work.PWM_Counter
port map (	
	i_clk_50			=> i_clk_50,
	o_PWMCt			=> w_PWMCt,
	o_NoteHoldReg	=> w_NoteHoldReg
);

----------------------------------------------------
-- PWM

w_SineSampleLatchedL <= (('0'&w_SineSampleLatchedL1) + ('0'&w_SineSampleLatchedL2));

w_PWMUnlatchedL <=	'0' when ((w_PWMCt < w_SineSampleLatchedL(8 downto 1)) and (i_Mute = '0')) else		-- Do the pulse
							'0' when ((w_PWMCt(7) = '0') and (i_Mute = '1')) else							-- Mute = 50/50 duty cycle to set AC zero
							'1';

process(i_clk_50, w_PWMUnlatchedL)
begin
	if rising_edge(i_clk_50) then
		o_PWMOutL <= w_PWMUnlatchedL;
	end if;
end process;	

w_SineSampleLatchedR <= ('0'&w_SineSampleLatchedR1) + ('0'&w_SineSampleLatchedR2);

w_PWMUnlatchedR <=	'0' when ((w_PWMCt < w_SineSampleLatchedR(8 downto 1)) and (i_Mute = '0')) else		-- Do the pulse
							'0' when ((w_PWMCt(7) = '0') and (i_Mute = '1')) else							-- Mute = 50/50 duty cycle to set AC zero
							'1';

process(i_clk_50, w_PWMUnlatchedR)
begin
	if rising_edge(i_clk_50) then
		o_PWMOutR <= w_PWMUnlatchedR;
	end if;
end process;	

end behv;
