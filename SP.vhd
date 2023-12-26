LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY SP_Circuit IS
  PORT (
    clk, reset, enable, MemWrite : STD_LOGIC;
    SP_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END ENTITY SP_Circuit;

ARCHITECTURE Behavioral OF SP_Circuit IS
  SIGNAL SP_Reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL SP_out_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

  PROCESS (clk, reset) IS
  BEGIN
    IF (reset = '1') THEN
      SP_Reg <= (OTHERS => '0);
    ELSIF (rising_edge(clk)) THEN
      IF (MemWrite = '1') THEN
        SP_out_reg <= STD_LOGIC_VECTOR(unsigned(SP_Reg) + 1);
      ELSE
        SP_out_reg <= SP_Reg;
      ELSIF falling_edge(clk) AND enable THEN
        IF (MemWrite = '1') THEN
          SP_Reg <= STD_LOGIC_VECTOR(unsigned(SP_Reg) + 1);
        ELSE
          SP_Reg <= STD_LOGIC_VECTOR(unsigned(SP_Reg) - 1);
        END IF;
      END IF;
    END PROCESS;

    SP_Out <= SP_out_reg;
  END ARCHITECTURE Behavioral;