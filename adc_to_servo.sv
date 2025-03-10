module adc_to_servo (
    input logic clk,            
    input logic reset_n,             
    input logic [11:0] adc_in,   
    input logic [11:0] adc_min,  
    input logic [11:0] adc_max,  
    output logic servo_pwm       //PWM signal to servo motor
);

    //Servo PWM Constants
    parameter integer SERVO_MIN = 50000;    //1ms pulse width (-90 degrees)
    parameter integer SERVO_NEUTRAL = 75000;//1.5ms pulse width (0 degrees)
    parameter integer SERVO_MAX = 100000;   //2ms pulse width (+90 degrees)
    parameter integer PERIOD = 1000000;     //20ms period for 50Hz at 50MHz

    logic [31:0] pulse_width;
    logic [31:0] counter;

    //cnvert ADC input to Servo PWM range
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            pulse_width <= SERVO_NEUTRAL; //default to neutral (1.5ms)
        end else begin
            //scale ADC values from (adc_min - adc_max) to (SERVO_MIN - SERVO_MAX)
            pulse_width <= SERVO_MIN + ((adc_in - adc_min) * (SERVO_MAX - SERVO_MIN)) / (adc_max - adc_min);
        end
    end

    //generate 50Hz signal
    always_ff @(posedge clk) begin
        if (!reset_n)
            counter <= 0;
        else if (counter >= PERIOD)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    //generate PWM output signal
    always_ff @(posedge clk) begin
        if (!reset_n)
            servo_pwm <= 0;
        else
            servo_pwm <= (counter < pulse_width); //HIGH when counter < pulse_width
    end

endmodule