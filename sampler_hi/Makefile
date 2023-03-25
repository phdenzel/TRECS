
F90 = gfortran
CC = cc
F90FLAGS = -O3 -fopenmp
I_CFITSIO = -I/usr/local/include  # /home/a.bonaldi/data-cold-for-backup/software/cfitsio/include/
L_CFITSIO = -L/usr/local/lib -lcfitsio  # /home/a.bonaldi/data-cold-for-backup/software/cfitsio/lib -lcfitsio
I_HEALPIX = -I/opt/healpix/include  # /home/a.bonaldi/data-cold-for-backup/software/Healpix_3.31/include
L_HEALPIX = -L/opt/healpix/lib -lhealpix -lgif  # /home/a.bonaldi/data-cold-for-backup/software/Healpix_3.31/lib -lhealpix -lgif
L_GSL = -L/usr/local/lib -lgsl -lgslcblas  # /home/a.bonaldi/data-cold-for-backup/software/libtyler/ -lgsl -lgslcblas
L_LAPACK = -L/usr/local/lib -llapack  # /home/bonaldi/libraries/ -llapack
LDFLAGS = 

INCLUDE := $(I_CFITSIO) $(I_HEALPIX) 
LINK := $(LINK) $(L_CFITSIO) $(L_HEALPIX) $(L_GSL) $(L_LAPACK) $(LDFLAGS)

OBJ := ../modules/random_modules.o ../modules/sampler_io.o ../modules/sampler_modules.o sampler.o

default: all
all : $(OBJ)
	$(F90) $(F90FLAGS) -o ../bin/sampler_hi $(OBJ) $(LINK)

%.o : %.f90
	$(F90) $(F90FLAGS) $(INCLUDE) -o $@ -c $<

clean: 
	rm *.o ../modules/*.o *.mod
