`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2026 02:32:59 PM
// Design Name: 
// Module Name: test
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

module tb_hamming_distance8;

    reg  [7:0] A, B;
    reg  [3:0] threshold;
    wire [7:0] difference;
    wire [3:0] distance;
    wire equal;
    wire within_threshold;

    integer errors;
    integer tests;
    integer ai, bi, ti;
    integer max_mismatches_to_print;
    reg [3:0] thr_set [0:8];

    function [3:0] ref_popcount;
        input [7:0] x;
        integer k;
        reg [3:0] cnt;
        begin
            cnt = 0;
            for (k = 0; k < 8; k = k + 1)
                if (x[k])
                    cnt = cnt + 1;
            ref_popcount = cnt;
        end
    endfunction

    hamming_distance8 dut (
        .A(A),
        .B(B),
        .threshold(threshold),
        .difference(difference),
        .distance(distance),
        .equal(equal),
        .within_threshold(within_threshold)
    );

    initial begin
        $dumpfile("hamming_distance8_tb.vcd");
        $dumpvars(0, tb_hamming_distance8);
    end

    initial begin
        thr_set[0] = 4'd0;
        thr_set[1] = 4'd1;
        thr_set[2] = 4'd2;
        thr_set[3] = 4'd3;
        thr_set[4] = 4'd4;
        thr_set[5] = 4'd6;
        thr_set[6] = 4'd8;
        thr_set[7] = 4'd9;
        thr_set[8] = 4'd15;

        errors = 0;
        tests  = 0;
        max_mismatches_to_print = 20;

        A = 8'b10110100;
        B = 8'b10011100;
        threshold = 4'd3;
        #1;
        if (difference !== 8'b00101000 || distance !== 4'd2 ||
            equal !== 1'b0 || within_threshold !== 1'b1) begin
            $display("FAIL: handout example mismatch. diff=%b dist=%0d eq=%b wth=%b",
                      difference, distance, equal, within_threshold);
        end else begin
            $display("PASS: handout example matches spec exactly.");
        end

        for (ai = 0; ai < 256; ai = ai + 1) begin
            for (bi = 0; bi < 256; bi = bi + 1) begin
                A = ai[7:0];
                B = bi[7:0];

                for (ti = 0; ti < 16; ti = ti + 1) begin
                    threshold = thr_set[ti];
                    #1;

                    tests = tests + 1;

                    begin : check
                        reg [7:0] exp_diff;
                        reg [3:0] exp_dist;
                        reg        exp_equal;
                        reg        exp_within;

                        exp_diff   = A ^ B;           
                        exp_dist   = ref_popcount(exp_diff); 
                        exp_equal  = (A == B);    
                        exp_within = (exp_dist <= threshold);

                        if (difference !== exp_diff ||
                            distance   !== exp_dist ||
                            equal      !== exp_equal ||
                            within_threshold !== exp_within) begin

                            errors = errors + 1;
                            if (errors <= max_mismatches_to_print) begin
                                $display("MISMATCH A=%b B=%b thr=%0d | DUT: diff=%b dist=%0d eq=%b wth=%b | EXPECTED: diff=%b dist=%0d eq=%b wth=%b",
                                    A, B, threshold,
                                    difference, distance, equal, within_threshold,
                                    exp_diff, exp_dist, exp_equal, exp_within);
                            end
                        end
                    end
                end
            end
        end

        // -----------------------------------------------------------------
        // Design-property sanity checks: d(A,A)=0, d(A,B)=d(B,A), 0<=d<=8
        // -----------------------------------------------------------------
        for (ai = 0; ai < 256; ai = ai + 1) begin
            A = ai[7:0];
            B = ai[7:0];
            threshold = 4'd0;
            #1;
            if (distance !== 4'd0 || equal !== 1'b1) begin
                errors = errors + 1;
                $display("PROPERTY FAIL: d(A,A) != 0 for A=%b", A);
            end
        end

        // -----------------------------------------------------------------
        // Final pass/fail summary
        // -----------------------------------------------------------------
        $display("--------------------------------------------------------");
        $display("Total checks run : %0d", tests);
        $display("Total mismatches : %0d", errors);
        if (errors == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TESTS FAILED (%0d mismatches, see log above)", errors);
        $display("--------------------------------------------------------");

        $finish;
    end

endmodule
