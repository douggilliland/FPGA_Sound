-- OutReg_Nbits.vhd
-- Implement an n-bit output register
	
library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

---------------------------------------------------

entity OutReg_Nbits is
generic(n: natural :=8);
	port(	
		dataIn	:	in std_logic_vector(n-1 downto 0);
		clock		:	in std_logic;
		load		:	in std_logic;
		regOut	:	out std_logic_vector(n-1 downto 0)
	);
end OutReg_Nbits;

----------------------------------------------------

architecture behv of OutReg_Nbits is

    signal Q_tmp: std_logic_vector(n-1 downto 0);

begin
	process(clock, load)
	begin
		if rising_edge(clock) then
			if load = '1' then
				Q_tmp <= dataIn;
			end if;
		end if;
	end process;

	-- concurrent statement
	regOut <= Q_tmp;

end behv;
