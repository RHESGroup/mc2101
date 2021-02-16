LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--USE IEEE.STD_LOGIC_SIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY BarrelShifter IS
	GENERIC (len: INTEGER := 32);
	PORT (
		shIn  : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		nSh   : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		selSh : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		shOut : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0)
	);
END ENTITY BarrelShifter;

ARCHITECTURE behavioral OF BarrelShifter IS

BEGIN
	PROCESS(ShIn, nSh, selSh) BEGIN
		IF (selSh = "00") THEN
			shOut <= STD_LOGIC_VECTOR (unsigned (shIn) SLL (to_integer (unsigned (nSh))));
		ELSIF (selSh = "10") THEN
			shOut <= STD_LOGIC_VECTOR (unsigned (shIn) SRL (to_integer (unsigned (nSh))));
		ELSIF (selSh = "11") THEN
			shOut <= TO_STDLOGICVECTOR (TO_BITVECTOR (STD_LOGIC_VECTOR (unsigned(shIn))) SRA to_integer ( unsigned(nSh)));
		ELSE
			shOut <= (OTHERS => '0');
		END IF;
	END PROCESS;
END ARCHITECTURE behavioral;  