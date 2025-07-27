 /* module ALU (
    input [31:0] A,         // First 32-bit input
    input [31:0] B,         // Second 32-bit input
    input [2:0] ALUctr,     // 3-bit ALU control signal              
    output reg [31:0] Result,  // 32-bit output result
    output Zero,            // Zero flag
    output Overflow,        // Overflow flag
    output reg Less         // Result of comparison
);

    wire [31:0] add_result, sub_result, or_result;
    wire add_overflow, sub_overflow;
    wire add_sign, sub_sign;
    wire [31:0] less_result;
    wire OPctr1, OPctr0, SUBctr, OVctr, SIGctr;
    wire Cin;

    // Control signals based on ALUctr
    assign SUBctr = ALUctr[2];
    assign OVctr = ~ALUctr[1] & ALUctr[0];
    assign SIGctr = ALUctr[0];
    assign OPctr1 = ALUctr[2] & ALUctr[1];
    assign OPctr0 = ~ALUctr[2] & ALUctr[1] & ~ALUctr[0];

    // Define operations
    assign Cin = SUBctr;
    assign add_result = A + B + Cin;                       // Addition
    assign sub_result = A - B;                             // Subtraction
    assign or_result = A | B;                              // Bitwise OR
    assign add_overflow = (A[31] & B[31] & ~add_result[31]) | (~A[31] & ~B[31] & add_result[31]);
    assign sub_overflow = (A[31] & ~B[31] & ~sub_result[31]) | (~A[31] & B[31] & sub_result[31]);
    assign add_sign = add_result[31];
    assign sub_sign = sub_result[31];
    
    // Select Result based on ALUctr
    always @(*) begin
        case (ALUctr)
            3'b000: Result = add_result;                   // addu: Unsigned addition
            3'b001: Result = add_result;                   // add: Signed addition
            3'b010: Result = or_result;                    // or: Bitwise OR
            3'b100: Result = sub_result;                   // subu: Unsigned subtraction
            3'b101: Result = sub_result;                   // sub: Signed subtraction
            3'b110: begin                                  // sltu: Unsigned less than comparison
                Less = (A < B) ? 1 : 0;
                Result = Less;
            end
            3'b111: begin                                  // slt: Signed less than comparison
                Less = (A[31] != B[31]) ? A[31] : (A < B);
                Result = Less;
            end
            default: Result = 32'b0;                       // Default case
        endcase
    end

    // Set Zero flag
    assign Zero = (Result == 32'b0);

    // Set Overflow flag
    assign Overflow = (ALUctr == 3'b001) ? add_overflow : ((ALUctr == 3'b101) ? sub_overflow : 1'b0);

endmodule
*/


module ALU(
	input [31:0] A,
	input [31:0] B,
	input [2:0] ALUctr,
	output wire [31:0] Result,
	output wire Zero,
	output wire Overflow
	);
	
	wire SUBctr, OVctr, SIGctr;
	wire [1:0] OPctr;
	ALUctr_incorder aluincoder(
		.ALUctr(ALUctr),
		.SUBctr(SUBctr), 
		.OVctr(OVctr),
		.SIGctr(SIGctr),
		.OPctr(OPctr)
		);
	
	wire [31:0] or_result;
	operater_or opor(
		.A(A),
		.B(B),
		.res(or_result));
		
	wire [31:0] extended_SUBctr;
	byte_entend_1_to_32 be1t32(
		.bite(SUBctr),
		.res(extended_SUBctr));
	wire [31:0] dealed_B;
	operator_xor(
		.A(extended_SUBctr),
		.B(B),
		.res(dealed_B));
	
	wire add_overflow, add_sign, add_carry;
	wire  [31:0] add_result;
	 parallel_adder_32bit pa32(
		.a(A),
		.b(dealed_B),
		.cin(SUBctr),
		.result(add_result),
		.add_carry(add_carry),
		.add_overflow(add_overflow),
		.add_sign(add_sign),
		.zero(Zero)
		);
		
	wire temp_less1, temp_less2, less;
	wire [31:0] less32;
	assign temp_less1 = SUBctr ^ add_carry;
	assign temp_less2 = add_overflow ^ add_sign;
	mutex_two_to_one_1 mttl1(
		.input_0(temp_less1),
		.input_1(temp_less2),
		.ctr(SIGctr),
		.res(less));
	assign Overflow = add_overflow && OVctr;
	assign less32 = (less == 0) ? 32'd0 : 32'd1;
	mutex_three_to_one_32 mtto32(
		.input_0(add_result),
		.input_1(or_result),
		.input_2(less32),
		.ctr(OPctr),
		.res(Result));
	
	
