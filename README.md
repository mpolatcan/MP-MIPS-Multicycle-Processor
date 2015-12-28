# MP-MIPS

MP-Mips is a 32-bit processor which was developed with multicycle design techniques in Verilog-HDL was developed by Mutlu Polatcan.

## MP-MIPS Details

Data memory size: 2kb											                                
Data memory each block size: 1 byte							                     	
Instruction memory size: 1kb								                           
Instruction memory each block size: 1 byte						                
Number of instructions in instruction memory: 256 instructions  
Number of words in data memory: 512 words						                 
Number of registers: 32 registers								                       

MP-Mips can execute instructions below:

## MP-MIPS INSTRUCTIONS 

### I-Type Instructions:

| OPCODE	|   NAME	 |                      OPERATION                         |
|:-------:|:--------:|:-------------------------------------------------------|
| 001000	|  ADDI    |   $rt <-- $rs + imm32 (signed)                         |
| 001001	|  ADDIU   |   $rt <-- $rs + imm32 (unsigned)                       |
| 001101	|  ORI     |   $rt <-- $rs | imm32                                  |
| 001100	|  ANDI    |   $rt <-- $rs & imm32                                  |
| 001110	|  XORI    |   $rt <-- $rs ^ imm32                                  |
| 001010	|  SLTI    |   $rt <-- ($rs < imm32) $rt = 1 else $rt = 0 (signed)  |
| 001011	|  SLTIU   |   $rt <-- ($rs < imm32) $rt = 1 else $rt = 0 (unsigned)|
| 001111	|  LUI     |   $rt <-- imm32 << 16                                  |

Bonus Instructions added to I-Type Instructions:

| OPCODE	|   NAME	 |                      OPERATION                         |
|:-------:|:--------:|:-------------------------------------------------------|
| 010111  |  SUBI    |   $rt <-- $rs - imm32 (signed)                         |
| 011100	|  SUBIU 	 |   $rt <-- $rs - imm32 (unsigned)                       |
| 100001	|  NORI 	 |   $rt <-- ~($rs | imm32)                               |
| 110011	|  XNORI 	 |   $rt <-- ~($rs ^ imm32)                               |
| 011101	|  NANDI 	 |   $rt <-- ~($rs & imm32)                               |


### R-Type Instructions:

| FUNC. FIELD |	  NAME   |	                      OPERATION                       |
|:-----------:|:--------:|:-------------------------------------------------------|
|   100000    |   ADD    |  $rd <-- $rs + $rt (signed)                            |
|   100010	  |	  SUB 	 |  $rd <-- $rs - $rt (signed)                            |
|   100100	  |	  AND    |  $rd <-- $rs & $rt                                     |
|   100101		|   OR     |  $rd <-- $rs | $rt                                     |
|   100110 		| 	XOR 	 |  $rd <-- $rs ^ $rt                                     |
|   000000		|   SLL 	 |  $rd <-- $rt << shamt;                                 |
|   000010	  |   SRL 	 |  $rd <-- $rt >> shamt;                                 |
|   000011		|   SRA 	 |  $rd <-- $rt >>> shamt;                                |
|   101010		|   SLT 	 |  $rd <-- ($rs < $rt) $rd = 1 else $rd = 0 (signed)     |
|   101011		|   SLTU   |  $rd <-- ($rs < $rt) $rd = 1 else $rd = 0 (unsigned)   |

Bonus Instructions added:

| FUNC. FIELD |	  NAME   |	                      OPERATION                       |
|:-----------:|:--------:|:-------------------------------------------------------|
|   100001		|  ADDU 	 |  $rd <-- $rs + $rt (unsigned)                          |
|   101111 		|  SUBU    |  $rd <-- $rs - $rt (unsigned)                          |
|   100111		|  NOR     |  $rd <-- ~($rs | $rt)                                  |
|   110000		|  XNOR 	 |  $rd <-- ~($rs ^ $rt)                                  |
|   101110	  |  NAND    |  $rd <-- ~($rs & $rt)                                  |


### Memory Instructions:

| OPCODE |	 NAME 	|               OPERATION                |
|:------:|:--------:|:---------------------------------------|
| 100011 |   LW  	  |   $rt <-- MEM[$rs + imm32]             |
| 100000 |	 LB 		|   $rt <-- MEM[$rs + imm32]             |
| 101011 |	 SW 		|   MEM[$rs + imm32] <-- $rt             |
| 101000 |	 SB 		|   MEM[$rs + imm32] <-- $rt             |

### Jump Instructions:

| OPCODE | 	 NAME	  |                           OPERATION                           |
|:------:|:--------:|:--------------------------------------------------------------|
| 000010 |		J 		|   PC <-- PC[31:28] | instruction[25:0] << 2                   |
| 000011 |	 	JAL	  |   $31 <-- PC + 4, PC <-- PC [31:28] | instruction[25:0] << 2  |
| 000000 |		JR    |   PC <-- $rs                                                  |
