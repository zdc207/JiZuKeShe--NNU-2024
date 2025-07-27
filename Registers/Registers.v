module Registers (
    input wire clk,               // ʱ���ź�
    input wire reset,             // ��λ�ź�
    input wire RegWr,             // дʹ���ź�
    input wire [4:0] Rw,          // д��Ĵ�����ַ
    input wire [4:0] Ra,          // ��ȡ�Ĵ���1��ַ
    input wire [4:0] Rb,          // ��ȡ�Ĵ���2��ַ
    input wire [31:0] busW,       // д����������
    output wire [31:0] busA,      // ��ȡ��������1
    output wire [31:0] busB     // ��ȡ��������2
);
    reg [31:0] reg_file [31:0];   // 32��32λ�Ĵ���

    // �첽��ȡ
    assign busA = reg_file[Ra]; // ��ȡ�Ĵ���1
    assign busB = reg_file[Rb]; // ��ȡ�Ĵ���2

    // ͬ��д���λ
    always @(negedge clk or posedge reset) begin
        if (reset) begin
            // ����λ�ź�Ϊ��ʱ�����Ĵ���������
            integer i;
            for (i = 0; i < 32; i = i + 1) begin
                reg_file[i] <= 32'b0;
            end
        end else if (RegWr) begin
            // ����λδ��������дʹ���ź���Ч��д������
            reg_file[Rw] <= busW;
        end
    end
endmodule
