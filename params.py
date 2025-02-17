import numpy as np

params = {
    # Path to the input and output directory
    'work_dir':'/albedo/work/projects/p_phytooptics/emehdipo/PS113/CMEMS/', # Working directory
    'data_dir':'/albedo/work/projects/p_phytooptics/emehdipo/PS113/CMEMS/data', # Data directory
    'sst_file':'/albedo/work/projects/p_phytooptics/emehdipo/PS113/GHRSST/METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2_2016_2019.nc', # SST file name
    'output_dir':'/albedo/work/projects/p_phytooptics/emehdipo/PS113/CMEMS/regions', # Output directory
    'fig_dir': 'fig', # Figure directory

    # The initial and final date to consider for the gap-filling
    'start_date' : np.datetime64('2016-04-25'),
    'end_date' : np.datetime64('2019-04-25'),
    
    # General boundary to crop the input dataset for initial analysis
    'boundaries': {
        'lon_min': -64,
        'lon_max': 3,
        'lat_min': -50,
        'lat_max': 52,
    },
    
    # The initial and final date of expedition duration or in situ measurement dates to consider for the validation
    # Also the algorithm ensure to reconstruct these dates even if they do not have ANY dataset.
    'expedition_start_date': np.datetime64('2018-05-10'),
    'expedition_end_date' : np.datetime64('2018-06-09'),
    # Number of dates sourounding the expedition to ensure the reconstruction
    'delta': np.timedelta64(3, 'D'),
    
    # Unit of the reconstructed dataset
    'units': r'$\frac{mg}{m^{3}}$',
    
    # List of the Phytoplankton Functional Types (PFT) datasets to extract from the original satellite dataset for reconstruction
    'PFT': [
        'CHL',
        'DIATO',
        'DINO',
        'HAPTO',
        'GREEN',
        'PROKAR',
    ],
    
    # Name of the flag file
    'flags': 'flags',

    # Long name of the PFT datasets
    'PFT_longname': {
        'CHL':'Total Chlorophyll-a', 
        'DIATO':'Diatoms', 
        'DINO':'Dinoflagellates', 
        'HAPTO':'Haptophyte',
        'GREEN':'Green algae', 
        # 'PROCHLO':r"$\it{Prochlorococcus}$",
        'PROKAR':'Prokaryotes',
    },
    
    # Dictionary to use to rename the HPLC dataset to Satellite dataset abbreviations
    'PFT_HPLC_dict': {
        'Diatoms': 'DIATO',
        'Dinoflagelllates': 'DINO',
        'Chlorophytes': 'GREEN',
        'Haptophytes': 'HAPTO',
        'Prochl': 'PROCHLO',
        'Cyano_noProchl': 'PROKAR',
        'TChla': 'CHL'
    },
    
    
    # List of the PFT datasets uncertainty to extract from the original satellite dataset
    'UNC' :[
        'CHL_uncertainty',
        'DIATO_uncertainty',
        'DINO_uncertainty',
        'HAPTO_uncertainty',
        'GREEN_uncertainty',
        'PROKAR_uncertainty',
    ],
    
    # Dictionary to use to rename the Uncertainty dataset to Satellite dataset abbreviations
    'UNC_dict': {
        'CHL_uncertainty':'CHL',
        'DIATO_uncertainty':'DIATO',
        'DINO_uncertainty':'DINO',
        'HAPTO_uncertainty':'HAPTO',
        'GREEN_uncertainty':'GREEN',
        'PROKAR_uncertainty':'PROKAR',
    },
    
    # Dictionary to use to rename the Sea Surface Temperature dimensions to Satellite dataset dimensions
    'sst_rename': {
        'latitude':'lat',
        'longitude':'lon',
        'analysed_sst':'sst'
    },
    
    # Dictionary to use to rename the DINCAE reconstructed error dataset to Satellite dataset abbreviations
    'DINCAE_error_dict':{
        'CHL_error':'CHL',
        'DIATO_error':'DIATO',
        'DINO_error':'DINO',
        'HAPTO_error':'HAPTO',
        'GREEN_error':'GREEN',
        'PROKAR_error':'PROKAR',
    },
    
    # List of Logarithmic values useful for plotting the log-transformed dataset
    'plot_labels' : np.array([
        0.001,0.003,0.006,
        0.01,0.03,0.06,
        0.1,0.3,0.6,
        1,3,6,
        10,30,60,100,
    ]),
    
}

# Creating a list of all useful dataset for our study
params['ALL_data'] = params['PFT'] + params['UNC'] + ['flags']