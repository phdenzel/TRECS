# T-RECS

This is the code used to produce the Tiered Radio Extragalactic Continuum Simulation
(T-RECS, Bonaldi et al. 2018). 
It can be run to produce radio sources catalogues with user-defined frequencies, area and depth. 

Once the code is installed (see the INSTALL.md file in this folder) and the installation
path has been added to your search path (i.e. export PATH=${PATH}:/path/to/prefix/bin)
the code runs by calling :

```bash
$ trecs [OPTIONAL FLAGS] -p/--params /path/to/parameter_file.ini
```

Available options can be printed on screen by calling

```bash
$ trecs -h/--help
```

A dummy parameter file is available at example/parameter_file.ini as well as a dummy
frequency list file at example/frequency_list.

According to the optional flags with which the master script is called different possible
results will be produced.

## Optional arguments

`-c`/`--continuum`	will run the continuum simulation

`-i`/`--HI`        	will run the HI simulation

`-x`/`--xmatch`    	cross-matches the continuum and HI simulations
	     		(this requires the two flags -c AND -i to have been used,
	       	 	not necessarily on the same run, as long as the output
		 	paths in the parameter file are compatible)

`-C`/`--clustering`	will add clustering properties based on the coordinates of
			sub-haloes in a lightcone built from the P-Millenium simullation

`-w`/`--wrap [tag]` 	will wrap raw catalogues in a single fits file (and eventually
	     		apply a rotation to the coordinates towards some required
			central latitude and longitude. This is required as the above
			options produce catalogues per redshift bin and per galaxy sub-population,
			on a user-specified output folder.

`-h`/`--help`		displays a help message with usage instructions

**NOTE 1)** For demanding simulations, the code can be easily parallelised by running
several instances of the master script code each processing a different redshift interval.
The redshift interval is controlled by the the z_min, z_max parameters that can be set in the
input parameter file (default is z_min=0, z_max=8, which means no parallelization).
The aforementioned parameters do not need to be related to the redshift bins intrinsically
defined in the code.
The resulting catalogues can be then wrapped in a second moment by calling the trecs master scrip
with only the wrap flag.

**NOTE 2)** the wrapping part of the code will position the field of view on the user-specified
central coordinates and collate all the output catalogues in just one. 
This is not computationally demanding and can be run multiple times, using the same catalogue inputs,
to project the simulated sky onto different fields. 


## Docker

The docker image from this fork can be built with
```bash
$ git checkout docker
$ make docker
```

To launch a container interactively, use
```bash
$ make docker-run
```

or non-interactively with
```bash
$ make docker-run-trecs
$ make docker-run-trecs-wrapper
```


## Sarus

`sarus` is a OCI-compliant container engine designed for HPC
systems. It can essentially be analogously used to docker (using the
same subcommands).

On CSCS (Piz Daint), first load all necessary modules for sarus, e.g.

```bash
$ module load daint-gpu
$ module load sarus
```

To run the image with `sarus`, first upload the built image to your
own docker hub registry, or alternatively use mine
(phdenzel/trecs:latest). Then, pull the image into your personal local
repository within a interactive srun bash session

```bash
$ srun -C gpu --pty --job-name=trecs-sarus --ntasks=1 --cpus-per-task=1 --mem=16G bash
~> sarus pull phdenzel/trecs:latest
~> exit
```

Once, the image is pulled, you can run the trecs executable in the container with
```bash
$ srun -C gpu -N 1 sarus run \
   	 --mount=type,bind,source=$SCRATCH/TRECS_Inputs,destination=/home/phdenzel/TRECS/TRECS_Inputs \
	 --mount=type,bind,source=$SCRATCH/TRECS_Outputs,destination=/home/phdenzel/TRECS/TRECS_Outputs \
	 --mount=type,bind,source=$HOME/TRECS/examples,destination=/home/phdenzel/TRECS/examples \
	 phdenzel/trecs -c 'trecs -c -p TRECS/examples/docker_pars.ini'
```
and
```bash
$ srun -C gpu -N 1 sarus run \
   	 --mount=type,bind,source=$SCRATCH/TRECS_Inputs,destination=/home/phdenzel/TRECS/TRECS_Inputs \
	 --mount=type,bind,source=$SCRATCH/TRECS_Outputs,destination=/home/phdenzel/TRECS/TRECS_Outputs \
	 --mount=type,bind,source=$HOME/TRECS/examples,destination=/home/phdenzel/TRECS/examples \
	 phdenzel/trecs -c 'trecs -w -p TRECS/examples/docker_pars.ini'
```

Note that the user home directory `/home/phdenzel` within the image
has to be adjusted in case a self-built image is used.