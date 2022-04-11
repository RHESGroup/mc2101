LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY ShiftReg IS
	GENERIC ( len : INTEGER := 32);
	PORT (
		clk, rst : IN STD_LOGIC;
		inReg : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0); 
		shiftR, shiftL, load, zero : IN STD_LOGIC;
		serIn  : IN STD_LOGIC;
		serOut : OUT STD_LOGIC;
		outReg : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0)); 
END ENTITY ShiftReg;

ARCHITECTURE behavioral OF ShiftReg IS

BEGIN
	PROCESS (clk, rst ) 
		VARIABLE outReg_t : STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		VARIABLE serOutp  : STD_LOGIC;
		BEGIN
		
		IF (rst= '1') THEN
				outReg_t := (OTHERS => '0');
				serOutp  := '0';
		ELSIF (clk = '1' AND clk'event) THEN
			IF zero= '1' THEN
				outReg_t := (OTHERS => '0');
			ELSIF load = '1' THEN
				outReg_t := inReg;
			ELSIF shiftL = '1' THEN
				serOutp  := outReg_t (len-1);
				outReg_t :=  outReg_t (len-2 DOWNTO 0) & serIn;
			ELSIF shiftR = '1' THEN
				serOutp  := outReg_t (0);
				outReg_t :=  serIn & outReg_t (len-1 DOWNTO 1);
			END IF;
		END IF;
	outReg <= outReg_t;
	serOut <= serOutp;
END PROCESS;
	
END ARCHITECTURE behavioral;