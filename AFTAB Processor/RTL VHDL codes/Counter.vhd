LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Counter IS 
	GENERIC ( len : INTEGER := 2);
	PORT (
		clk,rst   : IN STD_LOGIC;
		zeroCnt   : IN STD_LOGIC;
		incCnt    : IN STD_LOGIC;
		initCnt   : IN STD_LOGIC;
		initValue : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		outCnt    : OUT std_logic_vector (len-1 DOWNTO 0)
	);
END ENTITY Counter;
 
ARCHITECTURE Behavioral OF Counter IS
   SIGNAL temp: STD_LOGIC_VECTOR (len-1 DOWNTO 0);
BEGIN   
    PROCESS(clk,rst)
    BEGIN
		IF ( rst = '1' ) THEN
			temp <= (OTHERS => '0');
        ELSIF ( clk = '1' and clk 'EVENT)THEN
			IF ( zeroCnt = '1' ) THEN
				 temp <= (OTHERS => '0');
			ELSIF (initCnt = '1') THEN
				temp <= initValue;
			ELSIF (incCnt = '1') THEN
				temp <= temp + 1;
            END IF;
        END IF; 
    END PROCESS;
   outCnt <= temp;
END ARCHITECTURE Behavioral;