LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

-- entity declaration for your testbench.Dont declare any ports here
ENTITY mat_mul_tb IS 
END mat_mul_tb;

ARCHITECTURE behavior OF mat_mul_tb IS
   -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT mat_mul
--just copy and paste the input and output ports of your module as such. 
    PORT( 
		CLK		: in std_logic;
		RST		: in std_logic;
	--	en			: in std_logic;
		data_slave  : in std_logic_vector(7 downto 0);
		data_slave_ready : in std_logic;
		done		: out std_logic;
		data_in  : in  std_logic_vector(16588799 downto 0);
		data_out	: out std_logic_vector(16588799 downto 0);
		matrixReq: out std_logic_vector(1 downto 0)
        );
    END COMPONENT;
   --declare inputs and initialize them
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal data_slave : std_logic_vector(7 downto 0):= "00000000";
   --declare outputs and initialize them
  -- signal en  : std_logic := '1';
	signal data_slave_ready  : std_logic := '0';
	signal done: std_logic;
	signal data_in : std_logic_vector(16588799 downto 0) := std_logic_vector(to_unsigned(2147483646,16588800));
	signal data_out : std_logic_vector(16588799 downto 0);
	signal matrixReq : std_logic_vector(1 downto 0);
	
	--signal SDA : std_logic;
   -- Clock period definitions
   constant clk_period : time := 5 ps;
BEGIN
    -- Instantiate the Unit Under Test (UUT)
   uut: mat_mul PORT MAP (
			 CLK => CLK,
          RST => RST,
          data_slave => data_slave,
			 data_slave_ready => data_slave_ready,
			 done => done,
			 data_in => data_in,
			 data_out => data_out,
			 matrixReq => matrixReq
        );       

   -- Clock process definitions( clock with 50% duty cycle is generated here.
   clk_process :process
   begin
        CLK <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        CLK <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;
   -- Stimulus process
  stim_proc: process
   begin         
        wait for 7 ps;
        RST <='1';
        wait;
  end process;
  
  
  write_proc : process
  begin
		wait until RST = '1';
      wait until CLK = '0';
		data_slave_ready <= '1';
		wait until CLK = '1';
		
		wait until CLK = '0';
		data_slave_ready <= '0';
		data_slave <= "00001111";
		wait until CLK = '1';
		
		wait until CLK = '0';
		data_slave_ready <= '1';
		
      wait until matrixReq = "01";
		data_in <= std_logic_vector(to_unsigned(123456789,16588800));
		
      wait;
  end process;
END;