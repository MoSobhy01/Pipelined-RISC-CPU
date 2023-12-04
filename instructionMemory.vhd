LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE std.TEXTIO.ALL; -- Add this line for text file I/O

ENTITY InstructionMemory IS
    PORT (
        pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        instr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END InstructionMemory;

ARCHITECTURE Behavioral OF InstructionMemory IS
    SIGNAL address : STD_LOGIC_VECTOR(12 DOWNTO 0);
    TYPE MemoryArray IS ARRAY (0 TO 2047) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL instrMem : MemoryArray;

BEGIN
    PROCESS (pc, address)
        VARIABLE line_buffer : LINE;
        VARIABLE data : STD_LOGIC_VECTOR(15 DOWNTO 0);
        FILE memfile : text;
        VARIABLE i : INTEGER := 0;
    BEGIN
        FOR i IN 0 TO 2047 LOOP
            instrMem(i) <= (OTHERS => '0');
        END LOOP;

        file_open(memfile, "E:\ModelSim\project\instructionMem.txt", read_mode);
        WHILE((i < 2048) AND (NOT endfile(memfile))) LOOP
            readline(memfile, line_buffer);
            read(line_buffer, data);

            REPORT "line inst : ---------------- " & to_hstring(data);
                instrMem(i) <= data;
            i := i + 1;
        END LOOP;
        file_close(memfile);
        address <= pc(12 DOWNTO 0);

        instr <= instrMem(to_integer(unsigned(address)));

        --  WAIT;
    END PROCESS;

END Behavioral;