-- ------------------------------------------------------------------------------------------
-- ROM_Player
-- Note Player
-- Steps through music ROM
-- Increments one note every second
-- ------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity ROM_Player is
	port(
		i_clk_50			: in std_logic;								-- 50 MHz osillator on FPGA card
		o_NoteL1			: out	std_logic_vector(6 downto 0);		-- Note Number
		o_NoteL2			: out	std_logic_vector(6 downto 0);		-- Note Number
		o_NoteR1			: out	std_logic_vector(6 downto 0);		-- Note Number
		o_NoteR2			: out	std_logic_vector(6 downto 0)		-- Note Number
	);
end ROM_Player;

architecture struct of ROM_Player is

	signal w_NoteTC			: std_logic;
	signal w_1HzTC				: std_logic;
	
	signal w_1HzCounter		: std_logic_vector(25 downto 0);
	signal w_NoteCounter		: std_logic_vector(5 downto 0);

	signal w_NoteValue		: std_logic_vector(31 downto 0);

begin

-- 1 Hz counter to cycle through notes
--w_1HzTC <=  '1' when w_1HzCounter = "10"&x"faf07f" else  -- 1 Hz
w_1HzTC <=  '1' when ((w_1HzCounter = "0"&x"3af07f") and (w_NoteValue = x"00000000")) else
				'1' when w_1HzCounter = "01"&x"7af07f" else -- faster
				'0';
Note1Hz_Counter : entity work.counterLdInc
generic map (n => 26)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> "00"&x"000000",
	i_load		=> w_1HzTC,
	i_inc			=> '1',
	o_dataOut	=> w_1HzCounter
);

-- Count through octave around Middle C
w_NoteTC <= '1' when w_NoteCounter = "111111" else		-- Note to play
				'0';
Note_Counter : entity work.counterLdInc
generic map (n => 6)
port map (
	i_clock		=> i_clk_50,
	i_dataIn		=> "000000",		-- pre-load with first not to play on scale
	i_load		=> w_NoteTC,
	i_inc			=> w_1HzTC,
	o_dataOut	=> w_NoteCounter
);

Music_Score : ENTITY work.JesusLovesMe
	PORt map
	(
		address	=> w_NoteCounter,
		q			=> w_NoteValue
	);

o_NoteL1 <= w_NoteValue(30 downto 24);
o_NoteL2 <= w_NoteValue(22 downto 16);
o_NoteR1 <= w_NoteValue(14 downto 8);
o_NoteR2 <= w_NoteValue(6 downto 0);

end;
