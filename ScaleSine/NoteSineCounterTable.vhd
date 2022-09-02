-- Note Divisor Table
-- 50 MHz Clock
-- 8 bit Wave samples
-- Divisor table has values ( 50 MHz / ( 256 * note_freq ) ) - 1
-- 256 samples contain entire sine wave

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_unsigned.all;

ENTITY NoteSineCounterTable IS
	PORT
	(
		address : in std_logic_vector(6 downto 0);
		q : out std_logic_vector(15 downto 0)
	);
END NoteSineCounterTable;

architecture behavior of NoteSineCounterTable is
type romtable is array (0 to 87) of std_logic_vector(15 downto 0);
constant romdata : romtable :=
(
x"1BBD",	-- used as no note flag
x"1BBD",
x"1A2F",
x"18B6",
x"1753",
x"1604",
x"14C8",
x"139D",
x"1283",
x"1179",
x"107E",
x"0F91",
x"0EB1",
x"0DDE",
x"0D17",
x"0C5B",
x"0BA9",
x"0B02",
x"0A63",
x"09CE",
x"0941",
x"08BC",
x"083F",
x"07C8",
x"0758",
x"06EF",
x"068B",
x"062D",
x"05D4",
x"0580",
x"0531",
x"04E7",
x"04A0",
x"045E",
x"041F",
x"03E4",
x"03AC",
x"0377",
x"0345",
x"0316",
x"02EA",
x"02C0",
x"0298",
x"0273",
x"0250",
x"022E",
x"020F",
x"01F1",
x"01D5",
x"01BB",
x"01A2",
x"018A",
x"0174",
x"015F",
x"014C",
x"0139",
x"0127",
x"0117",
x"0107",
x"00F8",
x"00EA",
x"00DD",
x"00D0",
x"00C5",
x"00BA",
x"00AF",
x"00A5",
x"009C",
x"0093",
x"008B",
x"0083",
x"007C",
x"0075",
x"006E",
x"0068",
x"0062",
x"005C",
x"0057",
x"0052",
x"004D",
x"0049",
x"0045",
x"0041",
x"003D",
x"003A",
x"0036",
x"0033",
x"0030"
);
begin
process (address)
begin
q <= romdata (to_integer(unsigned(address)));
end process;
end behavior;
