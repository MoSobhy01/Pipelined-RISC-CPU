--PascalCase: control signals
--snake_case: other connections and variabels

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY Processor IS
port(
    clk, rst, interrupt: in std_logic;
    in_port: in std_logic_vector(31 downto 0);
    out_port: out std_logic_vector(31 downto 0)
);
END Processor;


ARCHITECTURE ArchProcessor OF Processor IS

--global helper variable
constant signal_count: integer := 16; --Alu_op takes 4 slots

--signal bus
signal ImmSrc, Branch, BranchIf0, MemRead, MemWrite, SpOp, Protect, Free, MemWb, RegWrite, PortWrite, PortWB : std_logic;
signal AluOp: std_logic_vector(3 downto 0);
signal signal_vector: std_logic_vector(signal_count - 1 downto 0);
signal instruction: std_logic_vector(15 downto 0);
signal read_reg1, read_reg2, write_reg : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal reg_read_data1, reg_read_data2, reg_write_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal alu_in1, alu_in2, alu_out, data_mem_in, data_mem_out: std_logic_vector (31 downto 0);
signal data_mem_address: std_logic_vector (19 downto 0);
signal immidiate_value: std_logic_vector (15 downto 0);
signal immidiate_alu_in: std_logic_vector (31 downto 0);
signal immidiate_flag: std_logic := '0';
signal WB_selector: std_logic_vector(1 downto 0);
signal zero_vector16: std_logic_vector(15 downto 0) := (others => '0');
signal one_vector16: std_logic_vector(15 downto 0) := (others => '1');
signal zero_vector32: std_logic_vector(31 downto 0) := (others => '0');
signal one_vector32: std_logic_vector(31 downto 0) := (others => '1');


--registers
signal pc, sp : std_logic_vector(31 downto 0);
signal CCR: std_logic_vector(2 downto 0);
signal CCR_next: std_logic_vector(2 downto 0);
signal if_id_reg: std_logic_vector(47 downto 0);
signal id_ex_reg: std_logic_vector(130 downto 0);
signal ex_mem_reg: std_logic_vector(107 downto 0);
signal mem_wb_reg: std_logic_vector(69 downto 0);

