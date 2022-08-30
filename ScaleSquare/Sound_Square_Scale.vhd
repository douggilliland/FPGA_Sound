----------------------------------------------------
-- VHDL code for Triangle Wave Generator
-- Creates Middle C
-- FPGA clock is 50 MHz
-- Prescale 50 MHz by 3 to get to 16.667 KHz
-- 256 samples in the table - one full wave
-- 256 clocks for PWM
-- Produces 261.00 Hz
-- output filter
--		https://github.com/douggilliland/FPGA_Sound/tree/main/Filter
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

----------------------------------------------------

entity Sound_Square_Scale is
port(	
	i_clk_50		:	in std_logic;
	i_Mute		:	in std_logic;
	i_pianoNote	:	in std_logic_vector(6 downto 0);
	o_PWMOut		:	out std_logic
);
end Sound_Square_Scale;

----------------------------------------------------

architecture behv of Sound_Square_Scale is		 	  

	signal w_ldPWMCtr			: std_logic;
	signal w_incROMAdr		: std_logic;
	signal w_PWMUnlatched	: std_logic;
	signal w_Up					: std_logic;
	signal w_PWMScaler		: std_logic_vector(19 downto 0);
	signal w_PWMScaleVals	: std_logic_vector(19 downto 0);

begin

SoundTable : entity work.SoundTable01
	port map (
		address			=> i_pianoNote,
		q					=> w_PWMScaleVals
	);

-- Pre-scale counter

w_ldPWMCtr <= '1' when w_PWMScaler = x"fffff" else '0';

PreScale_Counter : entity work.counterLdInc
generic map (n => 20)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> w_PWMScaleVals,
	i_load		=> w_ldPWMCtr,
	i_inc			=> '1',
	o_dataOut	=> w_PWMScaler
);


process(i_clk_50, w_PWMUnlatched)
begin
	if rising_edge(i_clk_50) then
		if w_PWMUnlatched = '1' and w_ldPWMCtr = '1' then
			w_PWMUnlatched <= '0';
		elsif w_ldPWMCtr = '1' then
			w_PWMUnlatched <= '1';
		end if;
	end if;
end process;

o_PWMOut <= w_PWMUnlatched and not i_Mute;

end behv;
