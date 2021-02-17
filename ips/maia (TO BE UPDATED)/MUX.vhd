LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY multiplexer IS
	GENERIC ( len : INTEGER := 32);
	PORT (
		a, b : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		s0   : IN STD_LOGIC; 
		s1   : IN STD_LOGIC; 
		w    : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0)
	);
END ENTITY multiplexer;

ARCHITECTURE procedural OF multiplexer IS BEGIN
	PROCESS (a, b, s0, s1) BEGIN
		IF (s0 = '1') THEN 
			w <= a;
		ELSIF (s1 = '1') THEN 
			w <= b;
		ELSE
			w <= (OTHERS => '0');
		END IF;
	END PROCESS;
END ARCHITECTURE procedural;
