/* Mutlu POLATCAN - 121044062 */
`define WRONG_INST 4'bxxxx
`define UNKNOWN_INST 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// <----------------------- I-TYPE INSTRUCTIONS --------------------------->
`define ADDIU_OPCODE 6'b001001 
`define SUBIU_OPCODE 6'b011100
`define ADDI_OPCODE 6'b001000
`define SUBI_OPCODE 6'b010111
`define ORI_OPCODE 6'b001101
`define NORI_OPCODE 6'b100001
`define SLTI_OPCODE 6'b001010
`define ANDI_OPCODE 6'b001100
`define NANDI_OPCODE 6'b011101
`define LUI_OPCODE 6'b001111
`define XORI_OPCODE 6'b001110
`define XNORI_OPCODE 6'b110011
`define SLTIU_OPCODE 6'b001011
// <----------------------- MEMORY INSTRUCTIONS -------------------------->
`define LW_OPCODE 6'b100011
`define LB_OPCODE 6'b100000
`define SW_OPCODE 6'b101011
`define SB_OPCODE 6'b101000
// <----------------------- JUMP INSTRUCTIONS ---------------------------->
`define J_OPCODE 6'b000010
`define JAL_OPCODE 6'b000011
`define JR_FUNC_FIELD 6'b001000
// <---------------------- BRANCH INSTRUCTIONS --------------------------->
`define BEQ_OPCODE 6'b000100
`define BNE_OPCODE 6'b000101
// <---------------------- R-TYPE INSTRUCTIONS --------------------------->
`define RTYPE_OPCODE 6'b000000
`define ADD_FUNC_FIELD 6'b100000
`define ADDU_FUNC_FIELD 6'b100001
`define SUB_FUNC_FIELD 6'b100010
`define SUBU_FUNC_FIELD 6'b101111
`define AND_FUNC_FIELD 6'b100100
`define NAND_FUNC_FIELD 6'b101110
`define SLTU_FUNC_FIELD 6'b101011
`define SLT_FUNC_FIELD 6'b101010
`define OR_FUNC_FIELD 6'b100101
`define XOR_FUNC_FIELD 6'b100110
`define NOR_FUNC_FIELD 6'b100111
`define XNOR_FUNC_FIELD 6'b110000
`define SRL_FUNC_FIELD 6'b000010
`define SLL_FUNC_FIELD 6'b000000
`define SRA_FUNC_FIELD 6'b000011
// <----------------------------------------------------------------------->

