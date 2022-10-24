import moments
import numpy as np
import yaml
import pickle
import moments_models as mm

# Adapted for Connor's inference

# Import config YAML file into global dictionary.
with open("config.yaml", "r") as f:
    yd = yaml.safe_load(f)

def model_func(params, ns, pop_ids=None):
    if yd["model"] == "split_mig":
        return moments.Demographics2D.split_mig(params, ns, pop_ids=pop_ids).fold()
    elif yd["model"] == "split_no_mig":
        return mm.split_no_mig(params, ns, pop_ids)
    elif yd["model"] == "split_mig_asymmetric":
        return mm.split_mig_asymmetric(params, ns, pop_ids)
    else:
        raise "Model name not recognized."

# Load VCF as serialized data_dict object.
with open(yd["data_dict_pickle_file"], "rb") as f:
    data_dict = pickle.load(f)
# Convert data_dict object into Spectrum object.
fs = moments.Spectrum.from_data_dict(data_dict, pop_ids=yd["pop_names"],
                                     projections=yd["projections"],
                                     polarized=False)

print("SFS loaded.")

# Setup for moments inference.
model_to_num_of_params = {"split_mig": 4, "split_no_mig": 3, "split_mig_asymmetric": 5}
lower_bound = [1e-4 for i in range(model_to_num_of_params[yd["model"]])]
upper_bound = [100 for i in range(model_to_num_of_params[yd["model"]])]

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
    if yd["model"] == "split_mig":
        popt[3] /= 2 * conversion_coeff
    elif yd["model"] == "split_mig_asymmetric":
        popt[3] /= 2 * conversion_coeff
        popt[4] /= 2 * conversion_coeff

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
