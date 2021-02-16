LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY AdderSubtractor IS
	GENERIC (len: INTEGER := 33);
	PORT (
		a : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		b : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		subSel : IN STD_LOGIC;
		pass : IN STD_LOGIC;
		cout   : OUT STD_LOGIC;
		outRes : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0)
	);
END ENTITY AdderSubtractor;

ARCHITECTURE behavioral OF AdderSubtractor IS
	SIGNAL bSel: STD_LOGIC_VECTOR (len-1 DOWNTO 0);
	SIGNAL addSubResult: STD_LOGIC_VECTOR (len-1 DOWNTO 0);
BEGIN
	bSel <= NOT(b) WHEN (subsel = '1') ELSE b;
	add : ENTITY WORK.Adder 
			GENERIC MAP(N => len) 
			PORT MAP( Cin => subSel, A => a, B => bSel,
				addResult => addSubResult, carryOut => cout);
				
	outRes <= addSubResult WHEN pass = '0' ELSE b;			
	
END ARCHITECTURE behavioral;  