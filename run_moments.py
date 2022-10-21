import moments
import numpy as np
import yaml
import pickle

# Adapted for Connor's inference

# Import config YAML file into global dictionary.
with open("config.yaml", "r") as f:
    yd = yaml.safe_load(f)

def model_func(params, ns, pop_ids=None):
    return moments.Demographics2D.split_mig(params, ns, pop_ids=pop_ids).fold()

# Load VCF as serialized data_dict object.
with open(yd["data_dict_pickle_file"], "rb") as f:
    data_dict = pickle.load(f)
# Convert data_dict object into Spectrum object.
fs = moments.Spectrum.from_data_dict(data_dict, pop_ids=yd["pop_names"],
                                     projections=yd["projections"],
                                     polarized=False)

print("SFS loaded.")

# Setup for moments inference.
lower_bound = [1e-4, 1e-4, 1e-4, 1e-4]
upper_bound = [10, 10, 10, 10]
ns = [i - 1 for i in fs.shape]

# Perform inference "rep" many times and choose the parameter estimates from the
# inference run with the greatest likelihood.
for rep in range(yd["num_of_inference_repeats"]):
    print("Rep:", rep)
    # Randomly generate initial guess for parameter estimates
    params = [np.random.uniform(lower_bound[j], upper_bound[j]) for j in range(len(lower_bound))]
    # Perform inference to get parameter estimates and assess model performance
    popt = moments.Inference.optimize_log(params, fs, model_func,
                                          lower_bound=lower_bound,
                                          upper_bound=upper_bound,
                                          verbose=yd["verbosity"])
    model = model_func(popt, ns)
    theta = moments.Inference.optimal_sfs_scaling(model, fs)
    log_likelihood = moments.Inference.ll_multinom(model, fs)

    # Convert from coalescent units.
    conversion_coeff = theta / (4 * yd["mutation_rate"] * yd["seq_len"])
    popt[0] *= conversion_coeff
    popt[1] *= conversion_coeff
    popt[2] *= 2 * conversion_coeff
    popt[3] /= 2 * conversion_coeff

    # Print to output file.
    with open(yd["output_file"], "a") as f:
        for n in yd["projections"]:
            f.write(str(n) + "\t")
        f.write(str(theta) + "\t")
        f.write(str(log_likelihood) + "\t")
        for param in popt:
            f.write(str(param) + "\t")
        for sd in moments.Godambe.FIM_uncert(model_func, popt, fs):
            f.write(str(sd) + "\t")
        f.write("\n")
