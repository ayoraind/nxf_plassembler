#!/usr/bin/env python

import os
import sys
import errno
import argparse


def parse_args(args=None):
    Description = 'Reformat samplesheet and check its contents for fasta files.'
    Epilog = """Example usage: python check_samplesheet.py <FILE_IN> <FILE_OUT>"""

    parser = argparse.ArgumentParser(description=Description, epilog=Epilog)
    parser.add_argument('FILE_IN', help="Input samplesheet file.")
    parser.add_argument('FILE_OUT', help="Output file.")
    return parser.parse_args(args)


def make_dir(path):
    if path:
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise


def print_error(error, line):
    print("ERROR: Please check samplesheet -> {}\nLine: '{}'".format(error, line.strip()))
    sys.exit(1)


def check_samplesheet(FileIn, FileOut):
    # Expected header
    HEADER = ['sample', 'R1', 'R2', 'LongFastQ']
    fin = open(FileIn, 'r')
    header = fin.readline().strip().split(',')
    if header != HEADER:
        print("ERROR: Please check samplesheet header -> {} != {}".format(','.join(header),','.join(HEADER)))
        sys.exit(1)

    sampleRunDict = {}
    while True:
        line = fin.readline()
        if not line:
            break
        lspl = [x.strip() for x in line.strip().split(',')]

        # Validate number of columns and if they match expected
        if len(lspl) != len(HEADER):
            print_error("Invalid number of columns!", line)

        sample, R1, R2, LongFastQ = lspl[0], lspl[1], lspl[2], lspl[3]
	
        if not sample:
            print_error("Sample name is missing!", line)

        if ' ' in sample:
            print_error("Sample name contains spaces!", line)

        if ' ' in R1:
            print_error("Forward fastq filename contains spaces!", line)
	    
        if ' ' in R2:
            print_error("Reverse fastq filename contains spaces!", line)
	    
        if ' ' in LongFastQ:
            print_error("Long read filename contains spaces!", line)

        if not any(R1.endswith(ext) for ext in ['.fastq.gz', '_1.fastq.gz']):
            print_error("Forward fastq file has an invalid extension. Expected _1.fastq.gz", line)
	    
        if not any(R2.endswith(ext) for ext in ['.fastq.gz', '_2.fastq.gz']):
            print_error("Reverse fastq file has an invalid extension. Expected _2.fastq.gz", line)
	    
        if not any(LongFastQ.endswith(ext) for ext in ['.fastq.gz']):
            print_error("Long read fastq file has an invalid extension. Expected .fastq.gz", line)

        # Add to dictionary, check for duplicates
        if sample not in sampleRunDict:
            sampleRunDict[sample] = [lspl]
        elif lspl in sampleRunDict[sample]:
            print_error("Samplesheet contains duplicate rows!", line)
        else:
            sampleRunDict[sample].append(lspl)

    fin.close()

    # Write the validated samplesheet with appropriate columns
    if sampleRunDict:
        OutDir = os.path.dirname(FileOut)
        make_dir(OutDir)
        fout = open(FileOut, 'w')
        fout.write(','.join(HEADER) + '\n')  # Write header
        for sample, values in sampleRunDict.items():
            for idx, val in enumerate(values):
                fout.write(','.join(val) + '\n')  # Write data
        fout.close()


def main(args=None):
    args = parse_args(args)
    check_samplesheet(args.FILE_IN, args.FILE_OUT)


if __name__ == '__main__':
    sys.exit(main())
