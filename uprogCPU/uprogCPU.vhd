library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--CPU interface
entity uprogCPU is
  port(clk: in std_logic;
       rst: in std_logic;
       SS : out std_logic;
       MOSI : out std_logic;
       MISO : in std_logic;
       SCLK : out std_logic;
       vgaRed : out std_logic_vector(2 downto 0);
       vgaGreen : out std_logic_vector(2 downto 0);
       vgaBlue : out std_logic_vector(2 downto 1);
       Hsync : out std_logic;
       Vsync : out std_logic;
       --T12: out std_logic; --JA(-1)
       --V12: out std_logic; --JA(0)
       --N10: in std_logic; --JA(1)
       --P11: out std_logic; -- JA(2)
       LED : out std_logic_vector(7 downto 0);
       joystick_code: in unsigned(3 downto 0);
       TIMER_test : out unsigned(25 downto 0);
       PC_test : out unsigned(11 downto 0);
       GR1_test : out unsigned(19 downto 0);
       uPC_test : out unsigned(7 downto 0);
       AR_test : out unsigned(21 downto 0)
       );
       
       --game_timer: out unsigned(31 downto 0);
       --index_grafik: out unsigned(31 downto 0));
  

       
end entity;

architecture func of uprogCPU is

signal HALT : std_logic := '0'; --HALT flag for PC


  -- micro Memory component
  component uMem
    port(uAddr : in unsigned(7 downto 0);
         uData : out unsigned(27 downto 0));
  end component;

  --program Memory component
  component pMem
    port(clk : in std_logic;
         pAddr : in unsigned(11 downto 0);
         pData : out unsigned(20 downto 0);
         pData_in : in unsigned(20 downto 0);
         pm_update : std_logic);
  end component;

  -- K1 memory component
  component K1
    port(operand: in unsigned(4 downto 0);
       K1_adress: out unsigned(7 downto 0));
  end component;

