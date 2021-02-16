LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY boothMultiplier IS
	GENERIC (len: INTEGER := 33 );
	PORT (
		clk, rst : IN STD_LOGIC;
		startBooth : IN STD_LOGIC;
		M : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		Q : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		P : OUT STD_LOGIC_VECTOR (2*len-1 DOWNTO 0);
		doneBooth : OUT STD_LOGIC
	);
END ENTITY boothMultiplier;

ARCHITECTURE behavioral OF boothMultiplier IS
	SIGNAL op : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL shrQ, ldQ, ldM, ldP, zeroP, sel, subSel : STD_LOGIC;
BEGIN
	Datapath : ENTITY WORK.datapathBoothMultiplier 
				  GENERIC MAP(len => len) 
				  PORT MAP(clk => clk, rst => rst, shrQ => shrQ, ldQ => ldQ, ldM => ldM,
					ldp => ldp, zeroP =>zeroP, sel => sel, 
					subsel => subsel, M => M, Q => Q, P => P, op => op);
						
	Controller : ENTITY WORK.controllerBoothMultiplier 
					GENERIC MAP(len => len) 
					PORT MAP(clk => clk, rst => rst, 
						startBooth => startBooth, shrQ => shrQ,	ldQ => ldQ,	ldM => ldM,
						ldP => ldP, zeroP => zeroP, sel => sel, 
						subSel => subSel, op => op, done => doneBooth);										  
END ARCHITECTURE behavioral;  