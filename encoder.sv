// File: encoder.sv
// Description:	This module reads two signals (a and b) and determines the direction of rotation:
//						clockwise (cw) or counterclockwise (ccw) Based on the changes in the state of inputs 
// 					'a' and 'b' on each rising clock edge
//Author: Chuibin Zeng & GPT
//Date: 2025-01-18

module encoder (
    input logic a,            // Input signal a from the encoder
    input logic b,            // Input signal b from the encoder
    input logic clk,          // Clock signal
    
    output logic cw,          // Output signal for clockwise direction
    output logic ccw          // Output signal for counterclockwise direction
);

    // Internal variables to store the previous state of a and b signals
    logic previous_a;
    logic previous_b;
    
    always_ff @(posedge clk) begin
        // Detect clockwise (cw) direction based on the transitions of a and b
        cw <= (previous_a == 0 && previous_b == 0 && a == 1 && b == 0) || 
              (previous_a == 0 && previous_b == 1 && a == 0 && b == 0) || 
              (previous_a == 1 && previous_b == 1 && a == 0 && b == 1) || 
              (previous_a == 1 && previous_b == 0 && a == 1 && b == 1);
        
        // Detect counterclockwise (ccw) direction based on the transitions of a and b
        ccw <= (previous_a == 0 && previous_b == 0 && a == 0 && b == 1) || 
               (previous_a == 0 && previous_b == 1 && a == 1 && b == 1) || 
               (previous_a == 1 && previous_b == 1 && a == 1 && b == 0) || 
               (previous_a == 1 && previous_b == 0 && a == 0 && b == 0);

        // Update previous_a and previous_b with the current state of a and b
        previous_a <= a;
        previous_b <= b;
    end
endmodule
