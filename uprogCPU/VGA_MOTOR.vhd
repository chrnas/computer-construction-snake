--------------------------------------------------------------------------------
-- VGA MOTOR
-- Version 1.1: 2016-02-16, Anders Nilsson
-- Version 1.2: 2023-01-11, Petter Kallstrom. Changelog: Corrected a pipeline mistake.


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity VGA_MOTOR is
	port (
		clk      : in std_logic;
		VR_data  : in std_logic_vector(3 downto 0);
		VR_addr  : out unsigned(12 downto 0);
		rst      : in std_logic;
		vgaRed   : out std_logic_vector(2 downto 0);
		vgaGreen : out std_logic_vector(2 downto 0);
		vgaBlue  : out std_logic_vector(2 downto 1);
		Hsync    : out std_logic;
		Vsync    : out std_logic);
end VGA_MOTOR;


-- architecture
architecture Behavioral of VGA_MOTOR is
	
	signal Xpixel1,Xpixel2: unsigned(9 downto 0); -- Horizontal pixel counter, and its pipelined version
	signal Ypixel1,Ypixel2 : unsigned(9 downto 0); --Vertical pixel counter
	signal ClkDiv : unsigned(1 downto 0);          -- Clock divisor, to generate 25 MHz signal
	signal Clk25  : std_logic;                     -- One pulse width 25 MHz signal
	
	signal CR_addr  : unsigned(9 downto 0);       -- address for CHAR_ROM
	signal CR_data : std_logic_vector(7 downto 0); -- data from CHAR_ROM.
	
	signal blank1, blank2, blank : std_logic; -- blanking signal, with delayed versions
	signal Hsync1, Hsync2 : std_logic;
	signal Vsync1, Vsync2 : std_logic;

	signal tile : unsigned(10 downto 0);
	signal tile_addr : unsigned(10 downto 0);
	signal VR_addr_sig : unsigned(12 downto 0);
	
	-- Character image rom:
	component CHAR_ROM is
		port (
			CR_addr  	: in unsigned (9 downto 0);
      		vgaRed  	: out std_logic_vector(2 downto 0);
      		vgaGreen	: out std_logic_vector(2 downto 0);
      		vgaBlue 	: out std_logic_vector(2 downto 1));
	end component;
	
