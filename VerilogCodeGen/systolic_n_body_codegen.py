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


def main():
    args = parse_args()

    code = generate_code(args.N)
    with open(args.file, 'w') as f:
        f.write(code)


if __name__ == '__main__':
    main()
