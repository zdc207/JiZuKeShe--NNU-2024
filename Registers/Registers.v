module Registers (
    input wire clk,               // 时钟信号
    input wire reset,             // 复位信号
    input wire RegWr,             // 写使能信号
    input wire [4:0] Rw,          // 写入寄存器地址
    input wire [4:0] Ra,          // 读取寄存器1地址
    input wire [4:0] Rb,          // 读取寄存器2地址
    input wire [31:0] busW,       // 写入数据总线
    output wire [31:0] busA,      // 读取数据总线1
    output wire [31:0] busB     // 读取数据总线2
);
    reg [31:0] reg_file [31:0];   // 32个32位寄存器

    // 异步读取
    assign busA = reg_file[Ra]; // 读取寄存器1
    assign busB = reg_file[Rb]; // 读取寄存器2

    // 同步写入或复位
    always @(negedge clk or posedge reset) begin
        if (reset) begin
            // 当复位信号为高时，将寄存器堆清零
            integer i;
            for (i = 0; i < 32; i = i + 1) begin
                reg_file[i] <= 32'b0;
            end
        end else if (RegWr) begin
            // 若复位未触发，且写使能信号有效，写入数据
            reg_file[Rw] <= busW;
        end
    end
endmodule
