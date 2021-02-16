
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY std_logic_ram IS
	GENERIC (data_file, dump_file :string);
	PORT (
	address : IN std_logic_vector;
	datain : IN std_logic_vector;
	dataout : OUT std_logic_vector;
	cs : IN std_logic; 
	memRead, memWrite : IN std_logic; 
	opr : IN BOOLEAN;
	data_ready : OUT std_logic
	);
END ENTITY std_logic_ram;
--
ARCHITECTURE RAM OF std_logic_ram IS
	TYPE mem IS ARRAY (NATURAL RANGE <>) of std_logic_vector(datain'length-1 downto 0);
	PROCEDURE init_mem (VARIABLE memory: OUT mem; CONSTANT datafile: STRING) IS
			FILE stddata : TEXT;
			VARIABLE l : LINE;
			VARIABLE data : std_logic_vector(datain'length-1 downto 0);
		BEGIN
		FILE_OPEN (stddata, datafile, READ_MODE);
		FOR i IN memory'RANGE(1) LOOP
			READLINE (stddata, l); READ (l, data);
		--	FOR j IN memory'RANGE(2) LOOP
				memory (i) := data;
			--END LOOP;
		END LOOP;
	END PROCEDURE init_mem;

	PROCEDURE dump_mem (VARIABLE memory: IN mem;
		CONSTANT datafile: STRING) IS
		FILE stddata : TEXT;
		VARIABLE stdvalue : std_logic_vector(datain'length-1 downto 0);
		VARIABLE l : LINE;
	BEGIN
		FILE_OPEN (stddata, datafile, WRITE_MODE);
		FOR i IN memory'RANGE(1) LOOP
		--	FOR j IN memory'RANGE(2) LOOP
				stdvalue := memory (i);
				WRITE (l, stdvalue);
		--	END LOOP;
			WRITELINE (stddata, l);
		END LOOP;
	END PROCEDURE dump_mem;

BEGIN
PROCESS
	CONSTANT memsize : INTEGER := 2**7;
	VARIABLE memory : mem (0 TO memsize-1);
	BEGIN
		data_ready <= '0';
		id:IF opr'EVENT THEN
		      IF opr=TRUE THEN init_mem (memory, data_file);
		      ELSE dump_mem (memory, dump_file); 
		      END IF;
		      END IF;
		wr: IF cs = '1' THEN
			IF memWrite = '1' THEN -- Writing
				WAIT FOR 1 ns;
				--FOR i IN dataout'RANGE LOOP
				memory(conv_integer(address)):=datain;
			--	END LOOP;
				WAIT FOR 4 ns;
				data_ready <= '1';
				WAIT FOR 25 ns;
				data_ready <= '0';
			ELSIF memRead = '1' THEN -- Reading
				--FOR i IN datain'RANGE LOOP
				WAIT FOR 1 ns;
				dataout<=memory(conv_integer(address));
				--END LOOP;
				WAIT FOR 4 ns;
				data_ready <= '1';
				WAIT FOR 25 ns;
				data_ready <= '0';
			ELSE 
				dataout<=  (datain'length-1 downto 0 => 'Z');
			END IF;
		END IF;
		WAIT ON cs, memWrite, memRead, address, datain, opr;
	END PROCESS;
END ARCHITECTURE RAM;

