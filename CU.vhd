library ieee;
use ieee.std_logic_1164.all;

entity CU is
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
end entity CU;

architecture Behavioral of CU is
  signal temp_vector : std_logic_vector(OUTPUT_WIDTH-1 downto 0);
begin
  process(input)
  

-- -------------------------------------- Control Signals Table -----------------------------------------------

  --   Instruction          | AluOp | ImmSrc | Branch | Branch zero | MemRead | MemWrite | SP-Op | Protect | Free | MemWB | RegWrite| PortWrite | PortWB 
  -- -----------------------|-------|--------|--------|-------------|---------|----------|-------|---------|------|-------|---------|-----------|----------
  -- NOP                    | 0000  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 0       | 0         | 0        
  -- NOT Rdst               | 0001  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- NEG Rdst               | 0010  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0       
  -- INC Rdst               | 0011  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- DEC Rdst               | 0100  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- OUT Rdst               | 0000  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 0       | 1         | 0        
  -- IN Rdst                | 0000  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 1        
    
  -- SWAP Rsrc, Rdst        | 0000  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- ADD Rdst, Rsrc1, Rsrc2 | 0110  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- ADDI Rdst, Rsrc1, Imm  | 0111  | 1      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- SUB Rdst, Rsrc1, Rsrc2 | 1000  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- AND Rdst, Rsrc1, Rsrc2 | 1001  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- OR Rdst, Rsrc1, Rsrc2  | 1010  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- XOR Rdst, Rsrc1, Rsrc2 | 1011  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- CMP Rsrc1, Rsrc2       | 1100  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- BITSET Rdst, Imm       | 1101  | 1      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- RCL Rsrc, Imm          | 1110  | 1      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- RCR Rsrc, Imm          | 1111  | 1      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
    
  -- PUSH Rdst              | 0000  | 0      | 0      | 0           | 0       | 1        | 1     | 0       | 0    | 0     | 0       | 0         | 0        
  -- POP Rdst               | 0000  | 0      | 0      | 0           | 1       | 0        | 1     | 0       | 0    | 1     | 1       | 0         | 0        
  -- LDM Rdst, Imm          | 0101  | 1      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 1       | 0         | 0        
  -- LDD Rdst, EA           | 0000  | 1      | 0      | 0           | 1       | 0        | 0     | 0       | 0    | 1     | 1       | 0         | 0        
  -- STD Rsrc, EA           | 0000  | 1      | 0      | 0           | 0       | 1        | 0     | 0       | 0    | 0     | 0       | 0         | 0        
  -- PROTECT Rsrc           | 0000  | 0      | 0      | 0           | 0       | 1        | 0     | 1       | 0    | 0     | 0       | 0         | 0        
  -- FREE Rsrc              | 0000  | 0      | 0      | 0           | 0       | 1        | 0     | 0       | 1    | 0     | 0       | 0         | 0        
    
  -- JZ Rdst                | 0000  | 0      | 0      | 1           | 0       | 0        | 0     | 0       | 0    | 0     | 0       | 0         | 0        
  -- JMP Rdst               | 0000  | 0      | 1      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 0       | 0         | 0        
  -- CALL Rdst              | 0000  | 0      | 1      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 0       | 0         | 0        
  -- RET                    | 0000  | 0      | 1      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 0       | 0         | 0        
  -- RTI                    | 0000  | 0      | 1      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 0       | 0         | 0        
    
  -- Reset                  | 0000  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 0       | 0         | 0        
  -- Interrupt              | 0000  | 0      | 0      | 0           | 0       | 0        | 0     | 0       | 0    | 0     | 0       | 0         | 0        


-- ---------------------------------- INSTRUCTIONS CS VECTORS ------------------------------------------------ 
  --NO Operation
  variable NOP_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others => '0');

