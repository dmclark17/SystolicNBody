// Systolic Arrays for n-body simulations
// Developed 2020/4/24 by William McInroy, David Clark, and Aaron Jacobson
//
// This program implements a 2x2 systolic array for n-body simulations, note
// that the size of the systolic array may be scaled, but requires blocking
// with different accumulations across systolic calculations of on and off
// diagonal blocks. Further details may be found at TODO


// We need floating point numbers TODO which library?


// We begin with a 1-dimensional problem for simplicity and readability
// We have ports for each 
module systolic_n_body_2x2_cell(input wire clk,
				input wire reset,
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
  f_ij = 6.67e-10 * in_m_i * in_m_j * (in_q_j - in_q_i) / denom / denom / denom;
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
  out_q_i_t <= ((in_q_i_t - (2.0 * in_q_i_told)) +
	      	((in_dt * in_dt) * in_a_t));
  out_q_i_told <= in_q_i_t;
end

endmodule  // end of Verlet integration module


// This module feeds the input positions into the systolic array by the defined
// blocking procedure and performs numerical integration when ready
module systolic_n_body_2x2_blocking(input wire clk,
			            input wire reset);  // TODO, dynamic n size

endmodule  // end of blocking module
