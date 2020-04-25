// Systolic Arrays for n-body simulations
// Developed 2020/4/24 by William McInroy, David Clark, and Aaron Jacobson
//
// This program implements a 2x2 systolic array for n-body simulations, note
// that the size of the systolic array may be scaled, but requires blocking
// with different accumulations across systolic calculations of on and off
// diagonal blocks. Further details may be found at TODO
// NOTE: real is not synthesizable.


// We begin with a 1-dimensional problem for simplicity and readability
// We have ports for each input/output
module systolic_n_body_2x2_cell(input wire clk,
				input real in_q_i,
				input real in_q_j,
				input real in_m_i,
				input real in_m_j,
				input real in_p_right,
				input real in_p_down,
				output real out_q_i,
				output real out_q_j,
				output real out_m_i,
				output real out_m_j,
				output real out_p_right,
				output real out_p_down);

real denom;
real f_ij;

// When the clock cycle hits the next input, then proceed with calculations
always @(posedge clk) begin
  denom = $sqrt((in_q_i - in_q_j) * (in_q_i - in_q_j));
  if (denom < 1e-10) begin
    f_ij = 0;
  end else begin
    f_ij = 6.67e-10 * in_m_i * in_m_j * (in_q_j - in_q_i) / denom / denom / denom;
  end
  out_p_right <= in_p_right + f_ij;  // since 2x2, don't worry about diag
  out_p_down <= in_p_down - f_ij;
  out_q_i <= in_q_i;
  out_m_j <= in_q_j;
  out_m_i <= in_m_i;
  out_m_j <= in_m_j;
end

endmodule  // end of single systolic cell module


// This module handles Verlet integration of the updated positions, which can
// be computed at the conclusion of a row of blocks
module systolic_n_body_2x2_integration(input wire clk,
				       input real in_q_i_told,
				       input real in_q_i_t,
				       input real in_a_t,
				       input real in_dt,
				       output real out_q_i_told,
				       output real out_q_i_t);
always @(posedge clk) begin
  out_q_i_t <= 2.0 * in_q_i_t - in_q_i_told + in_dt * in_dt * in_a_t;
  out_q_i_told <= in_q_i_t;
end

endmodule  // end of Verlet integration module


// This module computes the accelerations of 4 bodies using a 2x2 systolic array
// For dynamic bodies, we may have to split into each execution of the array and
// handle the pipelining in software? TODO on how to do that outside of testbench
module systolic_4_body_2x2(input wire clk,
		           input real q_1,
			   input real q_2,
			   input real q_3,
			   input real q_4,
			   input real m_1,
			   input real m_2,
			   input real m_3,
		           input real m_4,
			   output real a_1,
	  		   output real a_2,
			   output real a_3,
		           output real a_4);

// we define the accumulations as wires so the simulation doesn't store to memory.
// Note: pr_ij_uv is p right ij uv, likewise for pd_ij_uv.
// Note 2: Yes, we have to do a separate one for each block and cell in
// each execution. When we move to d > 1 then we can move to real matrices
// (unknown whether SystemVerilog supports, I believe it does?).
wire pr_00_00, pr_00_neg00, pr_00_10, pr_00_neg10,
     pd_00_00, pd_00_neg00, pd_00_01, pd_00_neg01,
     pr_01_00, pr_01_neg00, pr_01_10, pr_01_neg10,
     pd_01_00, pd_01_neg00, pd_01_01, pd_01_neg01,
     pr_11_00, pr_11_neg00, pr_11_10, pr_11_neg10,
     pd_11_00, pd_11_neg00, pd_11_01, pd_11_neg01;

// We also use wires for positions/masses between cells to accurately simulate
wire q_00_00, q_00_01, q_00_10, q_00_11,
     m_00_00, m_00_01, m_00_10, m_00_11,
     q_01_00, q_01_01, q_01_10, q_01_11,
     m_01_00, m_01_01, m_01_10, m_01_11,
     q_11_00, q_11_01, q_11_10, q_11_11,
     m_11_00, m_11_01, m_11_10, m_11_11;

systolic_n_body_2x2_cell b_00_00(.clk(clk),
                                 .in_q_i(q_1), .in_q_j(q_1),
                                 .in_m_i(m_1), .in_m_j(m_1),
                                 .in_p_right(pr_00_neg00), .in_p_down(pd_00_neg00),
                                 .out_q_i(q_00_01), .out_q_j(q_00_10),
                                 .out_m_i(m_00_01), .out_m_j(q_00_10),
			         .out_p_right(pr_00_00),
                                 .out_p_down(pd_00_00));
// TODO fix the q, m broadcasts
systolic_n_body_2x2_cell b_00_10(.clk(clk),
                                 .in_q_i(q_2), .in_q_j(q_00_10),
                                 .in_m_i(m_2), .in_m_j(m_00_10),
                                 .in_p_right(pr_00_neg10), .in_p_down(pd_00_00),
                                 .out_q_i(q_00_10), .out_q_j(q_00_01),
                                 .out_m_i(m_00_10), .out_m_j(q_00_01),
			         .out_p_right(pr_00_10),
                                 .out_p_down(pd_00_00));
systolic_n_body_2x2_cell b_00_01(.clk(clk),
                                 .in_q_i(q_00_10), .in_q_j(q_1),
                                 .in_m_i(m_00_10), .in_m_j(m_1),
                                 .in_p_right(pr_00_00), .in_p_down(pd_00_neg01),
                                 .out_q_i(q_00_10), .out_q_j(q_00_01),
                                 .out_m_i(m_00_10), .out_m_j(q_00_01),
			         .out_p_right(pr_01_neg00),
                                 .out_p_down(pd_00_01));
// TODO fix the q, m inputs
systolic_n_body_2x2_cell b_00_11(.clk(clk),
                                 .in_q_i(q_00_10), .in_q_j(q_1),
                                 .in_m_i(m_00_10), .in_m_j(m_1),
                                 .in_p_right(pr_00_00), .in_p_down(pd_00_neg01),
                                 .out_q_i(q_00_10), .out_q_j(q_00_01),
                                 .out_m_i(m_00_10), .out_m_j(q_00_01),
			         .out_p_right(pr_01_neg10),
                                 .out_p_down(pd_00_01));  // TODO no down

endmodule  // end of 4 body module
