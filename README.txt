This source code accompanies the paper entitled "COVID-19 in low-tolerance border quarantine systems: impact of the Delta variant of SARS-CoV-2" by Cameron Zachreson, Freya M. Shearer, David J. Price, Michael J. Lydeamore, Jodie McVernon, James McCaw, and Nicholas Geard.  
https://arxiv.org/abs/2109.12799

The enclosed scripts simulate the passage of international arrivals through a border quarantine system incorporating in-system transmission of SARS-CoV-2. The simulations produce linelists of "breach events" as output, describing the characteristics of individuals who leave the quarantine system while still infectious. 

The code is implemented in Julia language. To run the code using the Juno IDE (Atom package), 

set the working directory to the location of the main function (i.e., "[working directory]\Quar_main_R0_x_VE_scan_2021_08_26.jl")

run the script by including the script containing the main function:

include("Quar_main_R0_x_VE_scan_2021_08_26.jl")

If you receive the following error: 

"ERROR: LoadError: MethodError: no method matching initialise_agents! (" ... ") The applicable method may be too new"...

simply re-enter the include("...") command as listed above, the method should then initialise successfully. 

The above iterates over a specified range of R0 and VE values, and produce a linelist for each set of parameters, storred in an output directory called "R0_x_VE_scan_H14_tf_1M". The directory name used for the output can be altered within the script containing the main() function. 

The following scripts contain functions and parameters used by the main() function: 

Agent_Quar.jl 
provides the definition of the mutable structure containing the properties of individuals
[take care if modifying the agent_type: default constructor values must be placed in the same order as they are defined]

Quar_ABM_disease_no_R0.jl 
provides global parameter values that correspond to selected disease properties. R0 is modified in the main script, so is not included as a global parameter in this version. The calibration parameter beta = R0 / 3.83 was computed using the calibration script (implemented in MATLAB), which can be found in a subdirectory of the repository. 

Quar_ABM_environment.jl 
provides several structural components of the simulation, including the work rosters and the locations in which individuals can be found, or move between, during simulations of the quarantine system. 

Quar_ABM_functions_2021_08_26.jl
provides function definitions for the bulk of simulation processes. The exclamation point "!" used in function definitions is a Julia convention that indicates functions that modify input arguments (it is not required syntax). 
All functions have been given descriptive names that indicate their purpose. 

Quar_ABM_utils.jl
defines utility objects such as the random number seed, output dataframes, and global parameters specifying the simulation duration and timestep. 

NOTE: the file Quar_ABM_utils.jl defines the variable tf (Float64), this is the number of days simulated, and determines the run time. By default tf = 1000000.0 days. This long time frame is set in order to simulate many breach events from which statistics can be drawn for initialisation of outbreak models. 

The non-Julia script creat_results_table.m (MATLAB) processes the set of linelists into a results table that can be easily read for plotting in python using Seaborn. Heatmaps of results with overlaid contours can be produced using the python script plot_contour.py. Note that results relative to baseline require the specification of a baseline datafile in create_results_table.m

The scripts used for various sensitivity analysis investigations can be implemented in the same way as the above. Using the Juno IDE, set the appropriate working directory (containing the desired main script), and use the Include("[main script filename]") command to start the simulation. If a shorter linelists are desired, modify the tf variable in the Quar_ABM_utils.jl file contained within the same working directory (make sure to imply the Float64 datatype by adding a decimal to the value, even if it is a whole integer i.e., tf = 1000.0). 