endmodule


module ALUctr_incorder(
	input [2:0] ALUctr,
	output wire SUBctr, OVctr, SIGctr,
	output wire [1:0] OPctr
	);
	
	assign SUBctr = (ALUctr == 3'b100 || ALUctr == 3'b101 || ALUctr == 3'b110 || ALUctr == 3'b111);
	assign OVctr  = (ALUctr == 3'b001 || ALUctr == 3'b101);
	assign SIGctr = (ALUctr == 3'b111 || ALUctr == 3'b000); // Default to SIGctr = 1'b0 for other cases
	assign OPctr  = (ALUctr == 3'b010) ? 2'b01 :
                (ALUctr == 3'b110 || ALUctr == 3'b111) ? 2'b10 : 2'b00;

endmodule
			

module operater_or(
	input [31:0] A,
	input [31:0] B,
	output wire [31:0] res
	);
	
	assign res = A | B;
	
endmodule

module mutex_three_to_one_32(
	input [31:0] input_0,
	input [31:0] input_1,
	input [31:0] input_2,
	input [1:0] ctr,
	output wire [31:0] res
);
	
	assign res = (ctr == 2'b00) ? input_0 :
             (ctr == 2'b01) ? input_1 :
             (ctr == 2'b10) ? input_2 : 32'd0;

	
endmodule


module mutex_two_to_one_1(
	input input_0,
	input input_1,
	input ctr,
	output wire res
);

	assign res = (ctr == 1'b0) ? input_0 : 
             (ctr == 1'b1) ? input_1 : 1'b0;


endmodule

module byte_entend_1_to_32(
	input bite,
	output wire [31:0] res
);

	assign res = (bite == 1'b0) ? 32'd0 : 32'hFFFFFFFF;

endmodule


module operator_xor(
	input [31:0] A,
	input [31:0] B,
	output wire [31:0] res
	);
	
	assign res = A ^ B;
	
endmodule

module full_adder_1bit (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule

/*
module full_adder_32bit (
    input [31:0] a,
    input [31:0] b,
    input cin,
    output [31:0] result, // 加法结果
    output add_carry,         // 最高位进位
    output add_overflow,      // 溢出标志
    output add_sign,           // 结果的符号位
    output zero
);
    wire [31:0] carry_intermediate; // 中间进位信号

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : adder
            if (i == 0) begin
                full_adder_1bit fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(cin),
                    .sum(result[i]),
                    .cout(carry_intermediate[i])
                );
            end else begin
                full_adder_1bit fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(carry_intermediate[i-1]),
                    .sum(result[i]),
                    .cout(carry_intermediate[i])
                );
            end
        end
    endgenerate

    assign add_carry = carry_intermediate[31];       // 最高位进位
    assign add_sign = result[31];                    // 结果的符号位
    assign add_overflow = carry_intermediate[30] ^ carry_intermediate[31]; // 溢出标志
    assign zero = ~|result; 
    
endmodule
*/

module parallel_adder_32bit (
    input [31:0] a,         // 第一个加数
    input [31:0] b,         // 第二个加数
    input cin,              // 输入进位（对于多个加法器来说，通常是0）
    output [31:0] result,   // 加法结果
    output add_sign,            // 符号位
    output add_overflow,        // 溢出标志
    output add_carry,           // 进位标志
    output zero             // 零标志
);

    wire [31:0] sum;             // 存储加法结果
    wire [31:0] carry_intermediate; // 存储进位信息
    wire carry_out;             // 最后的进位信号
    
    // 使用 Verilog 内建的 32 位加法器（可以使用 + 运算符）
    assign {carry_out, sum} = a + b + cin;

    // 将 sum 赋值给 result
    assign result = sum;

    // sign 是结果的最高位
    assign add_sign = sum[31];

    // 溢出判断：当 a 和 b 的符号位相同，但结果的符号位不同时，发生溢出
    assign add_overflow = (a[31] == b[31]) && (sum[31] != a[31]);

    // carry 是最后的进位信号
    assign add_carry = carry_out;

    // zero 是当加法结果为 0 时为 1，其他情况为 0
    assign zero = (sum == 32'd0);

endmodule


	