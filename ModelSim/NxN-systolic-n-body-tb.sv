// Systolic Arrays for n-body simulations
// Developed 2020/6/10 by William McInroy
//
// This program simulates the implementation of the 2x2 systolic array cell
// found in NxN_systolic_n_body.sv


// testbench for a single systolic cell -- Confirmed
module NxN_cell_tb;

reg clk;
real in_q_i[3];
real in_q_j[3];
real in_m_i;
real in_m_j;
real in_p_right[3];
real in_p_down[3];

real out_q_i[3];
real out_q_j[3];
real out_m_i;
real out_m_j;
real out_p_right[3];
real out_p_down[3];

systolic_n_body_3D_cell UUT(.clk(clk),
                            .in_q_i(in_q_i),
			    .in_q_j(in_q_j),
                            .in_m_i(in_m_i),
			    .in_m_j(in_m_j),
                            .in_p_right(in_p_right),
			    .in_p_down(in_p_down),
                            .out_q_i(out_q_i),
			    .out_q_j(out_q_j),
                            .out_m_i(out_m_i),
			    .out_m_j(out_m_j),
			    .out_p_right(out_p_right),
			    .out_p_down(out_p_down));

// Create a test
initial begin

  // Initialize the variables
  in_q_i[0] = -3;
  in_q_i[1] = -2;
  in_q_i[2] = -2;
  in_q_j[0] = -1;
  in_q_j[1] = -1;
  in_q_j[2] = 0;
  in_m_i = 1;
  in_m_j = 1;
  in_p_right[0] = 0;
  in_p_right[1] = 0;
  in_p_right[2] = 0;
  in_p_down[0] = 0;
  in_p_down[1] = 0;
  in_p_down[2] = 0;
  clk = 1;
  #5;
  $stop;
  clk = 0;
  #5;
  in_q_i[0] = -2;
  in_q_i[1] = -2;
  in_q_i[2] = 0;
  in_q_j[0] = 2;
  in_q_j[1] = 2;
  in_q_j[2] = 2;
  clk = 1;
  #5;
  $stop;

end

endmodule