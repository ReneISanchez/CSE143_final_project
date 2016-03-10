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
    ctrl_din   : in  std_logic_vector(16588799 downto 0);
    ctrl_dout  : out std_logic_vector(16588799 downto 0);
     
    -- Multiplier port
    mul_clk   : in  std_logic;
    mul_wr    : in  std_logic;
    mul_addr  : in  std_logic_vector(1 downto 0);
    mul_din   : in  std_logic_vector(16588799 downto 0);
    mul_dout  : out std_logic_vector(16588799 downto 0)
);
end ram_file;
 
architecture behavioral of ram_file is
    -- Shared memory
    type ram_t is array (8313599 downto 0) of std_logic_vector(7 downto 0);
	 --type ram_t is std_logic_vector(0 to (2**30)*8);
    shared variable mem : ram_t;
	 
	 signal location_ctrl : std_logic_vector(33177599 downto 0);
	 signal location_mul :  std_logic_vector(33177599 downto 0);
	 constant mat : integer := 16588800;
	 constant res : integer := 9331200;
	 constant loc_size: integer := 33177600;
	 
	 function memGet(loc: in std_logic_vector; ram_mem: in ram_t; isRes: in integer) return std_logic_vector is
			variable output: std_logic_vector(16588799 downto 0) := std_logic_vector(to_unsigned(0,mat));
			variable count: integer := 0;
			variable offset: integer := 16588800;
			variable temp: std_logic_vector(7 downto 0) := "00000000";
			variable outCount: integer := 7;
		begin
			if(isRes = 1) then
				offset := 9331200;
			end if;
		
			for i in to_integer(unsigned(loc)) to (offset - 1 + to_integer(unsigned(loc))) loop
				if(count = 7) then
					--output((i) downto (i-7)) := ram_mem((i/7) - 1);
					temp := ram_mem((i/7) - 1);
					output((outCount) downto (outCount-7)) := temp;
					count := 0;
					outCount := outCount + 7;
				else
					count := count + 1;
				end if;
			end loop;
				
			return output;
 
		end memGet;
		
	 function memWrite(loc: in std_logic_vector; ram_mem: in ram_t; data_in: in std_logic_vector; isRes: in integer) 
		return ram_t is
			variable output: ram_t := ram_mem;
			variable count: integer := 0;
			variable offset: integer := 16588800;
			variable outCount: integer := 7;
		begin
			if(isRes = 1) then
				offset := 9331200;
			end if;
		
			for i in to_integer(unsigned(loc)) to (offset - 1 + to_integer(unsigned(loc))) loop
				if(count = 7) then
					output((i/7) - 1) := data_in(outCount downto (outCount-7));
					count := 0;
					outCount := outCount + 7;
				else
					count := count + 1;
				end if;
			end loop;
				
			return output;
 
		end memWrite;
begin

-- location = A when addr is 00
-- location = B when addr is 01
-- location = R when addr is 10

--Determine ctrl location
process(ctrl_addr)
begin
	case ctrl_addr is
		when "00" => location_ctrl <= std_logic_vector(to_unsigned(0, loc_size));			--Matrix A
		when "01" => location_ctrl <= std_logic_vector(to_unsigned(mat, loc_size));		--Matrix B
		when "10" => location_ctrl <= std_logic_vector(to_unsigned(mat*2, loc_size));		--Result
		when others => null;
	end case;
end process;
 
--Determine mul location 
process(mul_addr)
begin
	case mul_addr is
		when "00" => location_mul <= std_logic_vector(to_unsigned(0, loc_size));		--Matrix A
		when "01" => location_mul <= std_logic_vector(to_unsigned(mat, loc_size));		--Matrix B
		when "10" => location_mul <= std_logic_vector(to_unsigned(mat*2, loc_size));	--Result
		when others => null;
	end case;
end process;
 
-- Controller port
process(ctrl_clk)
begin
    if(ctrl_clk'event and ctrl_clk='1') then
        if(ctrl_wr='0') then
				if(ctrl_addr = "10") then
					mem := memWrite(location_ctrl, mem, ctrl_din, 1);
				else
					mem := memWrite(location_ctrl, mem, ctrl_din, 0);
				end if;
        else
				if(ctrl_addr = "10") then
					ctrl_dout <= memGet(location_ctrl, mem,1);
				else 
					ctrl_dout <= memGet(location_ctrl, mem,0);			
				end if;
			end if;
    end if;
end process;
 
-- Controller port
process(mul_clk)
begin
    if(mul_clk'event and mul_clk='1') then
        if(mul_wr='0') then
				if(mul_addr = "10") then
					mem := memWrite(location_mul, mem, mul_din,1);
				else	
					mem := memWrite(location_mul, mem, mul_din,0);					
				end if;
        else
				if(mul_addr = "10") then
					mul_dout <= memGet(location_mul, mem,1);
				else
					mul_dout <= memGet(location_mul, mem,0);
				end if;
			end if;
    end if;
end process;
 
end behavioral;