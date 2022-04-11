LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY controllerBoothMultiplier IS
	GENERIC (len : INTEGER := 33);
	PORT (
		clk, rst   : IN STD_LOGIC;
		startBooth : IN STD_LOGIC;	 
		shrQ, ldQ, ldM, ldP, zeroP, sel, subSel : OUT STD_LOGIC;	 
		op    : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		done  : OUT STD_LOGIC
	);
END ENTITY controllerBoothMultiplier ;

ARCHITECTURE behavioral OF controllerBoothMultiplier IS 
	TYPE state IS (INIT, COUNT, SHIFT);
	SIGNAL pstate, nstate : state;
	SIGNAL cnt  : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL temp : STD_LOGIC_VECTOR (6  DOWNTO 0);
	SIGNAL co, cnt_en, cnt_rst  : STD_LOGIC;
BEGIN
	PROCESS (pstate, startBooth, co, op) BEGIN
		nstate <= INIT;
		CASE pstate IS
			WHEN INIT => 
				IF (startBooth = '1') THEN
                nstate <= COUNT;
				ELSE 
                nstate <= INIT;
				END IF; 
			WHEN COUNT => 
				nstate <= SHIFT; 
			WHEN SHIFT => 
				IF (co = '0') THEN             
                nstate <= COUNT; 
				ELSE                    
                nstate <= INIT;
				END IF;
			WHEN OTHERS => 
				nstate <= INIT;
		END CASE;
	END PROCESS;   

    PROCESS (pstate, startBooth, co, op ) BEGIN
		ldM <= '0'; ldQ <= '0'; ldP <= '0'; zeroP <= '0'; shrQ <= '0'; 
		sel <= '0'; subsel <= '0'; done <= '0'; cnt_rst <= '0'; cnt_en <= '0';
		CASE pstate IS
			WHEN INIT => 
				--done    <= '1';
				ldQ     <= '1'; 
				zeroP   <= '1';
				ldM     <= '1'; 
				cnt_rst <= '1';
			WHEN COUNT => cnt_en <= '1';
			WHEN SHIFT => 
				shrQ <= '1'; 
				ldP  <= '1'; 
				done <= co;
				IF (op = "10") THEN
                subsel <= '1'; 
                sel <= '1'; 
				ELSIF (op = "01" ) THEN
                sel <= '1'; 
				END IF;
			WHEN OTHERS =>
				ldM <= '0'; ldQ <= '0'; ldP <= '0'; zeroP <= '0'; shrQ <= '0'; 
		        sel <= '0'; subsel <= '0'; done <= '0'; cnt_rst <= '0'; cnt_en <= '0';
		END CASE;
	END PROCESS;
	  
	sequential : PROCESS (clk) BEGIN
		IF (clk = '1' AND clk'EVENT) THEN
			IF rst = '1' THEN 
				pstate <= INIT;
			ELSE 
				pstate <= nstate;
			END IF;
		END IF;   
    END PROCESS sequential; 

	counter: PROCESS (clk, rst) BEGIN
		IF cnt_rst = '1' THEN 
			temp <= (OTHERS => '0');
		ELSIF (clk = '1' AND clk'EVENT) THEN 
			IF (cnt_en = '1') THEN
				temp <= ('0' & cnt) + '1';
				IF (temp (5 DOWNTO 0) = "100001") THEN
					co <= '1';
				ELSE 
					co <= '0';
				END IF;
			END IF;
		END IF;
    END PROCESS counter; 
	cnt <= temp (5 DOWNTO 0);
END ARCHITECTURE behavioral;
		
