library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity jstk_enc is
	port(
		clk, rst : in std_logic;
		-- User signals:
        --do_start : out std_logic;
        start : in std_logic;
		--set_LEDs : out std_logic_vector(2 downto 1);
		--output_valid : in std_logic;
		--X : in unsigned(9 downto 0);
		--Y : in unsigned(9 downto 0);

		-- JSTK signals:
       
        set_LEDs : in std_logic_vector(2 downto 1);
        dir : out unsigned(3 downto 0);

        
        SS : out std_logic; --originally out port
        MISO : in std_logic; 
        MOSI : out std_logic; --originally out port
        SCLK : out std_logic;
        test_output : out std_logic
    ); --originally out port
        
end jstk_enc;

architecture Behavioral of jstk_enc is

    component jstk 
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
        SS : out std_logic;
        MISO : in std_logic;
        MOSI : out std_logic;
        SCLK : out std_logic
        );

  end component;
  


    signal UP, DOWN, LEFT, RIGHT : std_logic := '0';
    signal start_1, start_2 : std_logic;
    signal X, Y : unsigned(9 downto 0);
    signal do_start : std_logic;
    signal output_valid : std_logic;
    signal test : std_logic;
    signal buttons : std_logic_vector(2 downto 0);

    --signal clk_enc : std_logic;
    --signal rst_enc : std_logic;
    --signal do_start_enc : std_logic;
    --signal set_LEDs_enc : std_logic_vector(2 downto 1);
    --signal output_valid_enc : std_logic;
    --signal X_enc : unsigned(9 downto 0);
    --signal Y_enc : unsigned(9 downto 0);
    --signal buttons_enc : std_logic_vector(2 downto 0);
    --signal SS_enc : std_logic;
    --signal MISO_enc : std_logic;
    --signal MOSI_enc : std_logic;
    --signal SCLK_enc : std_logic;

begin
    jstk_instance : jstk port map(
        X => X,
        Y => Y,
        output_valid => output_valid,
        do_start => do_start,
        clk => clk,
        rst => rst,
        MISO => MISO,
        MOSI => MOSI,
        SCLK => SCLK,
        SS => SS,
        set_LEDs => set_LEDs,
        buttons => buttons);

    process(clk) begin
        if rising_edge(clk) then
            if rst='1' then
                start_1 <= '1';
                start_2 <= '0';
            else
                start_1 <= start;
                start_2 <= not start_1;
            end if;
        end if;
    end process;
        
    do_start <= (not start_1) and (not start_2);

    process(clk) begin
        if rising_edge(clk) then
            if(rst = '1') then
                UP <= '0';
                DOWN <= '0';
                LEFT <= '0';
                RIGHT <= '0';
            elsif(output_valid = '1') then
                if (Y > 650) then UP <= '1'; else UP <= '0'; end if;
                if (Y < 350) then DOWN <= '1'; else DOWN <= '0'; end if;
                if(X < 350) then LEFT <= '1';  else LEFT <= '0'; end if;
                if(X > 650) then RIGHT <= '1'; else RIGHT <='0'; end if;
            end if;
        end if;
    end process;
    dir <= UP & DOWN & LEFT & RIGHT;

    test <= '1';
    
    --UJ1 : jstk port map(clk => clk_enc, rst => rst_enc,do_start => do_start_enc,set_LEDs => set_LEDs_enc, X => X_enc, Y => Y_enc, output_valid => output_valid_enc, buttons => buttons_enc, SS => SS_enc,MISO => MISO_enc, MOSI => MOSI_enc, SCLK => SCLK_enc);

end Behavioral;


