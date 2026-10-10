`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2026 02:05:33 PM
// Design Name: 
// Module Name: code
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux2_1_8bit (
    input wire [7:0] in0,
    input wire [7:0] in1,
    input wire sel,
    output wire [7:0] out
);
    assign out = sel ? in1 : in0;
endmodule

// -------------------------------------------------------------------------
// Top-Level Wrapper for Basys3 FPGA[span_3](start_span)[span_3](end_span)
// -------------------------------------------------------------------------
module hamming_wrapper (
    input wire clk,
    input wire [15:0] sw,
    output wire [15:0] led,
    output wire [3:0] an,
    output wire [6:0] seg,
    output wire dp
);

    // 1. Inputs[span_4](start_span)[span_4](end_span)
    wire [7:0] sw_data = sw[7:0]; // Operands A and B share SW7-SW0
    wire sw_sel = sw[8]; // 0 => write A, 1 => write B
    wire [3:0] threshold = sw[12:9]; // Threshold value

    // 2. Operand Registers and Next-State Logic[span_5](start_span)[span_5](end_span)
    reg [7:0] reg_A;
    reg [7:0] reg_B;
    wire [7:0] next_A;
    wire [7:0] next_B;

    mux2_1_8bit mux_A (
        .in0(sw_data), 
        .in1(reg_A), 
        .sel(sw_sel), 
        .out(next_A)
    );

    mux2_1_8bit mux_B (
        .in0(reg_B), 
        .in1(sw_data), 
        .sel(sw_sel), 
        .out(next_B)
    );

    always @(posedge clk) begin
        reg_A <= next_A;
        reg_B <= next_B;
    end

    // 3. Hamming Distance Engine (Lab 4a Instantiation)[span_6](start_span)[span_6](end_span)[span_7](start_span)[span_7](end_span)
    wire [7:0] diff_vector;
    wire [3:0] distance;
    wire equal_flag;
    wire within_thresh_flag;

    hamming_distance8 u_hamming (
        .A(reg_A),
        .B(reg_B),
        .threshold(threshold),
        .difference(diff_vector),
        .distance(distance),
        .equal(equal_flag),
        .within_threshold(within_thresh_flag)
    );

    // 4. LED Assignments[span_8](start_span)[span_8](end_span)
    assign led[7:0] = diff_vector;
    assign led[13:8] = 6'b000000;
    assign led[14] = within_thresh_flag;
    assign led[15] = equal_flag;

    // 5. Display Refresh Logic (From Lab 3)[span_9](start_span)[span_9](end_span)[span_10](start_span)[span_10](end_span)
    parameter REFRESH_COUNT = 17'd99999;
    reg [16:0] refresh_counter = 17'd0;
    reg [1:0] active_display = 2'b0;
    
    always @(posedge clk) begin
        if (refresh_counter == REFRESH_COUNT) begin
            refresh_counter <= 17'd0;
            active_display <= active_display + 2'b1;
        end else begin
            refresh_counter <= refresh_counter + 17'd1;
        end
    end 
    
    assign an[0] = (active_display == 2'b00) ? 1'b0 : 1'b1;
    assign an[1] = (active_display == 2'b01) ? 1'b0 : 1'b1;
    assign an[2] = (active_display == 2'b10) ? 1'b0 : 1'b1;
    assign an[3] = (active_display == 2'b11) ? 1'b0 : 1'b1; 
    assign dp = 1'b1; // Turn off decimal point

    // 6. Extended Seven-Segment Decoder[span_11](start_span)[span_11](end_span)
    reg [6:0] temp_seg;
    always @(*) begin
        case (active_display)
            2'b00: begin
                // Rightmost digit: distance 'd'
                case (distance)
                    4'd0: temp_seg = 7'b1000000;
                    4'd1: temp_seg = 7'b1111001;
                    4'd2: temp_seg = 7'b0100100;
                    4'd3: temp_seg = 7'b0110000;
                    4'd4: temp_seg = 7'b0011001;
                    4'd5: temp_seg = 7'b0010010;
                    4'd6: temp_seg = 7'b0000010;
                    4'd7: temp_seg = 7'b1111000;
                    4'd8: temp_seg = 7'b0000000;
                    default: temp_seg = 7'b1111111; 
                endcase
            end
            2'b01: begin
                // Third digit: '0'
                temp_seg = 7'b1000000;
            end
            2'b10, 2'b11: begin
                // Leftmost two digits: '-' (dash, segment G only)
                temp_seg = 7'b0111111;
            end
        endcase
    end
    
    assign seg = temp_seg;

endmodule
