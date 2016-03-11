------------------------------------------------------------------------------
-- i2c slave receiver
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------
entity i2c_slave is
	generic(
		WR       : std_logic:='0';
		DADDR		: std_logic_vector(6 downto 0) := "0000001"	   --device address
	);
	port(
		RST		: in std_logic;
		SCL		: in std_logic;
		SDA		: inout std_logic;
		DOUT 		: out std_logic_vector(7 downto 0)			   -- Data to send to multiplier
	);

end i2c_slave;

architecture Behavioral of i2c_slave is
	signal DOUT_S: std_logic_vector(7 downto 0);
	signal SDA_IN, SCL_IN, START, START_RST, STOP, ACTIVE, ACK	: std_logic;
	signal SHIFTREG	: std_logic_vector(8 downto 0);
	signal ACTIVE_REG : std_logic;
	signal STATE : std_logic_vector(1 downto 0) := "00";		-- 00 - idle state	

begin


-- start condition detection
process (RST, SCL_IN, SDA_IN)
begin
	if RST = '0' or SCL_IN = '0' then
		START <= '0';
	elsif SCL_IN = '1' and (SDA_IN = '0' and SDA_IN'event) then
		START <= '1';
	end if;
end process;

-- stop condition detection
process (RST, SCL_IN, SDA_IN, START)
begin
	if RST = '0' or SCL_IN = '0' or START='1' then
		STOP <= '0';
	elsif SCL_IN = '1' and (SDA_IN = '1' and SDA_IN'event) then
		STOP <= '1';
	end if;
end process;

--Active signal control
process (RST, STOP, START)
begin
	if RST = '0' or STOP = '1' then	 --or (SHIFTREG="000000001" and ACK = '0' and SCL='1' and SCL'event) 
		ACTIVE <= '0';
	elsif START = '0' and START'event then
		ACTIVE <= '1';
	end if;
end process;

-- Read data into shift reg
process (RST, ACTIVE, ACK, SCL_IN, SDA_IN)
begin 
if RST = '0' or ACTIVE = '0' then
	SHIFTREG 	<= "000000001";	
elsif SCL_IN'event and SCL_IN = '1' then
	if ACK = '1' then
		SHIFTREG <= "000000001";
	else
		if SDA_in = 'Z' then
			SHIFTREG(8 downto 0) <= SHIFTREG(7 downto 0) & '1';
		else 
			SHIFTREG(8 downto 0) <= SHIFTREG(7 downto 0) & '0';
		end if;
	end if;
end if;							  
end process;

-- send i2c data read to multiplier
process (RST, STATE, ACK, SHIFTREG)
begin
if RST = '0' then
	DOUT_S <= "00000000";
elsif STATE="10" and (ACK='1' and ACK'event) then 
	DOUT_S <= SHIFTREG(7 downto 0);
end if;
end process; 

-- ACK
process (RST, SCL_IN, SHIFTREG, STATE, ACTIVE)
begin
if RST = '0' or ACTIVE = '0' then
	ACK <= '0';
	STATE <= "00";
elsif SCL_IN='0' and SCL_IN'event then 
	if SHIFTREG(8) = '1' and STATE/="11" then
		STATE <= std_logic_vector(unsigned(STATE) + "1");
		if ((STATE="00" and SHIFTREG(7 downto 0) = DADDR & WR) or STATE="01") then 
			ACK <= '1';
		else
			STATE <= "11";
		end if;
	else
	   ACK <= '0';
	end if;
end if;
end process;

-- ACK response to master
SDA_IN <= SDA;
SDA <= '0' when ACK = '1' else 'Z';
SCL_IN <= '1' when SCL = 'Z' else '0';
DOUT(7 downto 0) <= DOUT_S(7 downto 0);

end Behavioral;