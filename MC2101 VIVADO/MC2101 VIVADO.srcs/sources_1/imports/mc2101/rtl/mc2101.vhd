-- **************************************************************************************
--	Filename:	mc2101.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		9 Sep 2022
--
-- Copyright (C) 2022 CINI Cybersecurity National Laboratory
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
--	CNL_RISC-V microcontroller hbus
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.Constants.ALL;

ENTITY mc2101 IS
    GENERIC( Physical_size     : INTEGER := Physical_size;
    		 busDataWidth      : INTEGER := dataWidth ;
		     busAddressWidth   : INTEGER := addressWidth
    );
	PORT(
	    sys_clk     : IN  STD_LOGIC;
	    sys_rst_n   : IN  STD_LOGIC;
	    gpio_pads   : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	    uart_rx     : IN  STD_LOGIC;
	    uart_tx     : OUT std_logic;
	    --Signals associated with the BRAM
	    address_bram  : OUT  STD_LOGIC_VECTOR(Physical_size-1 DOWNTO 0);
	    write_enable  : OUT STD_LOGIC;
	    enable        : OUT STD_LOGIC;
	    data_to_BRAM  : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
	    data_from_BRAM :IN STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
	    is_BRAM_busy : IN STD_LOGIC
	);
END mc2101;


ARCHITECTURE behavior OF mc2101 IS

    --MASTER INTERFACE
    COMPONENT core_bus_wrap IS
    GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32
	); 
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--input
		hready        : IN  STD_LOGIC;
		hresp         : IN  STD_LOGIC;
		hrdata        : IN  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		--output
		haddr         : OUT STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
		hwrdata       : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		hwrite        : OUT STD_LOGIC;
		htrans        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		--slave select (size must be extended to the number of slaves)
		hselram       : OUT STD_LOGIC;
		hselflash     : OUT STD_LOGIC;
		hselgpio      : OUT STD_LOGIC;
		hseluart      : OUT STD_LOGIC;
		--interrupt signals
		platInterrupts: IN  STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
    END COMPONENT;
    
    --SLAVES INTERFACE
    COMPONENT Mem_wrapper IS
	GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32;
		Physical_size     : INTEGER := 14
	);  
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--master driven signals
		htrans        : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		hselx         : IN  STD_LOGIC;
		hwrite        : IN  STD_LOGIC;
		hwrdata       : IN  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		haddr         : IN  STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
		--slave driven signals
		hrdata        : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		hready        : OUT STD_LOGIC;
		hresp         : OUT STD_LOGIC;
		---BRAM connections
        data_from_BRAM: IN STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		is_busy       : IN  STD_LOGIC;
		enable        : OUT STD_LOGIC;
		write_enable  : OUT STD_LOGIC;	
	    data_to_BRAM  : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0); 
	    address_bram  : OUT  STD_LOGIC_VECTOR(Physical_size-1 DOWNTO 0)
	);
    END COMPONENT;
    
    COMPONENT gpio_bus_wrap IS
	GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32
	);  
	PORT (
	    --#BUS INTERFACE SIGNAL
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--master driven signals
		htrans        : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		hselx         : IN  STD_LOGIC;
		hwrite        : IN  STD_LOGIC;
		hwrdata       : IN  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		haddr         : IN  STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
		--slave driven signals
		hrdata        : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		hready        : OUT STD_LOGIC;
		hresp         : OUT STD_LOGIC;
		--#EXTERNAL SIGNAL
	    gpio_interrupt: OUT STD_LOGIC;
	    gpio_pads     : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
    END COMPONENT;
    
    COMPONENT uart_bus_wrap IS 
    GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32
	);
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--master driven signals
		htrans        : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		hselx         : IN  STD_LOGIC;
		hwrite        : IN  STD_LOGIC;
		hwrdata       : IN  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		haddr         : IN  STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
		--slave driven signals
		hrdata        : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		hready        : OUT STD_LOGIC;
		hresp         : OUT STD_LOGIC;
		--slave external signals
		uart_interrupt: OUT STD_LOGIC;
		uart_rx       : IN  STD_LOGIC;
		uart_tx       : OUT STD_LOGIC
	);
    END COMPONENT;
    
    SIGNAL ssram_hrdata: STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
    SIGNAL ssram_hready: STD_LOGIC;
    SIGNAL ssram_hresp:  STD_LOGIC;
    
    SIGNAL gpio_hrdata: STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
    SIGNAL gpio_hready: STD_LOGIC;
    SIGNAL gpio_hresp: STD_LOGIC;
    
    SIGNAL uart_hrdata: STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
    SIGNAL uart_hready: STD_LOGIC;
    SIGNAL uart_hresp: STD_LOGIC;
    
    --BUS INTERCONNECTION
    SIGNAL htrans: STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL hselram: STD_LOGIC;
    SIGNAL hselflash: STD_LOGIC;
    SIGNAL hselgpio: STD_LOGIC;
    SIGNAL hseluart: STD_LOGIC;
    SIGNAL hwrite: STD_LOGIC;
    SIGNAL hwrdata: STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
    SIGNAL haddr: STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
    SIGNAL hrdata: STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
    SIGNAL hresp: STD_LOGIC;
    SIGNAL hready: STD_LOGIC;
    
    --INTERRUPTS
    SIGNAL platInterrupts: STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL gpio_interrupt: STD_LOGIC;  
    SIGNAL uart_interrupt: STD_LOGIC; 
    
    
    --POSITIVE RESET(to follow AMBA AHB protocol). The system has an active-low reset, but each component has an active-high reset
    SIGNAL rst_pos : STD_LOGIC;
    
