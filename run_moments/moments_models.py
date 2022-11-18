import numpy as np
import moments

def split_no_mig(params, ns, pop_ids=None):
    nu1, nu2, T = params
    sts = moments.LinearSystem_1D.steady_state_1D(ns[0] + ns[1])
    fs = moments.Spectrum(sts)
    fs = moments.Manips.split_1D_to_2D(fs, ns[0], ns[1])
    fs.integrate([nu1, nu2], T, m=np.zeros([2, 2]))
    fs.pop_ids = pop_ids
    return fs.fold()

def split_mig_asymmetric(params, ns, pop_ids=None):
    nu1, nu2, T, m12, m21 = params
    sts = moments.LinearSystem_1D.steady_state_1D(ns[0] + ns[1])
    fs = moments.Spectrum(sts)
    fs = moments.Manips.split_1D_to_2D(fs, ns[0], ns[1])
    fs.integrate([nu1, nu2], T, m=np.array([[0, m21], [m12, 0]]))
    fs.pop_ids = pop_ids
    return fs.fold()
