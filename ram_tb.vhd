library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity declaration for your testbench.Dont declare any ports here
ENTITY ram_tb IS 
END ram_tb;

ARCHITECTURE behavior OF ram_tb IS
   -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT ram_file
--just copy and paste the input and output ports of your module as such. 
    PORT( 
    -- Controller port
    ctrl_clk   : in  std_logic;
    ctrl_wr    : in  std_logic;
    ctrl_addr  : in  std_logic_vector(1 downto 0);
    ctrl_din   : in  std_logic_vector((3686400)*8 - 1 downto 0);
    ctrl_dout  : out std_logic_vector((3686400)*8 - 1 downto 0);
     
    -- Multiplier port
    mul_clk   : in  std_logic;
    mul_wr    : in  std_logic;
    mul_addr  : in  std_logic_vector(1 downto 0);
    mul_din   : in  std_logic_vector((3686400)*8 - 1 downto 0);
    mul_dout  : out std_logic_vector((3686400)*8 - 1 downto 0)
        );
    END COMPONENT;
	 
   --controller in/out
   signal ctrl_clk : std_logic := '0';
   signal ctrl_wr : std_logic := '1';
   signal ctrl_addr : std_logic_vector(1 downto 0) := "00";
	signal ctrl_din : std_logic_vector((3686400)*8 - 1 downto 0) := std_logic_vector(to_unsigned(10, (3686400)*8));
	signal ctrl_dout : std_logic_vector((3686400)*8 - 1 downto 0) := std_logic_vector(to_unsigned(0, (3686400)*8));
	
   --multiplier in/out
   signal mul_clk : std_logic := '0';
   signal mul_wr : std_logic := '1';
   signal mul_addr : std_logic_vector(1 downto 0) := "00";
	signal mul_din : std_logic_vector((3686400)*8 - 1 downto 0) := std_logic_vector(to_unsigned(0, (3686400)*8));
	signal mul_dout : std_logic_vector((3686400)*8 - 1 downto 0) := std_logic_vector(std_logic_vector(to_unsigned(0, (3686400)*8)));
	
   constant clk_period : time := 1 ns;
BEGIN
    -- Instantiate the Unit Under Test (UUT)
   uut: ram_file PORT MAP (
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
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        ctrl_clk <= '1';
		  mul_clk <= '0';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;

  write_proc : process
  begin
      
      wait for 50 ps;
      ctrl_wr <= '0';
		mul_addr <= "10";
		
      wait for 25 ps;
		ctrl_din <= std_logic_vector(to_unsigned(50, (3686400)*8));
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
END;