-- ram_file.vhd
-- A parameterized, inferable, true dual-port, dual-clock block RAM in VHDL.
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
  
 
entity ram_file is
port (
    -- Controller port
    ctrl_clk   : in  std_logic;
    ctrl_wr    : in  std_logic;
    ctrl_addr  : in  std_logic_vector(1 downto 0);
    ctrl_din   : in  std_logic_vector(29491199 downto 0);
    ctrl_dout  : out std_logic_vector(29491199 downto 0);
     
    -- Multiplier port
    mul_clk   : in  std_logic;
    mul_wr    : in  std_logic;
    mul_addr  : in  std_logic_vector(1 downto 0);
    mul_din   : in  std_logic_vector(29491199 downto 0);
    mul_dout  : out std_logic_vector(29491199 downto 0)
);
end ram_file;
 
architecture behavioral of ram_file is
    -- Shared memory
    type ram_t is array (11059199 downto 0) of std_logic_vector(7 downto 0);
	 --type ram_t is std_logic_vector(0 to (2**30)*8);
    shared variable mem : ram_t;
	 
	 signal location_ctrl : std_logic_vector(58982399 downto 0);
	 signal location_mul :  std_logic_vector(58982399 downto 0);
	 constant mat : integer := 29491200;
	 
	 function memWrite(loc: in std_logic_vector; ram_mem: in ram_t) return std_logic_vector is
			variable output: std_logic_vector(29491199 downto 0) := std_logic_vector(to_unsigned(0,mat));
			variable count: integer := 0;
		begin
			for i in to_integer(unsigned(loc)) to (294921200 + to_integer(unsigned(loc))) loop
				if(count = 7) then
					output((i) downto (i-7)) := ram_mem((i/7) - 1);
					count := 0;
				else
					count := count + 1;
				end if;
			end loop;
				
			return output;
 
		end memWrite;
		
	 function memReplace(loc: in std_logic_vector; ram_mem: in ram_t; data_in: in std_logic_vector) 
		return ram_t is
			variable output: ram_t := ram_mem;
			variable count: integer := 0;
		begin
			for i in to_integer(unsigned(loc)) to (294921200 + to_integer(unsigned(loc))) loop
				if(count = 7) then
					output((i/7) - 1) := data_in(i downto (i-7));
					count := 0;
				else
					count := count + 1;
				end if;
			end loop;
				
			return output;
 
		end memReplace;
begin

-- location = A when addr is 00
-- location = B when addr is 01
-- location = R when addr is 10

--Determine ctrl location
process(ctrl_addr)
begin
	case ctrl_addr is
		when "00" => location_ctrl <= std_logic_vector(to_unsigned(0, 58982400));			--Matrix A
		when "01" => location_ctrl <= std_logic_vector(to_unsigned(mat, 58982400));		--Matrix B
		when "10" => location_ctrl <= std_logic_vector(to_unsigned(mat*2, 58982400));		--Result
		when others => null;
	end case;
end process;
 
--Determine mul location 
process(mul_addr)
begin
	case mul_addr is
		when "00" => location_mul <= std_logic_vector(to_unsigned(0, 58982400));		--Matrix A
		when "01" => location_mul <= std_logic_vector(to_unsigned(mat, 58982400));		--Matrix B
		when "10" => location_mul <= std_logic_vector(to_unsigned(mat*2, 58982400));	--Result
		when others => null;
	end case;
end process;
 
-- Controller port
process(ctrl_clk)
begin
    if(ctrl_clk'event and ctrl_clk='1') then
        if(ctrl_wr='0') then
            --mem(to_integer(unsigned(location_ctrl)) to (3686400-1) + to_integer(unsigned(location_ctrl))) := ctrl_din((3686400-1));
				mem := memReplace(location_ctrl, mem, ctrl_din);
        else
				--ctrl_dout <= mem(to_integer(unsigned(location_ctrl)) to to_integer(unsigned(location_ctrl)) + (3686400-1));
				ctrl_dout <= memWrite(location_ctrl, mem);
			end if;
    end if;
end process;
 
-- Controller port
process(mul_clk)
begin
    if(mul_clk'event and mul_clk='1') then
        if(mul_wr='0') then
            --mem(to_integer(unsigned(location_mul)) to (3686400-1) + to_integer(unsigned(location_mul))) := mul_din((3686400-1));
				mem := memReplace(location_mul, mem, mul_din);
        else
				--mul_dout <= mem(to_integer(unsigned(location_mul)) to to_integer(unsigned(location_mul)) + (3686400-1));
				mul_dout <= memWrite(location_mul, mem);
			end if;
    end if;
end process;
 
end behavioral;