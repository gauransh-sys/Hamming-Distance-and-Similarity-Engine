`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2026 02:18:23 PM
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

module full_adder(
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b;
    assign cout = a & b;
endmodule

module popcount8 (
    input  wire [7:0] bits,
    output wire [3:0] count
);
    wire s0, c0, s1, c1, s2, c2;
    wire s3, c3;
    wire s4, c4, s5, c5;
    wire s6, c6;
    wire s7, c7;

    // Stage 1: reduce 8 weight-1 bits to 3 sum bits + 3 carry bits
    full_adder FA1 (.a(bits[0]), .b(bits[1]), .cin(bits[2]), .sum(s0), .cout(c0));
    full_adder FA2 (.a(bits[3]), .b(bits[4]), .cin(bits[5]), .sum(s1), .cout(c1));
    half_adder HA1 (.a(bits[6]), .b(bits[7]),                .sum(s2), .cout(c2));

    // Stage 2: combine the three weight-1 sum bits
    full_adder FA3 (.a(s0), .b(s1), .cin(s2), .sum(s3), .cout(c3));

    // Stage 3: combine the four weight-2 carry bits (c0,c1,c2,c3)
    half_adder HA2 (.a(c0), .b(c1), .sum(s4), .cout(c4));
    half_adder HA3 (.a(c2), .b(c3), .sum(s5), .cout(c5));

    // Stage 4: combine the two weight-2 sum bits
    half_adder HA4 (.a(s4), .b(s5), .sum(s6), .cout(c6));

    // Stage 5: combine the three weight-4 carry bits
    full_adder FA4 (.a(c4), .b(c5), .cin(c6), .sum(s7), .cout(c7));

    assign count = {c7, s7, s6, s3};
endmodule

module comparator8_eq (
    input  wire [7:0] diff,
    output wire        eq
);
    wire e0, e1, e2, e3, e4, e5, e6, e7;
    not (e0, diff[0]);
    not (e1, diff[1]);
    not (e2, diff[2]);
    not (e3, diff[3]);
    not (e4, diff[4]);
    not (e5, diff[5]);
    not (e6, diff[6]);
    not (e7, diff[7]);

    wire a01, a23, a45, a67;
    and (a01, e0, e1);
    and (a23, e2, e3);
    and (a45, e4, e5);
    and (a67, e6, e7);

    wire a0123, a4567;
    and (a0123, a01, a23);
    and (a4567, a45, a67);

    and (eq, a0123, a4567);
endmodule

module comparator4 (
    input  wire [3:0] A,
    input  wire [3:0] B,
    output wire eq,
    output wire lt,
    output wire gt
);
    wire e3, e2, e1, e0;
    wire g3, g2, g1, g0;
    wire l3, l2, l1, l0;

    assign e3 = ~(A[3] ^ B[3]);
    assign e2 = ~(A[2] ^ B[2]);
    assign e1 = ~(A[1] ^ B[1]);
    assign e0 = ~(A[0] ^ B[0]);

    assign g3 = A[3] & ~B[3];
    assign g2 = A[2] & ~B[2];
    assign g1 = A[1] & ~B[1];
    assign g0 = A[0] & ~B[0];

    assign l3 = ~A[3] & B[3];
    assign l2 = ~A[2] & B[2];
    assign l1 = ~A[1] & B[1];
    assign l0 = ~A[0] & B[0];

    assign eq = e3 & e2 & e1 & e0;
    assign gt = g3 | (e3 & g2) | (e3 & e2 & g1) | (e3 & e2 & e1 & g0);
    assign lt = l3 | (e3 & l2) | (e3 & e2 & l1) | (e3 & e2 & e1 & l0);
endmodule

module hamming_distance8 (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [3:0] threshold,
    output wire [7:0] difference,
    output wire [3:0] distance,
    output wire        equal,
    output wire        within_threshold
);
    
    assign difference = A ^ B;

    popcount8 u_popcount (
        .bits (difference),
        .count(distance)
    );

    comparator8_eq u_eqcmp (
        .diff(difference),
        .eq  (equal)
    );

    wire cmp_lt, cmp_eq, cmp_gt;
    comparator4 u_thcmp (
        .A (distance),
        .B (threshold),
        .eq(cmp_eq),
        .lt(cmp_lt),
        .gt(cmp_gt)
    );

    assign within_threshold = cmp_lt | cmp_eq;

endmodule



