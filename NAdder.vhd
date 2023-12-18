LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--Adder when K = 0, Subtractor when K = 1

ENTITY NAdder IS
	GENERIC (n : INTEGER := 32);
	PORT (
		a, b : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
		cin, k : IN STD_LOGIC;
		s : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
		cout : OUT STD_LOGIC);
END NAdder;

ARCHITECTURE ArchNAdder OF NAdder IS

	COMPONENT BitAdder IS
		PORT (
			a, b, cin : IN STD_LOGIC;
			s, cout : OUT STD_LOGIC);
	END COMPONENT;

	SIGNAL temp : STD_LOGIC_VECTOR(n DOWNTO 0);
	SIGNAL b_xor_k : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);

BEGIN
	temp(0) <= cin;
	b_xor_k <= NOT b WHEN k = '1' ELSE
		b; --similar effect to XOR between k and every bit in b
	loop1 : FOR i IN 0 TO n - 1 GENERATE
		fx : BitAdder PORT MAP(a(i), b_xor_k(i), temp(i), s(i), temp(i + 1));
	END GENERATE;
	cout <= temp(n);

END ArchNAdder;