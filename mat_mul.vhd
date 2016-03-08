--i2c master--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------
entity mat_mul is

	port(
		CLK		: in std_logic;
		RST		: in std_logic;
	--	en			: in std_logic;
		data_slave  : in std_logic_vector(7 downto 0);
		data_slave_ready : in std_logic;
		done		: out std_logic;
		data_in  : in  std_logic_vector(29491199 downto 0);
		data_out	: out std_logic_vector(29491199 downto 0);
		matrixReq: out std_logic_vector(1 downto 0)
		
		
	);
end mat_mul;

------------------------------------------------------------------------------
architecture Behavioral of mat_mul is
	
	TYPE machine IS(ready, getone, gettwo, compute, send, stop);
	constant N : integer := 1080; 
	constant M : integer := 1920;
	SIGNAL P   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL state: machine;
	SIGNAL upperP	: STD_LOGIC;
	SIGNAL lowerP  : STD_LOGIC;
	SIGNAL gotM1   : STD_LOGIC := '0';
	SIGNAL gotM2   : STD_LOGIC := '0';
--	SIGNAL row	: INTEGER RANGE 0 to 1079 := 0;
--	SIGNAL col2   : INTEGER RANGE 0 to 1919 := 0;
--	SIGNAL col1	: INTEGER RANGE 0 to 1919 := 0;
	SIGNAL data_slave_r_prev : STD_LOGIC;
	
	type matrix11 is array(0 to M-1) of std_logic_vector(7 downto 0); --column
	type matrix1 is array(0 to N-1) of matrix11; --row  1080x1920
	
	type matrix22 is array(0 to M-1) of std_logic_vector(7 downto 0); --column
	type matrix2 is array(0 to M-1) of matrix22; --row 1920 x P
	
	type result33 is array(0 to M-1)  of std_logic_vector(7 downto 0); --column
	type result is array(0 to N-1) of result33; --row 1080 x P
	
  shared variable m1 : matrix1;
	shared variable m2 : matrix2;
	shared variable r	: result;
	
	shared variable i,j,k : integer:= 0;
	
	SIGNAL readytosend : std_logic := '0';
	
	SIGNAL result_done : STD_LOGIC := '0';
	SIGNAL count : STD_LOGIC_VECTOR(1 DOWNTO 0);
	
--function mm (a : matrix1; b: matrix2 ) return result is
--variable i,j,k : integer:= 0;
--variable result : result:=(others => (others => (others => '0')));
--begin
--for i in 0 to N-1 loop
--for j in 0 to M-1 loop
--for k in 0 to M-1 loop
--	result(i)(j) := STD_LOGIC_VECTOR(to_unsigned(result(i)(j),8) + (to_unsigned(a(i)(k),8) * to_unsigned(b(k)(j),8)));
--end loop;
--end loop;
--end loop;
--return result;
--end mm; 

	
	
begin

--process(state, gotM1, gotM2, CLK) begin
	--if( (state = compute) AND (gotM1 = '1') AND (gotM2 = '1') AND (CLK'EVENT AND CLK = '1')) then
	--	if(i = N-1) then
	--		result_done <= '1';
	--	end if;
	--	
	--	if(j = M-1) then
	--		j <= 0;
	--		i <= i+1;
--		end if;
		--if(k = to_unsigned(P-1)) then
	--		k <= 0;
--			j <= j+1;
--		else k <= k + 1;
--		end if;
	--	
--		result(i)(j) <= STD_LOGIC_VECTOR(to_unsigned(result(i)(j),8) + (to_unsigned(a(i)(k),8) * to_unsigned(b(k)(j),8)));
--	end if;
--end process;

process(CLK, state) begin
	if(state = getone) then
		matrixReq <= "00";
		if(i < N AND gotM1 = '0') then
			if(j < M) then
				m1(i)(j) := data_in(29491199-(k*8) downto 29491199-(k*8)-7);
				j := j + 1;
				k := k + 1;
			else
				j := 0;
				i := i + 1;
			end if;
		else
			i := 0;
			j := 0;
			k := 0;
			gotM1 <= '1';
		end if;
	
	elsif (state = gettwo) then
		matrixReq <= "01";
		if(i < N AND gotM2 = '0') then
			if(j < M) then
				m2(i)(j) := data_in(29491199-(k*8) downto 29491199-(k*8)-7);
				j := j + 1;
				k := k + 1;
			else
				j := 0;
				i := i + 1;
			end if;
		else
			i := 0;
			j := 0;
			k := 0;
			gotM2 <= '1';
		end if;
	
	elsif (state = compute) then
		if(gotM1 = '1' and gotM2 = '1') then
			--sum <= "00000000";
			--p <= "00000000";
			gotM1 <= '0';
			gotM2 <= '0';
		else
			if(result_done = '0' AND i < N) then
				if(j < to_integer(unsigned(P))) then
					if(k < M) then
						r(i)(j) := std_logic_vector(unsigned(r(i)(j)) + unsigned((unsigned(m1(i)(k)) * unsigned(m2(k)(j))) ));
						k := k + 1;
					else
						k := 0;
						j := j + 1;
					end if;
				else
					j := 0;
					i := i + 1;
				end if;
			else
				result_done <= '1';
				i := 0;
				j := 0;
				k := 0;
			end if;
		end if;
	
	elsif (state = send) then
	
	if(i < N AND readytosend = '0') then
			if(j < M) then
				data_out(29491199-(k*8) downto 29491199-(k*8)-7) <= r(i)(j);
				j := j + 1;
				k := k + 1;
			else
				j := 0;
				i := i + 1;
			end if;
		else
			i := 0;
			j := 0;
			k := 0;
			readytosend <= '1';
			matrixReq <= "10";
		end if;
	
		
	else
	
	end if;

end process;


process(CLK, RST) begin
	IF(RST = '0') THEN
		P <= "0000000000000000";
		state <= ready;
		upperP <= '0';
		lowerP <= '0';
		done <= '0';
	ELSIF(CLK'EVENT AND CLK = '1') THEN
		CASE state IS
			WHEN ready =>
				data_slave_r_prev <= data_slave_ready;
				if (data_slave_ready = '1' AND data_slave_r_prev = '0') THEN
					if(upperP = '0') THEN
						P(15 downto 8) <= data_slave;
						upperP <= '1';
					elsif (lowerP = '0') THEN
						P(7 downto 0) <= data_slave;
						lowerP <= '1';
					end if;
				end if;
				if ( (upperP = '0') OR (lowerP = '0') ) THEN
					state <= ready;
				else
					state <= getone;
				end if;
			WHEN getone =>
				if(gotM1 = '1') THEN
					state <= gettwo;
				else state <= getone;
				end if;
			WHEN gettwo =>
				if(gotM2 = '1') THEN
					state <= compute;
				else state <= gettwo;
				end if;
			
			WHEN compute =>
				if(result_done = '1') then
					state <= send;
				else
					state <= compute;
				end if;
				
			WHEN send =>
				if(readytosend <= '1') then
					state <= stop;
				else state <= send;
			end if;
				
			WHEN stop =>
				state <= stop;
				done <= '1';
				
			
		END CASE;
	END IF;
end process;
end Behavioral;