import numpy as np
import sys

# Handle command-line arguments
# First CLA is .npy file containing folded SFS
# Optional second CLA is MAF threshold, which is 0.01 by default
if len(sys.argv) == 1:
    raise "One command line argument is required."
input_sfs = sys.argv[1]
if len(sys.argv) >= 3:
    maf_threshold = sys.argv[2]
else:
    maf_threshold = 0.01

def get_shared_allele_prop(fs, maf_threshold=0.01):
    # Iterate through "fs", summing element values, but skipping entries corresponding
    # to alleles that are not sufficiently shared according to "maf_threshold"
    shared_allele_count = 0
    coordinate_thresholds = np.array([len * maf_threshold + 1 for len in fs.shape]).astype(int)

    # Create NumPy iterator object
    it = np.nditer(fs, flags=['multi_index'])
    for i in it:
        shared_allele = True
        # Check for whether element should be skipped because it fails to cross
        # MAF threshold
        for j, coord in enumerate(it.multi_index):
            if coord < coordinate_thresholds[j]:
                shared_allele = False
                break

        # If it crosses the MAF threshold to be considered "shared", add it to the counter
        if shared_allele:
            shared_allele_count += i

    shared_allele_prop = shared_allele_count / np.sum(fs)
    return shared_allele_prop

# Import SFS specified by first command=line argument
fs = np.load(input_sfs)

# Output
print("Shared allele proportion: ", get_shared_allele_prop(fs, maf_threshold))