module mpolatcan_mips_multicycle_testbench();
	reg	regDst, byteIns, linkIns, iTypeIns,
		notEqIns, aluSrcA, regWrite, pcWrite, 
		pcWriteCond, iOrD, memRead, 
		memWrite, memToReg, irWrite;
	reg [1:0] aluSrcB, pcSource;
	reg [31:0] instruction_reg, mem_data_reg, rs_content, 
			   rt_content, mutable_rt_content, mutable_rs_content;
	reg [7:0] instruction_memory[1023:0];
	reg [7:0] data_memory[2047:0];
	reg [7:0] registers[127:0];
	reg [31:0] PC, jumpAddress, linkedPC;
	wire [31:0] extendedImm16, result;
	wire [4:0] operation;
 	
	initial begin
		$readmemh("instruction_memory.h", instruction_memory);
		$readmemh("data_memory.h", data_memory);
		$readmemh("registers.h", registers);
		PC = 0; 
	end

	always @(PC) begin
		memRead = 1;
		aluSrcA = 0;
		iOrD = 0;
		irWrite = 1;
		aluSrcB = 2'b01;
		pcWrite = 1;
		pcSource = 2'b00;
		regDst = 1'b0;
		pcWriteCond = 1'b0;
		regWrite = 1'b0;
		memWrite = 1'b0;
		memToReg = 1'b0;
		iTypeIns = 1'b0;
		byteIns = 1'b0;
		linkIns = 1'b0;
		notEqIns = 1'b0;
		$display("\n------------------------------------------------------------------------------\n");
		$display("\n<--------------IF STATE -------------->");
		$display("PC: %d", PC[9:0]);
		$display("Signals generated... --> MemRead: %b, AluSrcA: %b, IOrD: %b, IRWrite: %b, AluSrcB: %b, PCWrite: %b, PCSource: %b", 
			memRead, aluSrcA, iOrD, irWrite, aluSrcB, pcWrite, pcSource);
	end

	always @(iOrD or PC) begin
		if (!iOrD && irWrite)
			instruction_reg = {instruction_memory[PC[9:0]+3], instruction_memory[PC[9:0]+2], instruction_memory[PC[9:0]+1], instruction_memory[PC[9:0]]};

		if (instruction_reg !== `UNKNOWN_INST && !iOrD) begin
			$display("Instruction fetched... --> Instruction: %32b - %h", instruction_reg, instruction_reg);
			$display("<------------------------------------->\n");
		end
	end

	always @(instruction_reg or PC or pcSource) begin
		aluSrcA = 0;
		aluSrcB = 2'b11;
		
		if (instruction_reg !== `UNKNOWN_INST) begin
			$display("\n<--------------ID STATE -------------->");
			$display("Signals generated... --> AluSrcA: %b, AluSrcB: %b", aluSrcA, aluSrcB);
		end
			
		if (instruction_reg[31:26] === `LW_OPCODE || instruction_reg[31:26] === `SW_OPCODE ||
			instruction_reg[31:26] === `LB_OPCODE || instruction_reg[31:26] === `SB_OPCODE) begin 
			aluSrcA = 1;
			aluSrcB = 2'b10;

			if (instruction_reg[31:26] === `LW_OPCODE || instruction_reg[31:26] === `LB_OPCODE) begin
				memRead = 1;
				iOrD = 1;	
				regDst = 0;
				regWrite = 1;
				memToReg = 1;
				if (instruction_reg[31:26] === `LB_OPCODE) begin
					byteIns = 1;
					$display("Instruction decoded... --> Instruction Type: LB");
				end else
					$display("Instruction decoded... --> Instruction Type: LW");
			end else if (instruction_reg[31:26] === `SW_OPCODE || instruction_reg[31:26] === `SB_OPCODE) begin
				memWrite = 1;
				iOrD = 1;
				if (instruction_reg[31:26] === `SB_OPCODE) begin
					byteIns = 1;
					$display("Instruction decoded... --> Instruction Type: SB");
				end else
					$display("Instruction decoded... --> Instruction Type: SW");
			end
		end else if (instruction_reg[31:26] === `RTYPE_OPCODE) begin
			aluSrcA = 1;
			aluSrcB = 2'b00;
			if (instruction_reg[5:0] === `JR_FUNC_FIELD) begin
				pcWrite = 1;
				pcSource = 2'b01;
			end else begin
				regDst = 1;
				regWrite = 1;
				memToReg = 0;
			end
			$display("Instruction decoded... --> Instruction Type: RTYPE");
		end else if (instruction_reg[31:26] === `ADDI_OPCODE || instruction_reg[31:26] === `ADDIU_OPCODE || 
					instruction_reg[31:26] === `ORI_OPCODE || instruction_reg[31:26] === `SLTI_OPCODE || 
					instruction_reg[31:26] === `ANDI_OPCODE || instruction_reg[31:26] === `LUI_OPCODE ||
					instruction_reg[31:26] === `XORI_OPCODE || instruction_reg[31:26] === `SLTIU_OPCODE ||
					instruction_reg[31:26] === `NORI_OPCODE || instruction_reg[31:26] === `XNORI_OPCODE ||
					instruction_reg[31:26] === `SUBIU_OPCODE || instruction_reg[31:26] === `NANDI_OPCODE ||
					instruction_reg[31:26] === `SUBI_OPCODE) begin
			regDst = 0;
			regWrite = 1;
			aluSrcA = 1;
			aluSrcB = 2'b10;
			iTypeIns = 1;	
			$display("Instruction decoded... --> Instruction Type: ITYPE");			 	
		end else if (instruction_reg[31:26] === `BEQ_OPCODE || instruction_reg[31:26] === `BNE_OPCODE) begin
			aluSrcA = 1;
			aluSrcB = 2'b00;
			pcWriteCond = 1;
			pcSource = 2'b01;
			if (instruction_reg[31:26] === `BNE_OPCODE)
				notEqIns = 1;
			$display("Instruction decoded... --> Instruction Type: BRANCH");			 	
		end else if (instruction_reg[31:26] === `J_OPCODE || instruction_reg[31:26] === `JAL_OPCODE) begin
			pcWrite = 1;
			pcSource = 2'b10;
			if (instruction_reg[31:26] === `JAL_OPCODE)
				linkIns = 1;
			$display("Instruction decoded... --> Instruction Type: J");			 	
		end
		
		if (pcWriteCond || pcSource !== 2'b10) begin
			case (instruction_reg[25:21])
				5'b00000: rs_content = { registers[3], registers[2], registers[1], registers[0] };
				5'b00010: rs_content = { registers[11], registers[10], registers[9], registers[8] };
				5'b00011: rs_content = { registers[15], registers[14], registers[13], registers[12] };
				5'b00100: rs_content = { registers[19], registers[18], registers[17], registers[16] };
				5'b00101: rs_content = { registers[23], registers[22], registers[21], registers[20] };	
				5'b00110: rs_content = { registers[27], registers[26], registers[25], registers[24] };
				5'b00111: rs_content = { registers[31], registers[30], registers[29], registers[28] };
				5'b01000: rs_content = { registers[35], registers[34], registers[33], registers[32] };
				5'b01001: rs_content = { registers[39], registers[38], registers[37], registers[36] };
				5'b01010: rs_content = { registers[43], registers[42], registers[41], registers[40] };
				5'b01011: rs_content = { registers[47], registers[46], registers[45], registers[44] };
				5'b01100: rs_content = { registers[51], registers[50], registers[49], registers[48] };
				5'b01101: rs_content = { registers[55], registers[54], registers[53], registers[52] };
				5'b01110: rs_content = { registers[59], registers[58], registers[57], registers[56] };
				5'b01111: rs_content = { registers[63], registers[62], registers[61], registers[60] };
				5'b10000: rs_content = { registers[67], registers[66], registers[65], registers[64] };
				5'b10001: rs_content = { registers[71], registers[70], registers[69], registers[68] };
				5'b10010: rs_content = { registers[75], registers[74], registers[73], registers[72] };
				5'b10011: rs_content = { registers[79], registers[78], registers[77], registers[76] };
				5'b10100: rs_content = { registers[83], registers[82], registers[81], registers[80] };
				5'b10101: rs_content = { registers[87], registers[86], registers[85], registers[84] };
				5'b10110: rs_content = { registers[91], registers[90], registers[89], registers[88] };
				5'b10111: rs_content = { registers[95], registers[94], registers[93], registers[92] };
				5'b11000: rs_content = { registers[99], registers[98], registers[97], registers[96] };
				5'b11001: rs_content = { registers[103], registers[102], registers[101], registers[100] };
				5'b11100: rs_content = { registers[115], registers[114], registers[113], registers[112] };
				5'b11101: rs_content = { registers[119], registers[118], registers[117], registers[116] };
				5'b11110: rs_content = { registers[123], registers[122], registers[121], registers[120] };
				5'b11111: rs_content = { registers[127], registers[126], registers[125], registers[124] };
			endcase

			// take rt_content
			case (instruction_reg[20:16])
				5'b00000: rt_content = { registers[3], registers[2], registers[1], registers[0] };
				5'b00010: rt_content = { registers[11], registers[10], registers[9], registers[8] };
				5'b00011: rt_content = { registers[15], registers[14], registers[13], registers[12] };
				5'b00100: rt_content = { registers[19], registers[18], registers[17], registers[16] };
				5'b00101: rt_content = { registers[23], registers[22], registers[21], registers[20] };	
				5'b00110: rt_content = { registers[27], registers[26], registers[25], registers[24] };
				5'b00111: rt_content = { registers[31], registers[30], registers[29], registers[28] };
				5'b01000: rt_content = { registers[35], registers[34], registers[33], registers[32] };
				5'b01001: rt_content = { registers[39], registers[38], registers[37], registers[36] };
				5'b01010: rt_content = { registers[43], registers[42], registers[41], registers[40] };
				5'b01011: rt_content = { registers[47], registers[46], registers[45], registers[44] };
				5'b01100: rt_content = { registers[51], registers[50], registers[49], registers[48] };
				5'b01101: rt_content = { registers[55], registers[54], registers[53], registers[52] };
				5'b01110: rt_content = { registers[59], registers[58], registers[57], registers[56] };
				5'b01111: rt_content = { registers[63], registers[62], registers[61], registers[60] };
				5'b10000: rt_content = { registers[67], registers[66], registers[65], registers[64] };
				5'b10001: rt_content = { registers[71], registers[70], registers[69], registers[68] };
				5'b10010: rt_content = { registers[75], registers[74], registers[73], registers[72] };
				5'b10011: rt_content = { registers[79], registers[78], registers[77], registers[76] };
				5'b10100: rt_content = { registers[83], registers[82], registers[81], registers[80] };
				5'b10101: rt_content = { registers[87], registers[86], registers[85], registers[84] };
				5'b10110: rt_content = { registers[91], registers[90], registers[89], registers[88] };
				5'b10111: rt_content = { registers[95], registers[94], registers[93], registers[92] };
				5'b11000: rt_content = { registers[99], registers[98], registers[97], registers[96] };
				5'b11001: rt_content = { registers[103], registers[102], registers[101], registers[100] };
				5'b11100: rt_content = { registers[115], registers[114], registers[113], registers[112] };
				5'b11101: rt_content = { registers[119], registers[118], registers[117], registers[116] };
				5'b11110: rt_content = { registers[123], registers[122], registers[121], registers[120] };
				5'b11111: rt_content = { registers[127], registers[126], registers[125], registers[124] };
			endcase
		end

		if (pcSource !== 2'b10 && instruction_reg !== `UNKNOWN_INST) begin 
			if (instruction_reg[25:21] === 5'b00001 || instruction_reg[25:21] === 5'b11010 || instruction_reg[25:21] === 5'b11011) begin
				$display("You can't read register-%d's content (used by assembler or operating system)!", instruction_reg[25:21]);
				$display("So instruction_reg can't executed!");
			end else
				$display("Fetching rs register's content... -> Rs Content: %b", rs_content);

			if (instruction_reg[20:16] === 5'b00001 || instruction_reg[20:16] === 5'b11010 || instruction_reg[20:16] === 5'b11011) begin
				$display("You can't read register-%d's content (used by assembler or operating system)", instruction_reg[20:16]);
				$display("So instruction can't executed!");
			end else 
				$display("Fetching rt register's content... -> Rt Content: %b", rt_content);
		end
	end

	alu_control getOperation(instruction_reg[5:0], instruction_reg[31:26], iTypeIns, operation);
	sign_extender extender(instruction_reg[15:0], extendedImm16); // for I-type instructions save extended immed

	always @(aluSrcA or aluSrcB or PC or extendedImm16 or pcSource) begin
		if (pcSource !== 2'b10) begin
			if (aluSrcA)
				mutable_rs_content = rs_content;
			else
				mutable_rs_content = PC;

			if (aluSrcB === 2'b00) 
				mutable_rt_content = rt_content;
			else if (aluSrcB === 2'b10)
				mutable_rt_content = extendedImm16;
			else if (aluSrcB === 2'b11)
				mutable_rt_content = extendedImm16 << 2;

			if (operation !== `WRONG_INST) begin
				#5;
				$display("<------------------------------------->\n");
				$display("\n<----------- ALU's DATAS ---------->");
				if (aluSrcA)
					$display("ALU DATA A: %b (Content of rs register)", mutable_rs_content);
				else
					$display("ALU DATA A: %b (PC Value)", mutable_rs_content);

				if (aluSrcB === 2'b00) 
					$display("ALU DATA B: %b (Content of rt register)", mutable_rt_content);
				else if (aluSrcB === 2'b10)
					$display("ALU DATA B: %b (immediate field which is extended to 32 bit)", mutable_rt_content);
				$display("<--------------------------------->\n");
			end
		end
	end

	alu execInst(mutable_rs_content, mutable_rt_content, operation, instruction_reg[10:6], result);

	always @(regWrite or regDst or result or operation or memWrite or 
			 memRead or memToReg or iOrD or pcWrite or pcSource or pcWriteCond) begin
		#20;
		if (regWrite && (result !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) && operation !== `WRONG_INST) begin
			$display("\n<----------- MEM/WB STATE ----------->");
			if (regDst) begin
				if (instruction_reg[15:11] === 5'b00000 || instruction_reg[15:11] === 5'b00001 ||
					instruction_reg[15:11] === 5'b11010 || instruction_reg[15:11] === 5'b11011)
					$display("You can't write to register-%d (used by assembler or operating system or $zero register) !!!! ", instruction_reg[15:11]);
				else begin
					$display("Writing to rd register... ---> Address of rd register (in decimal): %d", instruction_reg[15:11]);
					$display("Writing to register.h file... ---> Line numbers of rd register in register.h: between %d and %d lines", instruction_reg[15:11]*4+4,
						instruction_reg[15:11]*4+7);
					registers[(instruction_reg[15:11]*4)] = result[7:0];
					registers[(instruction_reg[15:11]*4)+1] = result[15:8];
					registers[(instruction_reg[15:11]*4)+2] = result[23:16];
					registers[(instruction_reg[15:11]*4)+3] = result[31:24];
				end
			end else if (iOrD && memRead && memToReg) begin
				if (instruction_reg[20:16] === 5'b00000 || instruction_reg[20:16] === 5'b00001 ||
					instruction_reg[20:16] === 5'b11010 || instruction_reg[20:16] === 5'b11011)
					$display("You can't write to register-%d (used by assembler or operating system or $zero register) !!!!", instruction_reg[20:16]);
				else begin
					if (byteIns) begin
						$display("Loading byte which is at %b address in memory to register, %d line in file", result[10:0], result[10:0]+4);
						mem_data_reg = data_memory[result[10:0]];
						registers[(instruction_reg[20:16]*4)] = mem_data_reg;
						$display("Byte loaded from data memory to rt register... -> Byte %b, %d line in file", 
							registers[instruction_reg[20:16]*4], instruction_reg[20:16]*4+4);
					end else begin
						$display("Loading word which is at %b address in memory to register, between %d and %d lines in file", result[10:0], result[10:0]+4, result[10:0]+7);
						mem_data_reg = { data_memory[result[10:0] + 3], data_memory[result[10:0] + 2], data_memory[result[10:0] + 1], data_memory[result[10:0]] };
						registers[(instruction_reg[20:16]*4)+3] = mem_data_reg[31:24];
						registers[(instruction_reg[20:16]*4)+2] = mem_data_reg[23:16];
						registers[(instruction_reg[20:16]*4)+1] = mem_data_reg[15:8];
						registers[(instruction_reg[20:16]*4)] = mem_data_reg[7:0];
						$display("Word loaded from data memory to rt register... -> Word: %b, between %d and %d lines in file", 
							{ registers[(instruction_reg[20:16]*4)+3], registers[(instruction_reg[20:16]*4)+2], 
							  registers[(instruction_reg[20:16]*4)+1], registers[(instruction_reg[20:16]*4)]},
							  instruction_reg[20:16]*4+4, instruction_reg[20:16]*4+7);
					end
				end
			end else begin
				if (instruction_reg[20:16] === 5'b00000 || instruction_reg[20:16] === 5'b00001 ||
					instruction_reg[20:16] === 5'b11010 || instruction_reg[20:16] === 5'b11011)
					$display("You can't write to register-%d (used by assembler or operating system or $zero register) !!!!", instruction_reg[20:16]);
				else begin
					$display("Writing to rt register... ---> Address of rt register (in decimal): %d", instruction_reg[20:16]);
					$display("Writing to register.h file... ---> Lines number of rt register in register.h: between %d and %d lines in file", 
						instruction_reg[20:16]*4+4, instruction_reg[20:16]*4+7);
					registers[(instruction_reg[20:16]*4)] = result[7:0];
					registers[(instruction_reg[20:16]*4)+1] = result[15:8];
					registers[(instruction_reg[20:16]*4)+2] = result[23:16];
					registers[(instruction_reg[20:16]*4)+3] = result[31:24];
				end
			end
			$display("<------------------------------------>\n");
		end else if (iOrD && memWrite) begin
			$display("\n<----------- MEM/WB STATE ----------->");
			if (instruction_reg[20:16] === 5'b00001 || instruction_reg[20:16] === 5'b11010 || instruction_reg[20:16] === 5'b11011) begin
				$display("You can't read register-%d's content (used by assembler or operating system)", instruction_reg[20:16]);
				$display("So instruction can't executed!");
			end else begin
				if (byteIns) begin
					$display("Storing byte which is at %b address in register to memory, %d line in file", instruction_reg[20:16], instruction_reg[20:16]*4+4);
					data_memory[result[10:0]] = registers[(instruction_reg[20:16]*4)];
					$display("Byte stored from register to memory... -> Byte: %b, %d line in file", data_memory[result[10:0]], result[10:0]*4+4);
				end else begin
					$display("Storing word which is at %b address in register to memory, between %d and %d lines in file", instruction_reg[20:16], instruction_reg[20:16]*4+4, 
						instruction_reg[20:16]*4+7);
					data_memory[result[10:0]] = registers[(instruction_reg[20:16]*4)];	
					data_memory[result[10:0]+1] = registers[(instruction_reg[20:16]*4)+1];
					data_memory[result[10:0]+2] = registers[(instruction_reg[20:16]*4)+2];
					data_memory[result[10:0]+3] = registers[(instruction_reg[20:16]*4)+3];
					$display("Word stored from register to memory... -> Word: %b, between %d and %d lines in file",  
						{ data_memory[result[10:0]+3], data_memory[result[10:0]+2], data_memory[result[10:0]+1], data_memory[result[10:0]] }, 
						  result[10:0]+4, result[10:0]+7);
				end
			end
			$display("<------------------------------------>\n");
		end else if (pcWrite && pcSource === 2'b10) begin
			if (linkIns) begin
				linkedPC = PC + 4;
				$display("<-------------------------------->\n");
				$display("Linking PC: %d to 31. register in, between 124 and 127 lines in file", linkedPC[9:0]);
				registers[124] = linkedPC[7:0];
				registers[125] = linkedPC[15:8];
				registers[126] = linkedPC[23:16];
				registers[127] = linkedPC[31:24];
			end

			jumpAddress = { PC[31:28], (instruction_reg[25:0] << 2) };
			
			$display("Jumping from PC: %d to target adress: %d....", PC[9:0], jumpAddress[9:0]);

			if ((jumpAddress[9:0]) >= 1020)
				$stop(0);
			
			#50 PC = jumpAddress;

			$display("Jump completed... -> Current PC: %d", PC[9:0]);
			$display("\n------------------------------------------------------------------------------\n");
		end else if (pcWrite && pcWriteCond && pcSource === 2'b01) begin
			if (notEqIns) begin
				if (result !== 32'b00000000000000000000000000000000) begin
					$display("Rs register's content and Rt register's content are not equal!");
					#50 PC = PC + (extendedImm16 << 2);
					$display("We will jump to PC: %d...", PC[9:0]);
				end else begin 
					$display("Rs register's content and Rt register's content are equal!");
					#50 PC = PC + 4;
					$display("We will continue from next PC: %d", PC[9:0]);
				end
			end else begin
				if (result === 32'b00000000000000000000000000000000) begin
					$display("Rs register's content and Rt register's content are equal!");
					#50 PC = PC + (extendedImm16 << 2);
					$display("We will jump to PC: %d...", PC[9:0]);
				end else begin 
					$display("Rs register's content and Rt register's content are not equal!");
					#50 PC = PC + 4;
					$display("We will continue from next PC: %d", PC[9:0]);
				end
			end
		end else if (pcWrite && pcSource === 2'b01) begin

			$display("Jumping from PC: %d to target adress which is in register: %d...., between %d and %d lines in file", 
				PC[9:0], result[9:0], instruction_reg[25:21]*4+4, instruction_reg[25:21]*4+7);

			if ((result[9:0]) >= 1020)
				$stop(0);

			#50 PC = result;

			$display("Jump completed... -> Current PC: %d", PC[9:0]);
			$display("\n------------------------------------------------------------------------------\n");
		end else begin
			$display("\nInstruction can't be executed! Because it is wrong instruction!!!");
			$display("<------------------------------------>\n");
		end
		
		if ((PC[9:0]) >= 1020)
			$stop(0);

		if (!pcWriteCond && pcSource !== 2'b01 && pcSource !== 2'b10)
			#50 PC = PC + 4;

		if (pcSource !== 2'b10 && pcSource !== 2'b01)
			$display("\n------------------------------------------------------------------------------\n");

		$writememh("registers.h", registers);
		$writememh("data_memory.h", data_memory);		
	end
endmodule

module alu_control(functionField, opcode, iTypeIns, operation);
	input iTypeIns;
	input [5:0] opcode, functionField;
	output reg [4:0] operation;

	always @(functionField or opcode or iTypeIns) begin
		if (iTypeIns !== 1'bx) begin
			if (iTypeIns) begin 
				if (opcode === `ADDI_OPCODE) begin
					$display("Instruction name: ADDI");
					operation = 5'b01000;
				end else if (opcode === `SUBI_OPCODE) begin
					$display("Instruction name: SUBI");
					operation = 5'b11000;
				end else if (opcode === `ADDIU_OPCODE) begin 
					$display("Instruction name: ADDIU");
					operation = 5'b01110;
				end else if (opcode === `SUBIU_OPCODE) begin
					$display("Instruction name: SUBIU");
					operation = 5'b11100;
				end else if (opcode === `ORI_OPCODE) begin  
					$display("Instruction name: ORI");
					operation = 5'b00010;
				end else if (opcode === `NORI_OPCODE) begin
					$display("Instruction name: NORI");
					operation = 5'b00110;
				end else if (opcode === `SLTI_OPCODE) begin
					$display("Instruction name: SLTI");
					operation = 5'b11110;
				end else if (opcode === `SLTIU_OPCODE) begin
					$display("Instruction name: SLTIU");
					operation = 5'b10110;
				end else if (opcode === `ANDI_OPCODE) begin
					$display("Instruction name: ANDI");
					operation = 5'b00000;
				end else if (opcode === `LUI_OPCODE) begin
					$display("Instruction name: LUI");
					operation = 5'b10100;
				end else if (opcode === `XORI_OPCODE) begin
					$display("Instruction name: XORI");
					operation = 5'b00100;
				end else if (opcode === `XNORI_OPCODE) begin
					$display("Instruction name: XNORI");
					operation = 5'b01010;
				end else if (opcode === `NANDI_OPCODE) begin
					$display("Instruction name: NANDI");
					operation = 5'b11101;
				end else 
					operation = `WRONG_INST;
			end else if (opcode === `LW_OPCODE || opcode === `LB_OPCODE ||
						 opcode === `SW_OPCODE || opcode === `SB_OPCODE) begin
				if (opcode === `LW_OPCODE) 
					$display("Instruction name: LW");
				else if (opcode === `LB_OPCODE)
					$display("Instruction name: LB");
				else if (opcode === `SW_OPCODE)
					$display("Instruction name: SW");
				else if (opcode === `SB_OPCODE)
					$display("Instruction name: SB");
				operation = 5'b01110;
			end else if (opcode === `J_OPCODE) begin
				$display("Instruction name: J");
			end else if (opcode === `JAL_OPCODE) begin
				$display("Instruction name: JAL");
			end else if (opcode === `BEQ_OPCODE || opcode === `BNE_OPCODE) begin
				if (opcode === `BEQ_OPCODE)
					$display("Instruction name: BEQ");
				else if (opcode === `BNE_OPCODE)
					$display("Instruction name: BNE");
				operation = 5'b11000;
			end else begin
				if (functionField === `ADD_FUNC_FIELD) begin
					$display("Instruction name: ADD");
					operation = 5'b01000;
				end else if (functionField === `SUB_FUNC_FIELD) begin
					$display("Instruction name: SUB");
					operation = 5'b11000;
				end else if (functionField === `AND_FUNC_FIELD)	 begin
					$display("Instruction name: AND");
					operation = 5'b00000;
				end else if (functionField === `OR_FUNC_FIELD) begin 
					$display("Instruction name: OR");
					operation = 5'b00010;
				end else if (functionField === `SLTU_FUNC_FIELD) begin
					$display("Instruction name: SLTU");
					operation = 5'b10110;
				end else if (functionField === `SLL_FUNC_FIELD) begin
					$display("Instruction name: SLL");
					operation = 5'b01100;
				end else if (functionField === `SLT_FUNC_FIELD) begin 
					$display("Instruction name: SLT");
					operation = 5'b11110;
				end else if (functionField === `SRL_FUNC_FIELD) begin
					$display("Instruction name: SRL");
					operation = 5'b10000;
				end else if (functionField === `SRA_FUNC_FIELD) begin
					$display("Instruction name: SRA");
					operation = 5'b10010;
				end else if (functionField === `XOR_FUNC_FIELD) begin
					$display("Instruction name: XOR");
					operation = 5'b00100;
				end else if (functionField === `NOR_FUNC_FIELD) begin
					$display("Instruction name: NOR");
					operation = 5'b00110;
				end else if (functionField === `JR_FUNC_FIELD) begin
					$display("Instruction name: JR");	
					operation = 5'b11010;
				end else if (functionField === `XNOR_FUNC_FIELD) begin
					$display("Instruction name: XNOR");
					operation = 5'b01010;
				end else if (functionField === `ADDU_FUNC_FIELD) begin
					$display("Instruction name: ADDU");
					operation = 5'b01110;
				end else if (functionField === `SUBU_FUNC_FIELD) begin
					$display("Instruction name: SUBU");
					operation = 5'b11100;
				end else if (functionField === `NAND_FUNC_FIELD) begin
					$display("Instruction name: NAND");
					operation = 5'b11101;
				end else
					operation = `WRONG_INST;
			end
		end
	end
endmodule

module alu(data_A, data_B, operation, shamt, result);
	input [31:0] data_A, data_B;
	input [4:0] operation;
	input [4:0] shamt;
	output reg [31:0] result;

	always @(data_A or data_B or operation or shamt) begin
		#3;
		if (data_A !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx && 
			data_B !== 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) begin
			if (operation === 5'b01000) // ADD & ADDI 
				result = $signed(data_A) + $signed(data_B);
			else if (operation === 5'b01110) // ADDU & ADDIU
				result = $unsigned(data_A) + $unsigned(data_B);
			else if (operation === 5'b11000) // SUB & SUBI
				result = $signed(data_A) - $signed(data_B);
			else if (operation === 5'b11100) // SUBU & SUBIU
				result = $unsigned(data_A) - $unsigned(data_B);
			else if (operation === 5'b00000) // AND & ANDI
				result = data_A & data_B;
			else if (operation === 5'b11101) // NAND & NANDI
				result = ~(data_A & data_B);
			else if (operation === 5'b00010) // OR & ORI
				result = data_A | data_B;
			else if (operation === 5'b00110) // NOR & NORI
				result = ~(data_A | data_B);
			else if (operation === 5'b00100) // XOR & XORI
				result = data_A ^ data_B;
			else if (operation === 5'b01010) // XNOR & XNORI
				result = ~(data_A ^ data_B);
			else if (operation === 5'b10110) begin // SLTU & SLTIU
				if ($unsigned(data_A) < $unsigned(data_B))
					result = 32'b00000000000000000000000000000001;
				else
					result = 32'b00000000000000000000000000000000;
			end else if (operation === 5'b11110) begin
				if ($signed(data_A) < $signed(data_B)) // SLT & SLTI
					result = 32'b00000000000000000000000000000001;
				else 
					result = 32'b00000000000000000000000000000000;
			end else if (operation === 5'b01100) begin // SLL 
				result = data_B << shamt;
				$display("Shift amount: %d", shamt);
			end else if (operation === 5'b10000) begin // SRL
				result = data_B >> shamt;
				$display("Shift amount: %d", shamt);
			end else if (operation === 5'b10010) begin // SRA
				result = $signed(data_B) >>> shamt;
				$display("Shift amount: %d", shamt);
			end else if (operation === 5'b10100) begin // LUI
				result = data_B << 16;
			end else if (operation === 5'b11010) begin
				result = data_A;
			end

			#2;
			if (operation !== `WRONG_INST) begin
				$display("\n<--------------- EX STATE ---------------->");
				$display("Calculating result or adresss (for lw and sw instructions)...");
				$display("Result: %b", result);
				$display("<-------------------------------------------->\n");
			end
		end
	end
endmodule

module sign_extender(imm16, extendedImm16);
	input [15:0] imm16;
 	output reg [31:0] extendedImm16;

	always @(imm16) begin
		if (imm16[15:15] === 1)
			extendedImm16 = {16'b1111111111111111,imm16};
		else
			extendedImm16 = {16'b0000000000000000,imm16};
	end
endmodule						