-- K1 memory component
  component K2
    port (modd: in unsigned(1 downto 0);
      K2_adress: out unsigned(7 downto 0));
  end component;

  component jstk_enc 
    port(clk,rst : in std_logic;
      start : in std_logic;
      dir : out unsigned(3 downto 0);
      SS : out std_logic;
      MISO : in std_logic;
      MOSI : out std_logic;
      SCLK : out std_logic;
      set_LEDs : in std_logic_vector(2 downto 1);
      test_output : out std_logic
      );
  end component;

  component graphic_comp
    port(
        clk         :   in    std_logic; -- Signals from the CPU
        rst         :   in    std_logic; -- ---||---
        tile        :   in    unsigned(3 downto 0); --what tile to add "0000" means no tile to add
        index       :   in    unsigned(15 downto 0); --pos to add tile to        
        vgaRed   : out std_logic_vector(2 downto 0);
		    vgaGreen : out std_logic_vector(2 downto 0);
		    vgaBlue  : out std_logic_vector(2 downto 1);
		    Hsync    : out std_logic;
        Vsync    : out std_logic;
        PICT_MEM_out : out std_logic_vector(3 downto 0);
        pict_mem_update : std_logic   
    );
  end component;


  -- micro memory signals
  signal uM : unsigned(27 downto 0); -- micro Memory output
  alias ALU : unsigned(3 downto 0) is uM(27 downto 24);
  alias TB : unsigned(3 downto 0) is uM(23 downto 20);
  alias FB : unsigned(3 downto 0) is uM(19 downto 16);
  alias S : std_logic is uM(15);
  alias P : std_logic is uM(14);
  alias LC : unsigned(1 downto 0) is uM(13 downto 12);
  alias SEQ : unsigned(3 downto 0) is uM(11 downto 8);
  alias uAddr : unsigned(7 downto 0) is uM(7 downto 0);

  alias PCsig : std_logic is uM(14);  -- (0:PC=PC, 1:PC++)
  --alias uPCsig : std_logic is uM(6); -- (0:uPC++, 1:uPC=uAddr)

  signal HR : unsigned(20 downto 0);

  signal M : unsigned(1 downto 0);
  signal ADR : unsigned(11 downto 0);

  
  signal uSPC : unsigned(7 downto 0);
  --signal uADR : unsigned(7 downto 0);
  --signal SEQ : unsigned(3 downto 0); --micro memry setter
  signal K1_reg : unsigned(7 downto 0);
  signal K2_reg : unsigned(7 downto 0);

  -- program memory signals
  signal PM_in : unsigned(20 downto 0); -- Program Memory output
  signal PM_out : unsigned(20 downto 0);
  signal pm_update : std_logic := '0';

  --General registers
  signal GRx : unsigned(1 downto 0);
  signal GR0 : unsigned(20 downto 0);
  signal GR1 : unsigned(20 downto 0);
  signal GR2 : unsigned(20 downto 0);
  signal GR3 : unsigned(20 downto 0);

  signal LC_REG : unsigned(15 downto 0):=x"0000"; -- loop register
  signal OP : unsigned(4 downto 0) := "00000";

  signal TIMER : unsigned(25 downto 0) := "00000000000000000000000000"; -- Timer that ticks every clk cycle and gets reset every 2M.
  signal n_FR : std_logic; -- Goes from 0 to 1 during one clk cycle to indicate a frame change.
  signal random_x : unsigned(9 downto 0) := "0000000000";
  signal random_y : unsigned(8 downto 0) := "000000000";
  signal random_index : unsigned(12 downto 0);

  -- local registers
  signal uPC : unsigned(7 downto 0); -- micro Program Counter
  signal PC : unsigned(11 downto 0); -- Program Counter
  signal IR : unsigned(20 downto 0); -- Instruction Register
  signal ASR : unsigned(11 downto 0); -- Address Register
  

  --ALUstuff
  signal AR : unsigned(21 downto 0);
  signal AR_neg : std_logic := '0'; --negative value?
  signal AR_shift : std_logic := '0';


  -- local combinatorials
  signal DATA_BUS : unsigned(20 downto 0); -- Data Bus

  --PICT_MEM I/O signals
  signal tile : unsigned(3 downto 0) := "0000";
  signal index : unsigned(15 downto 0) := "0000000000000000";
  signal PICT_MEM_out : std_logic_vector(3 downto 0);
  signal pict_mem_update : std_logic;

  signal LED_count : std_logic_vector(7 downto 0) := "00001011";

  -- flags
  signal Z : std_logic;
  signal N : std_logic;
  signal O : std_logic;
  signal C : std_logic;
  signal L : std_logic;

  signal test_output : std_logic;

  --pict_mem signals
  --signal blank : std_logic;
  --signal tile : unsigned(3 downto 0);
  --signal index : unsigned(15 downto 0);
  --signal data2_out : std_logic_vector(3 downto 0);
  --signal addr2 : unsigned(11 downto 0); 

  --char_mem signals
  --signal tile_char : unsigned (3 downto 0);
  --signal tile_addr : unsigned (5 downto 0);
  --signal vgaRed    : std_logic;
  --signal vgaGreen  : std_logic;
  --signal vgaBlue   : std_logic;

  -- User signals:

   -- joystick


   -- User signals:


  signal jstk_start : std_logic;
  signal JstkDir : unsigned(3 downto 0) :="0000";
  signal Joystick_Reg : unsigned(3 downto 0);
  --signal MISO : std_logic;
  signal set_LEDs_jstk : std_logic_vector(2 downto 1);

