LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY uprogCPU_tb IS
END uprogCPU_tb;

ARCHITECTURE func OF uprogCPU_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT uprogCPU
  PORT(clk: in std_logic;
        rst: in std_logic;
        SS : inout std_logic;
        MOSI : inout std_logic;
        MISO : in std_logic;
        SCLK : inout std_logic;
        vgaRed : out std_logic_vector(2 downto 0);
        vgaGreen : out std_logic_vector(2 downto 0);
        vgaBlue : out std_logic_vector(2 downto 1);
        Hsync : out std_logic;
        Vsync : out std_logic;
        LED : out std_logic_vector(7 downto 0);
        joystick_code: in unsigned(3 downto 0);
        TIMER_test : out unsigned(25 downto 0);
        PC_test : out unsigned(11 downto 0);
        GR1_test : out unsigned(19 downto 0);
        uPC_test : out unsigned(7 downto 0);
        AR_test : out unsigned(21 downto 0)
       );
  END COMPONENT;

  --Inputs
  signal clk : std_logic;
  signal rst : std_logic;
  signal SS : std_logic;
  signal MOSI : std_logic;
  signal MISO : std_logic;
  signal SCLK : std_logic;

  signal joystick_code : unsigned(3 downto 0);
  signal TIMER_test : unsigned(25 downto 0);
  signal PC_test : unsigned(11 downto 0);
  signal uPC_test : unsigned(7 downto 0);
  signal AR_test : unsigned(21 downto 0);
  signal JA : std_logic_vector(7 downto 0);

  --Clock period definitions
  constant clk_period : time:= 10 ns;

  begin

  

  -- Instantiate the test_unit
  test_unit: uprogCPU PORT MAP (
    clk => clk,
    rst => rst,
    MOSI => MOSI,
    MISO => MISO,
    SS => SS,
    SCLK => SCLK,
    joystick_code => joystick_code,
    TIMER_test => TIMER_test,
    PC_test => PC_test,
    uPC_test => uPC_test,
    AR_test => AR_test
  );


    rst <= '1', '0' after 1.5*clk_period;
    
  -- Clock process definitions
  clk_process :process
  begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
  end process;



--PROC_SEQUENCE : process
--begin
  -- Test all possible input values
  
  --wait for 1 ns;
   
  --report "Test: OK";
  
 
--end process;  
  
  --PROC_CHECKER : process
--begin

 -- joystick_code <= "0000";

  --assert clk = '1' report "clk is 1" severity error;  

  --rst <= '1', '0' after 1.7 us;

  --wait until rising_edge(clk); 

 -- wait for 2 * clk_period;
  
  --assert clk = '1' report "clk is 1" severity error;

  --assert (Z = '1') report "Z is not 1" severity error;
  --assert (Z = '1') report "Z is not 1" severity error;
--end process;


TIMER_check : process
begin
  
  --Counters is 0
  wait for 1.5*clk_period;
  assert PC_test = "000000000000" report "PC counter is not 0" severity error;
  assert uPC_test = "00000000" report "uPC is not 0" severity error;
  assert TIMER_test = "00000000000000000000000000" report "timer not 0 at start" severity error;

  --Counters after 2 cycles
  wait for clk_period;
  assert uPC_test = "00000001" report "uPC is not 1" severity error;
  assert PC_test = "000000000000" report "PC counter is not 0" severity error;
  assert TIMER_test = "00000000000000000000000001" report "timer not 1 after another 2 clk_period" severity error;

  --Counters after 3 cycles
  wait for clk_period;
  assert uPC_test = "00000010" report "uPC is not 2" severity error;
  assert PC_test = "000000000001" report "PC counter is not 1" severity error;
  assert TIMER_test = "00000000000000000000000010" report "timer not 2" severity error;

  --Counters after 4 cycles
  wait for clk_period;
  assert uPC_test = "00000011" report "uPC is not 3" severity error;
  assert TIMER_test = "00000000000000000000000011" report "timer not 3" severity error;

  --Counters after 5 cycles
  wait for clk_period;
  assert uPC_test = "000001011" report "uPC is not 0B(LOAD)" severity error;
  assert TIMER_test = "00000000000000000000000100" report "timer not 4" severity error;


  wait;
end process;




  
end architecture;


