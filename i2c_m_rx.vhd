------------------------------------------------------------------------------
-- i2c slave receiver
------------------------------------------------------------------------------
-- Intended target: Xilinx CoolRunner-II CPLD  (XC2C64A)
-- Development tools: XILINX ISE 7.1i webpack
-- Author:  DMITRY PETROV
-- Notes:
-- Date:     11-09-2005
-- Revision: 1.0
------------------------------------------------------------------------------
-- This code implements i2c slave which is able to receive a data byte.
 
-- i2c message has 3 parts:
-- <Device Address> 22h
-- <Sub Address> 00h
-- <Data byte> XX 
-- If Device and Sub Addresses are matched the data byte will be accepted.

-- Because of SCL line used as clock for i2c state machine, slow SCL changes 
-- will make noise and invalid data reception. 

-- To avoid noise of slow SCL - usualy used an external CLOCK, for 
-- clocking all modules but it will take some amount of CPLD's macrocells.

-- Another way is to use an SCHMITT TRIGGER on SCL and SDA. 
-- Forexample XILINX CoolRunner-II CPLD, has SCHMITT TRIGGER on it's I/O.
-- By default this function is deactivated, PLEASE ACTIVATE IT !

-- If your PLD have no SCHMITT TRIGGER function, you may use solution wich 
-- require 2 resistors and aditional output pin. 
-- Here's an old Xilinx app note about it: 
-- http://www.xilinx.com/xcell/xl19/xl19-34.pdf 
-- ===========================================================================
-- DISCLAIMER: This code is FREEWARE which is provided on an �as is� basis, 
-- YOU MAY USE IT ON YOUR OWN RISK, WITHOUT ANY WARRANTY. 
-- ===========================================================================d

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

------------------------------------------------------------------------------
entity i2c_m_rx is
	generic(
		DADDR		: std_logic_vector(6 downto 0); --:= "0010001";		   -- 11h (22h) device address
		ADDR		: std_logic_vector(7 downto 0);  --:= "00000000"		   -- 00h	    sub address		
	);
	port(
		RST		: in std_logic;
		SCL		: in std_logic;
		SDA		: inout std_logic;
		DIN 		: in std_logic_vector(7 downto 0)			   -- Recepted over i2c data byte
	);
	--SCHMITT TRIGGER activation (folowing 3 strings should be uncommented)
	--attribute SCHMITT_TRIGGER: string; 
	--attribute SCHMITT_TRIGGER of SCL: signal is "true"; 
	--attribute SCHMITT_TRIGGER of SDA: signal is "true";
end i2cs_rx;

------------------------------------------------------------------------------
architecture Behavioral of i2cs_rx is
	signal DOUT_S: std_logic_vector(7 downto 0);
	signal SDA_IN, START, START_RST, STOP, ACTIVE, ACK	: std_logic;
	signal SHIFTREG	: std_logic_vector(8 downto 0);
	signal STATE : std_logic_vector(1 downto 0);		-- 00 - iddle state	
	signal addrData : std_logic;																		-- 01 - DADDR  compare
	signal count : std_logic_vector(3 downto 0);																			-- 10 - ADDR compare																		-- 11 - DATA read
begin


-- stop condition detection
process (RST, SCL, SDA, START)
begin
	if (RST = '0' or (SCL = '0')) or START = '1' then
		STOP <= '0';
		if(STATE = '00') then
			addrData <= '0';
			count <= "0110";
		end if;
	elsif SCL = '1' and (SDA = '1' and SDA'EVENT) then
		STOP <= '1';
	end if;
end process;

------------------------------------------------------------------------------
-- start condition detection, method 2 ( simple - but week against noise )
process (RST, SCL, SDA_IN, START)
begin
	if (SDA = '0' and (SCL = '0' and SCL'EVENT)  then
		START <= '1';
		if(STATE = '01') then
			count <= '0111';
		end if;
	elsif SCL = '1' and (SDA = '0' and SDA'event) then
		START <= '0';
	end if;
end process;

------------------------------------------------------------------------------
-- "active communication" signal 
process (RST, STOP, START)
begin
	if RST = '0' or STOP = '1' then	 --or (SHIFTREG="000000001" and ACK = '0' and SCL='1' and SCL'event) 
		ACTIVE <= '0';
	elsif START = '0' and START'event then
		ACTIVE <= '1';
	end if;
end process;

------------------------------------------------------------------------------
-- WX data shifter
process (RST, ACTIVE, ACK, SCL, SDA_IN)
begin 
if (STATE = "10" or STATE = "01") and (SCL = '1' and SCL'EVENT) then
	if(SDA = '0')
		addrData = '1';
		STATE = "11";
	end if;
	--SHIFTREG <= "000000001";	

		--SHIFTREG(8 downto 0) <= SHIFTREG(7 downto 0) & SDA_IN;
end if;							  
end process;

------------------------------------------------------------------------------
-- I2C data write
process (RST, SHIFTREG, addrData, START, STATE,count)
begin
if RST = '0' then
	DOUT_S <= "00000000";
elsif addrData='0' and (START = '0' and START'EVENT) and (to_integer(count) >= "0000") then	
	SDA <= DADDR(to_integer(unsigned count));
	count <= std_logic_vector(to_integer(unsigned count) - "0001");
	STATE <= '00';
elsif count = "1111" and addrData = '0'  then
	SDA <= '0';
	STATE <= '01';
elsif count >= "0000" and addrData = '1' and (START = '0' and START'EVENT) then
	SDA <= DIN(to_integer(unsigned count));
	count <= std_logic_vector(to_integer(unsigned count) - "0001");
   if count == "0000" then
		STATE <= "10";
	end if;
elsif addrData = '1' and STATE = "11" then
	RST <= '0';
	STATE <= '0';
	addrData <= '0';
end if;
end process; 

------------------------------------------------------------------------------
DOUT(7 downto 0) <= DOUT_S(7 downto 0);

end Behavioral;
------------------------------------------------------------------------------