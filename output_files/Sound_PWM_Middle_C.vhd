----------------------------------------------------
-- VHDL code for Sine Wave Generator
-- Creates Middle C
-- Sine Wave Table created in spreadsheet
--		https://github.com/douggilliland/FPGA_Sound/tree/main/MiddleCSine
-- FPGA clock is 50 MHz
-- Prescale 50 MHz by 3 to get to 16.667 KHz
-- 256 samples in the table - one full wave
-- 256 clocks for PWM
-- Produces 261.00 Hz
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
	signal w_incROMAdr		: std_logic;
	signal w_PWMUnlatched	: std_logic;
	signal w_PWMScaler		: std_logic_vector(10 downto 0);
	signal w_PWMCounter		: std_logic_vector(7 downto 0);

	signal w_ROMAddr			: std_logic_vector(7 downto 0);
	signal w_ROMData			: std_logic_vector(7 downto 0);

begin

-- Sine wave ROM table
-- Contains PWM width (0-255)

SineWaveROM : ENTITY work.MiddleCSine8Table
	PORT map (
		address	=> w_ROMAddr,
		q 			=> w_ROMData
	);

-- Pre-scale counter divides 50 MHz by 1045 to get ~48 KHz

PreScale_Counter : entity work.counterLdInc
generic map (n => 11)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> "00000000000",
	i_load		=> w_ldPWMCtr,
	i_inc			=> '1',
	o_dataOut	=> w_PWMScaler
);

-- Prescaler
w_ldPWMCtr <= '1' when w_PWMScaler =   "00000000010" else '0';

PWMCounter : entity work.counterLdInc
generic map (n => 8)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> x"00",
	i_load		=> '0',
	i_inc			=> w_ldPWMCtr,
	o_dataOut	=> w_PWMCounter
);

w_incROMAdr <= '1' when w_PWMCounter = x"ff" and w_ldPWMCtr = '1' else '0';

ROMAddrCounter : entity work.counterLdInc
generic map (n => 8)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> x"00",
	i_load		=> '0',
	i_inc			=> w_incROMAdr,
	o_dataOut	=> w_ROMAddr
);

w_PWMUnlatched <= '1' when w_PWMCounter < w_ROMData else '0';

process(i_clk_50, w_PWMUnlatched)
begin
	if rising_edge(i_clk_50) then
		o_PWMOut <= w_PWMUnlatched;
	end if;
end process;	

end behv;
