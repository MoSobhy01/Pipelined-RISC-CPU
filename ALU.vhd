library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
port(
	R1, R2: in std_logic_vector(31 downto 0);
	op: in std_logic_vector(3 downto 0);
	CCR_in: in std_logic_vector(2 downto 0); --(carry & negative & zero)
	CCR_out: out std_logic_vector(2 downto 0); 
	result: out std_logic_vector(31 downto 0));
end ALU;

architecture ArchALU of ALU is

signal Bitset, Rcl, Rcr: std_logic_vector(31 downto 0); 
signal temp_result: std_logic_vector(31 downto 0);
signal zero_vector: std_logic_vector(31 downto 0) := (others => '0');

Begin
process(R1, R2, op)
variable R2_val: integer;

begin
	R2_val := to_integer(UNSIGNED(R2));

	--Bitset
	if R2_val >= 0 and R2_val <= 31 then
		Bitset <= R1;
		Bitset(R2_val) <= '1'; 
	else
		Bitset <= R1;
	end if;

	--Rotate with carry (left and right)
	CCR_out(2) <= '0';
	if R2_val >= 1 and R2_val <= 32 then
		Rcl(31 downto R2_val) <= R1(31 - R2_val downto 0);	
		Rcr(31 - R2_val downto 0) <= R1(31 downto R2_val);
		Rcl(R2_val - 1) <= CCR_in(2);
		Rcr(32 - R2_val) <= CCR_in(2);
		CCR_out(2) <= Rcl(R2_val - 1);
		CCR_out(2) <= Rcr(32 - R2_val);

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
	
	if op = "0000" or op = "0101" then
		CCR_out(2) <= CCR_in(2);
	end if;
	
end process;


with op(3 downto 0) select temp_result <=
	R1	  when "0000",
	not R1	  when "0001",
	std_logic_vector( 0 - unsigned(R1) )    when "0010",
	std_logic_vector( unsigned(R1) + 1 )	when "0011",
	std_logic_vector( unsigned(R1) - 1 )	when "0100",
	R2	  when "0101",
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

result <= temp_result;
CCR_out(0) <= CCR_in(0) when op = "0000" or op = "0101" else '1' when temp_result = zero_vector else '0';
CCR_out(1) <= CCR_in(1) when op = "0000" or op = "0101" else '1' when temp_result(31) = '1' else '0';

end ArchALU;
