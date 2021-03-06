// Systolic Arrays for n-body simulations
// Developed 2020/4/24 by William McInroy
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
  if (denom < 1e-8) begin
    f_ij = 0;
  end else begin
    f_ij = in_m_i * in_m_j * (in_q_j - in_q_i) / denom / denom / denom;  // Gravity causes errors, use in verlet
  end
//end

// always @(negedge clk) begin
  out_p_right <= in_p_right + f_ij;  // since 2x2, don't worry about diag
  out_p_down <= in_p_down - f_ij;
  out_q_i <= in_q_i;
  out_q_j <= in_q_j;
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
  // We don't multiply by gravity until the end
  out_q_i_t <= 2.0 * in_q_i_t - in_q_i_told + in_dt * in_dt * in_a_t * 6.67e-11;  // gravitional constant
  out_q_i_told <= in_q_i_t;
end

endmodule  // end of Verlet integration module


// This module computes a single 2x2 execution of the systolic array.
module systolic_2x2 (input wire clk,
		     input real q_0i,
		     input real q_1i,
		     input real q_0j,
		     input real q_1j,
		     input real m_0i,
		     input real m_1i,
		     input real m_0j,
		     input real m_1j,
		     input real pd_0,
		     input real pd_1,
		     input real pr_0,
		     input real pr_1,
	             output real out_pd_0,
	             output real out_pd_1,
	             output real out_pr_0,
	             output real out_pr_1);

// we define the accumulations as across each
// Note 2: Yes, we have to do a separate one for each block and cell in
// each execution. When we move to d > 1 then we can move to real matrices
// (unknown whether SystemVerilog supports, I believe it does?).
real pd_00, pd_01, pr_00, pr_10;

// We also use wires for positions/masses between cells to accurately simulate
real q_00i, q_00j, q_10i, q_01j,
     m_00i, m_00j, m_10i, m_01j;

systolic_n_body_2x2_cell b_00(.clk(clk),
                              .in_q_i(q_0i), .in_q_j(q_0j),
                              .in_m_i(m_0i), .in_m_j(m_0j),
                              .in_p_right(pr_0), .in_p_down(pd_0),
                              .out_q_i(q_00i), .out_q_j(q_00j),
                              .out_m_i(m_00i), .out_m_j(m_00j),
			      .out_p_right(pr_00),
                              .out_p_down(pd_00));
systolic_n_body_2x2_cell b_01(.clk(clk),
                              .in_q_i(q_00i), .in_q_j(q_1j),
                              .in_m_i(m_00i), .in_m_j(m_1j),
                              .in_p_right(pr_00), .in_p_down(pd_1),
                              .out_q_i(), .out_q_j(q_01j),
                              .out_m_i(), .out_m_j(m_01j),
			      .out_p_right(out_pr_0),
                              .out_p_down(pd_01));
systolic_n_body_2x2_cell b_10(.clk(clk),
                              .in_q_i(q_1i), .in_q_j(q_00j),
                              .in_m_i(m_1i), .in_m_j(m_00j),
                              .in_p_right(pr_1), .in_p_down(pd_00),
                              .out_q_i(q_10i), .out_q_j(),
                              .out_m_i(m_10i), .out_m_j(),
			      .out_p_right(pr_10),
                              .out_p_down(out_pd_0));
systolic_n_body_2x2_cell b_11(.clk(clk),
                              .in_q_i(q_10i), .in_q_j(q_01j),
                              .in_m_i(m_10i), .in_m_j(m_01j),
                              .in_p_right(pr_10), .in_p_down(pd_01),
                              .out_q_i(), .out_q_j(),
                              .out_m_i(), .out_m_j(),
			      .out_p_right(out_pr_1),
                              .out_p_down(out_pd_1));

endmodule  // end of the 2x2 execution


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
real pr_00_00, pr_00_10, pr_00_11,
     pd_00_00, pd_00_01,
     pr_01_00, pr_01_neg00, pr_01_10, pr_01_neg10,  // use a for out
     pd_01_00, pd_01_01, pd_01_neg01,  // use pd_11_neg for out
     pr_11_00, pr_11_10, pr_11_neg10,  // use a for out
     pd_11_00, pd_11_01, pd_11_neg01, pd_11_10, pd_11_11;

// We also use wires for positions/masses between cells to accurately simulate
real q_00_00i, q_00_00j, q_00_01j, q_00_10i,
     m_00_00i, m_00_00j, m_00_01j, m_00_10i,
     q_01_00i, q_01_00j, q_01_01j, q_01_10i,
     m_01_00i, m_01_00j, m_01_01j, m_01_10i,
     q_11_00i, q_11_00j, q_11_01j, q_11_10i,
     m_11_00i, m_11_00j, m_11_01j, m_11_10i;

systolic_n_body_2x2_cell b_00_00(.clk(clk),
                                 .in_q_i(q_1), .in_q_j(q_1),
                                 .in_m_i(m_1), .in_m_j(m_1),
                                 .in_p_right(), .in_p_down(),
                                 .out_q_i(q_00_00i), .out_q_j(q_00_00j),
                                 .out_m_i(m_00_00i), .out_m_j(m_00_00j),
			         .out_p_right(pr_00_00),
                                 .out_p_down(pd_00_00));
