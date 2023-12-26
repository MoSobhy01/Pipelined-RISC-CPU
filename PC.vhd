LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY PC_circuit IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    enable : IN STD_LOGIC;
    branch : IN STD_LOGIC;
    pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END ENTITY PC_circuit;

ARCHITECTURE behavioral OF PC_circuit IS
  SIGNAL pc_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
BEGIN
  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      pc_reg <= (OTHERS => '0');
    ELSIF falling_edge(clk) AND enable = '1' THEN
      IF (branch = '0') THEN
        pc_reg <= STD_LOGIC_VECTOR(unsigned(pc_reg) + 1);
      ELSE
        pc_reg <= pc_in;
      END IF;
    END IF;
  END PROCESS;

  pc_out <= pc_reg;
END ARCHITECTURE behavioral;