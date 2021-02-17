LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
 
ENTITY Divider IS
	GENERIC ( len : INTEGER := 33);
	PORT (
		clk,rst  : IN STD_LOGIC;
		startDiv : IN STD_LOGIC;
		doneDiv  : OUT STD_LOGIC;
		dividend, divisor : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		Q : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		Remainder : OUT STD_LOGIC_VECTOR (len DOWNTO 0));
END ENTITY Divider;

ARCHITECTURE behavioral OF Divider IS
  SIGNAL R33, shRRegR, ShLRegR, ldRegR, zeroRegR, QQ0, selMux1 : STD_LOGIC;
  SIGNAL shRRegQ, ShLRegQ, ldRegQ, zeroRegQ, zeroRegM, ldRegM  : STD_LOGIC;
  
  BEGIN
    DataPathDiv : ENTITY work.DividerDatapath 
					  GENERIC MAP (len => len)
					  PORT MAP (clk => clk, rst => rst, dividend => dividend,
					  divisor => divisor, shRRegR => shRRegR, ShLRegR => ShLRegR,
					  ldRegR => ldRegR, zeroRegR => zeroRegR, QQ0 => QQ0,
					  selMux1 => selMux1, shRRegQ => shRRegQ, ShLRegQ => ShLRegQ,
					  ldRegQ => ldRegQ, zeroRegQ => zeroRegQ, zeroRegM => zeroRegM, 
					  ldRegM => ldRegM, R33 => R33, Q => Q, Remainder => Remainder);
   
    ControllerDiv : ENTITY work.DividerController 
						GENERIC MAP (len => len)
						PORT MAP (clk => clk, rst => rst, startDiv => startDiv, 
						R33 => R33, doneDiv => doneDiv, shRRegR => shRRegR,
						ShLRegR => ShLRegR, ldRegR => ldRegR, zeroRegR => zeroRegR,
						selMux1 => selMux1, shRRegQ => shRRegQ, ShLRegQ => ShLRegQ,
						ldRegQ => ldRegQ, zeroRegQ => zeroRegQ, zeroRegM => zeroRegM,
						ldRegM => ldRegM, QQ0 => QQ0); 
															
                                                                  
END ARCHITECTURE behavioral;