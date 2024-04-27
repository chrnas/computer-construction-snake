library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter2_tb is
end entity;

architecture sim of counter2_tb is
	component counter2 is
		port(clk, reset : in std_logic; -- reset is active high.
				 CE : in std_logic;
				 up_down : in std_logic;
				 clear : in std_logic;
				 u : out unsigned(3 downto 0));
	end component;
	-- DUT I/O:
	signal clk,reset : std_logic := '0';
	signal CE, up_down, clear : std_logic := '0';
	signal u : unsigned(3 downto 0);
	
	-- test bench signals:
	signal done : boolean := false;
begin
	clk <= not clk after 100 ns when not done; -- 5 MHz
	
	process begin
		reset <= '1', '0' after 500 ns;
		wait for 1 us;
		wait until rising_edge(clk);
		
		assert u = 0 report "1. u should be 0 after reset                         :-(" severity error;

		-- Test to count.
		up_down <= '1'; -- count up
		CE <= '1';
		wait until falling_edge(clk); -- now, CE='1', CE_sync='0', cntr=0
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=0 (note: CE_sync was 0 before the clock flank)
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=1
		assert u = 1 report "2. u should be 1 after 2 clock cycles                :-(" severity error;
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=2
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=3
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=4
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=5
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=6
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=7
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=8
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=9
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=0
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=1
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=2
		assert u = 2 report "3. u should be 2 after 12 clock cycles               :-(" severity error;

		-- Stop it
		CE <= '0';
		wait until falling_edge(clk); -- now, CE='0', CE_sync='0', cntr=3 (CE_sync was 1)
		wait until falling_edge(clk); -- now, CE='0', CE_sync='0', cntr=3
		wait until falling_edge(clk); -- now, CE='0', CE_sync='0', cntr=3
		assert u = 3 report "4. u should be 3 after stop                          :-(" severity error;

		-- Count back to 8 (pause at 0 and 9)
		CE <= '1';
		up_down <= '0';
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=3 (CE_sync was 0)
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=2
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=1
		CE <= '0';
		wait until falling_edge(clk); -- now, CE='0', CE_sync='0', cntr=0
		CE <= '1';
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=0
		CE <= '0';
		wait until falling_edge(clk); -- now, CE='0', CE_sync='0', cntr=9
		CE <= '1';
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=9
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=8
		assert u = 8 report "5. u should be 8 after stepping back                 :-(" severity error;

		-- Count up to 2 (paus at 9)
		up_down <= '1';
		wait until falling_edge(clk); -- now, ud='1', ud_sync='1', cntr=7 (up_down was 0)
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=8
		CE <= '0';
		wait until falling_edge(clk); -- now, CE='0', CE_sync='0', cntr=9
		CE <= '1';
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=9
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=0
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=1
		wait until falling_edge(clk); -- now, CE='1', CE_sync='1', cntr=2
		assert u = 2 report "6. u should be 2 after wrapping forward              :-(" severity error;

		-- Test to clear while counting
		clear <= '1';
		wait until falling_edge(clk); -- now, cl='1', cl_sync='1', cntr=3 (cl was zero, still counting)
		clear <= '0';
		wait until falling_edge(clk); -- now, cl='0', cl_sync='0', cntr=0
		wait until falling_edge(clk); -- now, cl='0', cl_sync='0', cntr=1
		assert u = 1 report "7. u should be 1 after clear+count                   :-(" severity error;
		
		-- Test that reset is asynchronouse, and overrides counting:
		reset <= '1';
		CE <= '1';
		wait for 30 ns;
		assert u = 0 report "8. u should reset asyncronouse                       :-(" severity error;
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		assert u = 0 report "9. u should keep 0 during reset                      :-(" severity error;
		
		-- Done
		report "### TEST BENCH DONE. Did you get any error message?" severity note;
		done <= true;
		wait;
	end process;
	
	-- Design under test:
	DUT : counter2 port map (
	  clk => clk,
	  reset => reset,
		CE => CE,
	  up_down => up_down,
		clear => clear,
	  u => u);
	  
end architecture;

