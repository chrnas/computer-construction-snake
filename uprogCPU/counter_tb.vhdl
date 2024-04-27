library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_tb is
end entity;

architecture sim of counter_tb is
	component uprog_CPU is
		port(clk, reset : in std_logic; -- reset is active high.
		     x : in std_logic; -- x
			 u : out unsigned(2 downto 0));
	end component;
	-- DUT I/O:
	signal clk,reset : std_logic := '0';
	signal x : std_logic;
	signal u : unsigned(2 downto 0);
	signal TIMER : unsigned(25 downto 0);
	
	-- test bench signals:
	signal done : boolean := false;
begin
	clk <= not clk after 100 ns when not done; -- 5 MHz
	
	process begin
		reset <= '1', '0' after 500 ns;
		x <= '0';
		wait for 1 us;
		wait until rising_edge(clk);
		
		assert u = 0 report "1. u should be 0 after reset                         :-(" severity error;
		-- Test to count.
		x <= '1';
		wait until falling_edge(clk); -- now, x='1', x_sync='0', counter=0
		wait until falling_edge(clk); -- now, x='1', x_sync='1', counter=0
		wait until falling_edge(clk); -- now, x='1', x_sync='1', counter=1
		assert u = 1 report "2. u should be 1 after 2 clock cycles                :-(" severity error;
		wait until falling_edge(clk); -- now, x='1', x_sync='1', counter=2
		wait until falling_edge(clk); -- now, x='1', x_sync='1', counter=3
		wait until falling_edge(clk); -- now, x='1', x_sync='1', counter=4
		wait until falling_edge(clk); -- now, x='1', x_sync='1', counter=5
		wait until falling_edge(clk); -- now, x='1', x_sync='1', counter=6
		wait until falling_edge(clk); -- now, x='1', x_sync='1', counter=7
		wait until falling_edge(clk); -- now, x='1', x_sync='1', counter=0
		wait until falling_edge(clk); -- now, x='1', x_sync='1', counter=1
		wait until falling_edge(clk); -- now, x='1', x_sync='1', counter=2
		assert u = 2 report "3. u should be 2 after 11 clock cycles               :-(" severity error;
		-- Stop it
		x <= '0';
		wait until falling_edge(clk); -- now, x='0', x_sync='0', counter=3
		wait until falling_edge(clk); -- now, x='0', x_sync='0', counter=3
		wait until falling_edge(clk); -- now, x='0', x_sync='0', counter=3
		assert u = 3 report "4. u should be 3 after stop                          :-(" severity error;
		
		-- Test that reset is asynchronouse, and overrides counting:
		reset <= '1';
		x <= '1';
		wait for 30 ns;
		assert u = 0 report "5. u should reset asyncronouse                       :-(" severity error;
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		assert u = 0 report "6. u should keep 0 during reset                      :-(" severity error;
		
		-- Done
		report "### TEST BENCH DONE. Did you get any error message?" severity note;
		done <= true;
		wait;
	end process;

	process begin
		wait until falling_edge(clk);
		assert Timer = 1 report "1. Timer should be 1 :-(" severity error;

	
	-- Design under test:
	DUT : counter port map (
	  clk => clk,
	  reset => reset,
	  x => x,
	  u => u);
	  
end architecture;

