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
BEGIN
  SP_Out<= SP_Reg when MemWrite = '0'
else STD_LOGIC_VECTOR(unsigned(Sp_Req) + 1);

  PROCESS (enable, MemWrite, SP_In)
  BEGIN
    IF enable = '1' THEN
      IF MemWrite = '1' THEN
        SP_Reg <= SP_In;
      END IF;
    END IF;
  END PROCESS;

  SP_Out <= SP_Reg;
END ARCHITECTURE Behavioral;