begin
	
	-- Clock divisor
	-- Divide system clock (100 MHz) by 4
	process(clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				ClkDiv <= (others => '0');
			else
				ClkDiv <= ClkDiv + 1;
			end if;
		end if;
	end process;
	
	-- 25 MHz clock (one system clock pulse width)
	Clk25 <= '1' when (ClkDiv = 3) else '0';
	
	-- ClkDiv:  | 0 | 1 | 2 | 3 | 0 | 1 | 2 | 3 | 0 | 1 | 2 | 3 |
	-- Clk25:   |___|___|___|---|___|___|___|---|___|___|___|---|
	-- Xpixel1: |<     ...     >|<     ...     >|<     ...     >|
	-- Ypixel1: ...            >|<     ...                       
	-- VR_addr: |<     ...     >|<     ...     >|<     ...     >|  f(*pixel)
	-- VR_data: ...>|<     ...     >|<     ...     >|<     ...     f(addr) @ cc
	-- CR_Addr: ...>|<     ...     >|<     ...     >|<     ...     f(data, *pixel)
	-- CR_data:     ...>|<     ...     >|<     ...     >|< ...     f(tAddr) @ cc
	-- RGB:         ...>|<     ...     >|<     ...     >|< ...     f(tPixel)
	-- blank1:  |___|___|___|___|---|---|---|---|___|___|___|___|
	-- blank2:  |___|___|___|___|___|---|---|---|---|___|___|___|
	-- *sync1:  |---|---|---|---|___|___|___|___|---|---|---|---|
	-- *sync2:  |---|---|---|---|---|___|___|___|___|---|---|---|
	-- *sync:   |---|---|---|---|---|---|___|___|___|___|---|---|
	

	-- Horizontal pixel counter
	-- *******************************
	-- *                             *
	-- *  VHDL for:                  *
	-- *  Xpixel1                    *
	-- *                             *
	-- *******************************

process(clk) begin
	if rising_edge(clk) then
		if rst = '1' then
			Xpixel1(9 downto 0) <= "0000000000";
		elsif(Clk25 = '1') then
			if (Xpixel1 = 799) then
				Xpixel1(9 downto 0) <= "0000000000";
			else
				Xpixel1 <= Xpixel1 + 1;
			end if;
		end if;	
    end if;  
end process;


	-- Horizontal sync
	-- *******************************
	-- *                             *
	-- *  VHDL for:                  *
	-- *  Hsync1                     *
	-- *                             *
	-- *******************************

Hsync1 <= '0' when (Xpixel1 > 655 and Xpixel1 < 751) else '1';  

	-- Vertical pixel counter
	-- *******************************
	-- *                             *
	-- *  VHDL for:                  *
	-- *  Ypixel1                    *
	-- *                             *
	-- *******************************
process(clk) begin
	if rising_edge(clk) then
		if rst = '1' then
			Ypixel1(9 downto 0) <= "0000000000";
		elsif(Clk25 = '1') then
			if(Xpixel1 = 799) then
				Ypixel1 <= Ypixel1 + 1;
			elsif(Ypixel1 = 520) then
				Ypixel1(9 downto 0) <= "0000000000";
			end if;
		end if;
	end if;  
end process;


	-- Vertical Sync
	-- *******************************
	-- *                             *
	-- *  VHDL for:                  *
	-- *  Vsync1                     *
	-- *                             *
	-- *******************************

Vsync1 <= '0' when (Ypixel1 > 489 and Ypixel1 < 492) else '1';       

	-- Video blanking signal
	-- *******************************
	-- *                             *
	-- *  VHDL for:                  *
	-- *  Blank1                     *
	-- *                             *
	-- *******************************


--blank1 <= '1' when ((Xpixel1 > 639 and Xpixel1 < 655) or (Xpixel1 > 751 and Xpixel1 < 799) or (Ypixel1 > 479 and Ypixel1 < 489) or (Ypixel1 > 491 and Ypixel1 < 521)) else '0';       
blank1 <= '1' when (Xpixel1 > 639 or Ypixel1 > 479) else '0';
	
	process(clk)
	begin
		if rising_edge(clk) then
			blank2 <= blank1;
			Hsync2 <= Hsync1;
			Vsync2 <= Vsync1;
			Xpixel2 <= Xpixel1;
			Ypixel2 <= Ypixel1;
		end if;
	end process;

	-- VIDEO_RAM:
	-- data <= mem(addr), with one clock cycle delay
	VR_addr_sig <= Xpixel1(9 downto 3) + to_unsigned(80,7)*Ypixel1(8 downto 3);
	VR_addr <= VR_addr_sig;
	
	--Character rom port
	CR_port : CHAR_ROM port map(
		CR_addr => CR_addr,
		vgaRed => vgaRed,
		vgaGreen => vgaGreen,
		vgaBlue => vgaBlue
	);

	--Character rom address:
	CR_addr <= unsigned(VR_data(3 downto 0)) & Ypixel2(2 downto 0) & Xpixel2(2 downto 0);

	--Video ram address composite
	--VR_addr <= to_unsigned(20, 7) * Ypixel1(8 downto 5) + Xpixel1(9 downto 5);


--	U0b : CHAR_ROM2 port map (
--		clk=>clk, 
--		addr=>CR_addr, 
--		data=>CR_data); -- one clock cycle delay.

	process(clk)
	begin
		if rising_edge(clk) then
			Hsync <= Hsync2;
			Vsync <= Vsync2;
			blank <= blank2;
		end if;
	end process;
	
	
	-- VGA generation
	--vgaRed(2)   <= CR_data(7) when blank = '0' else '0';
	--vgaRed(1)   <= CR_data(6) when blank = '0' else '0';
	--vgaRed(0)   <= CR_data(5) when blank = '0' else '0';
	--vgaGreen(2) <= CR_data(4) when blank = '0' else '0';
	--vgaGreen(1) <= CR_data(3) when blank = '0' else '0';
	--vgaGreen(0) <= CR_data(2) when blank = '0' else '0';
	--vgaBlue(2)  <= CR_data(1) when blank = '0' else '0';
	--vgaBlue(1)  <= CR_data(0) when blank = '0' else '0';
	
end Behavioral;

