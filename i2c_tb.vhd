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
    PORT( 
			RST		: in std_logic;
			SCL		: in std_logic;
			SDA		: inout std_logic;
			DIN		: in std_logic_vector(7 downto 0)					-- Recepted over i2c data byte
        );
    END COMPONENT;
   --declare inputs and initialize them
   signal scl : std_logic := '0';
   signal rst : std_logic := '1';
	signal din : std_logic_vector := "1111000";
   --declare outputs and initialize them
   signal count : std_logic_vector(3 downto 0);
   -- Clock period definitions
   constant clk_period : time := 6 ns;
BEGIN
    -- Instantiate the Unit Under Test (UUT)
   uut: test PORT MAP (
         scl => scl,
          rst => rst,
          din => din
        );       

   -- Clock process definitions( clock with 50% duty cycle is generated here.
   clk_process :process
   begin
        scl <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        scl <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;
   -- Stimulus process
  stim_proc: process
   begin         
        wait for 30 ns;
        reset <='0';
        wait for 15 ns;
		  reset <= '1';
		  wait for 30 ns:
        din <= "00001111";
        wait for 30 ns;
	     din <= "10101010";
        wait;
  end process;

END;