--i2c master--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------
entity i2c_master is

	port(
		CLK		: in std_logic;
		RST		: in std_logic;
		en			: in std_logic;
		rw			: in std_logic;
		addr		: in std_logic_vector(6 downto 0);
		data_wr  : in std_logic_vector(7 downto 0);
		
		SDA		: inout std_logic;
		SCL		: out std_logic;
		
		data_rd	: out std_logic_vector(7 downto 0)
	);
end i2c_master;

------------------------------------------------------------------------------
architecture Behavioral of i2c_master is
	TYPE machine IS(ready,start,command,slv_ack1,wr,rd,slv_ack2,mstr_ack,stop);
	SIGNAL state: machine;
	SIGNAL scl_clk	: STD_LOGIC;
	SIGNAL scl_clk_past : STD_LOGIC;
	SIGNAL sda_data: STD_LOGIC;
	SIGNAL sda_ena_n     : STD_LOGIC;
	SIGNAL addr_rw : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL data_w  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL data_r  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL bit_cnt	: INTEGER RANGE 0 to 7 := 7;
	SIGNAL count   : INTEGER RANGE 0 to 3 := 0;
begin

process(CLK, RST) begin
	IF(RST = '0') THEN
		count <= 0;
	ELSIF(CLK'EVENT and CLK = '1') THEN
		if(count = 0) THEN
				scl_clk <= '0';
				scl_clk_past <= scl_clk;
				count <= count + 1;
		elsif(count = 1) THEN
				scl_clk <= '0';
				scl_clk_past <= scl_clk;
				count <= count + 1;
		elsif(count = 2) THEN
				scl_clk <= '1';
				scl_clk_past <= scl_clk;
				count <= count + 1;
		else
				scl_clk <= '1';
				scl_clk_past <= scl_clk;
				count <= 0;
		end if;
	END IF;

end process;

process(CLK, RST) begin
	IF(RST = '0') THEN
		state <= ready;
		data_rd <= "00000000";
		bit_cnt <= 7;
		SDA <= '1';
	ELSIF(CLK'EVENT AND CLK = '1') THEN
		CASE state IS
		WHEN ready =>
			IF(en = '1') THEN
				addr_rw <= addr & rw;
				data_w  <= data_wr;
				state   <= start;
				sda_data <= '0';
			ELSE
				state <= ready;
			END IF;
		
		WHEN start =>
			if(scl_clk = '1' AND scl_clk_past = '0') THEN
				sda_data <= addr_rw(bit_cnt);
				state <= command;
			ELSE
				state <= start;
			end if;

		WHEN command =>
			IF(bit_cnt = 0) THEN
				bit_cnt <= 7;
				state <= slv_ack1;
			ELSE
				bit_cnt <= bit_cnt - 1;
				sda_data <= addr_rw(bit_cnt-1);
				state <= command;
			END IF;

		WHEN slv_ack1 =>
			IF(addr_rw(0) = '0') THEN
				state <= wr;
				sda_data <= data_w(bit_cnt);
			ELSE
				state <= rd;
				data_r(bit_cnt) <= SDA;
			END IF;
		
		WHEN wr =>
			IF(bit_cnt = 0) THEN
				bit_cnt <= 7;
				state <= slv_ack2;
				sda_data <= '0';
			ELSE
				bit_cnt <= bit_cnt - 1;
				sda_data <= data_w(bit_cnt-1);
			END IF;
		
		WHEN rd =>
			IF(bit_cnt = 0) THEN
				bit_cnt <= 7;
				data_rd <= data_r;
				state <= mstr_ack;
			ELSE
				bit_cnt <= bit_cnt -1;
				data_r(bit_cnt-1) <= SDA; 
				state <= rd;
			END IF;
			
		WHEN slv_ack2 =>
			IF(en = '1') THEN
				IF(rw = '1') THEN
					state <= start;
				ELSE
					state <= wr;
					sda_data <= data_w(bit_cnt);
				END IF;
			ELSE
				state <= stop;
			END IF;
			
		WHEN mstr_ack =>
			IF(en = '1') THEN
				addr_rw <= addr & rw;
				data_w <= data_wr;
				IF(rw ='0') THEN
					state <= start;
				ELSE
					state <= rd;
				END IF;
			ELSE
				state <= stop;
			END IF;
		WHEN stop =>
			IF(en = '1') THEN
				state <= ready;
			ELSE
				state <= stop;
			END IF;
		END CASE;
	END IF;

end process;

WITH state select
	sda_ena_n <= scl_clk_past WHEN start,     --generate start condition
                 NOT scl_clk_past WHEN stop,  --generate stop condition
                 sda_data WHEN OTHERS;          --set to internal sda signal

SCL <= scl_clk;
SDA <= '0' WHEN sda_ena_n = '0' ELSE 'H';


end Behavioral;