BEGIN

    rst_pos <= NOT sys_rst_n;

    AFTAB: core_bus_wrap
    GENERIC MAP(
		busDataWidth=>busDataWidth,
		busAddressWidth=>busAddressWidth
	) 
	PORT MAP(
		clk=>sys_clk,
		rst=>rst_pos,
		hready=>hready,
		hresp=>hresp,
		hrdata=>hrdata,
		haddr=>haddr,
		hwrdata=>hwrdata,
		hwrite=>hwrite,
		htrans=>htrans,
		hselram=>hselram,
		hselflash=>hselflash,
		hselgpio=>hselgpio,
		hseluart=>hseluart,
		platInterrupts=>platInterrupts
    );
    
	platInterrupts(0)<=gpio_interrupt;
	platInterrupts(1)<=uart_interrupt;
	platInterrupts(15 DOWNTO 2)<=(OTHERS=>'0');
	
	
	BRAM: Mem_wrapper
    GENERIC MAP (
		busDataWidth => busDataWidth,
		busAddressWidth => busAddressWidth,
		Physical_size => Physical_size
	)
	PORT MAP(
	    --system signals
		clk => sys_clk,
		rst => rst_pos,
		--master driven signals
		htrans => htrans,
		hselx => hselram,
		hwrite => hwrite,
		hwrdata => hwrdata,
		haddr => haddr,
		--slave driven signals
		hrdata => hrdata,
		hready => hready,
		hresp => hresp,
		---BRAM connections
        data_from_BRAM => data_from_BRAM,
		is_busy => is_BRAM_busy,
		enable => enable,
		write_enable => write_enable,
	    data_to_BRAM => data_to_BRAM,
	    address_bram => address_bram
	);
	
	GPIO: gpio_bus_wrap
	GENERIC MAP(
		busDataWidth=>busDataWidth,
		busAddressWidth=>busAddressWidth
	) 
	PORT MAP(
		clk=>sys_clk,
		rst=>rst_pos,
		htrans=>htrans,
		hselx=>hselgpio,
		hwrite=>hwrite,
		hwrdata=>hwrdata,
		haddr=>haddr,
		hrdata=>gpio_hrdata,
		hready=>gpio_hready,
		hresp=>gpio_hresp,
	    gpio_interrupt=>gpio_interrupt,
	    gpio_pads=>gpio_pads
	);
	
	UART: uart_bus_wrap 
    GENERIC MAP(
		busDataWidth=>busDataWidth,
		busAddressWidth=>busAddressWidth
	)
	PORT MAP(
		clk=>sys_clk,
		rst=>rst_pos,
		htrans=>htrans,
		hselx=>hseluart,
		hwrite=>hwrite,
		hwrdata=>hwrdata,
		haddr=>haddr,
		hrdata=>uart_hrdata,
		hready=>uart_hready,
		hresp=>uart_hresp,
		uart_interrupt=>uart_interrupt,
		uart_rx=>uart_rx,
		uart_tx=>uart_tx
	);
	
	--SLAVES MUX
	hrdata<=ssram_hrdata WHEN hselram='1' ELSE
	        gpio_hrdata WHEN hselgpio='1' ELSE
	        uart_hrdata WHEN hseluart='1' ELSE
	        ssram_hrdata;     
	hready<=ssram_hready WHEN hselram='1' ELSE
	        gpio_hready WHEN hselgpio='1' ELSE
	        uart_hready WHEN hseluart='1' ELSE
	        ssram_hready;      
	hresp <=ssram_hresp  WHEN hselram='1' ELSE
	        gpio_hresp WHEN hselgpio='1' ELSE
	        uart_hresp WHEN hseluart='1' ELSE
	        ssram_hresp; 

END behavior;

