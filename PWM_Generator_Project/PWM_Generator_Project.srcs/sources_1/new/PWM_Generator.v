// PWM Generator with Variable Duty Cycle
// Fixed: Output declaration, concurrent assignments, debounce logic

module PWM_Generator (
    input clk,                // 100MHz Clock Input
    input increase_duty,       // Button to increase duty cycle
    input decrease_duty,       // Button to decrease duty cycle
    output reg PWM_OUT         // PWM Output
);

// Internal Registers
reg [3:0] DUTY_CYCLE = 5;       // Initial Duty Cycle (50%)
reg [3:0] counter_PWM = 0;      // Counter for PWM
reg [27:0] counter_debounce = 0;// Counter for debounce clock

wire slow_clk_enable;           // Slow Clock Enable Signal
wire duty_inc, duty_dec;        // Debounced signals

// Generate Slow Clock Enable Signal (For Button Debounce)
always @(posedge clk) begin
    counter_debounce <= counter_debounce + 1;
    if (counter_debounce >= 25000000)  // 4Hz debounce clock for FPGA
        counter_debounce <= 0;
end
assign slow_clk_enable = (counter_debounce == 25000000) ? 1 : 0;

// Debounce Flip-Flops for Increase Duty Button
reg tmp1, tmp2;
always @(posedge clk) begin
    if (slow_clk_enable) begin
        tmp1 <= increase_duty;
        tmp2 <= tmp1;
    end
end
assign duty_inc = tmp1 & ~tmp2 & slow_clk_enable;

// Debounce Flip-Flops for Decrease Duty Button
reg tmp3, tmp4;
always @(posedge clk) begin
    if (slow_clk_enable) begin
        tmp3 <= decrease_duty;
        tmp4 <= tmp3;
    end
end
assign duty_dec = tmp3 & ~tmp4 & slow_clk_enable;

// Adjust Duty Cycle
always @(posedge clk) begin
    if (duty_inc && DUTY_CYCLE < 9)
        DUTY_CYCLE <= DUTY_CYCLE + 1;  // Increase duty cycle by 10%
    else if (duty_dec && DUTY_CYCLE > 1)
        DUTY_CYCLE <= DUTY_CYCLE - 1;  // Decrease duty cycle by 10%
end

// PWM Signal Generation (10MHz)
always @(posedge clk) begin
    counter_PWM <= counter_PWM + 1;
    if (counter_PWM >= 9)
        counter_PWM <= 0;
end

always @(posedge clk) begin
    PWM_OUT <= (counter_PWM < DUTY_CYCLE) ? 1 : 0;
end

endmodule
