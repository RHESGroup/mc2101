LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY datapathBoothMultiplier IS
	GENERIC (len: INTEGER := 33 );
	PORT(   
		clk, rst : IN STD_LOGIC;
		shrQ, ldQ, ldM, ldp, zeroP, sel, subsel: IN STD_LOGIC;
		M  : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		Q  : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		P  : OUT STD_LOGIC_VECTOR (2*len-1 DOWNTO 0);
		op : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END ENTITY datapathBoothMultiplier;

ARCHITECTURE behavioral OF datapathBoothMultiplier IS
	SIGNAL outM, Pin, Pout, result : STD_LOGIC_VECTOR (len-1 DOWNTO 0);
	SIGNAL outQ, shQ : STD_LOGIC_VECTOR (len DOWNTO 0);
	SIGNAL seiQ, seoQ : STD_LOGIC;
BEGIN
	mReg : ENTITY WORK.Reg 
			GENERIC MAP(len => len) 
				PORT MAP(clk => clk, rst => rst, zero => '0', 
					load => ldM, inReg => M, outReg => outM);										  
	shQ <= (Q & '0');										  
	qReg   : ENTITY WORK.ShiftReg 
				GENERIC MAP(len => len+1) 
				PORT MAP(clk => clk, rst => rst, inReg => shQ,
					shiftR => shrQ, shiftL => '0', load => ldQ, zero => '0', 
					serIn => seiQ, serOut => seoQ, outReg => outQ);
					
	pReg   : ENTITY WORK.Reg 
				GENERIC MAP(len => len) 
				PORT MAP(clk => clk, rst => rst, zero => zeroP, 
					load => ldp, inReg => Pin, outReg => Pout);
					
	addSub : ENTITY WORK.AdderSubtractor 
				GENERIC MAP(len => len) 
				PORT MAP(a => Pout, b => outM, subSel => subSel, pass => '0',
					cout => OPEN, outRes => result );						  
					
	Pin <= (result (len - 1) & result (len - 1 DOWNTO 1)) WHEN sel = '1' ELSE (Pout(len - 1) & Pout (len - 1 DOWNTO 1));						  
	seiQ <= result (0) WHEN sel = '1' ELSE Pout (0);
	op <= outQ (1 DOWNTO 0); 
	P <= (Pout & outQ (len DOWNTO 1));
END ARCHITECTURE behavioral; 