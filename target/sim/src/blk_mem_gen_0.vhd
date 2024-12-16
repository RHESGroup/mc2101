----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2024 03:37:35 PM
-- Design Name: 
-- Module Name: blk_mem_gen_0 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;
USE work.Constants.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY blk_mem_gen_0 IS
  GENERIC( Physical_size     : INTEGER := Physical_size;
    	   busDataWidth      : INTEGER := dataWidth 
  );
  PORT (
    --Port A --Port to write
    ENA        : IN STD_LOGIC;  --opt port
    WEA        : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    ADDRA      : IN STD_LOGIC_VECTOR(Physical_size - 1  DOWNTO 0);
    DINA       : IN STD_LOGIC_VECTOR(busDataWidth - 1 DOWNTO 0);
    CLKA       : IN STD_LOGIC;
    --Port B -- Port to read
    ENB        : IN STD_LOGIC;  --opt port
    ADDRB      : IN STD_LOGIC_VECTOR(Physical_size - 1   DOWNTO 0);
    DOUTB      : OUT STD_LOGIC_VECTOR(busDataWidth - 1 DOWNTO 0);
    CLKB       : IN STD_LOGIC
  );

END blk_mem_gen_0;

ARCHITECTURE Behavioral OF blk_mem_gen_0 IS

    TYPE MEMORY IS ARRAY (0 TO 2**Physical_size - 1) OF STD_LOGIC_VECTOR (busDataWidth - 1 DOWNTO 0);
	
	FUNCTION init_memory_from_file (filename : string) RETURN MEMORY IS
    FILE f : TEXT;
    VARIABLE m : MEMORY;
    VARIABLE adr: STD_LOGIC_VECTOR(addressWidthSRAM-1 DOWNTO 0);
	VARIABLE memline: LINE;
	VARIABLE linechar: CHARACTER;
	VARIABLE read_address: STD_LOGIC_VECTOR (31 DOWNTO 0);
	VARIABLE read_data: STD_LOGIC_VECTOR (31 DOWNTO 0);
	VARIABLE index: INTEGER:=0;
	VARIABLE end_iram : INTEGER := 16#FFFFF#;
    BEGIN
        file_open(f, filename, read_mode);
        for index in MEMORY'range loop  
            IF ENDFILE(f) THEN
                exit;
            END IF;
	        READLINE (f, memline);
			HREAD (memline, read_address);
			READ (memline, linechar); -- read character '_' 
		    HREAD (memline, read_data);
		    IF UNSIGNED(read_address) > end_iram THEN -- it is a data address (see file link.common.ld)
			    adr := '1' & read_address(addressWidthSRAM-2 DOWNTO 0);
			ELSE -- it is a program address
				adr := '0' & read_address(addressWidthSRAM-2 DOWNTO 0);
			END IF;
				m(TO_INTEGER(UNSIGNED(adr))) 	 := read_data(7 DOWNTO 0);
				m(TO_INTEGER(UNSIGNED(adr) + 1)) := read_data(15 DOWNTO 8);
				m(TO_INTEGER(UNSIGNED(adr) + 2)) := read_data(23 DOWNTO 16);
				m(TO_INTEGER(UNSIGNED(adr) + 3)) := read_data(31 DOWNTO 24);
		END LOOP;
		FILE_CLOSE (f);
        RETURN m;
    END init_memory_from_file;  
   
	SIGNAL mem : MEMORY:=init_memory_from_file("/home/mc2101-pynq/Desktop/mc2101/util/spi_stim.txt");

BEGIN

    --Synch write with enable
    PROCESS(CLKA)
    BEGIN
        IF (rising_edge(CLKA)) THEN
            IF(ENA = '1' and WEA = "1") THEN
                mem(TO_INTEGER(UNSIGNED(ADDRA))) <= DINA;
            END IF;
        END IF;
    END PROCESS;
      
    --Synch read with enable
    PROCESS(CLKB)
    BEGIN
        IF (rising_edge(CLKB)) THEN
            IF ENB = '1' THEN
                DOUTB <= mem(TO_INTEGER(UNSIGNED(ADDRB)));
            END IF;
        END IF;
    END PROCESS;

END Behavioral;
