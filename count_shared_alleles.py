import numpy as np
import sys
import msprime

# Handle command-line arguments
if len(sys.argv) >= 2:
    maf_threshold = sys.argv[2]
else:
    maf_threshold = 0.01

# Set demographic parameters
anc_pop_size = 1
pop0_size = 1
pop1_size = 1
t_split = 1
mig_rate = 1
ploidy = 2
seq_len = 1
rho = 1
mu = 1

# Set other parameters
anc = "anc"
pop0 = "pop0"
pop1 = "pop1"
end_time = None
samples = {pop0: 1, pop1: 1}
seed = 1

# Construct demography model
dem = msprime.Demography()
dem.add_population(name=anc, initial_size=anc_pop_size)
dem.add_population(name=pop0, initial_size=pop0_size)
dem.add_population(name=pop1, initial_size=pop1_size)
dem.add_population_split(time=t_split, derived=[pop0, pop1], ancestral=anc)
dem.set_symmetric_migration_rate([pop0, pop1], mig_rate)

# Simulate ancestry and mutations
ts = msprime.sim_ancestry(samples=samples, demography=dem,
                          sequence_length=seq_len,
                          recombination_rate=rho,
                          ploidy=ploidy,
                          random_seed=seed,
                          end_time=end_time)
mts = msprime.sim_mutations(ts, rate=mu, random_seed=seed)

# Convert TreeSequence object into SFS
sample_sets = [ts.samples()[:samples[pop0] * ploidy],
               ts.samples()[samples[pop1] * ploidy]:]
fs = mts.allele_frequency_spectrum(sample_sets=sample_sets)

# Iterate through "fs", summing element values, but skipping entries corresponding
# to alleles that are not sufficiently shared according to "maf_threshold"
shared_allele_count = 0
coordinate_thresholds = (fs.shape * maf_threshold).astype(int)
it = np.nditer(fs, flags=['f_index'])
for i in it:
    for j, coord in enumerate(it.multi_index):
        if coord < coordinate_thresholds[j]:
            continue
    shared_allele_count += i

# Output
print("Shared allele count: ", shared_allele_count)
print("Shared allele frequency: ", shared_allele_count / np.sum(fs))