--  AluOp | ImmSrc | Branch | Branch zero | MemRead | MemWrite | SP-Op | Protect | Free | MemWB | RegWrite

  -- ALU Operations
  variable NOT_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0001000000000100";
  variable NEG_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0010000000000100";
  variable DEC_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0100000000000100";
  variable INC_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0011000000000100";
  variable OR_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0)  := "1010000000000100";
  variable ADD_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0111000000000100";
  variable ADDI_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0):= "0111100000000100";
  variable SUB_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "1000000000000100";
  variable AND_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "1001000000000100";
  variable XOR_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "1011000000000100";
  variable CMP_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "1000000000000000";
  variable RCL_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "1110100000000100";
  variable RCR_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "1111100000000100";
  variable BITSET_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "1101100000000100";
  
  -- SP Operations
  variable PUSH_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0):= "0000000011000000";
  variable POP_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000000101001100";

  -- Memory Operations
  variable LDM_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0101100000000100";
  variable LDD_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000100100001100";
  variable STD_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000100010000000";
  variable FREE_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000000010010000";
  variable PROTECT_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000000010100000";

  -- Branch Opertions
  variable JMP_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000010000000000";
  variable JZ_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000001000000000";

  --**************************** NOT SURE ENOUGH ********************************
  -- CALL = PUSH + JMP
  variable CALL_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000010011000000";
  variable RET_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000010101000000";
  -- RTI = 2 x POP 
  variable RTI_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000010101000000";

  variable OUT_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000000000000010";
  variable IN_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000000000000101";

  variable SWAP_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "0000000000000000";

  -- |------------------------------------------ DECODING ------------------------------------------------|
  begin
    case input is
      when "000000" =>
        temp_vector <= NOP_INST;
      when "000001" =>
        temp_vector <= NOT_INST;
      when "000010" =>
        temp_vector <= NEG_INST;
      when "000011" =>
        temp_vector <= INC_INST;
      when "000100" =>
        temp_vector <= DEC_INST;
      when "000101" =>
        temp_vector <= OUT_INST;
      when "000110" =>
        temp_vector <= IN_INST;
      when "010000" =>
        temp_vector <= SWAP_INST;
      when "010001" =>
        temp_vector <= ADD_INST;
      when "010010" =>
        temp_vector <= ADDI_INST;
      when "010011" =>
        temp_vector <= SUB_INST;
      when "010100" =>
        temp_vector <= AND_INST;
      when "010101" =>
        temp_vector <= OR_INST;
      when "010110" =>
        temp_vector <= XOR_INST;
      when "010111" =>
        temp_vector <= CMP_INST;
      when "011000" =>
        temp_vector <= BITSET_INST;
      when "011001" =>
        temp_vector <= RCL_INST;
      when "011010" =>
        temp_vector <= RCR_INST;
      when "100000" =>
        temp_vector <= PUSH_INST;
      when "100001" =>
        temp_vector <= POP_INST;
      when "100010" =>
        temp_vector <= LDM_INST;
      when "100011" =>
        temp_vector <= LDD_INST;
      when "100100" =>
        temp_vector <= STD_INST;
      when "100101" =>
        temp_vector <= PROTECT_INST;
      when "100110" =>
        temp_vector <= FREE_INST;
      when "110000" =>
        temp_vector <= JZ_INST;
      when "110001" =>
        temp_vector <= JMP_INST;
      when "110010" =>
        temp_vector <= CALL_INST;
      when "110011" =>
        temp_vector <= RET_INST; 
      when "110100" =>
        temp_vector <= RTI_INST;
      when others =>
        temp_vector <= NOP_INST;
  end case;

  end process;

  AluOp    <= temp_vector(15 downto 12);
  ImmSrc    <= temp_vector(11);
  Branch    <= temp_vector(10);
  BranchIf0 <= temp_vector(9);
  MemRead   <= temp_vector(8);
  MemWrite  <= temp_vector(7);
  SpOp      <= temp_vector(6);
  protect   <= temp_vector(5);
  free      <= temp_vector(4);
  MemWb  <= temp_vector(3);
  RegWrite  <= temp_vector(2);
  PortWrite  <= temp_vector(1);
  PortWB  <= temp_vector(0);
end architecture Behavioral;