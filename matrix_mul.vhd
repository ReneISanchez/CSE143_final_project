--i2c master--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------
entity matrix_mul is

	port(
		CLK		: in std_logic;
		RST		: in std_logic;
		en			: in std_logic;
		data_slave  : in std_logic_vector(7 downto 0);
		data_slave_ready : in std_logic;
		done		: out std_logic;
		data_in  : in  std_logic_vector(29491199 downto 0);
		data_out	: out std_logic_vector(29491199 downto 0);
		matrixReq: out std_logic_vector(1 downto 0)
		
		
	);
end matrix_mul;

------------------------------------------------------------------------------
architecture Behavioral of matrix_mul is
	
	TYPE machine IS(ready, compute, stop);
	constant N : integer := 1080; 
	constant M : integer := 1920;
	SIGNAL P   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL state: machine;
	SIGNAL upperP	: STD_LOGIC;
	SIGNAL lowerP  : STD_LOGIC;
	SIGNAL gotM1   : STD_LOGIC;
	SIGNAL gotM2   : STD_LOGIC;
	SIGNAL row	: INTEGER RANGE 0 to 1079 := 0;
	SIGNAL col2   : INTEGER RANGE 0 to 1919 := 0;
	SIGNAL col1	: INTEGER RANGE 0 to 1919 := 0;
	SIGNAL data_slave_r_prev : STD_LOGIC;
	
	type matrix11 is array(0 to M-1) of std_logic_vector(7 downto 0);
	type matrix1 is array(0 to N-1) of matrix11;
	
	type matrix22 is array(0 to M-1) of std_logic_vector(7 downto 0);
	type matrix2 is array(0 to M-1) of matrix22;
	
	type result33 is array(0 to M-1)  of std_logic_vector(7 downto 0);
	type result is array(0 to M-1) of result33;
	
	
	SIGNAL result_done : STD_LOGIC;
	SIGNAL count : STD_LOGIC_VECTOR(1 DOWNTO 0);
	
function mm (a : matrix1; b: matrix2 ) return result is
variable i,j,k : integer:= 0;
variable prod : result:=(others => (others => (others => '0')));
begin
for i in 0 to N-1 loop
for j in 0 to M-1 loop
for k in 0 to M-1 loop
	prod(i)(j) := STD_LOGIC_VECTOR(to_unsigned(prod(i)(j),8) + (to_unsigned(a(i)(k),8) * to_unsigned(b(k)(j),8)));
end loop;
end loop;
end loop;
return prod;
end mm;

	
	
begin



process(count, CLK) begin
	if(RST ='0') THEN
		count <= "00";
		matrixReq <= "00";
	elsif(count = "00") then
		count <= "01";
		matrixReq <= "00";
	elsif (count = "01") then
		matrix1 <= data_in;
		count <= "10";
		matrixReq <= "01";
	elsif (count = "10") then
		matrix2 <= data_in;
		count <= "11";
		matrixReq <= "10";
	else
		count <= count;
		matrixReq <= count;
		data_out <= result;
		gotM1 <= '1';
		gotM2 <= '1';
	end if;
end process;


process(state, gotM1, gotM2) begin
	if( (state = compute) AND (gotM1 = '1') AND (gotM2 = '1') ) then
		result <= mm(matrix1,matrix2);
		result_done <= '1';
	end if;
end process;

process(CLK, RST) begin
	IF(RST = '0') THEN
		P <= "0000000000000000";
		state <= ready;
		upperP <= '0';
		lowerP <= '0';
		done <= '0';
		result_done <= '0';
	ELSIF(CLK'EVENT AND CLK = '1') THEN
		CASE state IS
			WHEN ready =>
				data_slave_r_prev <= data_slave_ready;
				if (data_slave_ready = '1' AND data_slave_r_prev = '0') THEN
					if(not upperP) THEN
						P(15 downto 8) <= data_slave;
						upperP <= '1';
					elsif (not lowerP) THEN
						P(7 downto 0) <= data_slave;
						lowerP <= '1';
					end if;
				end if;
				if ( (not upperP) OR (not lowerP) ) THEN
					state <= ready;
				else
					state <= compute;
				end if;
			WHEN compute =>
				if(result_done = '1') then
					state <= stop;
				else
					state <= compute;
				end if;
				
			WHEN stop =>
				state <= stop;
				done <= '1';
				
			
		END CASE;
	END IF;
end process;
end Behavioral;