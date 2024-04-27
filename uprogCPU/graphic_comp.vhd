library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- This component serves as the link between the picture memory and
-- the VGA_motor. Signals arrive here from the CPU and are distributed to 
-- the right component. Signals between the two components are also handled 
-- here.

-- Graphics entity
entity graphic_comp is
    port (
        clk         :   in    std_logic; -- Signals from the CPU
        rst         :   in    std_logic; -- ---||---
        tile        :   in    unsigned(3 downto 0); 
        index       :   in    unsigned(15 downto 0);
        vgaRed   : out std_logic_vector(2 downto 0);
		vgaGreen : out std_logic_vector(2 downto 0);
		vgaBlue  : out std_logic_vector(2 downto 1);
		Hsync    : out std_logic;
        Vsync    : out std_logic;
        PICT_MEM_out : out std_logic_vector(3 downto 0);
        pict_mem_update : in std_logic
        --Hsync       :   out   std_logic;
        --Vsync       :   out   std_logic;
        --vgaRed      : out std_logic_vector(2 downto 0);
        );

		--vgaGreen    : out std_logic_vector(2 downto 0);
        --vgaBlue     : out std_logic_vector(2 downto 1));
    end graphic_comp;

architecture Behavioral of graphic_comp is

    component PICT_MEM
    port ( 
        clk			: in std_logic;                         -- system clock
	    blank       : in std_logic;
        index       : in unsigned(15 downto 0);
        tile        : in unsigned(3 downto 0); 
        addr2		: in unsigned(12 downto 0);             -- address
        data_out2   : out std_logic_vector(3 downto 0);
        pict_mem_update : in std_logic
        );	-- data

    end component;

    component VGA_MOTOR
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
	   
  end component;

  -- signals between PICT_mem and VGA_motor

  signal    addr2_sig        :   unsigned(12 downto 0);
  signal    data_out2_sig    :   std_logic_vector(3 downto 0);
  signal    blank_sig        :   std_logic;

  --signal vgaRed : std_logic_vector(2 downto 0);
  --signal vgaGreen : std_logic_vector(2 downto 0);
  --signal vgaBlue : std_logic_vector(2 downto 1);
  --signal Hsync : std_logic;
  --signal Vsync : std_logic;

  begin

    PICT_MEM_out <= data_out2_sig;


    U1 : PICT_MEM port map(
        clk => clk,
        data_out2 => data_out2_sig,
        addr2 => addr2_sig,
        blank => blank_sig,
        tile => tile,
        index => index,
        pict_mem_update => pict_mem_update);

    U2 : VGA_MOTOR port map(
        clk => clk,
        rst => rst,
        VR_addr => addr2_sig, 
        VR_data => data_out2_sig, 
        vgaRed => vgaRed, 
        vgaGreen => vgaGreen, 
        vgaBlue => vgaBlue, 
        Hsync => Hsync, 
        Vsync => Vsync);



  end Behavioral;
  

