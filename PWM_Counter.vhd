----------------------------------------------------
-- VHDL code for PWM Counter
-- PWM
--		FPGA clock is 50 MHz
--		PWM runs at 50/4 = 12.5 MHz (clock divided by 4)
--		256 clocks at 12.5 MHz = 48.8 KHz
--
--	Doug Gilliland, 2022
--
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

----------------------------------------------------

entity PWM_Counter is
port(	
	i_clk_50			:	in std_logic;
	o_PWMCt			:	out std_logic_vector(7 downto 0);
	o_NoteHoldReg	:	out std_logic
);
end PWM_Counter;

----------------------------------------------------

architecture behv of PWM_Counter is		 	  

	signal w_PWMUnlatched		: std_logic;
	signal w_NoteHoldReg			: std_logic;
	signal w_SineSampleLatched	: std_logic_vector(7 downto 0);
	signal w_PWMCt					: std_logic_vector(9 downto 0);
	signal w_SineTblAddr			: std_logic_vector(7 downto 0);

begin

PWM_Ctr : entity work.counterLdInc
generic map (n => 10)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> "00"&x"00",
	i_load		=> '0',
	i_inc			=> '1',
	o_dataOut	=> w_PWMCt
);

o_PWMCt <= w_PWMCt(9 downto 2);

o_NoteHoldReg <= '1' when w_PWMCt = "1111111111" else '0';

end behv;
