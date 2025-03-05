`timescale 1ns / 1ps

// Testbench for PWM Generator with Variable Duty Cycle
module tb_PWM_Generator;

    // Inputs
    reg clk;
    reg increase_duty;
    reg decrease_duty;

    // Outputs
    wire PWM_OUT;

    // Instantiate PWM Generator Module
    PWM_Generator uut (
        .clk(clk),
        .increase_duty(increase_duty),
        .decrease_duty(decrease_duty),
        .PWM_OUT(PWM_OUT)
    );

    // Generate 100MHz Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period (100MHz)
    end

    // Test Sequence
    initial begin
        // Initialize Inputs
        increase_duty = 0;
        decrease_duty = 0;

        #100;
        increase_duty = 1; #50; increase_duty = 0;  // Increase duty cycle
        #200;
        increase_duty = 1; #50; increase_duty = 0;
        #200;
        increase_duty = 1; #50; increase_duty = 0;
        #200;

        decrease_duty = 1; #50; decrease_duty = 0;  // Decrease duty cycle
        #200;
        decrease_duty = 1; #50; decrease_duty = 0;
        #200;
        decrease_duty = 1; #50; decrease_duty = 0;

        #500;
        $stop;  // End Simulation
    end

endmodule
