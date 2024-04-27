library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- K1 interface
entity K1 is
  port (
    operand : in unsigned(4 downto 0);
    K1_adress : out unsigned(7 downto 0));
end K1;

architecture Behavioral of K1 is

-- K1 Memory
type K1_mem_t is array (0 to 40) of unsigned(7 downto 0);
constant K1_mem_c : K1_mem_t :=(
  x"0A", --:00 HALT
  x"0B", --:01 LOAD
  x"0C", --:02 STORE
  x"0D", --:03 ADD
  x"10", --:04 AND
  x"13", --:05 SUB
  x"16", --:06 LSR
  x"1D", --:07 BRA
  x"20", --:08 BNE
  x"22", --:09 BSE
  x"24", --:0A BGE
  x"29", --:0B BEQ
  x"2B", --:0C BPL
  x"2E", --:0D LDJ
  x"2F", --:0E CMP
  x"31", --:0F CMPA
  x"32", --:10 STRLC
  x"33", --:11 JMP
  x"34", --:12 LDRAN
  x"35", --:13 STRHR
  x"37", --:14 LDHR
  x"38", --:15 VHR_STR
  x"3A", --:16 VHR_LOAD
  x"3C", --:17 ADD_HR
  x"3F", --:18 SUB_HR
  x"42", --:19 LC--
  x"43", --:1A BRL
  others => (others => '0')

   );
   --K1 code

signal K1_sig : K1_mem_t := K1_mem_c;

begin -- behavioral

  K1_adress <= K1_sig(to_integer(operand));

end Behavioral;