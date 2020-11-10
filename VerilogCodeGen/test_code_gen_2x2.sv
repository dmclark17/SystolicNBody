// Systolic array for n-body simulations. Generated code.
//
// This program implements a 2x2 systolic array for n-body simulations.


// We have ports for each input/output
module systolic_n_body_3D_cell(input wire clk,
                               input real in_q_i[3],
                               input real in_q_j[3],
                               input real in_m_i,
                               input real in_m_j,
                               input real in_p_right[3],
                               input real in_p_down[3],
                               output real out_q_i[3],
                               output real out_q_j[3],
                               output real out_m_i,
                               output real out_m_j,
                               output real out_p_right[3],
                               output real out_p_down[3]);

  real diff[3];
  real denom;
  real scale;
  real f_ij[3];

  // When the clock cycle hits the next input, then proceed with calculations
  always @(posedge clk) begin
    diff[0] = in_q_j[0] - in_q_i[0];
    diff[1] = in_q_j[1] - in_q_i[1];
    diff[2] = in_q_j[2] - in_q_i[2];
    denom = $sqrt(diff[0] * diff[0] + diff[1] * diff[1] + diff[2] * diff[2]);
    if (denom < 1e-8) begin
      f_ij[0] = 0;
      f_ij[1] = 0;
      f_ij[2] = 0;
    end else begin
      // Gravity causes errors, use in verlet
      scale = in_m_i * in_m_j / denom / denom / denom;
      f_ij[0] = scale * diff[0];
      f_ij[1] = scale * diff[1];
      f_ij[2] = scale * diff[2];
    end

    out_p_right[0] <= in_p_right[0] + f_ij[0];
    out_p_right[1] <= in_p_right[1] + f_ij[1];
    out_p_right[2] <= in_p_right[2] + f_ij[2];
    out_p_down[0] <= in_p_down[0] - f_ij[0];
    out_p_down[1] <= in_p_down[1] - f_ij[1];
    out_p_down[2] <= in_p_down[2] - f_ij[2];
    out_q_i[0] <= in_q_i[0];
    out_q_i[1] <= in_q_i[1];
    out_q_i[2] <= in_q_i[2];
    out_q_j[0] <= in_q_j[0];
    out_q_j[1] <= in_q_j[1];
    out_q_j[2] <= in_q_j[2];
    out_m_i <= in_m_i;
    out_m_j <= in_m_j;
  end

endmodule  // end of single systolic cell module


// This module computes a single 2x2 execution of the systolic array.
module systolic_2x2_3D(input wire clk,
                       input real q_0i[3],
                       input real q_1i[3],
                       input real q_0j[3],
                       input real q_1j[3],
                       input real m_0i,
                       input real m_1i,
                       input real m_0j,
                       input real m_1j,
                       input real pd_0[3],
                       input real pd_1[3],
                       input real pr_0[3],
                       input real pr_1[3],
                       output real out_pd_0[3],
                       output real out_pd_1[3],
                       output real out_pr_0[3],
                       output real out_pr_1[3]);

  // The accumulation across to the right wires (i, j)

  real pr_0_0[3],
       pr_1_0[3];

  // The accumulation downwards wires (i, j)

  real pd_0_0[3],
       pd_0_1[3];

  // The position passing wires to the right out of (i, j)

  real q_0_0_i[3],
       q_1_0_i[3];

  // The position passing wires downwards out of (i, j)

  real q_0_0_j[3],
       q_0_1_j[3];

  // The mass passing wires to the right out of (i, j)

  real m_0_0_i[3],
       m_1_0_i[3];

  // The mass passing wires downwards out of (i, j)

  real m_0_0_j[3],
       m_0_1_j[3];

  systolic_n_body_3D_cell b_0_0(.clk(clk),
                                .in_q_i(q_0i), .in_q_j(q_0j),
                                .in_m_i(m_0i), .in_m_j(m_0j),
                                .in_p_right(pr_0), .in_p_down(pd_0),
                                .out_q_i(q_0_0_i), .out_q_j(q_0_0_j),
                                .out_m_i(m_0_0_i), .out_m_j(m_0_0_j),
                                .out_p_right(pr_0_0),
                                .out_p_down(pd_0_0));
  systolic_n_body_3D_cell b_0_1(.clk(clk),
                                .in_q_i(q_0_0_i), .in_q_j(q_1j),
                                .in_m_i(m_0_0_i), .in_m_j(m_1j),
                                .in_p_right(pr_0_0), .in_p_down(pd_1),
                                .out_q_i(), .out_q_j(q_0_1_j),
                                .out_m_i(), .out_m_j(m_0_1_j),
                                .out_p_right(out_pr_0),
                                .out_p_down(pd_0_1));
  systolic_n_body_3D_cell b_1_0(.clk(clk),
                                .in_q_i(q_1i), .in_q_j(q_0_0_j),
                                .in_m_i(m_1i), .in_m_j(m_0_0_j),
                                .in_p_right(pr_1), .in_p_down(pd_0_0),
                                .out_q_i(q_1_0_i), .out_q_j(),
                                .out_m_i(m_1_0_i), .out_m_j(),
                                .out_p_right(pr_1_0),
                                .out_p_down(out_pd_0));
  systolic_n_body_3D_cell b_1_1(.clk(clk),
                                .in_q_i(q_1_0_i), .in_q_j(q_0_1_j),
                                .in_m_i(m_1_0_i), .in_m_j(m_0_1_j),
                                .in_p_right(pr_1_0), .in_p_down(pd_0_1),
                                .out_q_i(), .out_q_j(),
                                .out_m_i(), .out_m_j(),
                                .out_p_right(out_pr_1),
                                .out_p_down(out_pd_1));

endmodule  // end of the 2x2 execution