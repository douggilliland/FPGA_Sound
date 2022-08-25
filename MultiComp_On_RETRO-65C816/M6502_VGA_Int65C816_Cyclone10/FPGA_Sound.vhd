-- Sound Generator code

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity FPGA_Sound is
	port(
		i_n_reset		: in std_logic;
		i_clk_50			: in std_logic;
		
		o_Sq_Wave		: out		std_logic := '0';
		o_Sine_Wave		: out		std_logic := '0'
		
	);
end FPGA_Sound;

architecture struct of FPGA_Sound is

	signal w_reset_n			: std_logic;

begin
	debounceReset : entity work.Debouncer
	port map (
		i_clk		 	=> i_clk_50,
		i_PinIn		=> i_n_reset,
		o_PinOut		=> w_reset_n
	);

SQWCounter : entity work.Sound_SQWave_Middle_C
	port map (
		i_clk_50			=> i_clk_50,
		o_sqOut			=> o_Sq_Wave
	);
	
PWMCounter : entity work.Sound_PWM_Middle_C
	port map (
		i_clk_50			=> i_clk_50,
		o_PWMOut			=> o_Sine_Wave
	);
	
end;
