library ieee;
use ieee.std_logic_1164.all;

entity CU is
  generic (
    OUTPUT_WIDTH : integer := 17
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
    PortWB  : out std_logic;
    PcWrite  : out std_logic
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

--  AluOp | ImmSrc | Branch | Branch zero | MemRead | MemWrite | SP-Op | Protect | Free | MemWB | RegWrite | PcWrite

  -- ALU Operations
  variable NOT_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00010000000001000";
  variable NEG_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00100000000001000";
  variable DEC_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "01000000000001000";
  variable INC_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00110000000001000";
  variable OR_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0)  := "10100000000001000";
  variable ADD_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "01110000000001000";
  variable ADDI_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0):= "01111000000001000";
  variable SUB_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "10000000000001000";
  variable AND_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "10010000000001000";
  variable XOR_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "10110000000001000";
  variable CMP_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "10000000000000000";
  variable RCL_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "11101000000001000";
  variable RCR_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "11111000000001000";
  variable BITSET_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "11011000000001000";
  
  -- SP Operations
  variable PUSH_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0):= "00000000110000001";
  variable POP_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00000001010011001";

  -- Memory Operations
  variable LDM_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "01011000000001000";
  variable LDD_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00001001000011000";
  variable STD_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00001000100000000";
  variable FREE_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00000000100100000";
  variable PROTECT_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00000000101000000";

  -- Branch Opertions
  variable JMP_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00000100000000000";
  variable JZ_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00000010000000000";

  --**************************** NOT SURE ENOUGH ********************************
  -- CALL = PUSH + JMP
  variable CALL_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00000100110000001";
  variable RET_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00000101010000001";
  -- RTI = 2 x POP 
  variable RTI_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00000101010000001";

  variable OUT_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00000000000000100";
  variable IN_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00000000000001010";

  variable SWAP_INST: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := "00000000000000000";

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

  AluOp    <= temp_vector(16 downto 13);
  ImmSrc    <= temp_vector(12);
  Branch    <= temp_vector(11);
  BranchIf0 <= temp_vector(10);
  MemRead   <= temp_vector(9);
  MemWrite  <= temp_vector(8);
  SpOp      <= temp_vector(7);
  protect   <= temp_vector(6);
  free      <= temp_vector(5);
  MemWb  <= temp_vector(4);
  RegWrite  <= temp_vector(3);
  PortWrite  <= temp_vector(2);
  PortWB  <= temp_vector(1);
  PcWrite <= temp_vector(0);
end architecture Behavioral;