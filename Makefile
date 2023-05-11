######################################################
# T-RECS: The Tiered Radio Extragalactic Continuum   #
# Top Level Makefile                                 #
#                                                    #
# DO NOT modify this Makefile                        #
# Note: Modify the make.inc file to suit your system #
######################################################

TOPSRCDIR := $(PWD)
-include $(TOPSRCDIR)/make.inc

F90FLAGS += $(OMPFLAG)

L_GSL     = -L$(GSL_LIB) -lgsl -lgslcblas
I_CFITSIO = -I$(CFITSIO_INC)
L_CFITSIO = -L$(CFITSIO_LIB) -lcfitsio
I_HEALPIX = -I$(HEALPIX_INC)
L_HEALPIX = -L$(HEALPIX_LIB) -lhealpix -lgif
L_LAPACK  = -L$(LAPACK_DIR) -llapack

INCLUDE := $(I_CFITSIO) $(I_HEALPIX) 
LINK := $(LINK) $(L_HEALPIX) $(L_CFITSIO) $(L_LAPACK) $(LDFLAGS) 

###############################################################################################
# Paths within the top directory

SRCDIR = $(TOPSRCDIR)/src
MODDIR = $(PREFIX)/mod
ifdef F90RMOD
F90FLAGS += $(F90RMOD) $(MODDIR)
endif
PYTHONDIR = $(TOPSRCDIR)/python

###############################################################################################
# Define objects

OBJ_MOD = $(BUILDDIR)/random_modules.o $(BUILDDIR)/sampler_io.o $(BUILDDIR)/sampler_modules.o
OBJ_CON = $(BUILDDIR)/sampler_continuum.o
OBJ_HyI = $(BUILDDIR)/sampler_hi.o
OBJ_WRP = $(BUILDDIR)/wrapper.o

###############################################################################################
# Rules to build library

default: all

all: mkdirs modules continuum hi xmatch_hi xmatch_clustering wrapper ending

mkdirs:
	mkdir -p $(BUILDDIR) $(MODDIR) $(PREFIX)/bin 

modules: $(OBJ_MOD)

continuum: $(OBJ_MOD) $(OBJ_CON)
	$(F90) $(F90FLAGS) -o $(PREFIX)/bin/trecs_sampler_continuum $(OBJ_MOD) $(OBJ_CON) $(LINK)

hi: $(OBJ_MOD) $(OBJ_HyI)
	$(F90) $(F90FLAGS) -o $(PREFIX)/bin/trecs_sampler_hi $(OBJ_MOD) $(OBJ_HyI) $(LINK)

xmatch_hi: $(PYTHONDIR)/xmatch_hi.py
	sed "s|@PYTHONSHEBANG@|! $(shell which python)|" $(PYTHONDIR)/xmatch_hi.py \
	> $(PREFIX)/bin/trecs_xmatch_hi && \
	chmod u+x $(PREFIX)/bin/trecs_xmatch_hi

xmatch_clustering: $(PYTHONDIR)/xmatch_clustering.py
	sed "s|@PYTHONSHEBANG@|! $(shell which python)|" $(PYTHONDIR)/xmatch_clustering.py \
	> $(PREFIX)/bin/trecs_xmatch_clustering && \
	chmod u+x $(PREFIX)/bin/trecs_xmatch_clustering

wrapper: $(OBJ_MOD) $(OBJ_WRP)
	$(F90) $(F90FLAGS) -o $(PREFIX)/bin/trecs_wrapper $(OBJ_MOD) $(OBJ_WRP) $(LINK)

###############################################################################################
# Generic rules

$(BUILDDIR)/%.o : $(SRCDIR)/%.f90
	$(F90) $(F90FLAGS) $(INCLUDE) -o $@ -c $<

###############################################################################################
# Phony rules

.PHONY: clean ending

ending:
	cp $(SRCDIR)/trecs.sh $(PREFIX)/bin/trecs && chmod u+x $(PREFIX)/bin/trecs
	$(info )
	$(info Success!!)
	$(info )
	$(info Library built in $(PREFIX)/bin)
	$(info To use it remember to add it to your search path)
	$(info now removing build directory)
	rm -rf $(BUILDDIR)

clean:
	$(info cleaning up)
	rm -f $(BUILDDIR)/*.o $(MODDIR)/*.mod *~ *# $(PREFIX)/bin/trecs*

###############################################################################################
# Docker shortcuts
include $(TOPSRCDIR)/.make/docker.inc
.PHONY: docker docker-init docker-volume docker-run

auto-download:
	@[ -e $(TRECS_INPUTS_DIR) ] || \
		{ echo "TRECS_Inputs doesn't exist at $(TRECS_INPUTS_DIR), starting download..." ; \
			wget -c -O $(TRECS_INPUTS_DIR).tgz https://www.dropbox.com/s/3u4wtk1fxps6fwg/TRECS_Inputs.zip?dl=1; \
		  bsdtar xvf $(TRECS_INPUTS_DIR).tgz -C $(dir $(TRECS_INPUTS_DIR)) \
			|| tar xvf $(TRECS_INPUTS_DIR).tgz -C $(dir $(TRECS_INPUTS_DIR)); }
	mkdir -p $(TRECS_OUTPUTS_DIR)

docker-volume: auto-download
	docker volume inspect $(DOCKER_TRECS_INPUTS) > /dev/null 2>&1 \
		|| docker volume create -o type=none -o o=bind -o device=$(TRECS_INPUTS_DIR) $(DOCKER_TRECS_INPUTS)
	docker volume inspect $(DOCKER_TRECS_OUPUTS) > /dev/null 2>&1 \
		|| docker volume create -o type=none -o o=bind -o device=$(TRECS_OUTPUTS_DIR) $(DOCKER_TRECS_OUTPUTS)

docker: docker-init
docker-init: docker-volume
	docker build \
		--build-arg USER_UID=$(DOCKER_UID) \
    --build-arg USER_GID=$(DOCKER_GID) \
    --build-arg USER_NAME=$(DOCKER_USERNAME) \
		-t $(DOCKER_USERNAME)/trecs .

docker-run:
	docker run --rm -it \
		-v "$(DOCKER_TRECS_INPUTS):/home/$(DOCKER_USERNAME)/TRECS/TRECS_Inputs" \
		-v "$(DOCKER_TRECS_OUTPUTS):/home/$(DOCKER_USERNAME)/TRECS/TRECS_Outputs" \
		-v "./examples:/home/$(DOCKER_USERNAME)/TRECS/examples" \
		$(DOCKER_USERNAME)/trecs

docker-run-trecs:
	docker run --rm \
		-v "$(DOCKER_TRECS_INPUTS):/home/$(DOCKER_USERNAME)/TRECS/TRECS_Inputs" \
		-v "$(DOCKER_TRECS_OUTPUTS):/home/$(DOCKER_USERNAME)/TRECS/TRECS_Outputs" \
		-v "./examples:/home/$(DOCKER_USERNAME)/TRECS/examples" \
		$(DOCKER_USERNAME)/trecs -c 'trecs -c -p TRECS/examples/docker_pars.ini'

docker-run-trecs-wrapper:
	docker run --rm \
		-v "$(DOCKER_TRECS_INPUTS):/home/$(DOCKER_USERNAME)/TRECS/TRECS_Inputs" \
		-v "$(DOCKER_TRECS_OUTPUTS):/home/$(DOCKER_USERNAME)/TRECS/TRECS_Outputs" \
		-v "./examples:/home/$(DOCKER_USERNAME)/TRECS/examples" \
		$(DOCKER_USERNAME)/trecs -c 'trecs -w -p TRECS/examples/docker_pars.ini'
