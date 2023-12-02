library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
port(
	R1, R2: in std_logic_vector(31 downto 0);
	op: in std_logic_vector(3 downto 0);
	CCR: in std_logic_vector(2 downto 0);
	result: out std_logic_vector(31 downto 0));
end ALU;

architecture ArchALU of ALU is

signal Bitset, Rcl, Rcr: std_logic_vector(31 downto 0); 

Begin
process(R1, R2, op)
variable R2_val: integer;

begin
	R2_val := to_integer(UNSIGNED(R2));
	if R2_val >= 0 and R2_val <= 31 then
		Bitset <= R1;
		Bitset(R2_val) <= '1'; 
	else
		Bitset <= R1;
	end if;

	if R2_val >= 1 and R2_val <= 32 then
		Rcl(31 downto R2_val) <= R1(31 - R2_val downto 0);	
		Rcr(31 - R2_val downto 0) <= R1(31 downto R2_val);
		Rcl(R2_val - 1) <= CCR(2);
		Rcr(32 - R2_val) <= CCR(2);
		if R2_val >= 2 then
			Rcl(R2_val - 2 downto 0) <= R1(31 downto 33 - R2_val);
			Rcr(31 downto 33 - R2_val) <= R1(R2_val - 2 downto 0);
		else
			Rcl(R2_val - 2 downto 0) <= Rcl(R2_val - 2 downto 0);
			Rcr(31 downto 33 - R2_val) <= Rcr(31 downto 33 - R2_val);
		end if;
	else
		Rcl <= R1;
		Rcr <= R1;
	end if;
	
	
end process;


with op(3 downto 0) select result <=
	R1	  when "0000",
	not R1	  when "0001",
	std_logic_vector( 0 - unsigned(R1) )    when "0010",
	std_logic_vector( unsigned(R1) + 1 )	when "0011",
	std_logic_vector( unsigned(R1) - 1 )	when "0100",
	R2	  when "0101", --SWAP "TO BE CHANAGED"
	std_logic_vector( unsigned(R1) + unsigned(R2) )	  when "0110",
	std_logic_vector( unsigned(R1) + unsigned(R2) )	  when "0111",
	std_logic_vector( unsigned(R1) - unsigned(R2) )	  when "1000",
	R1 and R2 when "1001",
	R1 or R2  when "1010",
	R1 xor R2 when "1011",
	std_logic_vector( unsigned(R1) - unsigned(R2) )	  when "1100",
	Bitset	  when "1101",
	Rcl	  when "1110",
	Rcr	  when "1111",
	(others => 'X') when others;


end ArchALU;
