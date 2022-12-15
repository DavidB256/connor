# connor
Pipeline for demographic inference, follow-up analysis, and data visualization on D. pulex data. Used to create Supplemental Figure 3.

Use:
1. Given VCF and popinfo files, **scripts/make_data_dict.py** outputs serialized .pickle objects containing data_dict objects for use in demographic inference with moments into **data/**.
2. **run_moments/wrapper_run_moments.slurm** is the Slurm wrapper for **run_moments/run_moments.py**. It uses **run_moments/instructions_run_moments.txt** to choose sample size projections.
3. **run_moments/run_moments.py** performs demographic inference according to specifications in **run_moments/config.yaml** on serialized data_dict objects in **data/**. Its output are the two files in **output/** whose names end in **_DI_output.txt**, where "DI" stands for "demographic inference". "busco" and "filt" in the output file names refer to demographic inference performed on SNP from "**daphnia.filtered.chr.busco.vcf**" and "**daphnia.filt.mlg.genome.11.18.22.vcf**", respectively.
4. **scripts/get_optimal_parameter_estimates.R** selects optimal parameter estimates from repeated demographic inference results reported in output files and converts units from coalescent units to conventional population genetic units.
5. **scripts/save_and_analyze_sfss.py** constructs site frequency spectra (SFSs) using moments' models according to optimal parameters, serializes them as .npy files into **sfss/sfs_npys/**, saves them as CSVs into **sfss/sfs_csvs/**, and outputs summary statistics into **output/sfs_statistics.txt**.
6. **scripts/visualize_sfs_from_csv.R** creates the figure, which is saved as **supp_fig3.pdf**, from data in **sfss/sfs_csvs/** and **output/sfs_statistics.txt**.

The contents of **sfss/sfs_figures/** come from automatic output of preliminary exploration of SFSs with moments' built-in visualization functions, which are based on matplotlib.