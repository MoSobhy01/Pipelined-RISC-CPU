library ieee;
use ieee.std_logic_1164.all;

--Adder when K = 0, Subtractor when K = 1

ENTITY NAdder IS
GENERIC (n : integer := 32);
PORT (
	a, b : IN std_logic_vector(n-1 DOWNTO 0) ;
	cin, k : IN std_logic;
	s : OUT std_logic_vector(n-1 DOWNTO 0);
	cout : OUT std_logic);
END NAdder;

ARCHITECTURE ArchNAdder OF NAdder IS

Component BitAdder IS
PORT( 
	a,b,cin : IN std_logic;
	s,cout : OUT std_logic);
END component;

signal temp: std_logic_vector(n downto 0);
signal b_xor_k: std_logic_vector(n-1 downto 0);

BEGIN
temp(0) <= cin;
b_xor_k <= not b when k = '1' else b; --similar effect to XOR between k and every bit in b
loop1: FOR i IN 0 TO n-1 GENERATE
	fx: BitAdder port map(a(i),b_xor_k(i),temp(i),s(i),temp(i+1));
END GENERATE;
cout <= temp(n);

END ArchNAdder;
