const fs = require('fs');
const BITS_3 = '000';

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
const Regs = {
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
const inputFilePath = 'testCases/Branch.asm';
const inputFile = fs.readFileSync(inputFilePath, 'utf8').split('\n');

// Open the instructions memory file
const outputFilePath = 'instructionMem.txt';
const InstructionMemory = fs.createWriteStream(outputFilePath);

let imm = '';
let lineNumber = 0;

for (const line of inputFile) {
  if (line.trim().startsWith('#') || line.trim() === '') continue;
  const instructionArray = line.trim().split(/\s+/);
  const inst = instructionArray[0].toUpperCase();
  const operands = instructionArray
    .slice(1)
    .join('')
    .split('#')[0]
    .toUpperCase();

  let instBts = '';

  if (inst === '.ORG') {
    while (lineNumber < Number(operands - 1)) {
      InstructionMemory.write(
        BITS_3 + BITS_3 + BITS_3 + BITS_3 + BITS_3 + '0\n'
      );
      lineNumber++;
    }
    continue;
  }

  if (OneZeroOperand[inst]) {
    instBts += OneZeroOperand[inst];

    if (inst === 'NOP' || inst === 'RET' || inst === 'RTI') {
      instBts += BITS_3 + BITS_3;
    } else {
      if (!Regs[operands]) {
        console.log(`Syntax Error near ${inst}`);
        InstructionMemory.destroy();
        InstructionMemory.end();
        return;
      }
      if (inst === 'IN') {
        instBts += Regs[operands] + BITS_3;
      } else if (
        inst === 'NOT' ||
        inst === 'NEG' ||
        inst === 'INC' ||
        inst === 'DEC'
      ) {
        instBts += Regs[operands] + Regs[operands];
      } else {
        instBts += BITS_3 + Regs[operands];
      }
    }
    instBts += BITS_3;
  } else if (TwoOperands[inst]) {
    instBts += TwoOperands[inst];
    const [op1, op2, op3] = operands.split(',').map((op) => op.trim());
    if (!Regs[op1] || !op2 || !(!isNaN(Number(op2)) || Regs[op2])) {
      console.log(`Syntax Error near ${inst}`);
      return;
    }
    if (inst === 'SWAP') {
      if (op3) {
        console.log(`Syntax Error near ${inst}, takes only two operands`);
        return;
      }
      instBts += BITS_3 + Regs[op1] + Regs[op2];
    } else if (inst === 'BITSET') {
      if (op3) {
        console.log(`Syntax Error near ${inst}, takes only two operands`);
        return;
      }
      instBts += Regs[op1] + Regs[op1] + BITS_3;
      imm = op2;
    } else if (inst === 'CMP') {
      if (op3) {
        console.log(`Syntax Error near ${inst}, takes only two operands`);
        return;
      }
      instBts += BITS_3 + Regs[op1] + Regs[op2];
    } else if (inst === 'RCL' || inst === 'RCR') {
      if (op3) {
        console.log(`Syntax Error near ${inst}, takes only two operands`);
        return;
      }
      instBts += Regs[op1] + Regs[op1] + BITS_3;
      imm = op2;
    } else if (inst === 'ADDI') {
      instBts += Regs[op1] + Regs[op2] + BITS_3;
      imm = op3;
    } else {
      instBts += Regs[op1] + Regs[op2] + Regs[op3];
    }
  } else if (MemoryInstructions[inst]) {
    instBts += MemoryInstructions[inst];
    const [op1, op2] = operands.split(',').map((op) => op.trim());
    if (!Regs[op1]) {
      console.log(`Syntax Error near ${inst}`);
      console.log(inst, op1, op2);
      InstructionMemory.destroy();
      InstructionMemory.end();
      return;
    }
    if (inst === 'POP') {
      instBts += Regs[op1] + BITS_3;
    } else if (inst === 'LDM' || inst === 'LDD') {
      instBts += Regs[op1] + BITS_3;
      imm = op2;
    } else if (inst === 'STD') {
      instBts += BITS_3 + Regs[op1];
      imm = op2;
    } else {
      instBts += BITS_3 + Regs[op1];
    }
    instBts += BITS_3;
  }

  if (!instBts) {
    console.log(`unknown instruction ${inst}`);
    InstructionMemory.destroy();
    InstructionMemory.end();
    return;
  }
  instBts += imm ? '1' : '0';
  InstructionMemory.write(instBts + '\n');
  lineNumber++;

  if (imm) {
    let immVal = '';
    // if (/^0x/i.test(imm)) {
      immVal += parseInt(imm, 16).toString(2).padStart(16, '0');
    // } else {
    // immVal += parseInt(imm).toString(2).padStart(16, '0');
    // }
    InstructionMemory.write(immVal + '\n');
    lineNumber++;
    imm = '';
  }
}

InstructionMemory.end();
