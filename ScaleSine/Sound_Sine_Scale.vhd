----------------------------------------------------
-- VHDL code for Sine Wave Generator
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

entity Sound_Sine_Scale is
port(	
	i_clk_50		:	in std_logic;
	i_Mute		:	in std_logic;
	i_pianoNote	:	in std_logic_vector(6 downto 0);
	o_PWMOut		:	out std_logic
);
end Sound_Sine_Scale;

----------------------------------------------------

architecture behv of Sound_Sine_Scale is		 	  

	signal w_PWMUnlatched		: std_logic;
	signal w_NoteHoldReg			: std_logic;
	signal w_SineSampleLatched	: std_logic_vector(7 downto 0);
	signal w_PWMCt					: std_logic_vector(9 downto 0);
	signal w_SineTblAddr			: std_logic_vector(7 downto 0);

begin

-- Generate sine wave scale outputs
sineCounter : entity work.ScaleSineGen
port map (	
	i_clk_50			=> i_clk_50,
	i_SampleHold	=> w_NoteHoldReg,
	i_pianoNote		=> i_pianoNote,
	o_SineWaveData	=> w_SineSampleLatched
);

----------------------------------------------------
-- PWM

PWM_Ctr : entity work.counterLdInc
generic map (n => 10)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> "00"&x"00",
	i_load		=> '0',
	i_inc			=> '1',
	o_dataOut	=> w_PWMCt
);

w_PWMUnlatched <= '0' when ((w_PWMCt(9 downto 2) < w_SineSampleLatched) and (i_Mute = '0')) else		-- Do the pulse
                  '0' when ((w_PWMCt(9) = '0') and (i_Mute = '1')) else							-- Mute = 50/50 duty cycle to set AC zero
						'1';

w_NoteHoldReg <= '1' when w_PWMCt = "1111111111" else '0';

process(i_clk_50, w_PWMUnlatched)
begin
	if rising_edge(i_clk_50) then
		o_PWMOut <= w_PWMUnlatched;
	end if;
end process;	

end behv;
