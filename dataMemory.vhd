
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE std.TEXTIO.ALL;
USE IEEE.std_logic_textio.ALL;

ENTITY DataMemory IS
    PORT (
        rst : IN STD_LOGIC;
        MemRead : IN STD_LOGIC;
        MemWrite : IN STD_LOGIC;
        protectSig : IN STD_LOGIC;
        freeSig : IN STD_LOGIC;
        DataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Addr : IN STD_LOGIC_VECTOR(19 DOWNTO 0)
    );
END DataMemory;

ARCHITECTURE Behavioral OF DataMemory IS
    TYPE MemoryArray IS ARRAY (0 TO 2047) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Memo : MemoryArray := (OTHERS => (OTHERS => '0'));
    TYPE ProtectArray IS ARRAY (0 TO 2047) OF STD_LOGIC;
    SIGNAL protect : ProtectArray := (OTHERS => '0');

BEGIN
    DataOut(31 DOWNTO 16) <= (OTHERS => '0') WHEN MemRead = '0' ELSE
    Memo(to_integer(unsigned(Addr(10 DOWNTO 0))));

    DataOut(15 DOWNTO 0) <= (OTHERS => '0') WHEN MemRead = '0' ELSE
    Memo(to_integer(unsigned(Addr(10 DOWNTO 0))) + 1);

    PROCESS (rst, MemWrite, MemRead, protectSig, freeSig, dataIn, addr)
        VARIABLE line_buffer : LINE;
        VARIABLE data : STD_LOGIC_VECTOR(15 DOWNTO 0);
        FILE memfile : text;
        VARIABLE i : INTEGER := 0;
    BEGIN
        IF rst = '1' THEN
            FOR i IN 0 TO 2047 LOOP
                Memo(i) <= (OTHERS => '0');
            END LOOP;

            file_open(memfile, "D:/Study/ARC_Project/Pipelined-RISC-CPU/dataMem.txt", read_mode);
            i := 0;
            WHILE((i < 2048) AND (NOT endfile(memfile))) LOOP
                readline(memfile, line_buffer);
                read(line_buffer, data);
                Memo(i) <= data;
                i := i + 1;
            END LOOP;
            file_close(memfile);

        ELSIF protectSig = '1' THEN
            protect(to_integer(unsigned(Addr(10 DOWNTO 0)))) <= '1';

        ELSIF freeSig = '1' THEN
            protect(to_integer(unsigned(Addr(10 DOWNTO 0)))) <= '0';

        ELSIF MemWrite = '1' AND protect(to_integer(unsigned(Addr(10 DOWNTO 0)))) = '0' THEN
            Memo(to_integer(unsigned(Addr(10 DOWNTO 0)))) <= DataIn(31 DOWNTO 16);
            Memo(to_integer(unsigned(Addr(10 DOWNTO 0))) + 1) <= DataIn(15 DOWNTO 0);
        END IF;
    END PROCESS;
END Behavioral;