systolic_n_body_2x2_cell b_00_10(.clk(clk),
                                 .in_q_i(q_2), .in_q_j(q_00_00j),
                                 .in_m_i(m_2), .in_m_j(m_00_00j),
                                 .in_p_right(), .in_p_down(pd_00_00),
                                 .out_q_i(q_00_10i), .out_q_j(),
                                 .out_m_i(m_00_10i), .out_m_j(),
			         .out_p_right(pr_00_10),
                                 .out_p_down());
systolic_n_body_2x2_cell b_00_01(.clk(clk),
                                 .in_q_i(q_00_00i), .in_q_j(q_2),
                                 .in_m_i(m_00_00i), .in_m_j(m_2),
                                 .in_p_right(pr_00_00), .in_p_down(),
                                 .out_q_i(), .out_q_j(q_00_01j),
                                 .out_m_i(), .out_m_j(m_00_01j),
			         .out_p_right(pr_01_neg00),
                                 .out_p_down(pd_00_01));
systolic_n_body_2x2_cell b_00_11(.clk(clk),
                                 .in_q_i(q_00_10i), .in_q_j(q_00_01j),
                                 .in_m_i(m_00_10i), .in_m_j(m_00_01j),
                                 .in_p_right(pr_00_10), .in_p_down(pd_00_01),
                                 .out_q_i(), .out_q_j(),
                                 .out_m_i(), .out_m_j(),
			         .out_p_right(pr_01_neg10),
                                 .out_p_down());
systolic_n_body_2x2_cell b_01_00(.clk(clk),
                                 .in_q_i(q_1), .in_q_j(q_3),
                                 .in_m_i(m_1), .in_m_j(m_3),
                                 .in_p_right(pr_01_neg00), .in_p_down(),
                                 .out_q_i(q_01_00i), .out_q_j(q_01_00j),
                                 .out_m_i(m_01_00i), .out_m_j(m_01_00j),
			         .out_p_right(pr_01_00),
                                 .out_p_down(pd_01_00));
systolic_n_body_2x2_cell b_01_10(.clk(clk),
                                 .in_q_i(q_2), .in_q_j(q_01_00j),
                                 .in_m_i(m_2), .in_m_j(m_01_00j),
                                 .in_p_right(pr_01_neg10), .in_p_down(pd_01_00),
                                 .out_q_i(q_01_10i), .out_q_j(),
                                 .out_m_i(m_01_10i), .out_m_j(),
			         .out_p_right(pr_01_10),
                                 .out_p_down(pd_11_neg00));
systolic_n_body_2x2_cell b_01_01(.clk(clk),
                                 .in_q_i(q_01_00i), .in_q_j(q_4),
                                 .in_m_i(m_01_00i), .in_m_j(m_4),
                                 .in_p_right(pr_01_00), .in_p_down(),
                                 .out_q_i(), .out_q_j(q_01_01j),
                                 .out_m_i(), .out_m_j(m_01_01j),
			         .out_p_right(a_1),
                                 .out_p_down(pd_01_01));
systolic_n_body_2x2_cell b_01_11(.clk(clk),
                                 .in_q_i(q_01_10i), .in_q_j(q_01_01j),
                                 .in_m_i(m_01_10i), .in_m_j(m_01_01j),
                                 .in_p_right(pr_01_10), .in_p_down(pd_01_01),
                                 .out_q_i(), .out_q_j(),
                                 .out_m_i(), .out_m_j(),
			         .out_p_right(a_2),
                                 .out_p_down(pd_11_neg01));
systolic_n_body_2x2_cell b_11_00(.clk(clk),
                                 .in_q_i(q_3), .in_q_j(q_3),
                                 .in_m_i(m_3), .in_m_j(m_3),
                                 .in_p_right(pd_11_neg00), .in_p_down(pd_11_neg00),  // TODO mess wiring
                                 .out_q_i(q_11_00i), .out_q_j(q_11_00j),
                                 .out_m_i(m_11_00i), .out_m_j(m_11_00j),
			         .out_p_right(pr_11_00),
                                 .out_p_down(pd_11_00));
systolic_n_body_2x2_cell b_11_10(.clk(clk),
                                 .in_q_i(q_4), .in_q_j(q_11_00j),
                                 .in_m_i(m_4), .in_m_j(m_11_00j),
                                 .in_p_right(), .in_p_down(pd_11_00),
                                 .out_q_i(q_11_10i), .out_q_j(),
                                 .out_m_i(m_11_10i), .out_m_j(),
			         .out_p_right(pr_11_10),
                                 .out_p_down());
systolic_n_body_2x2_cell b_11_01(.clk(clk),
                                 .in_q_i(q_11_00i), .in_q_j(q_4),
                                 .in_m_i(m_11_00i), .in_m_j(m_4),
                                 .in_p_right(pr_11_00), .in_p_down(pd_11_neg01),
                                 .out_q_i(), .out_q_j(q_11_01j),
                                 .out_m_i(), .out_m_j(m_11_01j),
			         .out_p_right(a_3),
                                 .out_p_down(pd_11_01));
systolic_n_body_2x2_cell b_11_11(.clk(clk),
                                 .in_q_i(q_11_10i), .in_q_j(q_11_01j),
                                 .in_m_i(m_11_10i), .in_m_j(m_11_01j),
                                 .in_p_right(pd_11_01), .in_p_down(pd_11_01),  // TODO mess wiring for result
                                 .out_q_i(), .out_q_j(),
                                 .out_m_i(), .out_m_j(),
			         .out_p_right(a_4),
                                 .out_p_down());

endmodule  // end of 4 body module
