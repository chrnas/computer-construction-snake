LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY uprogCPU_tb IS
END entity;

architecture behavioral of uprogCPU_tb is
  component uprogCPU is
    port(clk: in std_logic;
    rst: in std_logic;
    TIMER : out unsigned(25 downto 0));
end component;

signal clk, rst : std_logic;
signal TIMER : unsigned(25 downto 0);
begin

uut : uprogCPU port map(
      clk => clk,
      rst => rst,
      TIMER => TIMER
);

stim : process
begin
    
clk <= '0';
rst <= '0';
wait for 10 ns;
clk <= '1';
wait for 10 ns;
assert(TIMER = 1)
report "timer wrong" severity error;
end process;
end behavioral;