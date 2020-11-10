# systolic_n_body_codegen.py
#
# This program automates SystemVerilog code generation of a Systolic array of
# a given size for use in n body simulations.
#
# Developed by William McInroy, 2020/07/17.

import argparse


def parse_args():
    parser = argparse.ArgumentParser(
        description='A script to automatically generate SystemVerilog code '
                    'for n-body simulations with systolic arrays.')
    parser.add_argument('design_file', type=str,
                        help='Path pointing to the output design .sv file.')
    parser.add_argument('tb_file', type=str,
                        help='Path pointing to the output testbench .sv file.')
    parser.add_argument('N', type=int,
                        help='The size of the systolic array.')
    parser.add_argument('n', type=int,
                        help='The number of bodies for testbench file.')
    return parser.parse_args()


def generate_design_code(N):
    """A function to generate the SystemVerilog code for a systolic n-body.

    TODO: change from real to some synthesizable other form.
    """
    # start with the header
    code = ('// Systolic array for n-body simulations. Generated code.\n'
            '//\n'
            '// This program implements a {0}x{0} '.format(N) +
            'systolic array for n-body simulations.\n\n\n')
    # add the cell code
    code += ('// We have ports for each input/output\n'
             'module systolic_n_body_3D_cell(input wire clk,\n'
             '                               input real in_q_i[3],\n'
             '                               input real in_q_j[3],\n'
             '                               input real in_m_i,\n'
             '                               input real in_m_j,\n'
             '                               input real in_p_right[3],\n'
             '                               input real in_p_down[3],\n'
             '                               output real out_q_i[3],\n'
             '                               output real out_q_j[3],\n'
             '                               output real out_m_i,\n'
             '                               output real out_m_j,\n'
             '                               output real out_p_right[3],\n'
             '                               output real out_p_down[3]);\n\n'
             '  real diff[3];\n'
             '  real denom;\n'
             '  real scale;\n'
             '  real f_ij[3];\n\n'

             '  // When the clock cycle hits the next input, '
             'then proceed with calculations\n'
             '  always @(posedge clk) begin\n'
             '    diff[0] = in_q_j[0] - in_q_i[0];\n'
             '    diff[1] = in_q_j[1] - in_q_i[1];\n'
             '    diff[2] = in_q_j[2] - in_q_i[2];\n'
             '    denom = $sqrt(diff[0] * diff[0] + diff[1] * diff[1] + '
             'diff[2] * diff[2]);\n'
             '    if (denom < 1e-8) begin\n'
             '      f_ij[0] = 0;\n'
             '      f_ij[1] = 0;\n'
             '      f_ij[2] = 0;\n'
             '    end else begin\n'
             '      // Gravity causes errors, use in verlet\n'
             '      scale = in_m_i * in_m_j / denom / denom / denom;\n'
             '      f_ij[0] = scale * diff[0];\n'
             '      f_ij[1] = scale * diff[1];\n'
             '      f_ij[2] = scale * diff[2];\n'
             '    end\n\n'
             '    out_p_right[0] <= in_p_right[0] + f_ij[0];\n'
             '    out_p_right[1] <= in_p_right[1] + f_ij[1];\n'
             '    out_p_right[2] <= in_p_right[2] + f_ij[2];\n'
             '    out_p_down[0] <= in_p_down[0] - f_ij[0];\n'
             '    out_p_down[1] <= in_p_down[1] - f_ij[1];\n'
             '    out_p_down[2] <= in_p_down[2] - f_ij[2];\n'
             '    out_q_i[0] <= in_q_i[0];\n'
             '    out_q_i[1] <= in_q_i[1];\n'
             '    out_q_i[2] <= in_q_i[2];\n'
             '    out_q_j[0] <= in_q_j[0];\n'
             '    out_q_j[1] <= in_q_j[1];\n'
             '    out_q_j[2] <= in_q_j[2];\n'
             '    out_m_i <= in_m_i;\n'
             '    out_m_j <= in_m_j;\n'
             '  end\n\n'
             'endmodule  // end of single systolic cell module\n\n\n')

    # Now we add the design for the NxN array on the chip (assume it fits)

    # the module definition
    s = '\n' + (' ' * len('module systolic_{0}x{0}_3D('.format(N)))
    code += ('// This module computes a single {0}x{0} '.format(N) +
             'execution of the systolic array.\n'
             'module systolic_{0}x{0}_3D(input wire clk,'.format(N) + s +
             s.join(['input real q_' + str(i) + 'i[3],'  # input row pos
                     for i in range(N)]) + s +
             s.join(['input real q_' + str(i) + 'j[3],'  # input col pos
                     for i in range(N)]) + s +
             s.join(['input real m_' + str(i) + 'i,'  # input row mass
                     for i in range(N)]) + s +
             s.join(['input real m_' + str(i) + 'j,'  # input col mass
                     for i in range(N)]) + s +
             s.join(['input real pd_' + str(i) + '[3],'  # input down acc
                     for i in range(N)]) + s +
             s.join(['input real pr_' + str(i) + '[3],'  # input right acc
                     for i in range(N)]) + s +
             s.join(['output real out_pd_' + str(i) + '[3],'  # out down
                     for i in range(N)]) + s +
             s.join(['output real out_pr_' + str(i) + '[3],'  # out right
                     for i in range(N)])[:-1] + ');\n')

    # local wires: accumulations across/downwards, positions, masses
    s = '\n' + (' ' * len('  real '))
    code += ('\n  // The accumulation across to the right wires (i, j)\n'
             '\n  real ' +
             s.join(['pr_{0}_{1}[3],'.format(i, j)
                     for i in range(N) for j in range(N - 1)])[:-1] + ';')
    code += ('\n\n  // The accumulation downwards wires (i, j)\n'
             '\n  real ' +
             s.join(['pd_{0}_{1}[3],'.format(i, j)
                     for i in range(N - 1) for j in range(N)])[:-1] + ';')
    code += ('\n\n  // The position passing wires to the right out of (i, j)\n'
             '\n  real ' +
             s.join(['q_{0}_{1}_i[3],'.format(i, j)
                     for i in range(N) for j in range(N - 1)])[:-1] + ';')
    code += ('\n\n  // The position passing wires downwards out of (i, j)\n'
             '\n  real ' +
             s.join(['q_{0}_{1}_j[3],'.format(i, j)
                     for i in range(N - 1) for j in range(N)])[:-1] + ';')
    code += ('\n\n  // The mass passing wires to the right out of (i, j)\n'
             '\n  real ' +
             s.join(['m_{0}_{1}_i[3],'.format(i, j)
                     for i in range(N) for j in range(N - 1)])[:-1] + ';')
    code += ('\n\n  // The mass passing wires downwards out of (i, j)\n'
             '\n  real ' +
             s.join(['m_{0}_{1}_j[3],'.format(i, j)
                     for i in range(N - 1) for j in range(N)])[:-1] + ';')

    # the systolic cells. Cases for edges of array use input/output of module
    code += ('\n\n' + '\n'
             .join(['  systolic_n_body_3D_cell b_{0}_{1}(.clk(clk),'
                    .format(i, j) +
                    '\n' + (' ' * len('  systolic_n_body_3D_cell b_{0}_{1}('
                                      .format(i, j))) +
                    '.in_q_i({0}), .in_q_j({1}),'
                    .format('q_{0}i'.format(i) if j == 0 else
                            'q_{0}_{1}_i'.format(i, j - 1),
                            'q_{0}j'.format(j) if i == 0 else
                            'q_{0}_{1}_j'.format(i - 1, j)) +
                    '\n' + (' ' * len('  systolic_n_body_3D_cell b_{0}_{1}('
                                      .format(i, j))) +
                    '.in_m_i({0}), .in_m_j({1}),'
                    .format('m_{0}i'.format(i) if j == 0 else
                            'm_{0}_{1}_i'.format(i, j - 1),
                            'm_{0}j'.format(j) if i == 0 else
                            'm_{0}_{1}_j'.format(i - 1, j)) +
                    '\n' + (' ' * len('  systolic_n_body_3D_cell b_{0}_{1}('
                                      .format(i, j))) +
                    '.in_p_right({0}), .in_p_down({1}),'
                    .format('pr_{0}'.format(i) if j == 0 else
                            'pr_{0}_{1}'.format(i, j - 1),
                            'pd_{0}'.format(j) if i == 0 else
                            'pd_{0}_{1}'.format(i - 1, j)) +
                    '\n' + (' ' * len('  systolic_n_body_3D_cell b_{0}_{1}('
                                      .format(i, j))) +
                    '.out_q_i({0}), .out_q_j({1}),'
                    .format('' if j == N - 1 else
                            'q_{0}_{1}_i'.format(i, j),
                            '' if i == N - 1 else
                            'q_{0}_{1}_j'.format(i, j)) +
                    '\n' + (' ' * len('  systolic_n_body_3D_cell b_{0}_{1}('
                                      .format(i, j))) +
                    '.out_m_i({0}), .out_m_j({1}),'
                    .format('' if j == N - 1 else
                            'm_{0}_{1}_i'.format(i, j),
                            '' if i == N - 1 else
                            'm_{0}_{1}_j'.format(i, j)) +
                    '\n' + (' ' * len('  systolic_n_body_3D_cell b_{0}_{1}('
                                      .format(i, j))) +
                    '.out_p_right({0}),'
                    .format('out_pr_{0}'.format(i) if j == N - 1 else
                            'pr_{0}_{1}'.format(i, j)) +
                    '\n' + (' ' * len('  systolic_n_body_3D_cell b_{0}_{1}('
                                      .format(i, j))) +
                    '.out_p_down({0}));'
                    .format('out_pd_{0}'.format(j) if i == N - 1 else
                            'pd_{0}_{1}'.format(i, j))
                    for i in range(N) for j in range(N)]) +
             '\n\nendmodule  // end of the {0}x{0} execution'.format(N))

    return code


