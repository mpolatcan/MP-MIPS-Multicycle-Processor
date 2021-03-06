# MP-MIPS Multicycle Processor

**MP-Mips** is a MIPS architecture-based processor which was developed with multicycle design techniques in Verilog-HDL.

## MP-MIPS Details

Data memory size: **2kb**	

Data memory each block size: **1 byte**		

Instruction memory size: **1kb**			

Instruction memory each block size: **1 byte**			

Number of instructions in instruction memory: **256 instructions** 

Number of words in data memory: **512 words**		

Number of registers: **32 registers**						                       


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

*Bonus Instructions added to I-Type Instructions*:

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

*Bonus Instructions added to R-Type Instructions*:

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

## Usage
* Copy files to same folder. (for example folder name is **MP-MIPS**)
* Open **ModelSim-ALTERA** and click **File** menu and click **Change Directory** option.
* Select our directory (in our example **MP-MIPS**)
* Click **Compile** menu and click **Compile** option.
* In pop-up menu double-click **mp_mips_multicyle_testbench.v** to compile it.
* Click yes for question which is "The library work doesn't exist.Do you want to create this library ?"
* Then click **Simulate** menu and click **Start Simulation** option.
* In pop-up menu find **work** libray and select **mpolatcan_mips_multicycle_testbench** under the **work** library.
* Then click again **Simulate** menu and click **Run** option then select **run -all** option.

**NOTE**: If you want to change data memory,registers or instructions memory you need to edit **register.h**, 
          **data_memory.h** and **instruction_memory.h** files.
          In these files all lines are **2 bits** in **hexadecimal** (**8 bits** in **binary**).
          One register, data memory cell or instruction memory cell consists of sequentially **4 rows**.Because register content,
          memory cell's content and instruction memory cell's content consist of 32 bit content.
          
          
          Proof --> 4 line x 2 bits in hexadecimal = 4 line x 8 bits in binary = 32 bit content
          
          For example register.h file like that:
          
          
              1  02
              2  03
              3  04
              4  01
              .. ...
              .. ...
              
              In there memory cell's content is 01040301.That's is can be a 32 bit register's content, data memory cell's 
              content or instruction memory cell's content.In there 01 is most significant 8 bits and 02 is least 
              significant 8 bits.Concatenation like that (Line_4 - Line_3 - Line_2 - Line_1) in code.
