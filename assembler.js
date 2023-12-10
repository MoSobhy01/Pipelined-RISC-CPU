// No operand instructions
const OneZeroOperand = {
  NOP: '000000',
  NOT: '000001',
  NEG: '000010',
  INC: '000011',
  DEC: '000100',
  OUT: '000101',
  IN: '000110',
  JZ: '110000',
  JMP: '110001',
  CALL: '110010',
  RET: '110011',
  RTI: '110100',
};

// Two operand instructions
const TwoOperands = {
  SWAP: '010000',
  ADD: '010001',
  ADDI: '010010',
  SUB: '010011',
  AND: '010100',
  OR: '010101',
  XOR: '010110',
  CMP: '010111',
  BITSET: '011000',
  RCL: '011001',
  RCR: '011010',
};

// One operand instructions
const MemoryInstructions = {
  PUSH: '100000',
  POP: '100001',
  LDM: '100010',
  LDD: '100011',
  STD: '100100',
  PROTECT: '100101',
  FREE: '100110',
};

// registers
const Registers = {
  R0: '000',
  R1: '001',
  R2: '010',
  R3: '011',
  R4: '100',
  R5: '101',
  R6: '110',
  R7: '111',
};

// Open the input file
const fs = require('fs');
const inputFilePath = 'code.asm';
const inputFile = fs.readFileSync(inputFilePath, 'utf8').split('\n');

// Open the instructions memory file
const outputFilePath = 'instructionMem.txt';
const InstructionMemory = fs.createWriteStream(outputFilePath);

let imm = '';

for (const line of inputFile) {
  const instructionArray = line.trim().split(/\s+/);
  const inst = instructionArray[0].toUpperCase();
  const operands = instructionArray.slice(1).join(',').toUpperCase();

  let instBts = '';

  if (OneZeroOperand[inst]) {
    instBts += OneZeroOperand[inst];
    if (inst === 'NOP' || inst === 'RET' || inst === 'RTI') {
      instBts += '0000000000';
    } else {
      instBts += Registers[operands];
      instBts += '0000000';
    }
  } else if (TwoOperands[inst]) {
    instBts += TwoOperands[inst];
    const [op1, op2, op3] = operands.split(',').map((op) => op.trim());
    if (inst === 'SWAP') {
      instBts += Registers[op2];
      instBts += Registers[op1];
      instBts += '0000';
    } else if (inst === 'BITSET') {
      instBts += Registers[op1];
      instBts += '0000001';
      imm = op2;
    } else if (inst === 'CMP') {
      instBts += '000';
      instBts += Registers[op1];
      instBts += Registers[op2];
      instBts += '0';
    } else if (inst === 'RCL' || inst === 'RCR') {
      instBts += '000';
      instBts += Registers[op1];
      instBts += '0001';
      imm = op2;
    } else {
      instBts += Registers[op1];
      instBts += Registers[op2];
      instBts += Registers[op3];
      instBts += '0';
    }
  } else if (MemoryInstructions[inst]) {
    instBts += MemoryInstructions[inst];
    const [op1, op2] = operands.split(',').map((op) => op.trim());
    if (inst === 'POP') {
      instBts += Registers[op1];
      instBts += '0000000';
    } else if (inst === 'LDM' || inst === 'LDD') {
      instBts += Registers[op1];
      instBts += '0000001';
      imm = op2;
    } else if (inst === 'STD') {
      instBts += '000';
      instBts += Registers[op1];
      instBts += '0000001';
      imm = op2;
    } else {
      instBts += '000';
      instBts += Registers[op1];
      instBts += '0000';
    }
  }
  if (imm) {
    if (/^0x/i.test(imm)) {
      instBts += parseInt(imm, 16).toString(2).padStart(16, '0');
    } else {
      instBts += parseInt(imm).toString(2).padStart(16, '0');
    }
    imm = '';
  }

  if (instBts !== '') {
    InstructionMemory.write(instBts + '\n');
  }
}

InstructionMemory.end();
