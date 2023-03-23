
F90 = gfortran
CC = cc
F90FLAGS = -O3 
I_CFITSIO =  -I/usr/local/include  # /home/a.bonaldi/data-cold-for-backup/software/cfitsio/include/
L_CFITSIO =  -L/usr/local/lib  # /home/a.bonaldi/data-cold-for-backup/software/cfitsio/lib -lcfitsio
I_HEALPIX = -I/opt/healpix/include  # /home/a.bonaldi/data-cold-for-backup/software/Healpix_3.31/include
L_HEALPIX =  -L/opt/healpix/lib -lhealpux -lgif  # /home/a.bonaldi/data-cold-for-backup/software/Healpix_3.31/lib -lhealpix -lgif
I_SAMPLER = -I../sampler_continuum/


LDFLAGS = 
INCLUDE := $(I_HEALPIX)  $(I_CFITSIO) $(I_SAMPLER)
LINK := $(LINK) $(L_HEALPIX) $(L_CFITSIO) $(LDFLAGS) 


#OBJ := ../sampler/sampler_io.o  ../sampler/random_modules.o ../sampler/sampler_modules.o wrapper.o  
OBJ := ../modules/sampler_io.o  ../modules/random_modules.o ../modules/sampler_modules.o wrapper.o  


default: all
all : $(OBJ)
	$(F90) $(F90FLAGS) -o ../bin/wrapper $(OBJ) $(LINK) 

%.o : %.f90
	$(F90) $(F90FLAGS) $(INCLUDE) -o $@ -c $<

clean: rm *.o
