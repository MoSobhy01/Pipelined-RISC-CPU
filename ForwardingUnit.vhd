LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ForwardingUnit IS
  PORT (
    swapStall : IN STD_LOGIC;
    ID_EX_src1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    ID_EX_src2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    EX_MEM_MemRead : STD_LOGIC;
    EX_MEM_WB, MEM_WB_WB : IN STD_LOGIC;
    EX_MEM_dst, MEM_WB_dst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    Op1_Forward, Op2_Forward : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
END ForwardingUnit;
ARCHITECTURE ForwardingUnit_arc OF ForwardingUnit IS
BEGIN
  PROCESS (ID_EX_src1, ID_EX_src2, EX_MEM_WB, MEM_WB_WB, EX_MEM_dst, MEM_WB_dst)
  BEGIN
    Op1_Forward <= "00";
    Op2_Forward <= "00";

    -- MEM Hazard
    IF (MEM_WB_WB = '1') THEN
      IF (MEM_WB_dst = ID_EX_src1) THEN
        Op1_Forward <= "10";
      END IF;
      IF (MEM_WB_dst = ID_EX_src2) THEN
        Op2_Forward <= "10";
      END IF;
    END IF;

    -- EX Hazard
    IF (EX_MEM_WB = '1' AND EX_MEM_MemRead = '0' and swapStall = '0') THEN
      IF (EX_MEM_dst = ID_EX_src1) THEN
        Op1_Forward <= "01";
      END IF;
      IF (EX_MEM_dst = ID_EX_src2) THEN
        Op2_Forward <= "01";
      END IF;
    END IF;


  END PROCESS;
END ForwardingUnit_arc;