def generate_testbench_code(N, n):
    """Code to generate a testbench of the systolic design for n bodies.

    Arguments:
        N: The size of the systolic array.
        n: The number of bodies in the simulation.
            Must be divisible by N to ease our autogeneration.
    """
    if n % N != 0:
        raise ValueError('N ({}) must divide n ({})'.format(N, n))

    # start with the header
    code = ('// Systolic array for n-body simulations. Generated code.\n'
            '//\n'
            '// This program implements a testbench of a {0}x{0} '.format(N) +
            'systolic array for n-body simulations.\n\n\n')

    # add the cell test bench code
    code += ('// testbench for a single systolic cell -- Confirmed\n'
             'module NxN_cell_tb;\n\n'
             'reg clk;\n'
             'real in_q_i[3];\n'
             'real in_q_j[3];\n'
             'real in_m_i;\n'
             'real in_m_j;\n'
             'real in_p_right[3];\n'
             'real in_p_down[3];\n\n'
             'real out_q_i[3];\n'
             'real out_q_j[3];\n'
             'real out_m_i;\n'
             'real out_m_j;\n'
             'real out_p_right[3];\n'
             'real out_p_down[3];\n\n'
             'systolic_n_body_3D_cell UUT(.clk(clk),\n'
             '                            .in_q_i(in_q_i),\n'
             '                            .in_q_j(in_q_j),\n'
             '                            .in_m_i(in_m_i),\n'
             '                            .in_m_j(in_m_j),\n'
             '                            .in_p_right(in_p_right),\n'
             '                            .in_p_down(in_p_down),\n'
             '                            .out_q_i(out_q_i),\n'
             '                            .out_q_j(out_q_j),\n'
             '                            .out_m_i(out_m_i),\n'
             '                            .out_m_j(out_m_j),\n'
             '                            .out_p_right(out_p_right),\n'
             '                            .out_p_down(out_p_down));\n\n'
             '// Create a test\n'
             'initial begin\n\n'
             '  // Initialize the variables\n'
             '  in_q_i[0] = -3;\n'
             '  in_q_i[1] = -2;\n'
             '  in_q_i[2] = -2;\n'
             '  in_q_j[0] = -1;\n'
             '  in_q_j[1] = -1;\n'
             '  in_q_j[2] = 0;\n'
             '  in_m_i = 1;\n'
             '  in_m_j = 1;\n'
             '  in_p_right[0] = 0;\n'
             '  in_p_right[1] = 0;\n'
             '  in_p_right[2] = 0;\n'
             '  in_p_down[0] = 0;\n'
             '  in_p_down[1] = 0;\n'
             '  in_p_down[2] = 0;\n'
             '  clk = 1;\n'
             '  #5;\n'
             '  $stop;\n'
             '  clk = 0;\n'
             '  #5;\n'
             '  in_q_i[0] = -2;\n'
             '  in_q_i[1] = -2;\n'
             '  in_q_i[2] = 0;\n'
             '  in_q_j[0] = 2;\n'
             '  in_q_j[1] = 2;\n'
             '  in_q_j[2] = 2;\n'
             '  clk = 1;\n'
             '  #5;\n'
             '  $stop;\n'
             'end\n\nendmodule\n\n\n')

    # add the code for the NxN acceleration with n bodies test
    code += ('// testbench for {0}x{0} acceleration with {1} bodies '
             '-- Confirmed\nmodule acceleration_3D_tb;\n\n'
             .format(N, n))

    # add the variables used in the software
    s = '\n' + (' ' * len('real '))
    code += ('// Variables for the software side'
             '\nreal ' +
             s.join(['q_{}[3],'.format(i)
                     for i in range(n)]) + s +
             s.join(['a_{}[3],'.format(i)
                     for i in range(n)]) + s +
             s.join(['m_{},'.format(i)
                     for i in range(n)])[:-1] + ';')

    # add the variables to pass to UUT
    s = '\n' + (' ' * len('real '))
    code += ('\n\n// Variables to pass to the UUT'
             '\nreg clk;'
             '\nreal ' +
             s.join(['Q_{0}i[3],'.format(i)
                     for i in range(N)]) + s +
             s.join(['Q_{0}j[3],'.format(i)
                     for i in range(N)]) + s +
             s.join(['M_{0}i,'.format(i)
                     for i in range(N)]) + s +
             s.join(['M_{0}j,'.format(i)
                     for i in range(N)]) + s +
             s.join(['PR_{0}[3],'.format(i)
                     for i in range(N)]) + s +
             s.join(['PD_{0}[3],'.format(i)
                     for i in range(N)]) + s +
             s.join(['OPR_{0}[3],'.format(i)
                     for i in range(N)]) + s +
             s.join(['OPD_{0}[3],'.format(i)
                     for i in range(N)])[:-1] + ';')

    # create the UUT
    s = '\n' + (' ' * len('systolic_{0}x{0}_3D UUT('.format(N)))
    code += ('\n\nsystolic_{0}x{0}_3D UUT(.clk(clk),'.format(N) + s +
             s.join(['.q_{0}i(Q_{0}i),'.format(i) + s +  # input row pos
                     '.q_{0}j(Q_{0}j),'.format(i)  # input col pos
                     for i in range(N)]) + s +
             s.join(['.m_{0}i(M_{0}i),'.format(i) + s +  # input row mass
                     '.m_{0}j(M_{0}j),'.format(i)  # input col mass
                     for i in range(N)]) + s +
             s.join(['.pd_{0}(PD_{0}),'.format(i)  # input down acc
                     for i in range(N)]) + s +
             s.join(['.pr_{0}(PR_{0}),'.format(i)  # input right acc
                     for i in range(N)]) + s +
             s.join(['.out_pd_{0}(OPD_{0}),'.format(i)  # out down
                     for i in range(N)]) + s +
             s.join(['.out_pr_{0}(OPR_{0}),'.format(i)  # out right
                     for i in range(N)])[:-1] + ');\n')

    # initialize the variables
    s = '\n' + (' ' * 2)
    code += ('\ninitial begin\n' + s + 'clk = 0;' + s +
             s.join(['q_{0}[0] = {1}; q_{0}[1] = {2}; q_{0}[2] = {3};'
                     .format(i, 0, 0, 0)  # TODO put in initial positions
                     for i in range(n)]) + s +
             s.join(['a_{0}[0] = {1}; a_{0}[1] = {2}; a_{0}[2] = {3};'
                     .format(i, 0, 0, 0)  # TODO put in initial accelerations
                     for i in range(n)]) + s +
             s.join(['m_{0} = {1};'
                     .format(i, 1)  # TODO put in masses
                     for i in range(n)]) + '\n' + s +
             s.join(['Q_{0}i[0] = 0; Q_{0}i[1] = 0; Q_{0}i[2] = 0;'
                     .format(i)
                     for i in range(N)]) + s +
             s.join(['Q_{0}j[0] = 0; Q_{0}j[1] = 0; Q_{0}j[2] = 0;'
                     .format(i)
                     for i in range(N)]) + s +
             s.join(['M_{0}i = 0;'
                     .format(i)
                     for i in range(N)]) + s +
             s.join(['M_{0}j = 0;'
                     .format(i)
                     for i in range(N)]) + s +
             s.join(['PD_{0}[0] = 0; PD_{0}[1] = 0; PD_{0}[2] = 0;'
                     .format(i)
                     for i in range(N)]) + s +
             s.join(['PR_{0}[0] = 0; PR_{0}[1] = 0; PR_{0}[2] = 0;'
                     .format(i)
                     for i in range(N)]) + s +
             s.join(['OPD_{0}[0] = 0; OPD_{0}[1] = 0; OPD_{0}[2] = 0;'
                     .format(i)
                     for i in range(N)]) + s +
             s.join(['OPR_{0}[0] = 0; OPR_{0}[1] = 0; OPR_{0}[2] = 0;'
                     .format(i)
                     for i in range(N)]))

    # Now compute the timesteps block-by-block
    # To generate the code, we take note that for block i, j
    #   (where 0 <= i <= j < n / N) then
    #           Q_{u}i = q_{u + i * N}
    #           Q_{v}j = q_{v + j * N}
    #           M_{u}i = m_{u + i * N}
    #           M_{v}j = m_{v + j * N}
    #           and zero in the other terms when applicable
    # This gives the entire computation order when feeding in, since
    # we feed along each row across the diagonal.
    #
    # And then for the accumulations at the end of the blocks that
    #   are off the diagonal (which output N steps after input):
    #           a_{u + i * N} += OPR_{u}
    #           a_{v + j * N} += OPD_{v}
    #
    # Finally, we also add in the #10; command to flip the clk.

    def _generate_inputs(t):
        """sets the inputs for each t, starting at 0 and less than
        N * b * (b + 1) / 2 + 3 * N - 1).
        """
        # TODO diagonals
        def _generate_row_input(i, j, u):
            if i == N or i == -1:
                return (' '.join(['Q_{0}i[{1}] = 0;'
                                  .format(u, k)
                                  for k in range(3)]) +
                        'M_{0}i = 0;'.format(u))
            else:
                return ('Q_{0}i = q_{1}; M_{0}i = m_{1};'
                        .format(u, u + i * N))

        def _generate_col_input(i, j, v):
            if j == N or j == -1:
                return (' '.join(['Q_{0}j[{1}] = 0;'
                                  .format(v, k)
                                  for k in range(3)]) +
                        'M_{0}j = 0;'.format(v))
            else:
                return ('Q_{0}j = q_{1}; M_{0}j = m_{1};'
                        .format(v, v + j * N)) 

        # first compute which block t is in
        curr_block = int(t / N)
        into_next_block = t - curr_block

        # go up to n for in matrix (N * b * (b + 1) / 2 + 2 * N - 1 max)
        # then check after if in 0 phase
        comp_blocks = 0
        curr_i = -1
        for i in range(0, n):
            if comp_blocks < curr_block:
                comp_blocks += n - i
                curr_i += 1
            else:
                break

        # exit if we're after the feed in stage.
        if comp_blocks < curr_block:
            return ''

        curr_j = curr_block - int(curr_i * (curr_i + 1) / 2)
 
        into_i = curr_i if curr_j + 1 < N else curr_i + 1
        into_j = curr_j + 1 if curr_j + 1 < N else curr_i + 1

        # the first into_next_block inputs will be from into_i, into_j
        s = '\n  '
        inputs = s + s.join([_generate_row_input(into_i, into_j, k) + s +
                             _generate_col_input(into_i, into_j, k)
                             for k in range(into_next_block)])

        # the rest of them belong to curr_block
        inputs += s + s.join([_generate_row_input(curr_i, curr_j, k) + s +
                              _generate_col_input(curr_i, curr_j, k)
                              for k in range(into_next_block, N, 1)])
        return inputs

    def _generate_outputs(t):
        """increments from the outputs for each t (which should be in between
        0 and N * b * (b + 1) / 2 + 3 * N - 1).
        """
        def _increment_a_opr(i, u):
            """produce the a_{u + i * N} incremention above.
            """
            return ' '.join(['a_{0}[{1}] = a_{0}[{1}] + OPR_{2}[{1}];'
                             .format(i * N + u, k, u)
                             for k in range(3)])

        def _increment_a_opd(j, v):
            """produce the a_{v + j * N} incremention above.
            """
            return ' '.join(['a_{0}[{1}] = a_{0}[{1}] + OPR_{2}[{1}];'
                             .format(j * N + v, k, v)
                             for k in range(3)])

        if t < N:
            return ''

        # first compute which block t outputs are corresponding to
        curr_block = int(t / N) - 1
        into_next_block = t - N - curr_block

        comp_blocks = 0
        curr_i = -1
        for i in range(0, n):
            if comp_blocks < curr_block:
                comp_blocks += n - i
                curr_i += 1
            else:
                break

        curr_j = curr_block - int(curr_i * (curr_i + 1) / 2)
 
        last_i = curr_i if curr_j - 1 > curr_i else curr_i - 1
        last_j = curr_j - 1 if curr_j - 1 > curr_i else N - 1

        # the first into_next_block inputs will be from last_i, last_j
        s = '\n  '
        outputs = s + s.join([_increment_a_opr(last_i, k) + s +
                              _increment_a_opd(last_j, k)
                              for k in range(into_next_block)])

        # the rest of them belong to curr_i, curr_j
        outputs += s + s.join([_increment_a_opr(curr_i, k) + s +
                               _increment_a_opd(curr_j, k)
                               for k in range(into_next_block, N, 1)])

        return outputs

    s = '\n  '
    b = int(n / N)

    # Compute only a single cycle - this loop just feeds in until 0
    for t in range(int(N * b * (b + 1) / 2 + 2 * N - 1)):
        code += ('\n' + s + '//// compute step {}'.format(t) +
                 s + '#10; $stop;' +
                 _generate_inputs(t) + '\n' + s +
                 '// increment outputs' +
                 _generate_outputs(t))

    # end the code for the NxN acceleration with n bodies test
    code += ('\n\nend\n\n'
             '// always have clk taking care of sync across cells\n'
             'initial begin\n'
             '  forever #5 clk = ~clk;]\n'
             'end\n\n'
             'endmodule')

    return code


def main():
    args = parse_args()

    design_code = generate_design_code(args.N)
    with open(args.design_file, 'w') as f:
        f.write(design_code)

    testbench_code = generate_testbench_code(args.N, args.n)
    with open(args.tb_file, 'w') as f:
        f.write(testbench_code)


if __name__ == '__main__':
    main()
