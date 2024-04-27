library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- pMem interface
entity pMem is
  port(
    clk : std_logic;
    pAddr : in unsigned(11 downto 0);
    pData : out unsigned(20 downto 0);
    pData_in : in unsigned(20 downto 0);
    pm_update : std_logic);
end pMem;

architecture Behavioral of pMem is

-- program Memory
type p_mem_t is array (0 to 200) of unsigned(20 downto 0);
constant p_mem_c : p_mem_t :=
  (
    --Wait loop
    b"10001_00_00_000000101010", --00 jmp to 00
    --Find direction to turn
    b"01101_00_00_000000000000", --01 ldj jstk to AR
    b"01111_00_00_000000101101", --02 CMPA AR to "0000" 
    b"01011_00_00_000000110001", --03 BEQ moveRight
    b"01101_00_00_000000000000", --04 ldj jstk to AR
    b"01111_00_00_000000101110", --05 CMPA AR to "0010" 
    b"01011_00_00_000000110010", --06 BEQ moveLeft
    b"01101_00_00_000000000000", --07 ldj jstk to AR
    b"01111_00_00_000000101111", --08 CMPA AR to "0100" 
    b"01011_00_00_000000110011", --09 BEQ moveDown
    b"01101_00_00_000000000000", --0A ldj jstk to AR
    b"01111_00_00_000000110000", --0B CMPA AR to "1000" 
    b"01011_00_00_000000110100", --0C BEQ moveUp

    b"10001_00_00_000000101010", --0D jmp to 00
  
    --Move snake up
    b"00001_01_00_000000110101", --0E load gr1, snakeHeadPos
    b"00101_01_00_000000101100", --0F sub gr1, constEighty
    b"00010_01_00_000000110101", --10 store gr1, snakeHeadPos
    b"00001_10_00_000000101010", --11 load gr2, 0 (ska va inverterad)
    b"10100_00_00_000000110101", --12 ldhr hr:=snakeHeadPos
    b"10101_10_00_000000000000", --13 vhr_store GR2
    b"10001_00_00_000000101010", --14 jmp 00

    --Move snake down
    b"00001_01_00_000000110101", --15 load gr1, snakeHeadPos
    b"00011_01_00_000000101100", --16 add gr1, constEighty
    b"00010_01_00_000000110101", --17 store gr1, snakeHeadPos
    b"00001_10_00_000000101010", --18 load gr2, 0 (ska va inverterad)
    b"10100_00_00_000000110101", --19 ldhr hr:=snakeHeadPos
    b"10101_10_00_000000000000", --1A vhr_store GR2
    b"10001_00_00_000000101010", --1B jmp 00

    --Move snake left
    b"00001_01_00_000000110101", --1C load gr1, snakeHeadPos
    b"00101_01_00_000000101011", --1D sub gr1, constOne
    b"00010_01_00_000000110101", --1E store gr1, snakeHeadPos
    b"00001_10_00_000000101010", --1F load gr2, 0 (ska va inverterad)
    b"10100_00_00_000000110101", --20 ldhr hr:=snakeHeadPos
    b"10101_10_00_000000000000", --21 vhr_store GR2
    b"10001_00_00_000000101010", --22 jmp 00

    --Move snake right
    b"00001_01_00_000000110101", --23 load gr1, snakeHeadPos
    b"00011_01_00_000000101011", --24 add gr1, constOne
    b"00010_01_00_000000110101", --25 store gr1, snakeHeadPos
    b"00001_10_00_000000101010", --26 load gr2, 0 (ska va inverterad)
    b"10100_00_00_000000110101", --27 ldhr hr:=snakeHeadPos
    b"10101_10_00_000000000000", --28 vhr_store GR2
    b"10001_00_00_000000101010", --29 jmp 00
    
    --Constants
    b"00000_00_00_000000000000", --2A constZero
    b"00000_00_00_000000000001", --2B constOne
    b"00000_00_00_000001010000", --2C constEighty

    b"00000_00_00_000000000001", --2D joystickRigth
    b"00000_00_00_000000000010", --2E joystickLeft
    b"00000_00_00_000000000100", --2F joystickDown
    b"00000_00_00_000000001000", --30 joystickUp

    b"00000_00_00_000000100011", --31 moveSnakeRight
    b"00000_00_00_000000011100", --32 moveSnakeLeft
    b"00000_00_00_000000010101", --33 moveSnakeDown
    b"00000_00_00_000000001110", --34 moveSnakeUp
    
    --Variables
    b"00000_00_00_000110010111", --35 snakeHeadPos
    b"00000_00_00_000000000101", --36 snakeLength
    b"00000_00_00_000000000000", --37 applePos

    others => (others => '0')
   );

  signal p_mem : p_mem_t := p_mem_c;


