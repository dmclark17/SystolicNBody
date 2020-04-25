// Systolic Arrays for n-body simulations
// Developed 2020/4/24 by William McInroy, David Clark, and Aaron Jacobson
//
// This program simulates the implementation of the 2x2 systolic array cell
// found in 2x2_systolic_n_body.sv


// testbench for the numerical integration -- Confirmed
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


// testbench for a single systolic cell
module cell_tb;

reg clk;
real in_q_i;
real in_q_j;
real in_m_i;
real in_m_j;
real in_p_right;
real in_p_down;

real out_q_i;
real out_q_j;
real out_m_i;
real out_m_j;
real out_p_right;
real out_p_left;

systolic_n_body_2x2_cell UUT(.clk(clk),
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
  in_q_i = -2;
  in_q_j = -1;
  in_m_i = 1;
  in_m_j = 1;
  in_p_right = 0;
  in_p_down = 0;
  clk = 1;
  #10;
  $stop;
  clk = 0;
  #5;
  in_q_i = -2;
  in_q_j = 1;
  clk = 1;
  #10;
  $stop;
  clk = 0;
  #5;
  in_q_i = -2;
  in_q_j = 2;
  clk = 1;
  #10;
  $stop;

end

endmodule


// testbench for 2x2 with 4 bodies
module acceleration_tb;

reg clk;
real q_1,
     q_2,
     q_3,
     q_4,
     m_1,
     m_2,
     m_3,
     m_4,
     a_1,
     a_2,
     a_3,
     a_4;

systolic_4_body_2x2 UUT(.clk(clk),
		        .q_1(q_1),
                        .q_2(q_2),
                        .q_3(q_3),
                        .q_4(q_4),
		        .m_1(m_1),
                        .m_2(m_2),
                        .m_3(m_3),
                        .m_4(m_4),
		        .a_1(a_1),
                        .a_2(a_2),
                        .a_3(a_3),
                        .a_4(a_4));

initial begin

  // Initialize variables
  clk = 0;
  q_1 = -2.0;
  q_2 = -1.0;
  q_3 = 1.0;
  q_4 = 2.0;
  m_1 = 1.0;
  m_2 = 1.0;
  m_3 = 1.0;
  m_4 = 1.0;
  a_1 = 0;
  a_2 = 0;
  a_3 = 0;
  a_4 = 0;
  #200;
  $stop;

end

// always have clk taking care of sync across cells
initial begin
   forever #5 clk = ~clk;
end

endmodule;