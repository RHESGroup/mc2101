-- **************************************************************************************
--	Filename:	flash.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		17 May 2022
--
-- Copyright (C) 2022 CINI Cybersecurity National Laboratory and University of Teheran
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 3.0 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE. See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from https://www.gnu.org/licenses/lgpl-3.0.txt
--
-- **************************************************************************************
--
--	File content description:
--	flash read only memory containing code
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.CONSTANTS.ALL;

ENTITY flash IS
    GENERIC (
        dataWidth       :INTEGER:=8;
        addressWidth    :INTEGER:=12
    );
    PORT (
        clk             :IN  STD_LOGIC;
        address         :IN  STD_LOGIC_VECTOR(addressWidth-1 DOWNTO 0);
        enable          :IN  STD_LOGIC;
        dataOut         :OUT STD_LOGIC_VECTOR(dataWidth-1 DOWNTO 0)
    );
END flash;

ARCHITECTURE behavior OF flash IS
    --SIGNAL a_Q: UNSIGNED(dataWidth-1 DOWNTO 0);
BEGIN

    PROCESS(address, enable)
    BEGIN
        IF enable='1' THEN
            dataOut<=boot_code(TO_INTEGER(UNSIGNED(address)));
        END IF;
    END PROCESS;

END behavior;
