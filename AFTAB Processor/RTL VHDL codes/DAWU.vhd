LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY DAWU IS 
	GENERIC ( len : INTEGER := 32);
	PORT (
		clk, rst : IN STD_LOGIC;
		startDAWU, memReady : IN STD_LOGIC;
		nBytes       : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		addrIn       : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		dataIn       : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		addrOut      : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		dataOut      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		writeMem     : OUT STD_LOGIC;
		dataError    : OUT STD_LOGIC;
		completeDAWU : OUT STD_LOGIC
	);
END ENTITY DAWU;
 
ARCHITECTURE Behavioral OF DAWU IS
	SIGNAL enableData, enableAddr, incCnt, zeroCnt, initCnt, 
		   ldNumBytes, zeroNumBytes, ldAddr, zeroAddr, ldData, 
		   zeroData, coCnt, ldErrorFlag : STD_LOGIC;
BEGIN   
	Datapath : ENTITY WORK.datapathDAWU 
				  PORT MAP (clk => clk, rst => rst, ldData => ldData,
					enableData => enableData, enableAddr => enableAddr, 
					incCnt => incCnt, zeroCnt => zeroCnt, 
					initCnt => initCnt, ldNumBytes => ldNumBytes, 
					zeroNumBytes => zeroNumBytes, ldAddr => ldAddr, 
					zeroAddr => zeroAddr, zeroData => zeroData, 
					nBytesIn => nBytes, initValue => "00", 
					dataIn => dataIn, addrIn => addrIn, coCnt => coCnt, 
					dataOut => dataOut, addrOut =>addrOut );
		
	Controller : ENTITY WORK.controllerDAWU 
					PORT MAP (clk => clk, rst => rst, coCnt => coCnt, 
						startDAWU => startDAWU, memReady => memReady, 
						ldData => ldData, enableData => enableData, 
						enableAddr => enableAddr, incCnt => incCnt, 
						zeroCnt => zeroCnt, initCnt => initCnt, 
						ldNumBytes => ldNumBytes, zeroNumBytes => zeroNumBytes, 
						ldAddr => ldAddr,zeroAddr => zeroAddr, 
						zeroData => zeroData, writeMem => writeMem, 
						ldErrorFlag => ldErrorFlag, completeDAWU => completeDAWU);
END ARCHITECTURE Behavioral;