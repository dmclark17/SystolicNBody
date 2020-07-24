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
    parser.add_argument('file', type=str,
                        help='The path pointing to the output .sv file.')
    parser.add_argument('N', type=int,
                        help='The size of the systolic array.')
    return parser.parse_args()


def generate_code(N):
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
    # TODO: make code pretty with indentations, shorter line

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
    code += ('\n  real ' +
             s.join(['pr_{0}_{1}[3],'.format(i, j)
                     for i in range(N) for j in range(N - 1)])[:-1] + ';')
    code += ('\n  real ' +
             s.join(['pd_{0}_{1}[3],'.format(i, j)
                     for i in range(N - 1) for j in range(N)])[:-1] + ';')
    code += ('\n  real ' +
             s.join(['q_{0}_{1}_i[3],'.format(i, j)
                     for i in range(N) for j in range(N - 1)])[:-1] + ';')
    code += ('\n  real ' +
             s.join(['q_{0}_{1}_j[3],'.format(i, j)
                     for i in range(N - 1) for j in range(N)])[:-1] + ';')
    code += ('\n  real ' +
             s.join(['m_{0}_{1}_i[3],'.format(i, j)
                     for i in range(N) for j in range(N - 1)])[:-1] + ';')
    code += ('\n  real ' +
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


def main():
    args = parse_args()

    code = generate_code(args.N)
    with open(args.file, 'w') as f:
        f.write(code)


if __name__ == '__main__':
    main()
