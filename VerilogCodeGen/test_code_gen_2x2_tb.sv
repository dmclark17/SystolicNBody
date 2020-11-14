// Systolic array for n-body simulations. Generated code.
//
// This program implements a testbench of a 2x2 systolic array for n-body simulations.


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


// testbench for 2x2 acceleration with 4 bodies -- Confirmed
module acceleration_3D_tb;

// Variables for the software side
real q_0[3],
     q_1[3],
     q_2[3],
     q_3[3],
     a_0[3],
     a_1[3],
     a_2[3],
     a_3[3],
     m_0,
     m_1,
     m_2,
     m_3;

// Variables to pass to the UUT
reg clk;
real Q_0i[3],
     Q_1i[3],
     Q_0j[3],
     Q_1j[3],
     M_0i,
     M_1i,
     M_0j,
     M_1j,
     PR_0[3],
     PR_1[3],
     PD_0[3],
     PD_1[3],
     OPR_0[3],
     OPR_1[3],
     OPD_0[3],
     OPD_1[3];

systolic_2x2_3D UUT(.clk(clk),
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
  q_0[0] = 0; q_0[1] = 0; q_0[2] = 0;
  q_1[0] = 0; q_1[1] = 0; q_1[2] = 0;
  q_2[0] = 0; q_2[1] = 0; q_2[2] = 0;
  q_3[0] = 0; q_3[1] = 0; q_3[2] = 0;
  a_0[0] = 0; a_0[1] = 0; a_0[2] = 0;
  a_1[0] = 0; a_1[1] = 0; a_1[2] = 0;
  a_2[0] = 0; a_2[1] = 0; a_2[2] = 0;
  a_3[0] = 0; a_3[1] = 0; a_3[2] = 0;
  m_0 = 1;
  m_1 = 1;
  m_2 = 1;
  m_3 = 1;

  Q_0i[0] = 0; Q_0i[1] = 0; Q_0i[2] = 0;
  Q_1i[0] = 0; Q_1i[1] = 0; Q_1i[2] = 0;
  Q_0j[0] = 0; Q_0j[1] = 0; Q_0j[2] = 0;
  Q_1j[0] = 0; Q_1j[1] = 0; Q_1j[2] = 0;
  M_0i = 0;
  M_1i = 0;
  M_0j = 0;
  M_1j = 0;
  PD_0[0] = 0; PD_0[1] = 0; PD_0[2] = 0;
  PD_1[0] = 0; PD_1[1] = 0; PD_1[2] = 0;
  PR_0[0] = 0; PR_0[1] = 0; PR_0[2] = 0;
  PR_1[0] = 0; PR_1[1] = 0; PR_1[2] = 0;
  OPD_0[0] = 0; OPD_0[1] = 0; OPD_0[2] = 0;
  OPD_1[0] = 0; OPD_1[1] = 0; OPD_1[2] = 0;
  OPR_0[0] = 0; OPR_0[1] = 0; OPR_0[2] = 0;
  OPR_1[0] = 0; OPR_1[1] = 0; OPR_1[2] = 0;

  //// compute step 0
  #10; $stop;
  
  Q_0i = q_0; M_0i = m_0;
  Q_1i[1] = 0; Q_1i[1] = 0; Q_1i[1] = 0; M_1i = 0;
  
  Q_0j = q_0; M_0j = m_0;
  Q_1j[1] = 0; Q_1j[1] = 0; Q_1j[1] = 0; M_1j = 0;

  // increment outputs

  //// compute step 1
  #10; $stop;
  
  Q_0i = q_0; M_0i = m_0;
  Q_1i = q_1; M_1i = m_1;
  
  Q_0j = q_0; M_0j = m_0;
  Q_1j = q_1; M_1j = m_1;

  // increment outputs

  //// compute step 2
  #10; $stop;
  Q_0i = q_0; M_0i = m_0;
  Q_1i = q_1; M_1i = m_1;

  Q_0j = q_2; M_0j = m_2;
  Q_1j = q_1; M_1j = m_1;

  // increment outputs
  
  a_0[0] = a_0[0] + OPR_0[0]; a_0[1] = a_0[1] + OPR_0[1]; a_0[2] = a_0[2] + OPR_0[2];
  
  a_1[0] = a_1[0] + OPR_1[0]; a_1[1] = a_1[1] + OPR_1[1]; a_1[2] = a_1[2] + OPR_1[2];
  

  //// compute step 3
  #10; $stop;
  
  Q_0i = q_0; M_0i = m_0;
  Q_1i = q_1; M_1i = m_1;
  
  Q_0j = q_2; M_0j = m_2;
  Q_1j = q_3; M_1j = m_3;

  // increment outputs
  
  a_0[0] = a_0[0] + OPR_0[0]; a_0[1] = a_0[1] + OPR_0[1]; a_0[2] = a_0[2] + OPR_0[2];
  
  a_1[0] = a_1[0] + OPR_1[0]; a_1[1] = a_1[1] + OPR_1[1]; a_1[2] = a_1[2] + OPR_1[2];
  

  //// compute step 4
  #10; $stop;
  Q_0i = q_2; M_0i = m_2;
  Q_1i = q_1; M_1i = m_1;

  Q_0j = q_2; M_0j = m_2;
  Q_1j = q_3; M_1j = m_3;

  // increment outputs
  a_0[0] = a_0[0] + OPR_0[0]; a_0[1] = a_0[1] + OPR_0[1]; a_0[2] = a_0[2] + OPR_0[2];
  a_2[0] = a_2[0] + OPD_0[0]; a_2[1] = a_2[1] + OPD_0[1]; a_2[2] = a_2[2] + OPD_0[2];
  a_1[0] = a_1[0] + OPR_1[0]; a_1[1] = a_1[1] + OPR_1[1]; a_1[2] = a_1[2] + OPR_1[2];
  

  //// compute step 5
  #10; $stop;
  
  Q_0i = q_2; M_0i = m_2;
  Q_1i = q_3; M_1i = m_3;
  
  Q_0j = q_2; M_0j = m_2;
  Q_1j = q_3; M_1j = m_3;

  // increment outputs
  
  a_0[0] = a_0[0] + OPR_0[0]; a_0[1] = a_0[1] + OPR_0[1]; a_0[2] = a_0[2] + OPR_0[2];
  a_2[0] = a_2[0] + OPD_0[0]; a_2[1] = a_2[1] + OPD_0[1]; a_2[2] = a_2[2] + OPD_0[2];
  a_1[0] = a_1[0] + OPR_1[0]; a_1[1] = a_1[1] + OPR_1[1]; a_1[2] = a_1[2] + OPR_1[2];
  a_3[0] = a_3[0] + OPD_1[0]; a_3[1] = a_3[1] + OPD_1[1]; a_3[2] = a_3[2] + OPD_1[2];

  //// compute step 6
  #10; $stop;
  Q_0i[1] = 0; Q_0i[1] = 0; Q_0i[1] = 0; M_0i = 0;
  Q_1i = q_3; M_1i = m_3;

  Q_0j[1] = 0; Q_0j[1] = 0; Q_0j[1] = 0; M_0j = 0;
  Q_1j = q_3; M_1j = m_3;

  // increment outputs
  a_2[0] = a_2[0] + OPR_0[0]; a_2[1] = a_2[1] + OPR_0[1]; a_2[2] = a_2[2] + OPR_0[2];
  
  a_1[0] = a_1[0] + OPR_1[0]; a_1[1] = a_1[1] + OPR_1[1]; a_1[2] = a_1[2] + OPR_1[2];
  a_3[0] = a_3[0] + OPD_1[0]; a_3[1] = a_3[1] + OPD_1[1]; a_3[2] = a_3[2] + OPD_1[2];

  //// compute step 7
  #10; $stop;
  Q_0i[1] = 0; Q_0i[1] = 0; Q_0i[1] = 0; M_0i = 0;
  Q_1i[1] = 0; Q_1i[1] = 0; Q_1i[1] = 0; M_1i = 0;
  Q_0j[1] = 0; Q_0j[1] = 0; Q_0j[1] = 0; M_0j = 0;
  Q_1j[1] = 0; Q_1j[1] = 0; Q_1j[1] = 0; M_1j = 0;

  // increment outputs
  
  a_2[0] = a_2[0] + OPR_0[0]; a_2[1] = a_2[1] + OPR_0[1]; a_2[2] = a_2[2] + OPR_0[2];
  
  a_3[0] = a_3[0] + OPR_1[0]; a_3[1] = a_3[1] + OPR_1[1]; a_3[2] = a_3[2] + OPR_1[2];
  

  //// compute step 8
  #10; $stop;
  Q_0i[1] = 0; Q_0i[1] = 0; Q_0i[1] = 0; M_0i = 0;
  Q_1i[1] = 0; Q_1i[1] = 0; Q_1i[1] = 0; M_1i = 0;
  Q_0j[1] = 0; Q_0j[1] = 0; Q_0j[1] = 0; M_0j = 0;
  Q_1j[1] = 0; Q_1j[1] = 0; Q_1j[1] = 0; M_1j = 0;

  // increment outputs
  
  
  a_3[0] = a_3[0] + OPR_1[0]; a_3[1] = a_3[1] + OPR_1[1]; a_3[2] = a_3[2] + OPR_1[2];
  

end

// always have clk taking care of sync across cells
initial begin
  forever #5 clk = ~clk;]
end

endmodule