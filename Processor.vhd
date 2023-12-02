library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY Processor IS
END Processor;


ARCHITECTURE ArchProcessor OF Processor IS

--bus
signal clk, ImmSrc, Branch, BranchIf0, MemRead, MemWrite, MemOrAlu, RegWB : std_logic;
signal Alu_op: std_logic_vector(3 downto 0);
signal instruction: std_logic_vector(15 downto 0);
signal alu_in1, alu_in2, alu_out, data_in, data_out: std_logic_vector (31 downto 0);
signal data_address: std_logic_vector (19 downto 0);

--registers
signal pc, sp : std_logic_vector(31 downto 0);
signal CCR: std_logic_vector(2 downto 0);
signal if_id_reg: std_logic_vector(99 downto 0);
signal id_ex_reg: std_logic_vector(99 downto 0);
signal ex_mem_reg: std_logic_vector(99 downto 0);
signal mem_wb_reg: std_logic_vector(99 downto 0);

component InstructionMemory IS
    PORT (
        pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        instr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END component;

component ALU is
port(
	R1, R2: in std_logic_vector(31 downto 0);
	op: in std_logic_vector(3 downto 0);
	CCR: in std_logic_vector(2 downto 0);
	result: out std_logic_vector(31 downto 0));
end component;

component DataMemory IS
    PORT (
        Clk : IN STD_LOGIC;
        MemWrite : IN STD_LOGIC;
        MemRead : IN STD_LOGIC;
        DataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Addr : IN STD_LOGIC_VECTOR(19 DOWNTO 0)
    );
END component;

BEGIN
--components
u0: InstructionMemory port map(pc, instruction);
u1: alu port map(alu_in1, alu_in2, alu_op, CCR, alu_out);
u2: DataMemory port map(clk, MemWrite, MemRead, data_in, data_out, data_address);

--connections
data_in <= ex_mem_reg(63 downto 32);
data_address <= ex_mem_reg(19 downto 0);

--register changes
process(clk) begin
	if rising_edge(clk) then
		pc <= std_logic_vector(unsigned(pc) + 1);	
		if_id_reg(15 downto 0) <= instruction;
		ex_mem_reg(63 downto 0) <= alu_out & alu_in2;
		mem_wb_reg(63 downto 0) <= data_out & data_in;
	end if;
end process;
END ArchProcessor;