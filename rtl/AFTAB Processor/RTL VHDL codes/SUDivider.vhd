LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
 
ENTITY SUDivider IS
	GENERIC (len : INTEGER := 32);
	PORT (
		clk, rst  : IN STD_LOGIC;
		startSDiv : IN STD_LOGIC;
		SignedUnsignedbar : IN STD_LOGIC;
		dividend, divisor : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		doneSDiv  : OUT STD_LOGIC;
		Qout   : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		Remout : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0)
	);
END ENTITY SUDivider;

ARCHITECTURE behavioral OF SUDivider IS
	SIGNAL Remp : STD_LOGIC_VECTOR (len DOWNTO 0);
	SIGNAL ddIn, drIn : STD_LOGIC_VECTOR (len-1 DOWNTO 0);
	SIGNAL Qp : STD_LOGIC_VECTOR (len-1 DOWNTO 0);
	SIGNAL endd, endr, enQ, enR : STD_LOGIC;
BEGIN
	
	endd <= dividend (len-1) AND SignedUnsignedbar;
	endr <= divisor (len-1)  AND SignedUnsignedbar;
	enQ  <= (dividend (len-1) XOR divisor (len-1)) AND SignedUnsignedbar;
	enR  <= dividend (len-1) AND SignedUnsignedbar;
	
	TCLdividend : ENTITY work.TCL
					  GENERIC MAP (len => len)
					  PORT MAP (aIn => dividend, en => endd, aOut => ddIn);
	
	TCLdivisor  : ENTITY work.TCL
					  GENERIC MAP (len => len)
					  PORT MAP (aIn => divisor, en => endr, aOut => drIn);

	unsignedDiv : ENTITY work.Divider 
					GENERIC MAP (len => len) 
					PORT MAP ( clk => clk, rst => rst, startDiv => startSDiv,
						doneDiv => doneSDiv, dividend => ddIn, divisor => drIn,
						Q => Qp, Remainder => Remp);
	
	TCLQ : ENTITY work.TCL
			   GENERIC MAP (len => len)
			   PORT MAP (aIn => Qp, en => enQ, aOut => Qout);
	
	TCLRem : ENTITY work.TCL
				GENERIC MAP (len => len)
				PORT MAP (aIn => Remp (len-1 DOWNTO 0), en => enR, aOut => Remout);												
                                                                  
END ARCHITECTURE behavioral;