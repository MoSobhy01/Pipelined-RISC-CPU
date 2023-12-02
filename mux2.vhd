library ieee;
use ieee.std_logic_1164.all;

entity mux2 is
generic(n : integer := 32);
port(
	inA: in std_logic_vector(n-1 downto 0);
	inB: in std_logic_vector(n-1 downto 0);
	S: in std_logic;
	F_mux: out std_logic_vector(n-1 downto 0));
end mux2;

architecture archMux2 of mux2 is
Begin
with S select F_mux <=
	inA 	 when '0',
	inB	 when '1',
	(others => 'X') when others;

end archMux2;