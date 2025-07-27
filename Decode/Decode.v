module Decode (
    input wire [5:0] OP,            // 操作码
    input wire [5:0] func,          // 功能码（仅对 R 型指令有效）
    output reg Branch,              // 分支控制信号
    output reg Jump,                // 跳转控制信号
    output reg RegDst,              // 目标寄存器选择信号
    output reg ALUsrc,              // ALU 操作数来源选择
    output reg [2:0] ALUctr,        // 3 位 ALU 控制信号
    output reg MemtoReg,            // 内存数据写回寄存器选择
    output reg RegWr,               // 寄存器写使能
    output reg MemWr,               // 内存写使能
    output reg ExtOp                // 符号扩展/零扩展控制信号
);
    always @(*) begin

        // 根据操作码选择指令类型
        case (OP)
            6'b000000: begin
                // R 型指令 (Opcode = 000000)
                Branch <= 1'b0;
                Jump <= 1'b0;
                RegDst <= 1'b1;  
                ALUsrc <= 1'b0;     
                MemtoReg <= 1'b0; 
                RegWr  <= 1'b1;              
                MemWr <= 1'b0;
                ExtOp <= 1'b0;
                case (func)
                    6'b100000: ALUctr <= 3'b001; // add
                    6'b100011: ALUctr <= 3'b100; // subu
                    6'b100010: ALUctr <= 3'b101; // sub
                    6'b101011: ALUctr <= 3'b110; // sltu
                    6'b101010: ALUctr = 3'b111; // slt
                    default:   ALUctr <= 3'b000; // 默认：addu
                endcase
            end
            6'b100011: begin
                // lw 指令 (Opcode = 100011)
                Branch <= 1'b0;
                Jump <= 1'b0;
                RegDst <= 1'b0;  
                ALUsrc <= 1'b1; 
                ALUctr <= 3'b000;    
                MemtoReg <= 1'b1; 
                RegWr  <= 1'b1;              
                MemWr <= 1'b0;
                ExtOp <= 1'b1;
            end
            6'b101011: begin
                // sw 指令 (Opcode = 101011)
                Branch <= 1'b0;
                Jump <= 1'b0;
                RegDst <= 1'b0;  
                ALUsrc <= 1'b1; 
                ALUctr <= 3'b000;    
                MemtoReg <= 1'b0; 
                RegWr  <= 1'b0;              
                MemWr <= 1'b1;
                ExtOp <= 1'b1;
            end
            6'b000100: begin
                // beq 指令 (Opcode = 000100)
                Branch <= 1'b1;
                Jump <= 1'b0;
                RegDst <= 1'b0;  
                ALUsrc <= 1'b0; 
                ALUctr <= 3'b100;    
                MemtoReg <= 1'b0; 
                RegWr  <= 1'b0;              
                MemWr <= 1'b0;
                ExtOp <= 1'b0;
            end
            6'b000010: begin
                // j 指令 (Opcode = 000010)
                Branch <= 1'b0;
                Jump <= 1'b1;
                RegDst <= 1'b0;  
                ALUsrc <= 1'b0; 
                ALUctr <= 3'b100;    
                MemtoReg <= 1'b0; 
                RegWr  <= 1'b0;              
                MemWr <= 1'b0;
                ExtOp <= 1'b0;
            end
            6'b001101: begin
			// ori
				Branch <= 1'b0;
                Jump <= 1'b0;
                RegDst <= 1'b0;  
                ALUsrc <= 1'b1; 
                ALUctr <= 3'b010;    
                MemtoReg <= 1'b0; 
                RegWr  <= 1'b1;              
                MemWr <= 1'b0;
                ExtOp <= 1'b0;
			end
			6'b001001: begin
			// addiu
				Branch <= 1'b0;
                Jump <= 1'b0;
                RegDst <= 1'b0;  
                ALUsrc <= 1'b1; 
                ALUctr <= 3'b000;    
                MemtoReg <= 1'b0; 
                RegWr  <= 1'b1;              
                MemWr <= 1'b0;
                ExtOp <= 1'b1;
			end
            default: begin
                // 默认情况，所有控制信号为 0 (nop)
                Branch    <= 1'b0;
                Jump      <= 1'b0;
                RegDst    <= 1'b0;
                ALUsrc    <= 1'b0;
                ALUctr    <= 3'b000;
                MemtoReg  <= 1'b0;
                RegWr     <= 1'b0;
                MemWr     <= 1'b0;
                ExtOp     <= 1'b0;
            end
        endcase
    end
endmodule
