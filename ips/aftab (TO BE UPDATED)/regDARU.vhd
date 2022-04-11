LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY RegDARU IS
	GENERIC ( len : INTEGER := 32);
	PORT (
		clk, rst   :  IN STD_LOGIC; 
		zero, load, loadSigned : IN STD_LOGIC; 
		signBit : IN STD_LOGIC; 
		inReg      : IN STD_LOGIC_VECTOR(len-1 DOWNTO 0); 
		outReg     : OUT STD_LOGIC_VECTOR(len-1 DOWNTO 0)
	);
END ENTITY RegDARU;

ARCHITECTURE behavioral OF RegDARU IS

BEGIN
	PROCESS(clk, rst)
	BEGIN
		IF ( rst = '1' ) THEN
			outReg <= (OTHERS => '0');
		ELSIF ( clk = '1' AND clk 'EVENT)THEN
			IF (zero = '1') THEN
				outReg <= (OTHERS => '0');
			ELSIF (loadSigned = '1') THEN
				outReg <= (OTHERS => signBit);
			ELSIF (load = '1') THEN
				outReg <= inReg;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE behavioral;
