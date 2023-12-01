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

    FILE memfile : text;

BEGIN
    PROCESS
        VARIABLE line_buffer : LINE;
        VARIABLE data : INTEGER;
    BEGIN
        FOR i IN 0 TO 2047 LOOP
            instrMem(i) <= (OTHERS => '0');
        END LOOP;

        file_open(memfile, "instructionMem.txt", read_mode);
        FOR i IN 0 TO 2047 LOOP
            readline(memfile, line_buffer);
            read(line_buffer, data);
            instrMem(i) <= STD_LOGIC_VECTOR(to_unsigned(data, instrMem(i)'length));
        END LOOP;
        file_close(memfile);

        address <= pc(12 DOWNTO 0);
        instr <= instrMem(to_integer(unsigned(address)));

        WAIT;
    END PROCESS;

END Behavioral;