begin
  --jst clk
  LED <= "00000001" when Joystick_Reg = "0001" else
  "00000010" when Joystick_Reg = "0010" else 
  "00000100" when Joystick_Reg = "0100" else
  "00001000" when Joystick_Reg = "1000" else "00000000";

  process(clk) 
  begin
    if rising_edge(clk) then
      if(n_FR = '1') then
        --LED <= "00000000" when JstkDir = "0001" else "00000011";
        --LED <= "00000011";
        jstk_start <= '1';
      else
        jstk_start <= '0';
        --LED <= "00000000";
      end if;
    end if;
  end process;



  AR_test <= AR;
  uPC_test <= uPC;
  PC_test <= PC;
  TIMER_test <= TIMER;

  --JA0 <= JA(0);
  --JA1 <= JA(1);
  --JA2 <= JA(2);
  --JA3 <= JA(3);
  -- mPC : micro Program Counter
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') or SEQ = "0011" then
        uPC <= (others => '0');
        uSPC <= (others => '0');
        --elsif (uPCsig = '1') then
        --uPC <= uAddr;
      --else
        --uPC <= uPC + 1;
      --end if;
      else
        case SEQ is
          when "0000" => uPC <= uPC + 1;
          when "0001" => uPC <= K1_reg;
          when "0010" => uPC <= K2_reg;
          when "0100" => if Z = '0' then uPC <= uAddr; else uPC <= uPc +1; end if;
          when "0101" => uPC <= uAddr;
          when "0110" => uSPC <= uPC + 1;
                          uPC <= uAddr;                          
          when "0111" => uPC <= uSPC;
          when "1000" => if (Z = '1') then uPC <= uAddr; else uPC <= uPc +1; end if;
          when "1001" => if (N = '1') then uPC <= uAddr; else uPC <= uPc +1; end if;
          when "1010" => if (C = '1') then uPC <= uAddr; else uPC <= uPc +1; end if;
          when "1011" => if (O = '1') then uPC <= uAddr; else uPC <= uPc +1; end if;
          when "1100" => if (L = '1') then uPC <= uAddr; else uPC <= uPc +1; end if;
          when "1101" => if (C = '0') then uPC <= uAddr; else uPC <= uPc +1; end if;
          when "1110" => if (O = '0') then uPC <= uAddr; else uPC <= uPc +1; end if;
          when "1111" => uPC <= "00000000";
                        HALT <= '1';
          when others => null;
        end case;
      end if;
    end if;
  end process;
   
  -- PC : Program Counter
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        PC <= (others => '0');
      elsif n_FR = '1' then
        PC <= "000000000001";
      elsif (FB = "0011") then
        PC <= DATA_BUS(11 downto 0);
      elsif (PCsig = '1') then
        PC <= PC + 1;
      end if;
    end if;
  end process;

  --PM : Program Memory
  process(clk)
  begin
    if rising_edge(clk) then
      if FB = "0010" then
        PM_in <= DATA_BUS;
        pm_update <= '1';
      else
        pm_update <= '0';
      end if;
    end if;
  end process;

  --Pict_mem tile Input
  process(clk)
  begin
    if rising_edge(clk) then
      if FB = "1001" then
        pict_mem_update <= '1';
        --LED_count <= LED_count(6 downto 0) & LED_count(7);
        tile <= DATA_BUS(3 downto 0);
      else
        --LED <= LED_count;
        pict_mem_update <= '0';
      end if;
    end if;
  end process;


  -- IR : Instruction Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        IR <= (others => '0');
      elsif (FB = "0001") then
        IR <= DATA_BUS(20 downto 0);
      end if;
    end if;
  end process;
	
  -- ASR : Address Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        ASR <= (others => '0');
      elsif (FB = "1010") then
        ASR <= DATA_BUS(11 downto 0);
      else
        ASR <= ADR;
      end if;
    end if;
  end process;

  -- Index : PICT_MEM Address Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        index <= (others => '0');
      elsif (FB = "1111") then
        index <= DATA_BUS(15 downto 0);
      end if;
    end if;
  end process;
  

  --ALU : Accumulator
  process(clk)
  begin
    if rising_edge(clk) then
      AR_neg <= AR(19);
      if (rst = '1') then
        AR <= (others => '0');
        --HR <= (others => '0');
      else
        case ALU is
          when "0001" =>  AR <= ('0' & DATA_BUS); -- vi kanske kommer att behöva foga ihop en noll i varje bus beräkning kolla github repo

          when "0010" =>  AR <= '1' & ("111111111111111111111" xor DATA_BUS); --ett komplement

          when "0011" =>  AR <= (others => '0');

          when "0100" =>  AR <= AR + ('0' & DATA_BUS); --påverkar flaggor Z,N,O,C 

          when "0101" =>  AR <= AR - ('0' & DATA_BUS); --påverkar flaggor Z,N,O,C

          when "0110" =>  AR <= AR and ('0' & DATA_BUS);

          when "0111" =>  AR(20 downto 0) <= AR(20 downto 0) or DATA_BUS; --bitwise or

          when "1000" =>  AR <= AR + ('0' & DATA_BUS); -- påverkar ej flaggor, behövs nog ej

          when "1001" =>  AR <= AR(20 downto 0) & '0';  --logical
                          AR_shift <= AR(21); 

          when "1010" =>  AR <= AR(20 downto 0) & '0'; --logical
                          AR_shift <= AR(21); 
                          --HR <= AR(19 downto 0);
                          
          when "1011" =>  AR(20 downto 0) <= AR(20) & AR(20 downto 1); -- skifta AR ett steg höger aritmetiskt

          when "1100" =>  AR(20 downto 0) <= AR(20) & AR(20 downto 1); --kanske inte behövs kolla mia manual
                          --HR <= AR(19 downto 0);

          when "1101" =>  AR_shift <= AR(0);
                          AR(20 downto 0) <= '0' & AR(20 downto 1);  --logical
                          
          when "1110" =>  AR_shift <= AR(0);
                          AR(19 downto 0) <= AR(20 downto 1);
                          AR(20) <= AR_shift;

          when "1111" =>  AR_shift <= AR(20);
                          AR(20 downto 1) <= AR(19 downto 0);
                          AR(0) <= AR_shift;

          when others => null;
        end case;
      end if;
    end if; 

  end process;

