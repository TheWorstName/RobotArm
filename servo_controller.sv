module servo_controller (
    input logic clk,
    input logic reset_n,
    input logic [11:0] adc_joyx, adc_joyy, adc_accx, adc_accy,
    output logic pwm_joyx, pwm_joyy, pwm_accx, pwm_accy
);

    
    parameter integer ADC_MARGIN = 50; //margins to avoid edge cases

    //instantiate servo controllers with adjusted ADC min/max values
    adc_to_servo servo_x (
        .clk(clk), .reset_n(reset_n),
        .adc_in( (adc_joyx < (12'd8 + ADC_MARGIN))  ? (12'd8 + ADC_MARGIN) :
                 (adc_joyx > (12'd3176 - ADC_MARGIN)) ? (12'd3176 - ADC_MARGIN) :
                 adc_joyx ),
        .adc_min(12'd8 + ADC_MARGIN),    //joyX Min ADC Value
        .adc_max(12'd3176 - ADC_MARGIN), //joyX Max ADC Value
        .servo_pwm(pwm_joyx)
    );

    adc_to_servo servo_y (
        .clk(clk), .reset_n(reset_n),
        .adc_in( (adc_joyy < (12'd9 + ADC_MARGIN))  ? (12'd9 + ADC_MARGIN) :
                 (adc_joyy > (12'd3336 - ADC_MARGIN)) ? (12'd3336 - ADC_MARGIN) :
                 adc_joyy ),
        .adc_min(12'd9 + ADC_MARGIN),    //joyY Min ADC Value
        .adc_max(12'd3336 - ADC_MARGIN), //joyY Max ADC Value 
        .servo_pwm(pwm_joyy)
    );

    adc_to_servo servo_ax (
        .clk(clk), .reset_n(reset_n),
        .adc_in( (adc_accx < (12'd1128 + ADC_MARGIN))  ? (12'd1128 + ADC_MARGIN) :
                 (adc_accx > (12'd2265 - ADC_MARGIN)) ? (12'd2265 - ADC_MARGIN) :
                 adc_accx ),
        .adc_min(12'd1128 + ADC_MARGIN),    //aX min adc value
        .adc_max(12'd2265 - ADC_MARGIN),    //aX max adc value
        .servo_pwm(pwm_accx)
    );

   
    adc_to_servo servo_ay (
        .clk(clk), .reset_n(reset_n),
        .adc_in( (adc_accy < (12'd1128 + ADC_MARGIN))  ? (12'd1128 + ADC_MARGIN) :
                 (adc_accy > (12'd2265 - ADC_MARGIN)) ? (12'd2265 - ADC_MARGIN) :
                 adc_accy ),
        .adc_min(12'd1128 + ADC_MARGIN),  //ay min adc value
        .adc_max(12'd2265 - ADC_MARGIN),  //ay max adc value
        .servo_pwm(pwm_accy)
    );

endmodule
