################################################################################
#
# peridio elixir
#
################################################################################

PERIDIO_ELIXIR_VERSION = 1.13.4
PERIDIO_ELIXIR_SITE = $(call github,elixir-lang,elixir,v$(PERIDIO_ELIXIR_VERSION))
PERIDIO_ELIXIR_LICENSE = Apache-2.0
PERIDIO_ELIXIR_LICENSE_FILES = LICENSE
HOST_PERIDIO_ELIXIR_DEPENDENCIES = host-peridio-erlang

define HOST_PERIDIO_ELIXIR_BUILD_CMDS
	$(HOST_MAKE_ENV) $(HOST_CONFIGURE_OPTS) $(MAKE) -C $(@D) compile
endef

define HOST_PERIDIO_ELIXIR_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(HOST_CONFIGURE_OPTS) $(MAKE) PREFIX="$(HOST_DIR)" -C $(@D) install
endef

$(eval $(host-generic-package))