component InstructionMemory IS
    PORT (
        rst: IN STD_LOGIC;
        pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        instr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END component;

component RegFile IS
  PORT (
    reg_write : IN STD_LOGIC;
    write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    rst : IN STD_LOGIC;
    read_reg1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    read_reg2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    read_data1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    read_data2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    write_reg : IN STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END component;

component CU is
    generic (
        OUTPUT_WIDTH : integer := 16
      );
      port (
        input : in std_logic_vector(5 downto 0);
        AluOp   : out std_logic_vector(3 downto 0);
        ImmSrc   : out std_logic;
        Branch   : out std_logic;
        BranchIf0: out std_logic;
        MemRead  : out std_logic;
        MemWrite : out std_logic;
        SpOp     : out std_logic;
        protect  : out std_logic;
        free     : out std_logic;
        MemWb : out std_logic;
        RegWrite  : out std_logic;
	PortWrite  : out std_logic;
    	PortWB  : out std_logic
      );
  end component;

component ALU is
    port(
        R1, R2: in std_logic_vector(31 downto 0);
        op: in std_logic_vector(3 downto 0);
        CCR_in: in std_logic_vector(2 downto 0); --(carry & negative & zero)
        CCR_out: out std_logic_vector(2 downto 0); 
        result: out std_logic_vector(31 downto 0)
    );
end component;

component DataMemory IS
    PORT (
        rst: IN STD_LOGIC;
        MemRead : IN STD_LOGIC;
        MemWrite : IN STD_LOGIC;
        protectSig: in std_logic;
        freeSig: in std_logic;
        DataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Addr : IN STD_LOGIC_VECTOR(19 DOWNTO 0)
    );
END component;

component mux2 is
    generic(n : integer := 32);
    port(
        inA: in std_logic_vector(n-1 downto 0);
        inB: in std_logic_vector(n-1 downto 0);
        S: in std_logic;
        F_mux: out std_logic_vector(n-1 downto 0)
    );
end component;

component mux4 is
    generic(n : integer := 32);
    port(
        inA: in std_logic_vector(n-1 downto 0);
        inB: in std_logic_vector(n-1 downto 0);
        inC: in std_logic_vector(n-1 downto 0);
        inD: in std_logic_vector(n-1 downto 0);
        S: in std_logic_vector(1 downto 0);
        F_mux: out std_logic_vector(n-1 downto 0));
    end component;

BEGIN
--components
u0: InstructionMemory port map(rst, pc, instruction);
u1: RegFile port map(mem_wb_reg(68), reg_write_data, rst, read_reg1, read_reg2, reg_read_data1, reg_read_data2, write_reg);
u2: CU port map(if_id_reg(15 downto 10), AluOp, ImmSrc, Branch, BranchIf0, MemRead, MemWrite, SpOp, protect, free, MemWb, RegWrite, PortWrite, PortWB);
u3: alu port map(alu_in1, alu_in2, id_ex_reg(70 downto 67), CCR, CCR_next, alu_out);
u4: DataMemory port map(rst, ex_mem_reg(67), ex_mem_reg(68), ex_mem_reg(70), ex_mem_reg(71), data_mem_in, data_mem_out, data_mem_address);
u5: mux4 port map(mem_wb_reg(34 downto 3), mem_wb_reg(66 downto 35), in_port, in_port, WB_selector, reg_write_data); --Write back mux
u6: mux2 port map(id_ex_reg(34 downto 3), immidiate_alu_in, id_ex_reg(71), alu_in2);
u7: mux2 generic map(16) port map(zero_vector16, instruction, immidiate_flag, immidiate_value);

--connections

read_reg1 <= if_id_reg(6 downto 4);
read_reg2 <= if_id_reg(3 downto 1);
signal_vector <= PortWB & PortWrite & RegWrite & MemWb & free & protect & SpOp & MemWrite & MemRead & BranchIf0 & Branch & ImmSrc & AluOp;

alu_in1 <= id_ex_reg(66 downto 35);
immidiate_alu_in <= zero_vector16 & id_ex_reg(130 downto 115) when (id_ex_reg(128) = '0') else one_vector16 & immidiate_value;

data_mem_in <= ex_mem_reg(66 downto 35);
data_mem_address <= ex_mem_reg(22 downto 3);

write_reg <= mem_wb_reg(2 downto 0);
WB_selector <= mem_wb_reg(69) & mem_wb_reg(67);

--Out Instruction
out_port <= data_mem_in when ex_mem_reg(74) = '1' else (others => 'Z');

--register changes
process(clk, rst) begin
    if rst = '1' then
        pc <= (others => '0');
        sp <= (others => '0');
        CCR <= (others => '0');
        if_id_reg <= (others => '0');
        id_ex_reg <= (others => '0');
        ex_mem_reg <= (others => '0');
        mem_wb_reg <= (others => '0');

	elsif rising_edge(clk) then
		pc <= std_logic_vector(unsigned(pc) + 1);	
        CCR <= CCR_next;
		if immidiate_flag = '0' then
			immidiate_flag <= instruction(0);
			if_id_reg(47 downto 0) <= pc & instruction;
        	else
			immidiate_flag <= '0';
 			if_id_reg(47 downto 0) <= (others => '0');		
		end if; 
		id_ex_reg(130 downto 0) <= immidiate_value & if_id_reg(47 downto 16) & signal_vector & reg_read_data1 & reg_read_data2 & if_id_reg(9 downto 7);
		ex_mem_reg(107 downto 0) <= id_ex_reg(112 downto 81) & id_ex_reg(82 downto 74) & alu_out & alu_in2 & id_ex_reg(2 downto 0);
		mem_wb_reg(69 downto 0) <= ex_mem_reg(75) & ex_mem_reg(73 downto 72) & data_mem_out & data_mem_in & ex_mem_reg(2 downto 0);
	end if;
end process;
END ArchProcessor;

--id_ex_reg: 70-67:AluOP 71:immSrc --> 
--ex_mem_reg: 67: memRead 68:memWrite -->
--mem_wb_reg: 67: regWrite 68:MemWb