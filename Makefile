SUBDIRS := sampler_continuum sampler_hi wrapper
TRECS_INP_DIR ?= /data/TRECS_Inputs
TRECS_INP ?= trecs_inputs

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)

.PHONY: docker-volume
docker-volume:
	@( docker volume inspect $(TRECS_INP) 1>/dev/null || \
		 docker volume create -o type=none -o o=bind -o device=$(TRECS_INP_DIR) trecs_inputs )

.PHONY: docker
docker: docker-init
.PHONY: docker-init
docker-init: docker-volume
	@[ -n "$(SSH_AUTH_SOCK)" ] || \
		{ echo "SSH_AUTH_SOCK is not set, please run an ssh-agent" ; \
			exit 1 ; }
	docker build --ssh default -t trecs .

.PHONY: docker-run
docker-run:
	docker run --rm -it -v "$(TRECS_INP):/TRECS_Inputs" trecs
