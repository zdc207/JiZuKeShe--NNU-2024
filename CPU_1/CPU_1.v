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
	// 控制信号
    wire Branch, Jump, RegDst, ALUsrc, MemtoReg, RegWr, MemWr, ExtOp;
    wire [2:0] ALUctr;
    
    // 指令相关信号
    wire [15:0] imm16;            // 立即数扩展值
    wire [31:0] imm32;
    wire [5:0] func;                // 操作码
    wire [4:0] Rs, Rt, Rd, Rw;       // 源寄存器、目标寄存器等
    // wire [5:0] OP;
    
    wire Overflow, Zero;
    
     // 程序计数器信号
    // wire [31:0] PC;               // 程序计数器）
    
    // 存储信号
    wire [31:0] MemDataIn;        // 待写入的数据（数据存储）
    
    assign control = {Branch, Jump, RegDst, ALUsrc, ALUctr, MemtoReg, RegWr, MemWr, ExtOp};
    
    InstructionFetch IF (
        .CLK(CLK),
        .Branch(Branch),
        .Jump(Jump),
        .Zero(Zero),              // 由ALU控制
        .OP(OP),                  // 操作码
        .Rs(Rs),                  // 源寄存器1
        .Rt(Rt),                  // 源寄存器2
        .Rd(Rd),                  // 目标寄存器
        .imm16(imm16),    // 输出的原始立即数
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
        .busW(busW),       // 写入寄存器的数据来自 ALU 或其他
        .busA(busA),                 // 从寄存器中读取的数据A
        .busB(busB),                  // 从寄存器中读取的数据B
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
        .Adr(ALUresult),        // ALU 结果作为存储的地址
        .DataIn(busB),              // 寄存器中的数据写入存储器
        .DataOut(MemData)           // 输出存储的数据
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

