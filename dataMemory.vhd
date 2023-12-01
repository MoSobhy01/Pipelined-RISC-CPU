
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY DataMemory IS
    PORT (
        Clk : IN STD_LOGIC;
        MemWrite : IN STD_LOGIC;
        MemRead : IN STD_LOGIC;
        DataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Addr : IN STD_LOGIC_VECTOR(19 DOWNTO 0)
    );
END DataMemory;

ARCHITECTURE Behavioral OF DataMemory IS
    TYPE MemoryArray IS ARRAY (0 TO 2047) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Memo : MemoryArray;

BEGIN
    PROCESS (Clk)
    BEGIN
        IF rising_edge(Clk) THEN
            IF MemWrite = '1' THEN
                Memo(to_integer(unsigned(Addr(10 DOWNTO 0)))) <= DataIn(31 DOWNTO 16);
                Memo(to_integer(unsigned(Addr(10 DOWNTO 0))) + 1) <= DataIn(15 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;

    DataOut(31 DOWNTO 16) <= (OTHERS => '0') WHEN MemRead = '0' ELSE
    Memo(to_integer(unsigned(Addr(10 DOWNTO 0))));

    DataOut(15 DOWNTO 0) <= (OTHERS => '0') WHEN MemRead = '0' ELSE
    Memo(to_integer(unsigned(Addr(10 DOWNTO 0))) + 1);
END Behavioral;