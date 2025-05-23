####################################################
# T-RECS: The Tiered Radio Extragalactic Continuum #
# Make include file                                #
#                                                  #
# Modify this file to suit your system             #
# Note: DO NOT modify the general Makefile         #
####################################################

SHELL = /bin/sh

# PREFIX sets the root directory for installation of the binaries
#
PREFIX = /TRECS

#  CC is the C compiler, normally invoked with options CFLAGS.
#
CC = gcc
CFLAGS = -O3 -std=C99

# Modify the F90 and F90FLAGS definitions to the desired compiler
# and desired compiler options for your machine.
#
F90 = gfortran
F90FLAGS = -O3 -std=legacy

# Provide the flag in your compiler used to redirect
# .mod builds in directory different than current
# (e.g. gfortran -> '-J', ifort -> '-module')
# If commented or left empty modules will be compiled
# in the current directory
#
F90RMOD = -J

# OpenMP flag for your system
#
OMPFLAG = -fopenmp

# Eventual additional link flags
#
LDFLAGS = -lgcc

###############################################################################################
# Dependencies

# GSL library
#
GSL_DIR = /usr/local
GSL_LIB = $(GSL_DIR)/lib

# CFITSIO library
#
CFITSIO_DIR = /usr/local
CFITSIO_INC = $(CFITSIO_DIR)/include
CFITSIO_LIB = $(CFITSIO_DIR)/lib

# HEALPIX library
#
HEALPIX_DIR = /opt/healpix
HEALPIX_INC = $(HEALPIX_DIR)/include
HEALPIX_LIB = $(HEALPIX_DIR)/lib

# LAPACK library
#
LAPACK_DIR = /usr/local/lib
LAPACK_LIB = $(LAPACK_DIR)

###############################################################################################

BUILDDIR = /TRECS/build

###############################################################################################


