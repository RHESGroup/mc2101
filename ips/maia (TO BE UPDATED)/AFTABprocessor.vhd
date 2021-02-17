
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY AFTABprocessor IS
GENERIC( len : INTEGER := 32);
PORT (
		clk, rst, memReady : IN std_logic;
		memRead, memWrite : OUT std_logic;
		memDataIN : IN std_logic_vector (7 DOWNTO 0);		
		memDataOUT : OUT std_logic_vector (7 DOWNTO 0);

		memAddr : OUT std_logic_vector (len-1 DOWNTO 0)
		--memAddrDARU : OUT std_logic_vector (len-1 DOWNTO 0)
		-- : IN std_logic; 
		--w : OUT std_logic_vector (len-1 DOWNTO 0)
		);
END ENTITY;
--
ARCHITECTURE procedural OF AFTABprocessor IS 
SIGNAL selPCJ, selPC, selADR, selI4, selP2, selP1, selJL, selImm, selAdd, selI4PC, selInc4pc,selData, selBSU, selLLU, selDARU,selASU, selAAU, shr, shl, 
		 dataInstrBar, writeRegFile, addSubBar, pass, selAuipc, comparedsignedunsignedbar,
	    ldIR, ldADR, ldPC, ldDr,
		 setOne, setZero,
		 startDARU, startDAWU, completeDARU, completeDAWU, loadSignedUnsignedBar,
		 startMultiplyAAU, startDivideAAU, completeAAU, signedSigned, signedUnsigned, unsignedUnsigned, selAAL,	selAAH, 
		 eq, gt,lt,
		 dataerror:std_logic;
SIGNAL nBytes : std_logic_vector (1 DOWNTO 0);
SIGNAL selLogic : std_logic_vector (1 DOWNTO 0);
SIGNAL selShift : std_logic_vector (1 DOWNTO 0);
SIGNAL muxCode : std_logic_vector (11 DOWNTO 0);
SIGNAL IR : std_logic_vector (31 DOWNTO 0);


BEGIN


datapathAFTAB: ENTITY WORK.datapathAFTAB PORT MAP(
		clk => clk,
		rst => rst,
		writeRegFile => writeRegFile,
		setOne => setOne,
		setZero => setZero,
		ComparedSignedUnsignedBar => ComparedSignedUnsignedBar,
		selPC => selPC,
		selPCJ => selPCJ,
		selI4 => selI4,
		selAdd => selAdd,
		selP1 => selP1,
		selADR => selADR,
		selI4PC => selI4PC,
		selInc4pc => selInc4pc,
		selBSU => selBSU,
		selLLU => selLLU,
		selASU => selASU,
		selAAU => selAAU,
		selDARU => selDARU,
		selData => selData,
		selP2 => selP2,
		selJL => selJL,
		selImm => selImm ,
		ldPC => ldPC,
		zeroPC => '0',
		ldADR => ldADR,
		zeroADR => '0',
		ldDR => ldDR,
		zeroDR => '0',
		ldIR => ldIR,
		zeroIR => '0',
		selShift => selShift,

		addSubBar => addSubBar,
		pass => pass,
		selAuipc => selAuipc,
		muxCode => muxCode,
		selLogic => selLogic,
		startDAWU => startDAWU,
		startDARU => startDARU,
		memReady => memReady,
		loadSignedUnsignedBar => loadSignedUnsignedBar,
		
		startMultiplyAAU =>  startMultiplyAAU,
		startDivideAAU => startDivideAAU   , 
		signedSigned => signedSigned    ,
		signedUnsigned => signedUnsigned   , 
		unsignedUnsigned => unsignedUnsigned   , 
		selAAL => selAAL   ,	
		selAAH =>  selAAH  , 
  
  		completeAAU => completeAAU,
		
		nBytes => nBytes,
		memDataIn => memDataIn,
		memAddrDAWU => memAddr,
		memAddrDARU => memAddr,
		IR => IR,
		memDataOut => memDataOut,
		lt => lt,
		eq => eq,
		gt => gt,
		completeDAWU => completeDAWU,
		completeDARU => completeDARU,
		readMem => memRead,
		writeMem => memWrite,
		dataError => dataError 
	);


controllerAFTAB: ENTITY WORK.controllerAFTAB PORT MAP( 
		clk => clk,
		rst => rst,  
		completeDARU => completeDARU,
		completeDAWU => completeDAWU,
		completeAAU => completeAAU,
		lt => lt,
		eq => eq,
		gt => gt,
		IR => IR,
		muxCode => muxCode,
		nBytes => nBytes,
		selLogic => selLogic,
		selShift => selShift,
		selPCJ => selPCJ,
		selPC => selPC,
		selADR => selADR,
		selI4 => selI4,
		selP1 => selP1,
		selP2 => selP2,
		selJL => selJL,
		selImm => selImm,
		selAdd => selAdd,
		selInc4PC  => selInc4PC, 
		selBSU  => selBSU,
		selLLU  => selLLU, 
		selASU  => selASU, 
		selAAU  => selAAU,
		selDARU  => selDARU, 
		dataInstrBar => dataInstrBar,
		writeRegFile => writeRegFile,
		addSubBar => addSubBar,
		pass => pass,
		selAuipc => selAuipc,
		comparedsignedunsignedbar => comparedsignedunsignedbar,
		ldIR => ldIR,
		ldADR => ldADR,
		ldPC => ldPC,
		ldDr => ldDr,
		setOne => setOne,
		setZero => setZero,
		startDARU => startDARU,
		startDAWU => startDAWU,
		loadSignedUnsignedBar => loadSignedUnsignedBar,
		startMultiplyAAU => startMultiplyAAU,
		startDivideAAU => startDivideAAU,
		signedSigned => signedSigned,
		signedUnsigned => signedUnsigned,
		unsignedUnsigned => unsignedUnsigned,
		selAAL => selAAL,	
		selAAH => selAAH 
	);
END ARCHITECTURE procedural;
