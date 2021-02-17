LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Adder IS
	GENERIC (N : integer := 33);
	PORT (
		Cin : IN STD_LOGIC;
		A   : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		B   : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		addResult : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		carryOut  : OUT STD_LOGIC
	);
END ENTITY Adder;

ARCHITECTURE behavioral OF Adder IS 
	SIGNAL add : STD_LOGIC_VECTOR (N DOWNTO 0);
BEGIN 
	add <= ('0' & A) + ('0' & B) + Cin;
	addResult <= add(N-1 DOWNTO 0);
	carryOut <= add(N);
END ARCHITECTURE behavioral;
		
