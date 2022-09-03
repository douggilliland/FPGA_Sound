-- JesusLovesMe

-- Piano keys
--		https://en.wikipedia.org/wiki/Piano_key_frequencies

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_unsigned.all;

ENTITY JesusLovesMe IS
	PORT
	(
		address : in std_logic_vector(5 downto 0);
		q : out std_logic_vector(31 downto 0)
	);
END JesusLovesMe;

architecture behavior of JesusLovesMe is
type romtable is array (0 to 63) of std_logic_vector(31 downto 0);
constant romdata : romtable :=
(
x"322F271F",
x"00000000",
x"2C2F271F",
x"00000000",
x"2C2F271F",
x"00000000",
x"2D2A271B",
x"00000000",
x"00000000",
x"2F2C271F",
x"00000000",
x"2F32271F",
x"00000000",
x"2F32271D",
x"2F32271D",
x"00000000",
x"00000000",
x"34312518",
x"00000000",
x"34312518",
x"00000000",
x"37342518",
x"00000000",
x"3430251C",
x"00000000",
x"3431251F",
x"00000000",
x"322F271F",
x"00000000",
x"322F271F",
x"322F271F",
x"00000000",
x"00000000",
x"322F271F",
x"00000000",
x"2C2F271F",
x"00000000",
x"2C2F271F",
x"00000000",
x"2D2A271B",
x"00000000",
x"00000000",
x"2F2C271F",
x"00000000",
x"2F32271F",
x"00000000",
x"2F32271D",
x"2F32271D",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000"
);
begin
process (address)
begin
q <= romdata (to_integer(unsigned(address)));
end process;
end behavior;
