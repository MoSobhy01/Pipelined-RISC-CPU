library ieee;
use ieee.std_logic_1164.all;

entity mux4 is
generic(n : integer := 32);
port(
	inA: in std_logic_vector(n-1 downto 0);
	inB: in std_logic_vector(n-1 downto 0);
	inC: in std_logic_vector(n-1 downto 0);
	inD: in std_logic_vector(n-1 downto 0);
	S: in std_logic_vector(1 downto 0);
	F_mux: out std_logic_vector(n-1 downto 0));
end mux4;

architecture archMux4 of mux4 is
Begin
with S select F_mux <=
	inA 	when "00",
	inB	    when "01",
	inC	    when "10",
	inD	    when "11",
	(others => 'X') when others;

end archMux4;