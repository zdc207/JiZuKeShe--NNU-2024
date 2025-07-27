module CPU_1(
	input wire Reset,
	input wire CLK, 
	output wire [31:0] ALUresult,
	output wire [31:0] PCC,
	output wire [31:0] busA,
	output wire [31:0] busB,
	output wire [31:0] busW,
	output wire [31:0] busB_dealed,
	output wire [5:0] OP,
	output wire [10:0] control,
	output wire [31:0] MemData
);
	// �����ź�
    wire Branch, Jump, RegDst, ALUsrc, MemtoReg, RegWr, MemWr, ExtOp;
    wire [2:0] ALUctr;
    
    // ָ������ź�
    wire [15:0] imm16;            // ��������չֵ
    wire [31:0] imm32;
    wire [5:0] func;                // ������
    wire [4:0] Rs, Rt, Rd, Rw;       // Դ�Ĵ�����Ŀ��Ĵ�����
    // wire [5:0] OP;
    
    wire Overflow, Zero;
    
     // ����������ź�
    // wire [31:0] PC;               // �����������
    
    // �洢�ź�
    wire [31:0] MemDataIn;        // ��д������ݣ����ݴ洢��
    
    assign control = {Branch, Jump, RegDst, ALUsrc, ALUctr, MemtoReg, RegWr, MemWr, ExtOp};
    
    InstructionFetch IF (
        .CLK(CLK),
        .Branch(Branch),
        .Jump(Jump),
        .Zero(Zero),              // ��ALU����
        .OP(OP),                  // ������
        .Rs(Rs),                  // Դ�Ĵ���1
        .Rt(Rt),                  // Դ�Ĵ���2
        .Rd(Rd),                  // Ŀ��Ĵ���
        .imm16(imm16),    // �����ԭʼ������
		.func(func),
		.reset(reset),
		.PCC(PCC)
    );
    
    Decode decode (
        .OP(OP),                  
        .func(func),              
        .Branch(Branch),         
        .Jump(Jump),             
        .RegDst(RegDst),         
        .ALUsrc(ALUsrc),         
        .ALUctr(ALUctr),         
        .MemtoReg(MemtoReg),     
        .RegWr(RegWr),           
        .MemWr(MemWr),           
        .ExtOp(ExtOp)            
    );
    
    assign RegWr_dealed = RegWr && (~Overflow);
    MUX2to1 mux1(Rt, Rd, RegDst, Rw);
    
    Registers regs (
        .clk(CLK),
        .RegWr(RegWr_dealed),
        .Rw(Rw),
        .Ra(Rs),
        .Rb(Rt),
        .busW(busW),       // д��Ĵ������������� ALU ������
        .busA(busA),                 // �ӼĴ����ж�ȡ������A
        .busB(busB),                  // �ӼĴ����ж�ȡ������B
		.reset(reset)
    );
    
    Ext32 ext32(imm16, ExtOp, imm32);
    MUX2to1 mux2(busB, imm32, ALUsrc, busB_dealed);
    ALU alu(
		.A(busA),
		.B(busB_dealed),
		.ALUctr(ALUctr),
		.Result(ALUresult),
		.Zero(Zero),
		.Overflow(Overflow)
		);
		
	 Store store (
        .clk(CLK),
        .WrEn(MemWr),
        .Adr(ALUresult),        // ALU �����Ϊ�洢�ĵ�ַ
        .DataIn(busB),              // �Ĵ����е�����д��洢��
        .DataOut(MemData)           // ����洢������
    );
    MUX2to1 mux3(ALUresult, MemData, MemtoReg, busW);

	endmodule


module MUX2to1(
	input [31:0] A,
	input [31:0] B,
	input ctr,
	output [31:0] Result);
	assign Result = (ctr == 1'b0) ? A : B;
endmodule

module Ext32(
	input [15:0] imm16,
	input ExtOp,
	output [31:0] imm32
);
	assign imm32 = (ExtOp == 0) ? {16'b0, imm16} : {{16{imm16[15]}}, imm16};
endmodule

