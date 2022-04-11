LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ShiftRegister IS
	GENERIC (len: INTEGER := 32);
	PORT (
		clk, rst : IN STD_LOGIC;
		shIn     : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		ldR, shrR, seiR : IN STD_LOGIC;
		seoR  : OUT STD_LOGIC;
		shOut : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0));
END ENTITY ShiftRegister;

ARCHITECTURE behav OF ShiftRegister IS
SIGNAL Rreg : STD_LOGIC_VECTOR (len-1 DOWNTO 0);

BEGIN
	PROCESS (clk)
	BEGIN
		IF ( rst = '1' ) THEN
			Rreg <= (OTHERS => '0');
		ELSIF ( clk = '1' and clk 'EVENT)THEN
			IF(ldR = '1') THEN
				Rreg <= shIn;
			ELSIF (shrR = '1') THEN
				Rreg <= (seiR & Rreg (len-1 DOWNTO 1));
				seoR <= Rreg(0);
			END IF;
		END IF;
	END PROCESS;
	shOut <= Rreg; 
END ARCHITECTURE behav;  