module Store (
    input wire clk,               // 时钟信号
    input wire WrEn,              // 写入使能信号
    input wire [31:0] Adr,        // 地址输入（支持255个存储单元）
    input wire [31:0] DataIn,     // 数据写入总线
    output wire [31:0] DataOut    // 数据读取总线
);
    reg [31:0] mem [255:0];       // 255个32位存储单元

    // 异步读取
    assign DataOut = mem[Adr[7:0]]; // 仅使用地址的低 8 位

    // 同步写入或复位操作
    always @(negedge clk) begin
        if (WrEn) begin
            // 在时钟下降沿，若写使能信号有效，写入数据到指定地址
            mem[Adr[7:0]] <= DataIn;
        end
    end
endmodule
