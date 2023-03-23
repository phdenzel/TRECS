SUBDIRS := sampler_continuum sampler_hi wrapper

all: $(SUBDIRS)
$(SUBDIRS):
        $(MAKE) -C $@

.PHONY: all $(SUBDIRS)
