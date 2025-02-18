'''
**Project**

Assessment of gap-filling techniques applied to satellite phytoplankton composition products for the Atlantic Ocean

**Credit**

**© Ehsan Mehdipour**, 2025. (ehsan.mehdipour@awi.de)

Alfred Wegener Insitute for Polar and Marine Research, Bremerhaven, Germany

This work is licensed under the **GNU General Public License v3.0 (GPL-3.0)**. 
'''

import numpy as np
import os
from dask_jobqueue import SLURMCluster
from dask.distributed import Client

def dask_distributed_client(n_workers=8, threads_per_worker=None):
    '''
    Function to create a distributed Dask client for local computation and parallelization.
    
    Parameters:
    n_workers (int): Number of workers in the distributed cluster.
    threads_per_worker (int, optional): Number of threads per worker. Defaults to None.
    
    Returns:
    Client: A Dask distributed client instance.
    '''
    
    kwargs = {"n_workers": n_workers}
    if threads_per_worker is not None:
        kwargs["threads_per_worker"] = threads_per_worker
    
    return Client(**kwargs)

def dask_slurm_cluster(queue='smp', cores=32, scale=40, memory='60GB', walltime='00:30:00', account=None, **kwargs):
    '''
    Function to create a job queue with SLURMCluster for heavy computation and parallelization with DASK.

    Parameters:
    queue (str): SLURM queue type (e.g., 'smp' or 'mpp').
    cores (int): Number of cores allocated to each cluster.
    scale (int): Number of workers to scale the cluster to.
    memory (str): Memory allocation per worker (default: '60GB').
    walltime (str): Maximum walltime per worker (default: '00:30:00').
    account (str, optional): SLURM account name. If None, it won't be explicitly set.
    
    Returns:
    tuple: (SLURMCluster, Client)
    '''
    
    # Create log directory if it does not exist
    log_dir = "./log"
    os.makedirs(log_dir, exist_ok=True)
    
    # Construct SLURM cluster arguments
    cluster_kwargs = {
        'queue': queue,
        'cores': cores,
        'processes': 1,
        'memory': memory,
        'walltime': walltime,
        'interface': 'ib0',
        'local_directory': '/tmp/',
        'job_extra_directives': [
            "--qos=30min",
            f"-o {log_dir}/dask-worker-%j.log",
            f"-e {log_dir}/dask-worker-%j.err",
            "--export=OMP_NUM_THREADS=1"
        ],
        **kwargs  # Allow additional SLURMCluster options
    }

    # Include account if provided
    if account:
        cluster_kwargs["account"] = account

    # Create SLURM cluster
    cluster = SLURMCluster(**cluster_kwargs)

    # Scale the cluster if requested
    if scale:
        cluster.scale(scale)

    # Create client
    client = Client(cluster)
    
    return cluster, client


def unc_transform(ds_unc_rel):
    '''
    Function to convert the relative satellite uncertainty 
    to standard deviation in logarithmic scale
    
    Parameters:
    ds_unc_rel (xr.Dataset): Dataset containing relative uncertainty
    
    Returns:
    ds_unc_sd (xr.Dataset): Standard deviation uncertainty in logarithmic scale
    '''
    ds_unc_sd = np.log10((ds_unc_rel/100)+1)
    return ds_unc_sd

def RMSE(ds):
    '''
    Compute the root-mean-squared-error of Dataset
    
    Parameters:
    ds (xr.Dataset): dataset to compute the RMSE 
    
    Returns:
    ds (xr.Dataset): RMSE dataset
    '''
    return np.sqrt(np.nanmean(np.square(ds)))

def rm_boundry(ds, pixels=5):
    '''
    Function to remove a boundry from a dataset after reconstruction to remove the boundry effect
    
    Parameters:
    ds (xr.Dataset): Dataset from which to remove the boundry
    pixels (int): Number of pixels to be removed from the all the sides of the dataset
    
    Returns:
    ds (xr.Dataset): Dataset with removed boundry effect
    '''
    
    return ds.isel(lat=slice(pixels, -pixels), lon=slice(pixels, -pixels))