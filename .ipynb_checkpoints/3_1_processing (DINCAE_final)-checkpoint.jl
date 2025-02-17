"""
**Project**

Assessment of gap-filling techniques applied to satellite phytoplankton composition products for the Atlantic Ocean

**Credit**

Adapted from the DINCAE 2.0 example files 
https://github.com/gher-uliege/DINCAE.jl/blob/main/examples/DINCAE_tutorial.jl

**Objective**

This code creates a final run for DINCAE based on saved configuration.

**Dataset**

The dataset is accessable through Copernicus Marine Service with the following DOI:
https://doi.org/10.48670/moi-00280 and Dataset ID: cmems_obs-oc_glo_bgc-plankton_my_l3-multi-4km_P1D
"""

Threads.nthreads()

#--------------------------------------------------------------------
# Import modules

using Pkg
Pkg.activate(".../DINCAE/DINCAE.jl")
# Pkg.add(PackageSpec(name="CUDA", version="5.2.0"))
Pkg.instantiate()


using DINCAE
using DINCAE_utils
using CUDA
using Dates
using NCDatasets
using Random
using PyPlot
using JSON

#--------------------------------------------------------------------
# Parse command-line arguments
args = collect(ARGS)
region = parse(Int, args[1])

#--------------------------------------------------------------------
## Loading file

## Local directory
localdir = expanduser(".../regions/$region")

## Create directory
# mkpath(localdir)

## Filename of the data with added clouds for cross-validation
fname_cv = joinpath(localdir,"ds_pft_dev.nc")
# varname = "sst"

outdir = joinpath(localdir,"DINCAE/final")
mkpath(outdir)

#--------------------------------------------------------------------
## CUDA

const F = Float32

if CUDA.functional()
    Atype = CuArray{F}
else
    @warn "No supported GPU found. We will use the CPU which is very slow. Please check https://developer.nvidia.com/cuda-gpus"
    Atype = Array{F}
end

#--------------------------------------------------------------------
## Address to the optimal configuration json file
param_file = ".../9/DINCAE/106/param.json"

hyperparams = JSON.parsefile(param_file)

# Accessing the hyperparameters
sst = hyperparams["sst"]  # This will be a boolean
uncertainty_type = hyperparams["uncertainty_type"]
jitter_std = hyperparams["jitter_std"]
epochs = hyperparams["epochs"]
save_epochs = hyperparams["save_epochs"]
batch_size = hyperparams["batch_size"]
enc_nfilter_internal = hyperparams["enc_nfilter_internal"]
ntime_win = hyperparams["ntime_win"]
upsampling_method = Symbol(hyperparams["upsampling_method"])  # This will be a string
learning_rate = hyperparams["learning_rate"]
regularization_L2_beta = hyperparams["regularization_L2_beta"]
loss_weights_refine = Tuple(hyperparams["loss_weights_refine"])
laplacian_penalty = hyperparams["laplacian_penalty"]
truth_uncertain = hyperparams["truth_uncertain"]  # This will be a boolean
remove_mean = hyperparams["remove_mean"]  # This will be a boolean

#--------------------------------------------------------------------
# Data Parameters

if uncertainty_type=="spatial"

    data_param = [
        (filename = fname_cv,
         varname = "CHL",
         errvarname = "CHL_uncertainty",
         jitter_std = jitter_std,
         isoutput = true,
         ),
        (filename = fname_cv,
         varname = "DIATO",
         errvarname = "DIATO_uncertainty",
         jitter_std = jitter_std,
         isoutput = true,
         ),
        (filename = fname_cv,
         varname = "DINO",
         errvarname = "DINO_uncertainty",
         jitter_std = jitter_std,
         isoutput = true,
         ),
        (filename = fname_cv,
         varname = "HAPTO",
         errvarname = "HAPTO_uncertainty",
         jitter_std = jitter_std,
         isoutput = true,
         ),
        (filename = fname_cv,
         varname = "GREEN",
         errvarname = "GREEN_uncertainty",
         jitter_std = jitter_std,
         isoutput = true,
         ),
        (filename = fname_cv,
         varname = "PROKAR",
         errvarname = "PROKAR_uncertainty",
         jitter_std = jitter_std,
          isoutput = true,
         ),
    ]

    if sst
        push!(data_param, (
            filename = fname_cv,
            varname = "sst",
            errvarname = "sst_uncertainty",
            jitter_std = jitter_std,
            isoutput = false,
        ))
    end

elseif uncertainty_type=="equal" || uncertainty_type=="median"
    
    if uncertainty_type=="equal"
        
        CHL_err_std = 1
        DIATO_err_std = 1
        DINO_err_std = 1
        HAPTO_err_std = 1
        GREEN_err_std = 1
        PROKAR_err_std = 1
        sst_err_std = 1
        
    elseif uncertainty_type=="median"
        
        CHL_err_std = 0.118f0
        DIATO_err_std = 0.381079f0
        DINO_err_std = 0.3274f0
        HAPTO_err_std = 0.342107f0
        GREEN_err_std = 0.254379f0
        PROKAR_err_std = 0.299965f0
        sst_err_std = 0.00791152f0
        
    end
    
    data_param = [
        (filename = fname_cv,
         varname = "CHL",
         obs_err_std = CHL_err_std,
         jitter_std = jitter_std,
         isoutput = true,
         ),
        (filename = fname_cv,
         varname = "DIATO",
         obs_err_std = DIATO_err_std,
         jitter_std = jitter_std,
         isoutput = true,
         ),
        (filename = fname_cv,
         varname = "DINO",
         obs_err_std = DINO_err_std,
         jitter_std = jitter_std,
         isoutput = true,
         ),
        (filename = fname_cv,
         varname = "HAPTO",
         obs_err_std = HAPTO_err_std,
         jitter_std = jitter_std,
         isoutput = true,
         ),
        (filename = fname_cv,
         varname = "GREEN",
         obs_err_std = GREEN_err_std,
         jitter_std = jitter_std,
         isoutput = true,
         ),
        (filename = fname_cv,
         varname = "PROKAR",
         obs_err_std = PROKAR_err_std,
         jitter_std = jitter_std,
         isoutput = true,
         ),
    ]

    if sst
        push!(data_param, (
            filename = fname_cv,
            varname = "sst",
            obs_err_std = sst_err_std,
            jitter_std = jitter_std,
            isoutput = false,
        ))
    end

end

data_test = data_param;
fnames_rec = [joinpath(outdir,"ds_reconstructed.nc")]
data_all = [data_param,data_test]
varname = data_all[1][1].varname

paramfile = joinpath(outdir,"paramfile.param")
#---------------------------------------------------------------------
# Run DINCAE

loss = DINCAE.reconstruct(
    Atype,data_all,fnames_rec;
    epochs = epochs,
    save_epochs = save_epochs,
    batch_size = batch_size,
    enc_nfilter_internal = enc_nfilter_internal,
    # skipconnections = skipconnections,
    ntime_win = ntime_win,
    learning_rate = learning_rate,
    upsampling_method = upsampling_method,
    regularization_L2_beta = regularization_L2_beta,
    loss_weights_refine = loss_weights_refine,
    laplacian_penalty = laplacian_penalty,
    truth_uncertain = truth_uncertain,
    remove_mean = remove_mean,
    paramfile = paramfile,
)

#--------------------------------------------------------------------
