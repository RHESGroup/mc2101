LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
 
ENTITY DARU IS
	PORT (
		clk,rst   : IN STD_LOGIC;
		startDARU : IN STD_LOGIC;
		loadSignedUnsignedBar : IN STD_LOGIC;
		nBytes    : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        addrIn    : In STD_LOGIC_VECTOR (31 downto 0);
		memData   : In STD_LOGIC_VECTOR (7 downto 0);
		memReady  : IN STD_LOGIC;
        completeDARU    : OUT STD_LOGIC;
        dataOut, addrOut : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		dataError, instrError : OUT STD_LOGIC;
		readMem : OUT STD_LOGIC
	);
END ENTITY DARU;

ARCHITECTURE behavioral OF DARU IS
  SIGNAL zeroAddr, ldAddr, selldEn, zeroNumBytes, ldNumBytes,
		 zeroCnt, incCnt, initCnt, initReading, enableAddr, LdErrorFlag, zeroS, ldS : STD_LOGIC;
  SIGNAL coCnt : STD_LOGIC;
  SIGNAL sel, nBO   : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL loadSigned   : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL initValueCnt : STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0');
BEGIN


    DataPath    : ENTITY work.DARUdatapath 
					GENERIC MAP(len => 32) 
					PORT MAP (clk, rst, memReady,nBytes, initValueCnt, addrIn,
						memData, loadSigned, zeroAddr, ldAddr, selldEn, zeroNumBytes, ldNumBytes,
						zeroCnt, incCnt, initCnt, initReading, enableAddr,
						--LdErrorFlag,
						coCnt, nBO, dataOut, addrOut);
   
    Controller  : ENTITY work.DARUcontroller 
					PORT MAP (clk, rst, startDARU, loadSignedUnsignedBar,  coCnt, memReady, nBO,
						initCnt, ldAddr, zeroAddr, initReading, ldErrorFlag, ldNumBytes, selldEn,
						readMem, enableAddr, incCnt, zeroCnt, completeDARU, loadSigned);												                                                    
END ARCHITECTURE behavioral;