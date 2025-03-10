//File: adcinterface.sv
//Description: This module interfaces with the LTC2308 ADC with a state machine.
//             It handles ADC channel selection, initiates conversion, and retrieves 
//             the 12-bit conversion result.
// 			   
//Author: Chuibin Zeng and GPT
//Date: 01-25-2025

module adcinterface (	
    input logic clk, reset_n,       // System clock and active-low reset
    output logic [11:0] result_base=0,  // ADC conversion result for Servo Base (Channel 2)
    output logic [11:0] result_arm1=0,  // ADC conversion result for Servo Arm1 (Channel 3)
    output logic [11:0] result_claw=0,  // ADC conversion result for Servo ClawX (Channel 0)
    output logic [11:0] result_arm2=0,  // ADC conversion result for Servo Arm2 (Channel 1)

    // LTC2308 ADC signals
    output logic ADC_CONVST, ADC_SCK, ADC_SDI = 0,
    input logic ADC_SDO
);
    //state machine
    typedef enum logic [2:0] {
        START, //initiate adc conversion
        WAIT, // wait state one cycle after starting
        WAIT2, // stabilize wait
        TRANSFER, //send SDI and receive SDO
        PAUSE //store conversion result and setup to start again
    } state_t;
    
    state_t state, next_state; //current state and next state
    logic [3:0] bit_count; //counter for tracting transfer bits
    logic [5:0] config_word;  // Configuration word for ADC
    logic [11:0] adc_data; //stores received ADC data
	 
	 logic [1:0] adc_channel=0;  //cycles between 0 to 3

   
    //configuration word assignment based on cycling channels
    always_comb begin
        case (adc_channel)
            2'b00: config_word = 6'b100010; // Channel 0 (ClawX)
            2'b01: config_word = 6'b110010; // Channel 1 (Arm2)
            2'b10: config_word = 6'b100110; // Channel 2 (Base)
            2'b11: config_word = 6'b110110; // Channel 3 (Arm1)
            default: config_word = 6'b100010; // Default to Channel 0
        endcase
    end

    //state Machine transition logic
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            state <= START; //start on reset
        end else begin
            state <= next_state; //advance state
        end
    end

    //next state logic 
    always_comb begin
        next_state = state;
        case (state)
            START:     next_state = WAIT; // toggle CONVST
            WAIT:      next_state = WAIT2; // one cycle wait
            WAIT2:      next_state = TRANSFER; //stabilize before config is sent
            TRANSFER:  if (bit_count == 11) next_state = PAUSE; //finish transfer
            PAUSE:     next_state = START; //setup conditions to restart cycle
            default:   next_state = START;
        endcase
    end

    // Bit Counter to keep track of transfer state
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n)
            bit_count <= 0; // reset
        else if (state == TRANSFER)
            bit_count <= bit_count + 1; //increement when in transfer state
        else
            bit_count <= 0; // make 0 to prepare for next transfer
    end

    //Control Signals
    always_ff @(negedge clk, negedge reset_n) begin
        if (!reset_n) begin
            ADC_CONVST <= 1'b1;  //Default high
            adc_data   <= 12'b0; //clear result register
        end else begin
            case (state)
                START: begin
                    ADC_CONVST <= 1'b1; //Pulse CONVST high for one cycle
                end
                WAIT: begin
                    ADC_CONVST <= 1'b0; //Immediately return low
                end
                WAIT2: begin
                    ADC_CONVST <= 1'b0; //hold low to stabilize before shifting configword
                end
                TRANSFER: begin
                    //shift in SDO into adc data on negative clock edge
                    if (!clk && bit_count < 12) adc_data <= {adc_data[10:0], ADC_SDO};
                end
                PAUSE: begin
                    ADC_CONVST <= 1'b0; // prepare for restarting transfer
                    case (adc_channel)
                        2'b00: result_claw <= adc_data;
                        2'b01: result_arm2 <= adc_data;
                        2'b10: result_base <= adc_data;
                        2'b11: result_arm1 <= adc_data;
                    endcase
						  adc_channel <= adc_channel + 1'b1; //increment channel
                end
            endcase
        end
    end


   //send configure word to ADC
   always_ff @(negedge clk) begin
        if (state == WAIT2) 
            ADC_SDI <= config_word[5];  // Send MSB once in WAIT2
        else if (state == TRANSFER && bit_count < 5) 
            ADC_SDI <= config_word[4 - bit_count];  // send the rest from next bit in TRANSFER
    end

    // Ensure SCLK only toggles for 12 cycles only during transfer state
    assign ADC_SCK = (state == TRANSFER && bit_count < 12) ? clk : 1'b0;
	 
	 


endmodule