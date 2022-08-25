----------------------------------------------------
-- VHDL code for Square Wave Generator
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

----------------------------------------------------

entity Sound_SQWave_Middle_C is
port(	
	i_clk_50		:	in std_logic;
	o_sqOut		:	out std_logic
);
end Sound_SQWave_Middle_C;

----------------------------------------------------

architecture behv of Sound_SQWave_Middle_C is		 	  

	signal w_ldSQWCtr			: std_logic;
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

w_ldSQWCtr <= '1' when w_sqCounter = x"2EA89" else '0';

o_sqOut <= '1' when w_sqCounter = x"17544" else
           '0' when w_sqCounter = x"00000";

end behv;
