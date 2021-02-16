LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY regFile IS
	GENERIC (len : integer := 32);
	PORT (
		clk,rst      : IN STD_LOGIC;
		setZero      : IN STD_LOGIC;
		setOne       : IN STD_LOGIC;
		rs1          : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		rs2          : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		rd           : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		writeData    : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		writeRegFile : IN STD_LOGIC; 
		p1 			 : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0); 
		p2 			 : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0) 
	);
END ENTITY regFile ;

ARCHITECTURE behavioral OF regFile IS 
	TYPE reg_arr IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR (31 DOWNTO 0) ;
	SIGNAL rData : reg_arr  := (OTHERS => (OTHERS => '0')) ;
BEGIN 
	p1 <= rData(to_integer (unsigned(rs1))) WHEN (rs1/="00000") ELSE (OTHERS => '0');
	p2 <= rData(to_integer (unsigned(rs2))) WHEN (rs2/="00000") ELSE (OTHERS => '0');
	
	wrProc: PROCESS (clk, rst) 
	BEGIN
		IF (rst = '1') THEN
			rData <= (OTHERS => (OTHERS => '0'));	
		ELSIF (clk = '1' AND clk'EVENT) THEN
			IF (rd/="00000" ) THEN
				IF (setOne = '1') THEN
					rData(to_integer(unsigned(rd))) <= ((len-1 DOWNTO 1 => '0') & '1'); 	
				ELSIF (setZero = '1') THEN
					rData(to_integer(unsigned(rd))) <= (OTHERS => '0');	
				ELSIF (writeRegFile = '1') THEN
					rData(to_integer(unsigned(rd))) <= writeData;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE behavioral;
		
