--PascalCase: control signals
--snake_case: other connections and variabels

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Processor IS
    PORT (
        clk, rst, interrupt : IN STD_LOGIC;
        in_port : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END Processor;
ARCHITECTURE ArchProcessor OF Processor IS

    COMPONENT InstructionMemory IS
        PORT (
            rst : IN STD_LOGIC;
            pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            instr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT RegFile IS
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
    END COMPONENT;

    COMPONENT CU IS
        GENERIC (
            OUTPUT_WIDTH : INTEGER := 17
        );
        PORT (
            input : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            AluOp : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            ImmSrc : OUT STD_LOGIC;
            Branch : OUT STD_LOGIC;
            BranchIf0 : OUT STD_LOGIC;
            MemRead : OUT STD_LOGIC;
            MemWrite : OUT STD_LOGIC;
            SpOp : OUT STD_LOGIC;
            protect : OUT STD_LOGIC;
            free : OUT STD_LOGIC;
            MemWb : OUT STD_LOGIC;
            RegWrite : OUT STD_LOGIC;
            PortWrite : OUT STD_LOGIC;
            PortWB : OUT STD_LOGIC;
            PCWrite : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT ALU IS
        PORT (
            R1, R2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            op : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            CCR_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0); --(carry & negative & zero)
            CCR_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT DataMemory IS
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
    END COMPONENT;

    COMPONENT swapDetection IS
        PORT (
            clk : IN STD_LOGIC;
            instruction : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            swapStall : OUT STD_LOGIC;
            swap_ins : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT mux2 IS
        GENERIC (n : INTEGER := 32);
        PORT (
            inA : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            inB : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            S : IN STD_LOGIC;
            F_mux : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT mux4 IS
        GENERIC (n : INTEGER := 32);
        PORT (
            inA : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            inB : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            inC : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            inD : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            S : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            F_mux : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
    END COMPONENT;
    COMPONENT PC_circuit IS
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            enable : IN STD_LOGIC;
            branch : IN STD_LOGIC;
            pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ForwardingUnit IS
        PORT (
            swapStall : IN STD_LOGIC;
            ID_EX_src1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            ID_EX_src2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            EX_MEM_MemRead : STD_LOGIC;
            EX_MEM_WB, MEM_WB_WB : IN STD_LOGIC;
            EX_MEM_dst, MEM_WB_dst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Op1_Forward, Op2_Forward : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT SP_Circuit IS
        PORT (
            clk, reset, enable, MemWrite : STD_LOGIC;
            SP_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    -------------global helper variable-------------
    CONSTANT signal_count : INTEGER := 17; --Alu_op takes 4 slots

    -----------------signal bus--------------------
    SIGNAL ImmSrc, Branch, BranchIf0, MemRead, MemWrite, SpOp, Protect, Free, MemWb, RegWrite, PortWrite, PortWB, PCWrite : STD_LOGIC;
    SIGNAL AluOp : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL signal_vector : STD_LOGIC_VECTOR(signal_count - 1 DOWNTO 0);
    SIGNAL fetched_instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL read_reg1, read_reg2, write_reg : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL reg_read_data1, reg_read_data2, reg_write_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL alu_in1, alu_in2, alu_in1_nof, alu_in2_nof, alu_out, data_mem_in, data_mem_out, alu_or_in_port : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL data_mem_address : STD_LOGIC_VECTOR (19 DOWNTO 0);
    SIGNAL immidiate_value : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL immidiate_alu_in : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL pc_if_branch : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL immidiate_flag : STD_LOGIC := '0';
    SIGNAL zero_vector16 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL one_vector16 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '1');
    SIGNAL zero_vector32 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL one_vector32 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '1');

    SIGNAL branch_sel : STD_LOGIC;
    SIGNAL insert_nop : STD_LOGIC;
    SIGNAL instructon_selector : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL pc_enable : STD_LOGIC := '0';
    SIGNAL Op1_Forward, Op2_Forward : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal if_id_flush: std_logic;
    signal pop_use: std_logic;
    signal pc_next: std_logic_vector(31 downto 0);


    --swap
    SIGNAL swapStall : STD_LOGIC;
    SIGNAL swap_ins : STD_LOGIC_VECTOR(15 DOWNTO 0);
    -----------------registers--------------------
    SIGNAL pc, sp : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL CCR : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL CCR_next : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL if_id_reg : STD_LOGIC_VECTOR(48 DOWNTO 0);
    SIGNAL id_ex_reg : STD_LOGIC_VECTOR(138 DOWNTO 0);
    SIGNAL ex_mem_reg : STD_LOGIC_VECTOR(107 DOWNTO 0);
    SIGNAL mem_wb_reg : STD_LOGIC_VECTOR(69 DOWNTO 0);
BEGIN
    --components
    u0 : InstructionMemory PORT MAP(rst, pc, fetched_instruction);
    u1 : RegFile PORT MAP(mem_wb_reg(68), reg_write_data, rst, read_reg1, read_reg2, reg_read_data1, reg_read_data2, write_reg);
    u2 : CU PORT MAP(if_id_reg(15 DOWNTO 10), AluOp, ImmSrc, Branch, BranchIf0, MemRead, MemWrite, SpOp, protect, free, MemWb, RegWrite, PortWrite, PortWB, PCWrite);
    u3 : alu PORT MAP(alu_in1, alu_in2, id_ex_reg(70 DOWNTO 67), CCR, CCR_next, alu_out);
    u4 : DataMemory PORT MAP(rst, ex_mem_reg(67), ex_mem_reg(68), ex_mem_reg(70), ex_mem_reg(71), data_mem_in, data_mem_out, data_mem_address);

    u5 : mux2 PORT MAP(mem_wb_reg(34 DOWNTO 3), mem_wb_reg(66 DOWNTO 35), mem_wb_reg(67), reg_write_data); --Write back mux
    u6 : mux2 PORT MAP(id_ex_reg(34 DOWNTO 3), immidiate_alu_in, id_ex_reg(71), alu_in2_nof);
    u7 : mux2 GENERIC MAP(16) PORT MAP(zero_vector16, fetched_instruction, immidiate_flag, immidiate_value);
    u8 : swapDetection PORT MAP(clk, fetched_instruction, swapStall, swap_ins);
    u9 : mux4 GENERIC MAP(16) PORT MAP(fetched_instruction, zero_vector16, swap_ins, zero_vector16, instructon_selector, instruction);

    u11 : PC_circuit PORT MAP(clk, rst, pc_enable, branch_sel, pc_if_branch, pc);
    u12 : mux2 PORT MAP(alu_in1, reg_write_data, mem_wb_reg(69), pc_if_branch);

    u13 : ForwardingUnit PORT MAP(id_ex_reg(132), id_ex_reg(138 DOWNTO 136), id_ex_reg(135 DOWNTO 133), ex_mem_reg(67), ex_mem_reg(73), mem_wb_reg(68), ex_mem_reg(2 DOWNTO 0), mem_wb_reg(2 DOWNTO 0), Op1_Forward, Op2_Forward);
    u14 : mux4 PORT MAP(alu_in1_nof, ex_mem_reg(66 DOWNTO 35), reg_write_data, zero_vector32, Op1_Forward, alu_in1);
    u15 : mux4 PORT MAP(alu_in2_nof, ex_mem_reg(66 DOWNTO 35), reg_write_data, zero_vector32, Op2_Forward, alu_in2);
    u16 : SP_Circuit PORT MAP(clk, rst, ex_mem_reg(69), ex_mem_reg(68), sp);
    u17 : mux2 GENERIC MAP(20) PORT MAP(ex_mem_reg(22 DOWNTO 3), sp(19 DOWNTO 0), ex_mem_reg(69), data_mem_address);
    u18 : mux2 PORT MAP(ex_mem_reg(66 DOWNTO 35), pc_next, ex_mem_reg(75), data_mem_in);
    u19 : mux2 PORT MAP(alu_out, in_port, id_ex_reg(82), alu_or_in_port);
    --connections
    branch_sel <= id_ex_reg(72) OR (id_ex_reg(73) AND CCR(0)) OR mem_wb_reg(69);

    read_reg1 <= if_id_reg(6 DOWNTO 4);
    read_reg2 <= if_id_reg(3 DOWNTO 1);
    signal_vector <= PCWrite & PortWB & PortWrite & RegWrite & MemWb & free & protect & SpOp & MemWrite & MemRead & BranchIf0 & Branch & ImmSrc & AluOp;

    alu_in1_nof <= id_ex_reg(66 DOWNTO 35);
    immidiate_alu_in <= zero_vector16 & id_ex_reg(131 DOWNTO 116) WHEN (id_ex_reg(129) = '0') ELSE
        one_vector16 & immidiate_value;

    write_reg <= mem_wb_reg(2 DOWNTO 0);

    --Out Instruction
    out_port <= data_mem_in WHEN ex_mem_reg(74) = '1' ELSE
        (OTHERS => 'Z');

    --pop use
    pop_use <= id_ex_reg(74) and id_ex_reg(76) and id_ex_reg(79) and id_ex_reg(80);

    --pc enable                                          Call instructions
    pc_enable <= '0' when pop_use = '1' or swapStall = '1' or id_ex_reg(83) = '1' or ex_mem_reg(75) = '1' else '1';

    --flush if/id
    if_id_flush <= id_ex_reg(72) OR (id_ex_reg(73) AND CCR(0)) or ex_mem_reg(75);

    --instruction selector
    insert_nop <= immidiate_flag OR id_ex_reg(83) OR ex_mem_reg(75);
    instructon_selector <= swapStall & insert_nop;

    --memory stage small alu to increment the pc
    pc_next <= STD_LOGIC_VECTOR(unsigned(ex_mem_reg(107 downto 76)) + 1);

    --register changes
    PROCESS (clk, rst) BEGIN
        IF rst = '1' THEN
            CCR <= (OTHERS => '0');
            if_id_reg <= (OTHERS => '0');
            id_ex_reg <= (OTHERS => '0');
            ex_mem_reg <= (OTHERS => '0');
            mem_wb_reg <= (OTHERS => '0');

        ELSIF rising_edge(clk) THEN
            CCR <= CCR_next;

            IF immidiate_flag = '0' THEN
                immidiate_flag <= instruction(0);
            ELSE
                immidiate_flag <= '0';
            END IF;

            IF if_id_flush = '1' THEN
                if_id_reg(48 DOWNTO 0) <= (OTHERS => '0');
                id_ex_reg(138 DOWNTO 0) <= (OTHERS => '0');
            ELSif pop_use = '1' then
                if_id_reg(48 DOWNTO 0) <= swapStall & pc & instruction;
                id_ex_reg(138 DOWNTO 0) <= (OTHERS => '0');
            ELSE
                if_id_reg(48 DOWNTO 0) <= swapStall & pc & instruction;
                id_ex_reg(138 DOWNTO 0) <= if_id_reg(6 DOWNTO 1) & if_id_reg(48) & immidiate_value & if_id_reg(47 DOWNTO 16) & signal_vector & reg_read_data1 & reg_read_data2 & if_id_reg(9 DOWNTO 7);
            END IF;

            ex_mem_reg(107 DOWNTO 0) <= id_ex_reg(115 DOWNTO 84) & id_ex_reg(83) & id_ex_reg(81 DOWNTO 74) & alu_or_in_port & alu_in2 & id_ex_reg(2 DOWNTO 0);
            mem_wb_reg(69 DOWNTO 0) <= ex_mem_reg(75) & ex_mem_reg(73 DOWNTO 72) & data_mem_out & ex_mem_reg(66 DOWNTO 35) & ex_mem_reg(2 DOWNTO 0);
        END IF;
    END PROCESS;
END ArchProcessor;