begin  -- pMem
  pData <= p_mem(to_integer(pAddr));
  process(clk)
  begin
    if rising_edge(clk) then
      if pm_update = '1' then
        p_mem(to_integer(pAddr)) <= unsigned(pData_in);
      end if;
    end if;
  end process;

end Behavioral;

-- --Wait loop
-- b"10001_00_00_000000000000", --00 jmp to 00
-- --Find direction to turn
-- b"01101_00_00_000000000000", --01 ldj jstk to AR
-- b"01111_00_00_000001001111", --02 CMPA AR to "0001" 
-- b"01011_00_00_000001010011", --03 BEQ moveRight
-- b"01101_00_00_000000000000", --04 ldj jstk to AR
-- b"01111_00_00_000001010000", --05 CMPA AR to "0010" 
-- b"01011_00_00_000001010100", --06 BEQ moveLeft
-- b"01101_00_00_000000000000", --07 ldj jstk to AR
-- b"01111_00_00_000001010001", --08 CMPA AR to "0100" 
-- b"01011_00_00_000001010101", --09 BEQ moveDown
-- b"01101_00_00_000000000000", --0A ldj jstk to AR
-- b"01111_00_00_000001010010", --0B CMPA AR to "1000" 
-- b"01011_00_00_000001010110", --0C BEQ moveUp
-- --Check apple
-- b"00001_11_00_000001010111", --0D load gr3, snake_head_pos
-- b"01110_11_00_000001011001", --0E cmp gr3, apple_pos
-- b"01011_00_00_000000101000", --0F beq to appleFound
-- --load snake length
-- b"10000_00_00_000001011000", --10 STRLC snake_length -> LC 
-- b"10100_00_00_000001010111", --11 ldhr hr, snakeHeadPos
-- --Remove tail loop
-- b"10110_00_00_000000000000", --12 vhr_load pictmem(hr), gr0
-- b"11001_00_00_000000000000", --13 LC--
-- b"11010_00_00_", --14 LC = 0  A bit lost
-- b"01011_00_00_tailRemoval", --15 beq tailRemoval
-- b"01110_00_00_moveRightTile", --16 cmp gr0 to moveRightTile
-- b"01011_00_00_movePointerRight", --17 beq movePointerRight
-- b"01110_00_00_moveLeftTile", --18 cmp gr0 to moveLeftTile
-- b"01011_00_00_movePointerLeft", --19 beq movePointerLeft  
-- b"01110_00_00_moveDownTile", --1A cmp gr0 to moveDownTile
-- b"01011_00_00_movePointerDown", --1B beq movePointerDown
-- b"01110_00_00_moveUpTile", --1C cmp gr0 to moveUpTile
-- b"01011_00_00_movePointerUp", --1D beq movePointerUp
-- --movePoinerRight
-- b"10111_00_00_constOne", --1E AddHR HR, 1
-- b"10001_00_00_000000001111" --1F jmp Remove tail loop
-- --movePointerLeft
-- b"11000_00_00_constOne", --20 SUBHR HR, 1
-- b"10001_00_00_000000001111" --21 jmp Remove tail loop
-- --movePointerDown
-- b"10111_00_00_constEighty", --22 AddHR HR, 80
-- b"10001_00_00_000000001111" --23 jmp Remove tail loop
-- --movePointerUp    
-- b"10111_00_00_constEighty", --24 AddHR HR, 80
-- b"10001_00_00_000000001111" --25 jmp Remove tail loop
-- --Tail removal
-- b"00001_10_00_backgroundPic", --26 load gr2, snake_lenght
-- b"10101_10_00_000000000000", --27 vhr_store gr2, hr
-- --Apple found
-- b"00001_11_00_snakeLength", --28 load gr3, snakeLength
-- b"00011_11_00_constOne", --29 add gr3, constOne
-- b"00010_11_00_snakeLenght", --2A store gr3, snakeLegth
-- b"00001_11_00_applePic", --2B load gr3, applePic
-- b"10010_00_00_000000000000", --2C LDRAN
-- b"10110_11_00_000000000000", --2D vhr_store gr3
-- b"10001_00_00_000000000000", --2E jmp Wait loop
-- --Move snake up
-- b"00001_01_00_snakeHeadPos", --2F load gr1, snakeHeadPos
-- b"00101_01_00_constEighty", --30 sub gr1, constEighty
-- b"00010_01_00_snakeHeadPos", --31 store gr1, snakeHeadPos
-- b"00001_10_00_moveDownTile", --32 load gr2, moveDownTile (ska va inverterad)
-- b"10100_00_00_snakeHeadPos", --33 ldhr hr:=snakeHeadPos
-- b"10101_10_00_000000000000", --34 vhr_store GR2
-- b"10001_00_00_000000001010", --35 jmp Check apple
-- --Move snake down
-- b"00001_01_00_snakeHeadPos", --36 load gr1, snakeHeadPos
-- b"00011_01_00_constEighty", --37 add gr1, constEighty
-- b"00010_01_00_snakeHeadPos", --38 store gr1, snakeHeadPos
-- b"00001_10_00_moveUpTile", --39 load gr2, moveUpTile (ska va inverterad)
-- b"10100_00_00_snakeHeadPos", --3A ldhr hr:=snakeHeadPos
-- b"10101_10_00_000000000000", --3B vhr_store GR2
-- b"10001_00_00_000000001010", --3C jmp Check apple
-- --Move snake left
-- b"00001_01_00_snakeHeadPos", --3D load gr1, snakeHeadPos
-- b"00101_01_00_constOne", --3F sub gr1, constOne
-- b"00010_01_00_snakeHeadPos", --40 store gr1, snakeHeadPos
-- b"00001_10_00_moveRightTile", --41 load gr2, moveRightTile (ska va inverterad)
-- b"10100_00_00_snakeHeadPos", --42 ldhr hr:=snakeHeadPos
-- b"10101_10_00_000000000000", --43 vhr_store GR2
-- b"10001_00_00_000000001010", --44 jmp Check apple
-- --Move snake right
-- b"00001_01_00_snakeHeadPos", --45 load gr1, snakeHeadPos
-- b"00011_01_00_constOne", --46 add gr1, constOne
-- b"00010_01_00_snakeHeadPos", --47 store gr1, snakeHeadPos
-- b"00001_10_00_moveLeftTile", --48 load gr2, moveLeftTile (ska va inverterad)
-- b"10100_00_00_snakeHeadPos", --49 ldhr hr:=snakeHeadPos
-- b"10101_10_00_000000000000", --4A vhr_store GR2
-- b"10001_00_00_000000001010", --4B jmp Check apple
-- --Constants
-- b"00000_00_00_000000000000", --4C constZero
-- b"00000_00_00_000000000001", --4D constOne
-- b"00000_00_00_000001010000", --4E constEighty
-- b"00000_00_00_000000000001", --4F moveRightTile
-- b"00000_00_00_000000000010", --50 moveLeftTile
-- b"00000_00_00_000000000100", --51 moveDownTile
-- b"00000_00_00_000000001000", --52 moveUpTile
-- b"00000_00_00_000001000101", --53 moveSnakeRight
-- b"00000_00_00_000000111101", --54 moveSnakeLeft
-- b"00000_00_00_000000110110", --55 moveSnakeDown
-- b"00000_00_00_000000101111", --56 moveSnakeUp
-- --Variables
-- b"00000_00_00_position", --57 snakeHeadPos
-- b"00000_00_00_000000000101", --58 snakeLength
-- b"00000_00_00_000000000000", --59 applePos



