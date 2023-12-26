LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RegFile IS
  PORT (
    reg_write : IN STD_LOGIC;
    write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    rst : IN STD_LOGIC;
    read_reg1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    read_reg2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    read_data1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    read_data2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    write_reg : IN STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END RegFile;

ARCHITECTURE Behavioral OF RegFile IS
  SIGNAL sel : STD_LOGIC_VECTOR(7 DOWNTO 0);
  TYPE RegisterArray IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL registers : RegisterArray;

BEGIN

  read_data1 <= registers(to_integer(unsigned(read_reg1)));
  read_data2 <= registers(to_integer(unsigned(read_reg2)));

  PROCESS (rst, write_reg, write_data, reg_write)
    VARIABLE i : INTEGER;
  BEGIN
    IF rst = '1' THEN
      FOR i IN 0 TO 7 LOOP
        registers(i) <= (OTHERS => '0');
      END LOOP;
    ELSIF reg_write = '1' THEN
      registers(to_integer(unsigned(write_reg))) <= write_data;
    END IF;
  END PROCESS;

END Behavioral;