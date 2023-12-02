library ieee;
use ieee.std_logic_1164.all;


ENTITY BitAdder IS
PORT( 
	a,b,cin : IN std_logic;
	s,cout : OUT std_logic);
END BitAdder;

ARCHITECTURE ArchBitAdder OF BitAdder IS
BEGIN
s <= a XOR b XOR cin;
cout <= (a AND b) or (cin AND (a XOR b));
END ArchBitAdder;
