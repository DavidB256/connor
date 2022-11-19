import moments
import pickle

# Setup
vcf_file = "daphnia.filt.mlg.genome.11.18.22.vcf.gz"
popinfo_file = "moments_list.popinfo"
pickle_file = "daphnia.filt.mlg.genome.11.18.22_data_dict.pickle"

# Load data_dict object from gzipped VCF
dd = moments.Misc.make_data_dict_vcf(vcf_file, popinfo_file)

# Pickle it
with open(pickle_file, "wb") as f:
    pickle.dump(dd, f)
