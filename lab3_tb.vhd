LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

-- entity declaration for your testbench.Dont declare any ports here
ENTITY lab3_tb IS 
END lab3_tb;

ARCHITECTURE behavior OF lab3_tb IS
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

	  COMPONENT ram_file
	  PORT(
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
	  END COMPONENT ram_file;
	  
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
    END COMPONENT mat_mul;	  
	 
	 
	 -----------------------------------------
	 -- MASTER / SLAVE
	 -----------------------------------------
   --declare inputs and initialize them
	signal clk : std_logic := '0';
   signal scl : std_logic := 'Z';
	signal sda : std_logic := '0';
   signal rst : std_logic := '0';
	signal rw  : std_logic := '0';
	signal en : std_logic := '1';
	signal addr : std_logic_vector(6 downto 0) := "0000001";
	signal data_wr : std_logic_vector(7 downto 0) := "00000100";
	
   --declare outputs and initialize them
	signal dout  : std_logic_vector(7 downto 0) := "00000000";
	signal data_rd : std_logic_vector(7 downto 0) := "00000000";
	
	signal en_SDA : std_logic;
	
	signal output_slave : std_logic;
   -- Clock period definitions
   constant clk_period_master_slave : time := 6 ns;
	
	
	 -----------------------------------------
	 -- RAM
	 -----------------------------------------	
   --controller in/out
   signal ctrl_clk : std_logic := '0';
   signal ctrl_wr : std_logic := '1';
   signal ctrl_addr : std_logic_vector(1 downto 0) := "00";
	signal ctrl_din : std_logic_vector(16588799 downto 0) := std_logic_vector(to_unsigned(10, 16588800));
	signal ctrl_dout : std_logic_vector(16588799 downto 0) := std_logic_vector(to_unsigned(0, 16588800));
	
   --multiplier in/out
   signal mul_clk : std_logic := '0';
   signal mul_wr : std_logic := '1';
   signal mul_addr : std_logic_vector(1 downto 0) := "00";
	signal mul_din : std_logic_vector(16588799 downto 0) := std_logic_vector(to_unsigned(0, 16588800));
	signal mul_dout : std_logic_vector(16588799 downto 0) := std_logic_vector(std_logic_vector(to_unsigned(0, 16588800)));
	
   constant clk_period_ram : time := 5 ps;
	
	 -----------------------------------------
	 -- MULTIPLIER
	 -----------------------------------------
	--declare inputs and initialize them
   signal CLK_mul : std_logic := '0';
   signal RST_mul : std_logic := '0';
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
   constant clk_period_mul : time := 5 ps;
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
   clk_process_master_slave :process
   begin
        CLK <= '0';
        wait for clk_period_master_slave/2;  --for 0.5 ns signal is '0'.
        CLK <= '1';
        wait for clk_period_master_slave/2;  --for next 0.5 ns signal is '1'.
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
		data_wr <= "00111000";
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
  
	 -----------------------------------------
	 -- RAM
	 -----------------------------------------
	 
	   -- Instantiate the Unit Under Test (UUT)
   uut_ram: ram_file PORT MAP (
			 ctrl_clk => ctrl_clk,
          ctrl_wr => ctrl_wr,
          ctrl_addr => ctrl_addr,
			 ctrl_din => ctrl_din,
			 ctrl_dout => ctrl_dout,

			 mul_clk => mul_clk,
          mul_wr => mul_wr,
          mul_addr => mul_addr,
			 mul_din => mul_din,
			 mul_dout => mul_dout
        );       

   -- Clock process definitions( clock with 50% duty cycle is generated here.
   clk_process :process
   begin
        ctrl_clk <= '0';
		  mul_clk <= '0';
        wait for clk_period_ram/2;  --for 0.5 ns signal is '0'.
        ctrl_clk <= '1';
		  mul_clk <= '1';
        wait for clk_period_ram/2;  --for next 0.5 ns signal is '1'.
   end process; 
	
 write_proc_ram : process
  begin
      
      wait for 50 ps;
      ctrl_wr <= '0';
		mul_addr <= "10";
		
      wait for 25 ps;
		ctrl_din <= std_logic_vector(to_unsigned(50, 16588800));
		ctrl_addr <= "01";
		
      wait for 25 ps;
		ctrl_wr <= '1';
      ctrl_addr <= "00";
		mul_addr <= "00";
		
      wait for 25 ps;
      mul_addr <= "01";
		
      wait for 25 ps;
      mul_addr <= "10";
		mul_wr <= '0';

      wait;
  end process;	
  
	 -----------------------------------------
	 -- Multiplier
	 -----------------------------------------
	
	-- Instantiate the Unit Under Test (UUT)
   uut_mul: mat_mul PORT MAP (
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
   clk_process_mul :process
   begin
        CLK <= '0';
        wait for clk_period_mul/2;  --for 0.5 ns signal is '0'.
        CLK <= '1';
        wait for clk_period_mul/2;  --for next 0.5 ns signal is '1'.
   end process;
   -- Stimulus process
  stim_proc_mul: process
   begin         
        wait for 7 ps;
        RST <='1';
        wait;
  end process;
  
  
  write_proc_mul : process
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