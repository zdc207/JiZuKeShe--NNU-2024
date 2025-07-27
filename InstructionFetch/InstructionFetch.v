module InstructionFetch (
    input wire CLK,               // ʱ���ź�
    input wire reset,             // ��λ�ź�
    input wire Branch,            // ��֧�ź�
    input wire Jump,              // ��ת�ź�
    input wire Zero,              // Zero ��־�źţ����ڷ�֧�о�
    output wire [5:0] OP,         // ������
    output wire [4:0] Rs,         // Դ�Ĵ���1
    output wire [4:0] Rt,         // Դ�Ĵ���2
    output wire [4:0] Rd,         // Ŀ��Ĵ���
    output wire [15:0] imm16, // ԭʼ16λ������
    output wire [5:0] func,        // ������
    output wire [31:0] PCC
);
    reg [31:0] PC;                      // ���������
    reg [31:0] instruction_mem [0:255]; // ָ��洢�����洢256��32λָ��

    // ��ʼ�������������ָ��洢��
    initial begin
        PC = 32'b0;
		instruction_mem[0] = 32'b00100100000010000000000000000000; // addiu $t0, $zero, 0   # sum = 0
        instruction_mem[1] = 32'b00100100000010010000000000000001; // addiu $t1, $zero, 1   # i = 1
        instruction_mem[2] = 32'b00100100000010100000000000001010; // addiu $t2, $zero, 10  # limit = 10

        // loop:
        instruction_mem[3] = 32'b00010001001010100000000000000011; // beq $t1, $t2, end     # if (i > limit) ���� end
        instruction_mem[4] = 32'b00000001000010010100000000100000; // add $t0, $t0, $t1     # sum += i
        instruction_mem[5] = 32'b00100101001010010000000000000001; // addiu $t1, $t1, 1     # i++
        instruction_mem[6] = 32'b00001000000000000000000000000011; // j loop                # ���� loop

        // end:
        //instruction_mem[7] = 32'b10101100000100000000000000000000; // sw $t0, 0($zero)      # ���� sum ����ַ 0x10010000
        instruction_mem[7] = 32'b00000000000000000000000000000000; // nop                   # ��ָ���������
       
    end

	/* 
#include <stdio.h>

int main() {
    int sum = 0;       // �洢�ͣ���ʼֵΪ 0
    int i = 1;         // �������� i����ʼֵΪ 1
    int limit = 10;    // ѭ������

    // ѭ������ sum = 1 + 2 + ... + limit
    while (i <= limit) {
        sum += i;      // ����ǰ i ���� sum
        i++;           // i ���� 1
    }

    // ��ӡ���
    printf("Sum = %d\n", sum);
    return 0;
} */
    // ȡָ��
    wire [31:0] instruction;
    assign instruction = instruction_mem[PC[9:2]]; // ���� PC ���ֶ���
	assign PCC = PC;
    // �ֽ�ָ��
    assign OP = instruction[31:26];
    assign Rs = instruction[25:21];
    assign Rt = instruction[20:16];
    assign Rd = instruction[15:11];
    assign imm16 = instruction[15:0];
    assign func = instruction[5:0];

    // PC �����߼�
    always @(negedge CLK or posedge reset) begin
        if (reset) begin
            PC <= 32'b0; // �����λ�ź���Ч������ PC
        end else if (Jump) begin
            PC <= {PC[31:28], instruction[25:0], 2'b00}; // �����ת�ź���Ч����ת��ָ����ַ
        end else if (Branch && Zero) begin
            PC <= PC + 4 + {{14{imm16[15]}}, imm16, 2'b00}; // ��֧���� (������չ���������)
        end else begin
            PC <= PC + 4; // Ĭ��˳��ִ�У�PC+4
        end
    end
endmodule
/*
module InstructionFetch (
    input wire CLK,               // ʱ���ź�
    input wire Branch,            // ��֧�ź�
    input wire Jump,              // ��ת�ź�
    input wire Zero,              // Zero ��־�źţ����ڷ�֧�о�
    input wire [31:0] imm16,      // 16λ������ (�ѷ�����չ��32λ)
    input wire [31:0] jumpAddr,   // ��ת��ַ
    input wire [31:0] instruction, // �ⲿ�ṩ��32λ��ǰָ��
    output wire [31:0] PC_out,    // �������������������ⲿ�鿴��
    output wire [5:0] OP,         // ������
    output wire [4:0] Rs,         // Դ�Ĵ���1
    output wire [4:0] Rt,         // Դ�Ĵ���2
    output wire [4:0] Rd,         // Ŀ��Ĵ���
    output wire [15:0] imm16_out  // ԭʼ16λ������
);
    reg [31:0] PC;                // ���������

    // ��ʼ�����������
    initial begin
        PC = 32'b0;
    end

    // ��ָ��ֽ�
    assign OP = instruction[31:26];    // ������
    assign Rs = instruction[25:21];   // Դ�Ĵ���1
    assign Rt = instruction[20:16];   // Դ�Ĵ���2
    assign Rd = instruction[15:11];   // Ŀ��Ĵ���
    assign imm16_out = instruction[15:0]; // ԭʼ16λ������
    assign PC_out = PC;               // �����ǰPCֵ

    // ����PC���߼�
    always @(posedge CLK) begin
        if (Jump) begin
            PC <= jumpAddr;           // ��ת�ź���Чʱ����ת��ָ����ַ
        end else if (Branch && Zero) begin
            PC <= PC + 4 + (imm16 << 2); // ��֧���� (������չ���������)
        end else begin
            PC <= PC + 4;             // Ĭ��˳��ִ�У�PC + 4
        end
    end
endmodule
*/
