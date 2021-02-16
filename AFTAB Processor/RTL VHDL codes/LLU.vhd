LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY LLU IS
	GENERIC (n: INTEGER := 32);
	PORT (
		ain      : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		bin      : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		selLogic : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		result   : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0)
	);
END ENTITY LLU;

ARCHITECTURE behavioral OF LLU IS 
	SIGNAL y : STD_LOGIC_VECTOR (ain'LENGTH-1 DOWNTO 0);
BEGIN
	PROCESS (ain, bin, selLogic) BEGIN
		CASE selLogic IS
			WHEN "00" => y <= ain XOR bin;
			WHEN "10" => y <= ain OR bin;
			WHEN "11" => y <= ain AND bin;
			WHEN OTHERS => y <= (OTHERS => '0');
		END CASE;
	END PROCESS;
	result <= y (ain'LENGTH - 1 DOWNTO 0);
END ARCHITECTURE behavioral;


