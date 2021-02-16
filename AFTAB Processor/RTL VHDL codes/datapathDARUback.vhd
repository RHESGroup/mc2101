LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY DARUdatapath IS
	GENERIC (len : INTEGER := 32);
	PORT (
		clk, rst : IN STD_LOGIC;
	--	loadSignedUnsignedBar : IN STD_LOGIC;
		nBytes,initValueCnt : IN STD_LOGIC_VECTOR (1 DOWNTO 0); 
		addrIn  : IN STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		memData : IN STD_LOGIC_VECTOR ((len/4)-1 DOWNTO 0); 
		loadSigned : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		zeroAddr, ldAddr, selldEn, zeroNumBytes, ldNumBytes : IN STD_LOGIC;
		zeroCnt, incCnt, initCnt, initReading, enableAddr   : IN STD_LOGIC;
		--LdErrorFlag : IN STD_LOGIC;
		coCnt   : OUT STD_LOGIC;
        nBO : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        dataOut : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0);
		addrOut : OUT STD_LOGIC_VECTOR (len-1 DOWNTO 0)
		-- dataError,instrError : OUT STD_LOGIC)
	);
END ENTITY DARUdatapath;

ARCHITECTURE behavioral OF DARUdatapath IS
	SIGNAL readAddr, readAddrP : STD_LOGIC_VECTOR (len-1 DOWNTO 0);
	SIGNAL outCnt, nBytesOut   : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL outDecoder : STD_LOGIC_VECTOR (3 DOWNTO 0);
	--SIGNAL dataReadingError,instReadingError;
BEGIN
	-- addrReg
	addrReg : ENTITY WORK.Reg 
				GENERIC MAP (len => 32) 
				PORT MAP (clk => clk, rst => rst, zero => zeroAddr, 
					load => ldAddr, inReg => addrIn, outReg => readAddr);
	-- Decoder
	decoder : ENTITY WORK.Decoder  
				PORT MAP (inDecoder => outCnt, En => selldEn, outDecoder => outDecoder);
				
	-- nByte Register
	nByteReg : ENTITY WORK.Reg 
				GENERIC MAP (len => 2) 
				PORT MAP (clk => clk, rst => rst, zero => zeroNumBytes, 
					load => ldNumBytes, inReg => nBytes, outReg => nBytesOut);
	nBO <= 	nBytesOut;

	-- Counter
	Counter : ENTITY WORK.Counter 
				PORT MAP (clk => clk, rst => rst, zeroCnt => zeroCnt, incCnt => incCnt,
					initCnt => initCnt, initValue => initValueCnt, outCnt => outCnt);
	-- dataReg
	Reg0 : ENTITY WORK.RegDARU 
			GENERIC MAP (len => 8) 
			PORT MAP (clk => clk, rst => rst, zero => initReading, 
				load => outDecoder (0), loadSigned => loadSigned(0), signBit => memData((len/4)-1), inReg => memData, outReg => dataOut (7 DOWNTO 0));
				
	Reg1 : ENTITY WORK.RegDARU 
			GENERIC MAP (len => 8) 
			PORT MAP (clk => clk, rst => rst, zero => initReading, 
				load =>  outDecoder (1), loadSigned => loadSigned(1) , signBit => memData((len/4)-1), inReg => memData, outReg => dataOut (15 DOWNTO 8));
					
	Reg2 : ENTITY WORK.RegDARU 
			GENERIC MAP (len => 8) 
			PORT MAP (clk => clk, rst => rst, zero => initReading, 
				load =>  outDecoder (2), loadSigned => loadSigned(2), signBit => memData((len/4)-1), inReg => memData, outReg => dataOut (23 DOWNTO 16));
					
	Reg3 : ENTITY WORK.RegDARU 
			GENERIC MAP (len => 8) 
			PORT MAP (clk => clk, rst => rst, zero => initReading, 
				load =>  outDecoder(3), loadSigned => loadSigned(3) , signBit => memData((len/4)-1), inReg => memData, outReg => dataOut (31 DOWNTO 24));
	-- edit address
	readAddrP (0) <= readAddr (0) OR outCnt (0);
	readAddrP (1) <= readAddr (1) OR outCnt (1);
	readAddrP(len-1 DOWNTO 2) <=  readAddr (len-1 DOWNTO 2);
	-- comparison part 
	coCnt <= '1' WHEN (outCnt = nBytesOut) ELSE '0';
	
	-- Error Decoder
	
	-- Error Register
	
	-- Tri-State
	addrOut <= readAddrP WHEN enableAddr='1' ELSE (OTHERS => 'Z');
	
END ARCHITECTURE behavioral;
