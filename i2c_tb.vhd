LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;

-- entity declaration for your testbench.Dont declare any ports here
ENTITY i2c_tb IS 
END i2c_tb;

ARCHITECTURE behavior OF i2c_tb IS
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
    END COMPONENT i2c_master;
	 
	 COMPONENT i2c_slave
	 PORT(
		RST		: in std_logic;
		SCL		: in std_logic;
		SDA 		: inout std_logic;
		DOUT		: out std_logic_vector(7 downto 0)
		);
	  END COMPONENT i2c_slave;

   --declare inputs and initialize them
	signal clk : std_logic := '0';
   signal scl : std_logic := 'Z';
	signal sda : std_logic := '0';
   signal rst : std_logic := '0';
	signal rw  : std_logic := '0';
	signal en : std_logic := '1';
	signal addr : std_logic_vector(6 downto 0) := "0000001";
	signal data_wr : std_logic_vector(7 downto 0) := "00110011";
	
   --declare outputs and initialize them
	signal dout  : std_logic_vector(7 downto 0) := "00000000";
	signal data_rd : std_logic_vector(7 downto 0) := "00000000";
	
	signal en_SDA : std_logic;
	
	signal output_slave : std_logic;
   -- Clock period definitions
   constant clk_period : time := 6 ns;
BEGIN
    -- Instantiate the Unit Under Test (UUT)

	uut_master: i2c_master PORT MAP (
			 CLK => CLK,
          RST => RST,
          en => en,
			 rw => rw,
			 addr => addr,
			 data_wr => data_wr,
			 data_rd => data_rd,
			 SDA => SDA,
			 scl => scl
        );    
		  
   uut_slave: i2c_slave PORT MAP(
			 rst => rst, 
			 scl => scl,
			 --output_slave => sda,
			 sda => output_slave, 
			 dout => dout
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
        --RST <='1';
		    
        wait;
  end process;
  --SDA <= output_slave when output_en = '1' ELSE 'Z';
  output_slave <= SDA when en_SDA = '0';
  SDA <= output_slave when en_SDA = '1' ELSE 'Z';
  write_proc : process
  begin
      
      en_SDA <= '0'; --let SDA be SDA
      wait for 49500 ps;
		rst <= '1';
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
		en <= '1';
		
		wait for 470000 ps;
		rst <= '0';
		wait for 800000 ps;
		rst <= '1';
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
		en <= '1';
		
		
		
      wait;
  end process;
END;