-- just in worst case
    --   --Wait loop  
    --   b"10001_00_00_000000001011", --00 jmp to 00
    --   b"01101_00_00_000000000000", --01 ldj jskt to AR
    --   b"01111_00_00_000000001011", --02 cmpa to constZero
    --   b"01011_00_00_000000001011",-- 03 beq jmp to 00
    --   --Paint on screen
    --   b"00001_01_00_000000001110", --04 load gr1, snakeHeadPos
    --   b"00011_01_00_000000001100", --05 add gr1, constOne
    --   b"00010_01_00_000000001110", --06 store gr1, snakeHeadPos
    --   b"00001_10_00_000000001101", --07 load gr2, moveLeftTile (ska va inverterad)
    --   b"10100_00_00_000000001110", --08 ldhr hr:=snakeHeadPos
    --   b"10101_10_00_000000000000", --09 vhr_store GR2
    --   b"10001_00_00_000000001011", --0A jmp to 00
    --   --Constants
    --   b"00000_00_00_000000000000", --0B constZero
    --   b"00000_00_00_000000000001", --0C constOne
    --   b"00000_00_00_000000000011", --0D Snake Up
    --   --Variables
    --   b"00000_00_00_000110010111", --0E snakeHeadPos
    --   b"00000_00_00_000000000101", --0F snakeLength









  -- simpler version where tail isnt removed
  -- --Wait loop
  --   b"10001_00_00_000000101010", --00 jmp to 00

  --   --Find direction to turn
  --   b"01101_00_00_000000000000", --01 ldj jstk to AR
  --   b"01111_00_00_000000101101", --02 CMPA AR to "0001" 
  --   b"01011_00_00_000000110001", --03 BEQ moveRight
  --   b"01101_00_00_000000000000", --04 ldj jstk to AR
  --   b"01111_00_00_000000101110", --05 CMPA AR to "0010" 
  --   b"01011_00_00_000000110010", --06 BEQ moveLeft
  --   b"01101_00_00_000000000000", --07 ldj jstk to AR
  --   b"01111_00_00_000000101111", --08 CMPA AR to "0100" 
  --   b"01011_00_00_000000110011", --09 BEQ moveDown
  --   b"01101_00_00_000000000000", --0A ldj jstk to AR
  --   b"01111_00_00_000000110000", --0B CMPA AR to "1000" 
  --   b"01011_00_00_000000110100", --0C BEQ moveUp

  --   b"10001_00_00_000000101010", --0D jmp to 00
  
  --   --Move snake up
  --   b"00001_01_00_000000110101", --0E load gr1, snakeHeadPos
  --   b"00101_01_00_000000101100", --0F sub gr1, constEighty
  --   b"00010_01_00_000000110101", --10 store gr1, snakeHeadPos
  --   b"00001_10_00_000000101010", --11 load gr2, 0 (ska va inverterad)
  --   b"10100_00_00_000000110101", --12 ldhr hr:=snakeHeadPos
  --   b"10101_10_00_000000000000", --13 vhr_store GR2
  --   b"10001_00_00_000000101010", --14 jmp 00

  --   --Move snake down
  --   b"00001_01_00_000000110101", --15 load gr1, snakeHeadPos
  --   b"00011_01_00_000000101100", --16 add gr1, constEighty
  --   b"00010_01_00_000000110101", --17 store gr1, snakeHeadPos
  --   b"00001_10_00_000000101010", --18 load gr2, 0 (ska va inverterad)
  --   b"10100_00_00_000000110101", --19 ldhr hr:=snakeHeadPos
  --   b"10101_10_00_000000000000", --1A vhr_store GR2
  --   b"10001_00_00_000000101010", --1B jmp 00

  --   --Move snake left
  --   b"00001_01_00_000000110101", --1C load gr1, snakeHeadPos
  --   b"00101_01_00_000000101011", --1D sub gr1, constOne
  --   b"00010_01_00_000000110101", --1E store gr1, snakeHeadPos
  --   b"00001_10_00_000000101010", --1F load gr2, 0 (ska va inverterad)
  --   b"10100_00_00_000000110101", --20 ldhr hr:=snakeHeadPos
  --   b"10101_10_00_000000000000", --21 vhr_store GR2
  --   b"10001_00_00_000000101010", --22 jmp 00

  --   --Move snake right
  --   b"00001_01_00_000000110101", --23 load gr1, snakeHeadPos
  --   b"00011_01_00_000000101011", --24 add gr1, constOne
  --   b"00010_01_00_000000110101", --25 store gr1, snakeHeadPos
  --   b"00001_10_00_000000101010", --26 load gr2, 0 (ska va inverterad)
  --   b"10100_00_00_000000110101", --27 ldhr hr:=snakeHeadPos
  --   b"10101_10_00_000000000000", --28 vhr_store GR2
  --   b"10001_00_00_000000101010", --29 jmp 00
    
  --   --Constants
  --   b"00000_00_00_000000000000", --2A constZero
  --   b"00000_00_00_000000000001", --2B constOne
  --   b"00000_00_00_000001010000", --2C constEighty

  --   b"00000_00_00_000000000001", --2D joystickRigth
  --   b"00000_00_00_000000000010", --2E joystickLeft
  --   b"00000_00_00_000000000100", --2F joystickDown
  --   b"00000_00_00_000000001000", --30 joystickUp

  --   b"00000_00_00_000000100011", --31 moveSnakeRight
  --   b"00000_00_00_000000011100", --32 moveSnakeLeft
  --   b"00000_00_00_000000010101", --33 moveSnakeDown
  --   b"00000_00_00_000000001110", --34 moveSnakeUp
    
  --   --Variables
  --   b"00000_00_00_011001110010", --35 snakeHeadPos
  --   b"00000_00_00_000000000101", --36 snakeLength
  --   b"00000_00_00_000000000000", --37 applePos
  