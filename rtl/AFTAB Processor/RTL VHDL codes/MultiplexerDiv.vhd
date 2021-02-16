LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY MultiplexerDiv IS
	GENERIC (len: INTEGER := 32);
	PORT (
		a, b : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		sel  : IN STD_LOGIC;
	    W    : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0));
END ENTITY MultiplexerDiv;

ARCHITECTURE procedural OF MultiplexerDiv IS BEGIN
	PROCESS (a, b, sel) BEGIN
		IF (sel = '0') THEN
			w <= a;
		ELSE 
			w <= b;
		END IF;
	END PROCESS;
END ARCHITECTURE procedural;
