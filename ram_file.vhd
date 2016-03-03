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
    ctrl_din   : in  std_logic_vector((3686400-1)*8 downto 0);
    ctrl_dout  : out std_logic_vector((3686400-1)*8 downto 0);
     
    -- Multiplier port
    mul_clk   : in  std_logic;
    mul_wr    : in  std_logic;
    mul_addr  : in  std_logic_vector(1 downto 0);
    mul_din   : in  std_logic_vector((3686400-1)*8 downto 0);
    mul_dout  : out std_logic_vector((3686400-1)*8 downto 0)
);
end ram_file;
 
architecture behavioral of ram_file is
    -- Shared memory
    type ram_t is array (0 to 2**30 ) of std_logic_vector(7 downto 0);
    shared variable mem : ram_t;
	 
	 signal location_ctrl : std_logic_vector(((2**30) - 1)*8 downto 0);
	 signal location_mul : std_logic_vector(((2**30) - 1)*8 downto 0);
	 constant mat : integer := 29491200;
	 
	 function memWrite(loc:std_logic_vector, ram_mem:mem) return std_logic; 
begin

-- location = A when addr is 00
-- location = B when addr is 01
-- location = R when addr is 10

--Determine ctrl location
process(ctrl_addr)
begin
	case ctrl_addr is
		when "00" => location_ctrl <= std_logic_vector(to_unsigned(0,mat));
		when "01" => location_ctrl <= std_logic_vector(to_unsigned(mat - 1,mat));
		when "10" => location_ctrl <= std_logic_vector(to_unsigned(mat*2 - 1, mat));
		when others => null;
	end case;
end process;
 
--Determine mul location 
process(mul_addr)
begin
	case mul_addr is
		when "00" => location_mul <= std_logic_vector(to_unsigned(0,mat));
		when "01" => location_mul <= std_logic_vector(to_unsigned(mat - 1,mat));
		when "10" => location_mul <= std_logic_vector(to_unsigned(mat*2 - 1, mat));
		when others => null;
	end case;
end process;
 
-- Controller port
process(ctrl_clk)
begin
    if(ctrl_clk'event and ctrl_clk='1') then
        if(ctrl_wr='1') then
            mem(to_integer(unsigned(location_ctrl)) to (3686400-1) + to_integer(unsigned(location_ctrl))) := ctrl_din((3686400-1));
        end if;
        ctrl_dout <= mem(to_integer(unsigned(location_ctrl)) to to_integer(unsigned(location_ctrl)) + (3686400-1));
    end if;
end process;
 
-- Controller port
process(mul_clk)
begin
    if(mul_clk'event and mul_clk='1') then
        if(mul_wr='1') then
            mem(to_integer(unsigned(location_mul)) to (3686400-1) + to_integer(unsigned(location_mul))) := mul_din((3686400-1));
        end if;
        mul_dout <= mem(to_integer(unsigned(location_mul)) to to_integer(unsigned(location_mul)) + (3686400-1));
    end if;
end process;
 
 function memWrite(loc:std_logic_vector, ram_mem: mem)
	return std_logic is 
 begin
 
 end memWrite;
 
end behavioral;