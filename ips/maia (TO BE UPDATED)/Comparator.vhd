LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Comparator IS
	GENERIC (n: INTEGER := 32);
	PORT (
		ain : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		bin : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		compareSignedUnsignedBar : IN STD_LOGIC;
		Lt, Eq, Gt : OUT STD_LOGIC
	);
END ENTITY Comparator;

ARCHITECTURE behavioral OF Comparator IS 
	SIGNAL ainp, binp : STD_LOGIC_VECTOR (n-1 DOWNTO 0);
BEGIN
	ainp (n-1) <= ain(n-1) XOR compareSignedUnsignedBar;
	binp (n-1) <= bin(n-1) XOR compareSignedUnsignedBar;
	ainp (n-2 DOWNTO 0) <= ain (n-2 DOWNTO 0);
	binp (n-2 DOWNTO 0) <= bin (n-2 DOWNTO 0);
	
	Eq <= '1' WHEN (ainp = binp) ELSE '0';
	Gt <= '1' WHEN (ainp > binp) ELSE '0';
	Lt <= '1' WHEN (ainp < binp) ELSE '0';
END ARCHITECTURE behavioral;





