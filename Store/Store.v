module Store (
    input wire clk,               // ʱ���ź�
    input wire WrEn,              // д��ʹ���ź�
    input wire [31:0] Adr,        // ��ַ���루֧��255���洢��Ԫ��
    input wire [31:0] DataIn,     // ����д������
    output wire [31:0] DataOut    // ���ݶ�ȡ����
);
    reg [31:0] mem [255:0];       // 255��32λ�洢��Ԫ

    // �첽��ȡ
    assign DataOut = mem[Adr[7:0]]; // ��ʹ�õ�ַ�ĵ� 8 λ

    // ͬ��д���λ����
    always @(negedge clk) begin
        if (WrEn) begin
            // ��ʱ���½��أ���дʹ���ź���Ч��д�����ݵ�ָ����ַ
            mem[Adr[7:0]] <= DataIn;
        end
    end
endmodule
