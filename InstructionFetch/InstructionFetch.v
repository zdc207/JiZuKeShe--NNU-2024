module InstructionFetch (
    input wire CLK,               // 时钟信号
    input wire reset,             // 复位信号
    input wire Branch,            // 分支信号
    input wire Jump,              // 跳转信号
    input wire Zero,              // Zero 标志信号，用于分支判决
    output wire [5:0] OP,         // 操作码
    output wire [4:0] Rs,         // 源寄存器1
    output wire [4:0] Rt,         // 源寄存器2
    output wire [4:0] Rd,         // 目标寄存器
    output wire [15:0] imm16, // 原始16位立即数
    output wire [5:0] func,        // 功能码
    output wire [31:0] PCC
);
    reg [31:0] PC;                      // 程序计数器
    reg [31:0] instruction_mem [0:255]; // 指令存储器，存储256条32位指令

    // 初始化程序计数器和指令存储器
    initial begin
        PC = 32'b0;
		instruction_mem[0] = 32'b00100100000010000000000000000000; // addiu $t0, $zero, 0   # sum = 0
        instruction_mem[1] = 32'b00100100000010010000000000000001; // addiu $t1, $zero, 1   # i = 1
        instruction_mem[2] = 32'b00100100000010100000000000001010; // addiu $t2, $zero, 10  # limit = 10

        // loop:
        instruction_mem[3] = 32'b00010001001010100000000000000011; // beq $t1, $t2, end     # if (i > limit) 跳到 end
        instruction_mem[4] = 32'b00000001000010010100000000100000; // add $t0, $t0, $t1     # sum += i
        instruction_mem[5] = 32'b00100101001010010000000000000001; // addiu $t1, $t1, 1     # i++
        instruction_mem[6] = 32'b00001000000000000000000000000011; // j loop                # 跳回 loop

        // end:
        //instruction_mem[7] = 32'b10101100000100000000000000000000; // sw $t0, 0($zero)      # 保存 sum 到地址 0x10010000
        instruction_mem[7] = 32'b00000000000000000000000000000000; // nop                   # 空指令（结束程序）
       
    end

	/* 
#include <stdio.h>

int main() {
    int sum = 0;       // 存储和，初始值为 0
    int i = 1;         // 迭代变量 i，初始值为 1
    int limit = 10;    // 循环上限

    // 循环计算 sum = 1 + 2 + ... + limit
    while (i <= limit) {
        sum += i;      // 将当前 i 加入 sum
        i++;           // i 自增 1
    }

    // 打印结果
    printf("Sum = %d\n", sum);
    return 0;
} */
    // 取指令
    wire [31:0] instruction;
    assign instruction = instruction_mem[PC[9:2]]; // 假设 PC 按字对齐
	assign PCC = PC;
    // 分解指令
    assign OP = instruction[31:26];
    assign Rs = instruction[25:21];
    assign Rt = instruction[20:16];
    assign Rd = instruction[15:11];
    assign imm16 = instruction[15:0];
    assign func = instruction[5:0];

    // PC 更新逻辑
    always @(negedge CLK or posedge reset) begin
        if (reset) begin
            PC <= 32'b0; // 如果复位信号有效，重置 PC
        end else if (Jump) begin
            PC <= {PC[31:28], instruction[25:0], 2'b00}; // 如果跳转信号有效，跳转到指定地址
        end else if (Branch && Zero) begin
            PC <= PC + 4 + {{14{imm16[15]}}, imm16, 2'b00}; // 分支计算 (符号扩展后的立即数)
        end else begin
            PC <= PC + 4; // 默认顺序执行，PC+4
        end
    end
endmodule
/*
module InstructionFetch (
    input wire CLK,               // 时钟信号
    input wire Branch,            // 分支信号
    input wire Jump,              // 跳转信号
    input wire Zero,              // Zero 标志信号，用于分支判决
    input wire [31:0] imm16,      // 16位立即数 (已符号扩展到32位)
    input wire [31:0] jumpAddr,   // 跳转地址
    input wire [31:0] instruction, // 外部提供的32位当前指令
    output wire [31:0] PC_out,    // 输出程序计数器（方便外部查看）
    output wire [5:0] OP,         // 操作码
    output wire [4:0] Rs,         // 源寄存器1
    output wire [4:0] Rt,         // 源寄存器2
    output wire [4:0] Rd,         // 目标寄存器
    output wire [15:0] imm16_out  // 原始16位立即数
);
    reg [31:0] PC;                // 程序计数器

    // 初始化程序计数器
    initial begin
        PC = 32'b0;
    end

    // 将指令分解
    assign OP = instruction[31:26];    // 操作码
    assign Rs = instruction[25:21];   // 源寄存器1
    assign Rt = instruction[20:16];   // 源寄存器2
    assign Rd = instruction[15:11];   // 目标寄存器
    assign imm16_out = instruction[15:0]; // 原始16位立即数
    assign PC_out = PC;               // 输出当前PC值

    // 更新PC的逻辑
    always @(posedge CLK) begin
        if (Jump) begin
            PC <= jumpAddr;           // 跳转信号有效时，跳转到指定地址
        end else if (Branch && Zero) begin
            PC <= PC + 4 + (imm16 << 2); // 分支计算 (符号扩展后的立即数)
        end else begin
            PC <= PC + 4;             // 默认顺序执行：PC + 4
        end
    end
endmodule
*/
