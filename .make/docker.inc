####################################################
# T-RECS: The Tiered Radio Extragalactic Continuum #
# Make include file (for docker shortcuts)         #
#                                                  #

# Modify this file to suit your system             #
# Note: DO NOT modify the general Makefile         #
####################################################

# Path to the TRECS_Inputs directory
#
TRECS_INPUTS_DIR = /data/TRECS_Inputs
TRECS_OUTPUTS_DIR = /data/TRECS_Outputs

# Docker-specific settings
#
DOCKER_TRECS_INPUTS = trecs_inputs
DOCKER_TRECS_OUTPUTS = trecs_outputs
DOCKER_USERNAME = $(shell id -un)
DOCKER_UID = $(shell id -u)
DOCKER_GID = $(shell id -g)
