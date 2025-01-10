import numpy as np

# Function to Create distributed client for local mid-level computation and parallalization with DASK
def dask_distributed_client(n_workers=8, threads_per_worker=None):
    from dask.distributed import Client

    if threads_per_worker==None:
        client = Client(n_workers=8)
        
    else:
        client = Client(n_workers=8, threads_per_worker=1)
    
    return client

# Function to Create SLURM Cluster for heavy computation and parallalization with DASK
def dask_slurm_cluster(queue='smp', cores=32, scale=40, **kwargs):
    import os
    from dask_jobqueue import SLURMCluster
    from dask.distributed import Client
    
    # Create log folder if it doesn't exist
    folder_name = "./log"
    os.makedirs(folder_name, exist_ok=True)
    
    # Additional SLURMCluster keyword arguments
    cluster_kwargs = {
        'queue': queue,  # SLURM queue name
        'account': "oze.oze",  # SLURM account name
        'cores': cores,
        'processes': 1,
        'walltime': '00:30:00',  # Walltime for SLURM job
        'memory': '60GB',
        'interface': 'ib0',
        'local_directory': '/tmp/',
        'job_extra_directives': [
            "--qos 30min",  # Quality of Service for SLURM job
            "-o ./log/dask-worker-%j.log",  # Output log file for workers
            "-e ./log/dask-worker-%j.err",  # Error log file for workers
            "--export=OMP_NUM_THREADS=1"  # Environment variable export
        ],
        **kwargs  # Unpack additional keyword arguments
    }
    
    # Configure SLURMCluster
    cluster = SLURMCluster(**cluster_kwargs)
    
    # Scale the cluster
    cluster.scale(scale)
    
    # Connect client to the cluster
    client = Client(cluster)
    
    # Return both cluster and client
    return cluster, client


# Function to convert the relative 
def unc_transform(ds_unc_rel):
    ds_unc_sd = np.log10((ds_unc_rel/100)+1)
    return ds_unc_sd

def RMSE(ds):
    return np.sqrt(np.nanmean(np.square(ds)))