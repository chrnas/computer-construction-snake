-- Module for using the PMOD joystick.
-- Author: Petter Kallstrom <petter.kallstrom@liu.se>
-- Date: 2021-04-30
-- 
-- Instantiation:
--  * Instantiate the module with clk_over_SCLK = f_clk / f_SCLK
--    (f_SCLK = 50 kHz seems reasonable. Default is 100 MHz / 50 kHz = 2000)
-- Runtime usage:
--  1. Provide two bits LED information on the set_LEDs input.
--  2. Give a one-pulser to the do_start
--     => The output_valid will go low the next clock cycle.
--  3a. Wait until output_valid = 1.
--  3b. Read the X, Y, buttons values
--  4. Wait a time corresponding to at least half a SCLK period before starting again.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity jstk is
	generic (clk_over_SCLK : integer range 0 to 32768 := 2000);
	port(
		clk, rst : in std_logic;
		-- User signals:
		do_start : in std_logic;
		set_LEDs : in std_logic_vector(2 downto 1);
		output_valid : out std_logic;
		X : out unsigned(9 downto 0);
		Y : out unsigned(9 downto 0);
		buttons : out std_logic_vector(2 downto 0); -- buttons(0) = Joystick
		-- JSTK signals:
		SS : out std_logic; --originally out port
		MISO : in std_logic;
		MOSI : out std_logic; --originally out port
		SCLK : out std_logic); --originally out port
end entity;

architecture beh of jstk is
	signal clk_div : unsigned(15 downto 0) := to_unsigned(clk_over_SCLK-2, 16); -- counts (clk_over_SCLK/2-2 .. -1), and restarts twice per SCLK.
	signal tick : std_logic; -- This is MSB of the clk_div
	-- SPI mode 0, MSB first. Read 5 bytes (40 bits). One tick / 4char below:
	-- do_start:___-____________________________________________________
	-- SS:      ----____________________//________________________------
	-- SCLK:    ________----____----____//----____----____----__________
	-- M*S*:    ----< d39  >< d38  ><d37//d02>< d01  >< d00  >----------
	-- tick:    _______-___-___-___-___-//___-___-___-___-___-___-______
	-- bit_cnt: 256><80><79><78><77><76>//< 5>< 4>< 3>< 2>< 1>< 0><511    // (start at 511 next time)
	-- SR/sample:  L   s   <   s   <   s     <   s   <   s   <  (s)       // 'L'=Load, '<'=Shift, 's'=sample
	signal bit_cnt : unsigned(8 downto 0) := (8=>'1', others=>'0');
	signal SR : std_logic_vector(39 downto 0);
	signal sampled_MISO : std_logic;
	-- rst:       ---_____________________________________________________________
	-- do_start:  _______-___________________________-____________________________
	-- bit_cnt:    256   >< 80 ... 0>< 511           >< 80 ... 0 >< 511
	-- bit_cnt(8): -------___________-----------------____________---------------- SS = "working", active low
	-- bit_cnt(7): __________________-----------------____________---------------- result valid, active high.
begin
	SS <= bit_cnt(8);
	SCLK <= bit_cnt(0) when bit_cnt(8)='0' else '0';
	MOSI <= SR(39);
	output_valid <= bit_cnt(7); -- this is reset to zero, and set to 1 after countdown...

	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' or bit_cnt(7) = '1' or tick = '1' then
				clk_div <= to_unsigned(clk_over_SCLK/2-2, clk_div'length);
			else
				clk_div <= clk_div - 1;
			end if;
		end if;
	end process;
	tick <= clk_div(clk_div'left);
	
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				bit_cnt <= (8=>'1', others=>'0');
			elsif do_start = '1' and bit_cnt(8) = '1' then
				bit_cnt <= to_unsigned(80, 9);
			elsif bit_cnt(8) = '0' and tick = '1' then
				bit_cnt <= bit_cnt - 1;
			end if;
		end if;
	end process;
	
	process(clk) begin
		if rising_edge(clk) then
			if do_start = '1' and bit_cnt(8) = '1' then
				SR <= (others=>'0'); -- default
				SR(39) <= '1';
				SR(33 downto 32) <= set_LEDs;
			elsif tick = '1' and bit_cnt(0) = '1' then -- falling edge of SCLK: shift
				SR <= SR(38 downto 0) & sampled_MISO;
			end if;
			
			if tick = '1' and bit_cnt(0) = '0' then -- rising edge of SCLK: Sample data
				sampled_MISO <= MISO;
			end if;
		end if;
	end process;
	
	-- SR byte order: [X_low, X_high, Y_low, Y_high, buttons], where the _high uses the two LSB's.
	X <= unsigned(SR(25 downto 24) & SR(39 downto 32));
	Y <= unsigned(SR( 9 downto  8) & SR(23 downto 16));
	buttons <= SR(2 downto 0);
end architecture;

