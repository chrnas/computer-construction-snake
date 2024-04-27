LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ALU_tb IS
END ALU_tb;

ARCHITECTURE func OF ALU_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT ALU
  PORT(clk : IN std_logic;
       rst : IN std_logic;
       A : IN unsigned(27 downto 0);
       B : IN unsigned(27 downto 0);
       U : OUT unsigned(27 downto 0);

       O : OUT std_logic;
       C : OUT std_logic;
       N : OUT std_logic;
       Z : OUT std_logic;
       L : OUT std_logic);
  END COMPONENT;

  --Inputs
  signal clk : std_logic:= '0';
  signal rst : std_logic:= '0';
  signal A : unsigned(27 downto 0) := "0000000000000000000000000000";
  signal B : unsigned(27 downto 0) := "0000000000000000000000000000";
  signal U : unsigned(27 downto 0) := "0000000000000000000000000000";

  signal O : std_logic := '0';
  signal C : std_logic := '0';
  signal N : std_logic := '0';
  signal Z : std_logic := '0';
  signal L : std_logic := '0';

  --Clock period definitions
  constant clk_period : time:= 1 us;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut: ALU PORT MAP (
    clk => clk,
    rst => rst,
    A => A,
    B => B
  );
		
  -- Clock process definitions
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  stimuli_generator : process
  variable error_count : integer := 0;

    procedure asserter(cond : in boolean; str : in string) is begin
      if cond then
        report str & " : PASS " & string'(str'length to 53 => ' ') & ":-)" severity note;
      else
        report str & " : FAIL " & string'(str'length to 53 => ' ') & "X-(" severity error;
        error_count := error_count +1;
      end if;
    end procedure;
      

begin

  wait until rising_edge(clk); 

  wait for 2 * clk_period;
  --asserter(TIMER = 1, "shuld be 1");     
  
  wait;       
end process;
end architecture;