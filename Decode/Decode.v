module Decode (
    input wire [5:0] OP,            // ������
    input wire [5:0] func,          // �����루���� R ��ָ����Ч��
    output reg Branch,              // ��֧�����ź�
    output reg Jump,                // ��ת�����ź�
    output reg RegDst,              // Ŀ��Ĵ���ѡ���ź�
    output reg ALUsrc,              // ALU ��������Դѡ��
    output reg [2:0] ALUctr,        // 3 λ ALU �����ź�
    output reg MemtoReg,            // �ڴ�����д�ؼĴ���ѡ��
    output reg RegWr,               // �Ĵ���дʹ��
    output reg MemWr,               // �ڴ�дʹ��
    output reg ExtOp                // ������չ/����չ�����ź�
);
    always @(*) begin

        // ���ݲ�����ѡ��ָ������
        case (OP)
            6'b000000: begin
                // R ��ָ�� (Opcode = 000000)
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
                    default:   ALUctr <= 3'b000; // Ĭ�ϣ�addu
                endcase
            end
            6'b100011: begin
                // lw ָ�� (Opcode = 100011)
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
                // sw ָ�� (Opcode = 101011)
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
                // beq ָ�� (Opcode = 000100)
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
                // j ָ�� (Opcode = 000010)
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
                // Ĭ����������п����ź�Ϊ 0 (nop)
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
