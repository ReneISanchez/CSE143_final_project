LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;

-- entity declaration for your testbench.Dont declare any ports here
ENTITY i2c_tb IS 
END i2c_tb;

ARCHITECTURE behavior OF i2c_tb IS
   -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT i2c_m_rx  --'test' is the name of the module needed to be tested.
--just copy and paste the input and output ports of your module as such. 

	 --master
    PORT( 
			CLK		: in std_logic;
			RST		: in std_logic;
			SCL		: out std_logic;
			SDA		: inout std_logic;
			DIN		: in std_logic_vector(7 downto 0);					-- Recepted over i2c data byte
			DOUT 		: out std_logic_vector(7 downto 0)
        );
    END COMPONENT;
	 
	 --slave
	 COMPONENT i2cs_rx
    PORT( 
			RST		: in std_logic;
			SCL		: in std_logic;
			SDA		: inout std_logic;
			DOUT 		: out std_logic_vector(7 downto 0)
        );
    END COMPONENT;
	 
	 
   --declare inputs and initialize them
		--master
		signal clk : std_logic := '0';
		signal rst : std_logic := '0';
		signal din : std_logic_vector(7 downto 0) := "11110000";
		signal sda : std_logic := '0';
	
		--slave
		signal rst_s : std_logic := '0';
		signal scl_s : std_logic := '0';
		signal sda_s : std_logic := '0';
	
	
   --declare outputs and initialize them
		--master
		signal dout : std_logic_vector (7 downto 0) := "00000000";
		signal scl  : std_logic := '0';
		
		--slave
		signal dout_s  : std_logic_vector(7 downto 0) := "00000000";
	
   -- Clock period definitions
   constant clk_period : time := 6 ns;
	
	
BEGIN
    -- Instantiate the Unit Under Test (UUT)
   uut_master: i2c_m_rx PORT MAP (
			clk => clk,
         --scl => scl,
			sda => sda,
         rst => rst,
         din => din,
			dout => dout
        );       

	uut_slave: i2cs_rx PORT MAP(
			rst => rst_s, 
			scl => scl,
			sda => sda,	
			dout => dout_s
		);	  
		
		
   -- Clock process definitions( clock with 50% duty cycle is generated here.
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;
	
	
   -- Stimulus process
  stim_proc: process
   begin         
        wait for 10 ns;
        rst <='0';
		  rst_s <= '0';
		  
        wait for 15 ns;
		  rst <= '1';
		  rst_s <= '1';
		  
		  wait for 30 ns;
        din <= "00001111";
		  
        wait for 30 ns;
	     din <= "10101010";
		  
        wait;
  end process;

END;