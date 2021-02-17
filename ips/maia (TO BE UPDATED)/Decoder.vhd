LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Decoder IS
	PORT (
		En : IN STD_LOGIC;
		inDecoder : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		outDecoder : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END ENTITY Decoder ;

ARCHITECTURE behavioral OF Decoder IS 

BEGIN 
	PROCESS(inDecoder, En)
	BEGIN
		IF En='1' then
			CASE inDecoder IS
				WHEN "00" => outDecoder <= "0001"; 
				WHEN "01" => outDecoder <= "0010"; 
				WHEN "10" => outDecoder <= "0100"; 
				WHEN "11" => outDecoder <= "1000";
				WHEN OTHERS => outDecoder <= "0000";
			END CASE;
		ELSE 
			outDecoder <= "0000";
		END IF;
	END PROCESS;
END ARCHITECTURE behavioral;
		

