LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;

-- entity declaration for your testbench.Dont declare any ports here
ENTITY i2c_master_tb IS 
END i2c_master_tb;

ARCHITECTURE behavior OF i2c_master_tb IS
   -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT i2c_master
--just copy and paste the input and output ports of your module as such. 
    PORT( 
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
    END COMPONENT;
   --declare inputs and initialize them
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal SDA : std_logic;
   --declare outputs and initialize them
   signal en  : std_logic := '1';
	signal rw  : std_logic := '1';
	signal addr: std_logic_vector(6 downto 0) := "1010101";
	signal data_wr : std_logic_vector(7 downto 0) := "00110011";
	signal data_rd : std_logic_vector(7 downto 0);
	
	signal en_SDA : std_logic;
	--signal SDA : std_logic;
   -- Clock period definitions
   constant clk_period : time := 1 ns;
BEGIN
    -- Instantiate the Unit Under Test (UUT)
   uut: i2c_master PORT MAP (
			 CLK => CLK,
          RST => RST,
          en => en,
			 rw => rw,
			 addr => addr,
			 data_wr => data_wr,
			 data_rd => data_rd,
			 SDA => SDA
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
        wait for 7 ns;
        RST <='1';
        wait for 7 ns;
		    en <= '0';
		    
        wait;
  end process;
  SDA <= '0' when en_SDA = '1' ELSE 'Z';
  write_proc : process
  begin
      
      en_SDA <= '0'; --let SDA be SDA
      wait for 49500 ps;
      en_SDA <= '0';
      wait for 4000 ps;
      en_SDA <= '0';
      wait for 4000 ps;
      en_SDA <= '1';
      wait for 4000 ps;
      en_SDA <= '0';
      wait for 4000 ps;
      en_SDA <= '1';
      wait for 4000 ps;
      en_SDA <= '1';
      wait for 4000 ps;
      en_SDA <= '1';
      wait for 4000 ps;
      en_SDA <= '0';
      wait;
  end process;
END;