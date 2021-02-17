LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ImmSel_SignExt IS 
	PORT (
		IR7  : IN STD_LOGIC;
		IR20 : IN STD_LOGIC;
		IR31 : IN STD_LOGIC;
		IR11_8  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		IR19_12 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);	
		IR24_21 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		IR30_25 : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		selI, selS, selBUJ, selIJ, selSB, selU,
		selISBJ, selIS, selB, selJ, selISB, selUJ : IN STD_LOGIC;
		Imm : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END ENTITY ImmSel_SignExt;
 
ARCHITECTURE Behavioral OF ImmSel_SignExt IS

BEGIN   
	Imm (0) 	<= 	IR20 WHEN selI='1' ELSE 
				    IR7  WHEN selS='1' ELSE 
				    '0'  WHEN selBUJ='1' ELSE '0';
						
	Imm (4 DOWNTO 1) <=  IR24_21 WHEN selIJ='1' ELSE 
						 IR11_8  WHEN selSB='1' ELSE 
						 (OTHERS =>'0') WHEN selU='1' ELSE 
						 (OTHERS => '0');
						
	Imm (10 DOWNTO 5) <= IR30_25 WHEN selISBJ='1' ELSE 
						 (OTHERS =>'0') WHEN selU='1' ELSE 
						 (OTHERS => '0');
						
	Imm (11) <= 	IR31 WHEN selIS='1' ELSE 
				IR7  WHEN selB='1' ELSE 
				'0'  WHEN selU='1' ELSE 
				IR20 WHEN selJ='1' ELSE '0';
						
	Imm (19 DOWNTO 12) <=  (OTHERS => IR31) WHEN selISB='1' ELSE 
						   IR19_12          WHEN selUJ='1' ELSE 
						   (OTHERS => '0');
							
	Imm (30 DOWNTO 20) <= (OTHERS => IR31)           WHEN selISBJ='1' ELSE 
						  (IR30_25 & IR24_21 & IR20) WHEN selU='1' ELSE 
						  (OTHERS => '0');
	Imm (31) <= IR31;
	
END ARCHITECTURE Behavioral;