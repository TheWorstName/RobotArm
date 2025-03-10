//File: enc2chan.sv
//Description: this module is used to select an ADC channel based on 
//             number of encoder turns
// 			   
//Author: Chuibin Zeng and GPT
//Date: 01-25-2025
module enc2chan(
    input logic clk,        // Clock input
    input logic cw,         // Clockwise signal from encoder
    input logic ccw,        // Counterclockwise signal from encoder
    input logic reset_n,    // Active low reset
    output logic [3:0] chan // Ooutput Channel (0 to 7)
);

           
    logic signed [4:0] four_count; // Count encoder pulses

    // Always block to handle the encoder signal and channel mapping and resets
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            four_count <= 0;  // Reset pulse count
            chan <= 0;        // Reset chan index to 0
        end else begin
            // Increase or decrease pulse count based on cw or ccw
            if (cw) 
                four_count <= four_count + 1;
            else if (ccw) 
                four_count <= four_count - 1;

            // Increment the chan every 4 counts (CW direction)
            if (four_count == 4) begin
                if (chan < 7)
                    chan <= chan + 1; // Increment chan
                else
                    chan <= 0;        // Wrap the chan back to 0
                four_count <= 0;      // Reset pulse count
            end

            // Decrement the chan every 4 counts (CCW direction)
            if (four_count == -4) begin
                if (chan > 0)
                    chan <= chan - 1; // Decrement chan
                else
                    chan <= 7;        // Wrap the chan back to 7
                four_count <= 0;      // Reset pulse count
            end
        end
    end



endmodule
