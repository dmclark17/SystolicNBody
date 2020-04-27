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

// Variables for the 
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

// Variables to pass to UUT
reg clk;
real Q_0i,
     Q_0j,
     Q_1i,
     Q_1j,
     M_0i,
     M_0j,
     M_1i,
     M_1j,
     PD_0,
     PD_1,
     PR_0,
     PR_1,
     OPD_0,
     OPD_1,
     OPR_0,
     OPR_1;

systolic_2x2 UUT(.clk(clk),
		 .q_0i(Q_0i),
		 .q_0j(Q_0j),
		 .q_1i(Q_1i),
		 .q_1j(Q_1j),
		 .m_0i(M_0i),
		 .m_0j(M_0j),
		 .m_1i(M_1i),
		 .m_1j(M_1j),
		 .pd_0(PD_0),
		 .pd_1(PD_1),
		 .pr_0(PR_0),
		 .pr_1(PR_1),
		 .out_pd_0(OPD_0),
		 .out_pd_1(OPD_1),
		 .out_pr_0(OPR_0),
		 .out_pr_1(OPR_1));

initial begin

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

  Q_0i = 0;
  Q_1j = 0;
  Q_0i = 0;
  Q_1j = 0;
  M_0i = 0;
  M_1j = 0;
  M_0i = 0;
  M_1j = 0;
  PD_0 = 0;
  PD_1 = 0;
  PR_0 = 0;
  PR_1 = 0;
  OPD_0 = 0;
  OPD_1 = 0;
  OPR_0 = 0;
  OPR_1 = 0;

  // test a single execution - works
  // #10; Q_0i = q_1; Q_0j = q_3; Q_1i = 0; Q_1j = 0;
  //      M_0i = m_1; M_0j = m_3; M_1i = 0; M_1j = 0;
  // #10; Q_0i = 0; Q_0j = 0; Q_1i = q_2; Q_1j = q_4;
  //      M_0i = 0; M_0j = 0; M_1i = m_2; M_1j = m_4;
  // $stop;
  // #10; Q_1i = 0; Q_1j = 0;
  //      M_1i = 0; M_1j = 0;
  // $stop;
  // #20; $stop;
  // Block order i: 10, 12, 32, 04
  //             j: 10, 32, 34, 04
  // First block first inputs
  #5; Q_0i = q_1; Q_0j = q_1; Q_1i = 0; Q_1j = 0;
       M_0i = q_1; M_0j = m_1; M_1i = 0; M_1j = 0;
  // Second block first inputs
  #10; $stop;
  Q_0i = q_1; Q_0j = q_3; Q_1i = q_2; Q_1j = q_2;
  M_0i = m_1; M_0j = m_3; M_1i = m_2; M_1j = m_2;
  // Third block first inputs - We now have block 0 pr0, pd0 outputs
  #10; $stop; // Got OPD_0 for 0 here
  Q_0i = q_3; Q_0j = q_3; Q_1i = q_2; Q_1j = q_4;
  M_0i = m_3; M_0j = m_3; M_1i = m_2; M_1j = m_4;
  a_2 = a_2 + OPD_0;  // Using diagonal trick instead
  // Third block final inputs - We now have block 1 pr0, pd0 and block 0 pr1, pd1 outputs
  #10; $stop; // Got OPR_0 for 0 here, OPD_0 for 1, OPR_1 
  Q_0i = 0; Q_0j = 0; Q_1i = q_4; Q_1j = q_4;
  M_0i = 0; M_0j = 0; M_1i = m_4; M_1j = m_4;
  a_1 = a_1 + OPR_0;
  // reset inputs - We now have block 2 pr0, pd0 and block 1 pr1, pd1 outputs
  #10; $stop;
  Q_0i = 0; Q_0j = 0; Q_1i = 0; Q_1j = 0;
  M_0i = 0; M_0j = 0; M_1i = 0; M_1j = 0;
  // finally get block 2 pr1, pd1 outputs
  #10; $stop;
  
end

// always have clk taking care of sync across cells
initial begin
  forever #5 clk = ~clk;
end

endmodule


// testbench for 2x2 with 4 bodies
module acceleration_block_tb;

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

endmodule