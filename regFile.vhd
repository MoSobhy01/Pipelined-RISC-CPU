LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RegFile IS
  PORT (
    reg_write : IN STD_LOGIC;
    write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC;
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

  PROCESS (clk, rst)
    VARIABLE i : INTEGER;
  BEGIN
    IF rst = '1' THEN
      FOR i IN 0 TO 7 LOOP
        registers(i) <= (OTHERS => '0');
      END LOOP;
    ELSIF falling_edge(clk) THEN
      IF reg_write = '1' THEN
        registers(to_integer(unsigned(write_reg))) <= write_data;
      END IF;
      -- Add your display statement here if needed
    END IF;
  END PROCESS;

END Behavioral;