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

	signal w_ldPWMCtr			: std_logic;
	signal w_incROMAdr		: std_logic;
	signal w_PWMUnlatched	: std_logic;
	signal w_Up					: std_logic;
	signal w_SineSampleCt	: std_logic_vector(7 downto 0);
	signal w_ROMData			: std_logic_vector(7 downto 0);
	signal w_PWMCt				: std_logic_vector(9 downto 0);
	signal w_PWMScaler		: std_logic_vector(15 downto 0);
	signal w_PWMScaleVals	: std_logic_vector(15 downto 0);

begin

NoteSineSoundTable : entity work.NoteSineCounterTable
	port map (
		address			=> i_pianoNote,
		q					=> w_PWMScaleVals
	);

-- Note counter

w_ldPWMCtr <= '1' when w_PWMScaler = w_PWMScaleVals else '0';

PreScale_Counter : entity work.counterLdInc
generic map (n => 16)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> x"0000",
	i_load		=> w_ldPWMCtr,
	i_inc			=> '1',
	o_dataOut	=> w_PWMScaler
);

SineWave_Counter : entity work.counterLdInc
generic map (n => 8)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> x"00",
	i_load		=> '0',
	i_inc			=> w_ldPWMCtr,
	o_dataOut	=> w_SineSampleCt
);

SineWaveROM : ENTITY work.MiddleCSineTable
	PORT map (
		address	=> w_SineSampleCt,
		q 			=> w_ROMData
	);

PWM_Counter : entity work.counterLdInc
generic map (n => 10)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> "00"&x"00",
	i_load		=> '0',
	i_inc			=> '1',
	o_dataOut	=> w_PWMCt
);

w_PWMUnlatched <= '0' when w_PWMCt(7 downto 0) < w_ROMData else '1';

--o_PWMOut <= w_PWMUnlatched and not i_Mute;

process(i_clk_50, w_PWMUnlatched)
begin
	if rising_edge(i_clk_50) then
		o_PWMOut <= w_PWMUnlatched and not i_Mute;
	end if;
end process;	

end behv;
