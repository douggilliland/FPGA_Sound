----------------------------------------------------
-- VHDL code for Square Wave Generator
-- Divide 50 MHz clock to generate Middle C
-- From https://en.wikipedia.org/wiki/Piano_key_frequencies
-- 	Middle C is 261.6256 Hz
-- Divisor is 50_000_000 / 261.6256 = 191_112.79
-- Can only do integer divisor, round up to 191_113
-- 191_113 dec = 2EA89 hex
-- Count from 0 to 2EA88
-- Set low at count = 0, set high at 1/2 wave (17544 hex)
-- Minimal error < 1 part in 191_112
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

----------------------------------------------------
-- Sqare Wave, Middle C

entity Sound_SQWave_Middle_C is
port(	
	i_clk_50		:	in std_logic;		-- 50 MHz
	i_Mute		:	in std_logic;
	o_sqOut		:	out std_logic		-- Middle C square wave
);
end Sound_SQWave_Middle_C;

----------------------------------------------------

architecture behv of Sound_SQWave_Middle_C is		 	  

	signal w_ldSQWCtr			: std_logic;
	signal w_SQWave			: std_logic;
	signal w_sqCounter		: std_logic_vector(19 downto 0);

begin

SquareWaveCounter : entity work.counterLdInc
generic map (n => 20)
port map (	
	i_clock		=> i_clk_50,
	i_dataIn		=> x"00000",
	i_load		=> w_ldSQWCtr,
	i_inc			=> '1',
	o_dataOut	=> w_sqCounter
);

w_ldSQWCtr <= '1' when w_sqCounter = x"2EA88" else '0';

o_sqOut <= w_SQWave;

w_SQWave	<= '0' when i_Mute = '1' else
				'1' when w_sqCounter = x"17544" else
				'0' when w_sqCounter = x"00000";

end behv;
