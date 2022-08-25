-- Sound Generator code

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity FPGA_Sound is
	port(
		i_clk_50			: in std_logic;
		i_play_n			: in std_logic;
		
		o_Sq_Wave		: out		std_logic := '0';
		o_Sine_Wave		: out		std_logic := '0'
		
	);
end FPGA_Sound;

architecture struct of FPGA_Sound is

	signal w_reset_n			: std_logic;
	signal w_SQWave			: std_logic;
	signal w_PWMSineWave		: std_logic;

begin

-- Push play button to play on pin

o_Sq_Wave	<= (not i_play_n) and w_SQWave;
o_Sine_Wave	<= (not i_play_n) and w_PWMSineWave;

SQWCounter : entity work.Sound_SQWave_Middle_C
	port map (
		i_clk_50			=> i_clk_50,
		o_sqOut			=> w_SQWave
	);
	
PWMCounter : entity work.Sound_PWM_Middle_C
	port map (
		i_clk_50			=> i_clk_50,
		o_PWMOut			=> w_PWMSineWave
	);
	
end;
