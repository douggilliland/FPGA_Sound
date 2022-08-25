----------------------------------------------------
-- VHDL code for Sine Wave Generator
-- 50 MHz
-- 50,000,000 / 1024 = 48,828.125 KHz
-- 187 elements in the table - one full wave
-- 48,828.125 KHz\ / 187 = 261.11 Hz
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

----------------------------------------------------

entity Sound_PWM_Middle_C is
port(	
	i_clk_50		:	in std_logic;
	o_PWMOut		:	out std_logic
);
end Sound_PWM_Middle_C;

----------------------------------------------------

architecture behv of Sound_PWM_Middle_C is		 	  

	signal w_ldPWMCtr			: std_logic;
	signal w_PWMCounter		: std_logic_vector(7 downto 0);
	signal w_PWMScaler		: std_logic_vector(9 downto 0);

	signal w_ROMAddr			: std_logic_vector(7 downto 0);
	signal w_ROMData			: std_logic_vector(7 downto 0);

begin

SineWaveROM : ENTITY work.MiddleCSine8Table
	PORT map (
		address	=> w_ROMAddr,
		q 			=> w_ROMData
	);

PreScale_Counter : entity work.counterLdInc
generic map (n => 10)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> "0000000000",
	i_load		=> '0',
	i_inc			=> '1',
	o_dataOut	=> w_PWMScaler
);

w_ldPWMCtr <= '1' when w_PWMScaler = "0000000000" else '0';

ROMAddrCounter : entity work.counterLdInc
generic map (n => 8)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> "00000000",
	i_load		=> w_ldPWMCtr,
	i_inc			=> '1',
	o_dataOut	=> w_PWMCounter
);

o_PWMOut <= '1' when w_PWMCounter = "00000000" else '1';

end behv;
