## Adapted from the DINCAE 2.0 example files
## https://github.com/gher-uliege/DINCAE.jl/blob/main/examples/DINCAE_tutorial.jl

Threads.nthreads()

#--------------------------------------------------------------------
# Import modules

using Pkg
# activate the environment
Pkg.activate("~/DINCAE/DINCAE.jl")
Pkg.instantiate()

using CUDA
using DINCAE
using DINCAE_utils
using Dates
using NCDatasets
using Random
using PyPlot
using JSON

#--------------------------------------------------------------------
# Parse command-line arguments

args = collect(ARGS)

array_id = parse(Int, args[1])
region = parse(Int, args[2])

#--------------------------------------------------------------------
# loading file

# local directory
localdir = expanduser("~/regions/$region")

# create directory
mkpath(localdir)

# filename of the data with added clouds for cross-validation
fname_cv = joinpath(localdir,"ds_pft_train.nc")
# varname = "sst"

outdir = joinpath(localdir,"DINCAE/$array_id")
mkpath(outdir)

#--------------------------------------------------------------------
# CUDA

const F = Float32

if CUDA.functional()
    Atype = CuArray{F}
else
    @warn "No supported GPU found. We will use the CPU which is very slow. Please check https://developer.nvidia.com/cuda-gpus"
    Atype = Array{F}
end

#--------------------------------------------------------------------
# Random Hyperparameters

# sst = rand([true, false])
sst = false
# uncertainty_type = rand(["equal", "median", "spatial"])
uncertainty_type = "spatial"
jitter_std = rand() * 0.1

epochs = rand(8:12)*100
save_epochs = 200:10:epochs

batch_size = rand(16:64)
power_base = 1.5 + rand()/2; enc_nfilter_internal = round.(Int,rand(32:64) * power_base .^ (0:rand(3:4)))
# skipconnections = rand([1,2]):(length(enc_nfilter_internal)+1)
ntime_win = rand([3,5,7])
upsampling_method = rand([:nearest,:bilinear])

learning_rate = Float32(10^(-4 + rand()))
regularization_L2_beta = 10^(-2 - (2 * rand()))
ww = rand()/2; loss_weights_refine  = (0.5-ww,0.5+ww)
laplacian_penalty = rand([Int32(0), Float32(10^(-2 - (4 * rand())))])

truth_uncertain = rand([true, false])
remove_mean = rand([true, false])

#--------------------------------------------------------------------
# Save hyperparameters as json file

hyperp = Dict(
    "array" => array_id,
    "sst" => sst,
    "uncertainty_type" => uncertainty_type,
    "jitter_std" => jitter_std,
    "epochs" => epochs,
    "save_epochs" => collect(save_epochs),
    "batch_size" => batch_size,
    "enc_nfilter_internal" => enc_nfilter_internal,
    # "skipconnections" => skipconnections,
    "ntime_win" => ntime_win,
    "upsampling_method" => Symbol(upsampling_method),
    "learning_rate" => learning_rate,
    "regularization_L2_beta" => regularization_L2_beta,
    "loss_weights_refine" => loss_weights_refine,
    "laplacian_penalty" => laplacian_penalty,
    "truth_uncertain" => truth_uncertain,
    "remove_mean" => remove_mean,
)

json_hyperp = JSON.json(hyperp,4)

# Save to a file

fname_json = joinpath(outdir,"param.json")

open(fname_json, "w") do io
    println(io, json_hyperp)
end

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
