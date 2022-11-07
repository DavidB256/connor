import numpy as np
import sys

# Handle command-line arguments
if len(sys.argv) == 1:
    raise "One command line argument is required."
input_sfs = sys.argv[1]
if len(sys.argv) >= 3:
    maf_threshold = sys.argv[2]
else:
    maf_threshold = 0.01

fs = np.load(input_sfs)

# Iterate through "fs", summing element values, but skipping entries corresponding
# to alleles that are not sufficiently shared according to "maf_threshold"
shared_allele_count = 0
coordinate_thresholds = np.array([len * maf_threshold + 1 for len in fs.shape]).astype(int)

it = np.nditer(fs, flags=['multi_index'])
for i in it:
    shared_allele = True
    for j, coord in enumerate(it.multi_index):
        if coord < coordinate_thresholds[j]:
            shared_allele = False
            break

    if shared_allele:
        shared_allele_count += i

# Output
print("Shared allele count: ", shared_allele_count)
print("Shared allele proportion: ", shared_allele_count / np.sum(fs))


