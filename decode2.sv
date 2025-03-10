//FilE: decode2.sv
//Description: ELEX 7660 decode2 module used to turn on each part of the
//					of the 4 part 7 segment display individually
//					based on the clock signal received
//Author: Chuibin Zeng
//Date: 2025-01-17


module decode2 ( 
	input logic [1:0] digit, //2-bit input representing which 7segment to activate based on clock
	output logic [3:0] ct	//4-bit output controlling which 7segment to activate
);

	//map the 2-bit digit clock input to the corresponding active low 
	always_comb begin
		case (digit)
			2'b00: ct = 4'b1110; //turn on right most digit
			2'b01: ct = 4'b1101; //turn on second right most digit
         2'b10: ct = 4'b1011;	//turn on second left most digit
         2'b11: ct = 4'b0111; //turn on left most digit
		endcase
	end
endmodule

