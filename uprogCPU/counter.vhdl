library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
	port(clk, reset : in std_logic; -- reset is active high.
	     x : in std_logic; -- x
	     u : out unsigned(2 downto 0));
end entity;

architecture behav of counter is
	signal x_sync : std_logic;
	signal cntr : unsigned(2 downto 0);
begin
	-- Input syncronization (no reset):
	process(clk) begin
		-- TODO: Assign x_sync in this process (and remove this comment)
	end process;
	
	-- Implement the internal counter, cntr:
	process(clk, reset) begin
		-- TODO: Implement cntr in this process (and remove this comment)
	end process;
	
	-- Connect the counter to the u output:
	u <= cntr;
end architecture;

