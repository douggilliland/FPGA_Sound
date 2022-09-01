----------------------------------------------------
-- VHDL code for Sine Wave Generator
-- Creates Grand Piano scale frequencies
-- Sine wave waveform
--		256 samples in the table - one full wave
--		50 MHz / 256 counts = 195.3125 KHz
--		Scaler runs at 195.3125 KHz divided by note frequency
--		Example
--			C4 (Middle C) is 261.5256 Hz with a divisor of 746.53
--			A0 is 27.5 Hs with a divisor of 7102.27
--			B7 is 3951.06 Hz with a divisor of 49.43
--
--	Doug Gilliland, 2022
--
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

----------------------------------------------------

entity ScaleSineGen is
port(	
	i_clk_50			:	in std_logic;								-- FPGA clock
	i_SampleHold	:	in std_logic;								-- Sample the waveform (from PWM)
	i_pianoNote		:	in std_logic_vector(6 downto 0);		-- Piano note
	o_SineWaveData	:	out std_logic_vector(7 downto 0)		-- 8-bit sine wave vale at sample
);
end ScaleSineGen;

----------------------------------------------------

architecture behv of ScaleSineGen is		 	  

	signal w_ldNoteCtr		: std_logic;
	signal w_NoteScaler		: std_logic_vector(15 downto 0);
	signal w_NoteScaleVals	: std_logic_vector(15 downto 0);
	signal w_SineTblAddr		: std_logic_vector(7 downto 0);
	signal w_ROMData			: std_logic_vector(7 downto 0);

begin

-- Note divisor = 50MHz / (Note Freq * 256)	
NoteScalerTable : entity work.NoteSineCounterTable
	port map (
		address	=> i_pianoNote,
		q			=> w_NoteScaleVals		-- Note Counter divider
	);

w_ldNoteCtr <= '1' when w_NoteScaler = w_NoteScaleVals else '0';
Note_Ctr : entity work.counterLdInc
generic map (n => 16)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> x"0000",
	i_load		=> w_ldNoteCtr,
	i_inc			=> '1',
	o_dataOut	=> w_NoteScaler
);

-- Count 256 samples per sinewave cycle
Sine_Ctr : entity work.counterLdInc
generic map (n => 8)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> x"00",
	i_load		=> '0',
	i_inc			=> w_ldNoteCtr,
	o_dataOut	=> w_SineTblAddr
);

-- Sinewave table
SineTblROM : ENTITY work.SineTable_256
	PORT map (
		address	=> w_SineTblAddr,
		q 			=> w_ROMData
	);

-- Note hold register
RegHoldTableVal : entity work.OutReg_Nbits
generic map (n => 8)
	port map (
		clock		=> i_clk_50,
		dataIn	=> w_ROMData,
		load		=> i_SampleHold,
		regOut	=> o_SineWaveData
	);

end behv;
