library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter2 is
	port(clk, reset : in std_logic; -- reset is active high.
	     CE : in std_logic;
			 up_down : in std_logic;
			 clear : in std_logic;
	     u : out unsigned(3 downto 0));
end entity;

architecture behav of counter2 is
	signal CE_sync : std_logic;
	signal up_down_sync : std_logic;
	signal clear_sync : std_logic;
	signal cntr : unsigned(3 downto 0);
begin
	-- process 1: Syncronize the three inputs:
	
	-- process 2: Implement the counter:
	
end architecture;

