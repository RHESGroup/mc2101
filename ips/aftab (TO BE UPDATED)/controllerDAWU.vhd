LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY controllerDAWU IS
	PORT (
		clk, rst : IN STD_LOGIC;
		coCnt, startDAWU, memReady  : IN STD_LOGIC;
		ldData, enableData, enableAddr, incCnt, zeroCnt, initCnt, 
		ldNumBytes, zeroNumBytes, ldAddr, zeroAddr, 
		zeroData, writeMem, ldErrorFlag, completeDAWU  : OUT STD_LOGIC
	);
END ENTITY controllerDAWU ;

ARCHITECTURE behavioral OF controllerDAWU IS 
	TYPE state IS (waitForStart, waitForWrite);
	SIGNAL pstate, nstate : state;
BEGIN
	PROCESS (pstate, coCnt, startDAWU, memReady) BEGIN
		nstate <= waitForStart;
		CASE pstate IS
			WHEN waitForStart => 
				IF startDAWU = '1' THEN 
					nstate <= waitForWrite;
				ELSE
					nstate <= waitForStart; 
				END IF;
			WHEN waitForWrite => 
				IF (coCnt = '1' AND memReady = '1') THEN 
					nstate <= waitForStart;
				ELSE 
					nstate <= waitForWrite; 
				END IF;
			WHEN OTHERS => 
				nstate <= waitForStart;
		END CASE;
	END PROCESS;   

    PROCESS (pstate, coCnt, startDAWU, memReady) BEGIN
	 ldData <= '0'; ldAddr <= '0'; enableData <= '0'; enableAddr <= '0'; incCnt <= '0';
	 zeroCnt <= '0'; initCnt <= '0'; ldNumBytes <= '0'; zeroNumBytes <= '0'; 
	 ldAddr <= '0'; zeroAddr <= '0'; zeroData <= '0'; writeMem <= '0'; ldErrorFlag <= '0'; 
	 completeDAWU <= '0';
		CASE pstate IS
			WHEN waitForStart => 
				IF(startDAWU = '1') THEN
					ldAddr <= '1';      
					initCnt <= '1';     
					ldNumBytes <= '1';  
					ldErrorFlag <= '1'; 
					ldData <= '1';
				ELSE
					ldAddr <= '0';      
					initCnt <= '0';     
					ldNumBytes <= '0';  
					ldErrorFlag <= '0'; 
					ldData <= '0';
				END IF;
			WHEN waitForWrite => 
				enableData <= '1'; 
				enableAddr <= '1'; 
				writeMem <= '1'; 
				IF(memReady = '1') THEN
					incCnt <= '1';
				ELSE
					incCnt <= '0';
				END IF;
				IF (coCnt = '1' AND memReady = '1') THEN 
					completeDAWU <= '1';
				ELSE 
					completeDAWU <= '0'; 
				END IF;
			
			WHEN OTHERS => 
				ldData <= '0'; ldAddr <= '0'; enableData <= '0'; enableAddr <= '0'; incCnt <= '0';
				zeroCnt <= '0'; initCnt <= '0'; ldNumBytes <= '0'; zeroNumBytes <= '0'; 
				ldAddr <= '0'; zeroAddr <= '0'; zeroData <= '0'; writeMem <= '0'; ldErrorFlag <= '0'; 
				completeDAWU <= '0';
		END CASE;
	END PROCESS;
	  
	sequential: PROCESS (clk, rst) BEGIN
		IF (rst = '1') THEN 
			pstate <= waitForStart;	
		ELSIF (clk = '1' AND clk'EVENT) THEN
			pstate <= nstate;
		END IF;   
    END PROCESS sequential; 

END ARCHITECTURE behavioral;
		
