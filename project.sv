module project (
    input logic CLOCK_50,       // 50 MHz clock
    (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) 
    input logic enc1_a, enc1_b, // Encoder 1 pins
    (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *)       
   
    input logic enc2_a, enc2_b, 
            
    output logic [7:0] leds,    
    output logic [3:0] ct,      
    output logic spkr,         

	 //for the adc servos
    output logic servo_base,  //accelerometer X servo output
    output logic servo_arm1,  //accelerometer Y servo output
    output logic servo_arm2,  //joystick Y servo outpu
    output logic servo_clawx, //joystick X servo output
	 
	 //for the button servos
	 input logic s1,
	 input logic s2, 
	 input logic joysel,
	 output logic servo_claw,
	 output logic servo_arm3,
	 
    //ADC interface signals
    output logic ADC_CONVST, ADC_SCK, ADC_SDI,
    input logic ADC_SDO
);

    logic [15:0] clk_div_count;
    logic slow_clk;
    logic reset_n;  
    assign reset_n = 1;  //temp change to a encoder value later we need s1

    logic [11:0] adc_result_base; //accelerometer X results
    logic [11:0] adc_result_arm1; //accelerometer Y results
    logic [11:0] adc_result_claw; //joystick X results
    logic [11:0] adc_result_arm2; //joystick Y results
	 
	 
	 //counter used to generate 50hz for the button servos
	 logic [31:0] pwm_counter;
	 always_ff @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n)
            pwm_counter <= 0;
        else if (pwm_counter >= 1000000) // Reset every 20ms (1,000,000 counts at 50MHz)
            pwm_counter <= 0;
        else
            pwm_counter <= pwm_counter + 1;
    end
	 //

	 
    always_ff @(posedge CLOCK_50) 
        clk_div_count <= clk_div_count + 1'b1;

    assign slow_clk = clk_div_count[6];//for adc

    //ADC interface
    adcinterface adc_inst (
        .clk(slow_clk), 
        .reset_n(reset_n), 
        .result_base(adc_result_base), 
        .result_arm1(adc_result_arm1), 
        .result_claw(adc_result_claw), 
        .result_arm2(adc_result_arm2), 
        .ADC_CONVST(ADC_CONVST), 
        .ADC_SCK(ADC_SCK), 
        .ADC_SDI(ADC_SDI), 
        .ADC_SDO(ADC_SDO)
    );
	 //

    //servo controller for all four adc servos
    servo_controller servo_ctrl (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .adc_joyx(adc_result_claw),  // Joystick X - Claw
        .adc_joyy(adc_result_arm2),  // Joystick Y - Arm2
        .adc_accx(adc_result_base),  // Accelerometer X - Base
        .adc_accy(adc_result_arm1),  // Accelerometer Y - Arm1
        .pwm_joyx(servo_clawx),
        .pwm_joyy(servo_arm2),
        .pwm_accx(servo_base),
        .pwm_accy(servo_arm1)
    );
	 //
	 
	 
//logic for button servos (claw and arm3)
	 
	 //claw servo PWM control
    logic [31:0] pwm_claw = 50000;  //time for servo control

    //set PWM based on joysel
    always_ff @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n)
            pwm_claw <= 50000; //default to 1ms (Open)
        else if (joysel)
            pwm_claw <= 100000; //2ms (Close)
        else
            pwm_claw <= 50000;  //1ms (Open)
    end

    //PWM signal for the claw servo
    assign servo_claw = (pwm_counter < pwm_claw) ? 1'b1 : 1'b0;
	 //
	 
	 
	 //arm servo
    logic [31:0] pwm_arm3 = 75000;  //time for arm movement
    logic [23:0] move_counter = 0;  //Slow down movement updates

    always_ff @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n) begin
            pwm_arm3 <= 75000; //start at neutral (1.5ms)
            move_counter <= 0;
        end 
        else begin
            move_counter <= move_counter + 1; 

            //Update every 10ms (move_counter threshold) for smooth motion
            if (move_counter >= 500000) begin  
                move_counter <= 0;  // Reset counter after update

                //If s1 is pressed move up
                if (!s1 && pwm_arm3 < 100000)
                    pwm_arm3 <= pwm_arm3 + 500; //smooth increment

                //If s2 is pressed move down
                else if (!s2 && pwm_arm3 > 50000)
                    pwm_arm3 <= pwm_arm3 - 500; //smooth decrement
            end
        end
    end

    assign servo_arm3 = (pwm_counter < pwm_arm3) ? 1'b1 : 1'b0;
	 //
	
endmodule
