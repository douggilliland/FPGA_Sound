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
		address : in std_logic_vector(4 downto 0);
		q : out std_logic_vector(31 downto 0)
	);
END JesusLovesMe;

architecture behavior of JesusLovesMe is
type romtable is array (0 to 31) of std_logic_vector(31 downto 0);
constant romdata : romtable :=
(
x"2F32271F",
x"00000000",
x"2C2F271F",
x"00000000",
x"2C2F271F",
x"00000000",
x"2D2A271B",
x"00000000",
x"00000000",
x"2C2F271F",
x"00000000",
x"2F32271F",
x"00000000",
x"2F32271F",
x"2F32271F",
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
x"00000000",
x"00000000"
);
begin
process (address)
begin
q <= romdata (to_integer(unsigned(address)));
end process;
end behavior;
