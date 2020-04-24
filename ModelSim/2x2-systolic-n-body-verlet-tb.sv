// Systolic Arrays for n-body simulations
// Developed 2020/4/24 by William McInroy, David Clark, and Aaron Jacobson
//
// This program simulates the implementation of the 2x2 systolic array cell
// found in 2x2_systolic_n_body.sv


// include "2x2-systolic-n-body.sv";

// testbed for the numerical integration
module verlet_tb;

reg clk;
real in_q_i_told;
real in_q_i_t;
real in_a_t;
real in_dt;

real out_q_i_told;
real out_q_i_t;

systolic_n_body_2x2_integration UUT_Verlet(.clk(clk),
					   .in_q_i_told(in_q_i_told),
	                                   .in_q_i_t(in_q_i_t),
 			   	           .in_a_t(in_a_t),
	       				   .in_dt(in_dt),
	       				   .out_q_i_told(out_q_i_told),
	                                   .out_q_i_t(out_q_i_t));

// Create a test
initial begin

  // Initialize inputs
  in_q_i_told = 1.5;
  in_q_i_t = 4.0;
  in_a_t = 1.0;
  in_dt = 0.1;
  clk = 1;
  #100;
  $display(out_q_i_told);
  $display(out_q_i_t);
  $stop;

end

endmodule