--ALU flags
--Status Reg.

  Z <= '1' when (AR = 0) else '0';
  N <= '1' when (AR(21) = '1') else '0';
  O <= '1' when ((not (AR(20) = AR_neg)) and (AR(20) = DATA_BUS(20))) else '0';
  C <= AR(21); 
  L <= '1' when (LC_REG = 0) else '0';


 
 --LC, Loop Counter
  process(clk)
  begin
  if rising_edge(clk) then
    if(rst = '1') then
      LC_REG <= x"0000";
    else
      case LC is

        when "00" => null;

        when "01" => LC_REG <= LC_REG - 1;

        when "10" => LC_REG <= LC_REG(15 downto 7) & DATA_BUS(6 downto 0);

        when "11" => LC_REG <= LC_REG(15 downto 8) & uAddr;

        when others => null;

      end case;
    end if;
  end if;
  end process;

 -- micro memory component connection
  U0 : uMem port map(uAddr=>uPC, uData=>uM);

  -- K2 memory component connection
  U1 : K2 port map (modd => M, K2_adress => K2_reg);
 

   -- K1 memory component connection
  U2 : K1 port map(operand => OP, K1_adress => K1_reg);

  U3 : pMem port map(clk=>clk, pAddr=>ASR, pData=>PM_out, pData_in=>PM_in, pm_update=>pm_update);

  jstk_enc_instance : jstk_enc port map(
    SS => SS,
    MOSI => MOSI,
    MISO => MISO,
    SCLK => SCLK,
    dir => JstkDir,
    clk => clk, 
    rst => rst, 
    start => jstk_start,
    set_LEDs => set_LEDs_jstk,
    test_output => test_output
    );

  grapic_inst : graphic_comp port map(
    clk => clk,
    rst => rst,
    tile => tile,    
    index => index,  --aka P_ASR
    vgaRed => vgaRed,
    vgaGreen => vgaGreen,
    vgaBlue => vgaBlue,
    Hsync => Hsync,
    Vsync => Vsync,
    PICT_MEM_out => PICT_MEM_out,
    pict_mem_update => pict_mem_update
  );
 
  --Joystick_Reg
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        Joystick_Reg <= (others => '0');
      else
        Joystick_Reg <= JstkDir;
      end if;
    end if;
  end process;

 
    -- HR - Hjälp register
  process(clk)
  begin
  if rising_edge(clk) then
    if (rst = '1') then
      HR <= "000000000000000000000";
    elsif (FB = "0110") then
      HR <= DATA_BUS;
    end if;
  end if;
  end process;

    -- GRX Mux
  process(clk)
  begin
  if rising_edge(clk) then
    if rst = '1' then
      GR0 <= "000000000000000000000";
      GR1 <= "000000000000000000000";
      GR2 <= "000000000000000000000";
      GR3 <= "000000000000000000000";
    elsif (FB = "0111") then
      case GRx is
        when "00" => GR0 <= DATA_BUS;
        when "01" => GR1 <= DATA_BUS;
        when "10" => GR2 <= DATA_BUS;
        when "11" => GR3 <= DATA_BUS;
        when others => null;
      end case;
    end if;
  end if;
  end process;


    -- (Timer)
  process(clk)
  begin
  if rising_edge(clk) then
    if rst = '1' then
    TIMER <= "00000000000000000000000000";
    else
    if TIMER < "00100110001001011010000000" then
      TIMER <= TIMER + 1;
      n_FR <= '0';
    else
      TIMER <= "00000000000000000000000000";
      n_FR <= '1';
    end if;

    end if;
  end if;
  end process;


    

    -- (Random)
  process(clk)
  begin
  if rising_edge(clk) then
    if rst = '1' then
    random_x <= "0000000000";
    random_y <= "000000000";
    else
      if random_x < 640 then
        random_x <= random_x + 1;
      else
        random_x <= "0000000000";
      end if;
      if random_y < 480 then
        random_y <= random_y + 1;
      else
        random_y <= "000000000";
      end if;
    end if;
  end if;
  end process;

  random_index <= random_x(9 downto 3) + to_unsigned(80,7)*random_y(8 downto 3);


	
  -- micro memory component connection
  --Förslag gör alla dessa till 27 bitar + data buss eventuellt 32 bitar


  DATA_BUS <= 
    DATA_BUS when (TB = "0000") else
    IR when (TB = "0001") else
    PM_out when (TB = "0010") else
    "000000000" & PC when (TB = "0011") else
    AR(20 downto 0) when (TB = "0100") else
    uM(20 downto 0) when (TB = "0101") else
    HR when (TB = "0110") else
    "00000000000000000" & Joystick_Reg when (TB = "1000") else
    "00000000" & random_index when (TB = "1110") else
    GR0 when ((TB = "0111") and GRx = "00") else
    GR1 when ((TB = "0111") and GRx = "01") else
    GR2 when ((TB = "0111") and GRx = "10") else
    GR3 when ((TB = "0111") and GRx = "11") else
    "00000000000000000" & unsigned(PICT_MEM_out) when (TB = "1001") else
    "000000000000000000000";


   --micro memory signal assignements
  --ALU <= uM(27 downto 24);
  --TB <= uM(23 downto 20);
  --FB <= uM(19 downto 16);
  --S <= uM(15)
  --P <= uM(14);
  --LC <= uM(13 downto 12);
  --SEQ <= uM(11 downto 8);
  --uADR <= uM(7 downto 0);


  OP <= IR(20 downto 16);
  GRx <= IR(15 downto 14);
  M <= IR(13 downto 12);
  ADR <= IR(11 downto 0);



end func;
