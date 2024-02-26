################################################################################
#
# peridiod
#
################################################################################

PERIDIOD_VERSION = 2.4.1
PERIDIOD_SITE = $(call github,peridio,peridiod,v$(PERIDIOD_VERSION))
PERIDIOD_DEPENDENCIES = host-elixir host-erlang erlang libmnl
PERIDIOD_ERTS_DIR = $(wildcard $(STAGING_DIR)/usr/lib/erlang/erts-*)
PERIDIOD_MIX = $(HOST_DIR)/usr/bin/mix

define PERIDIOD_BUILD_CMDS
	$(PERIDIOD_MIX) local.hex --force
	$(PERIDIOD_MIX) local.rebar --force
	cd $(@D) && $(PERIDIOD_MIX) deps.get

	cd $(@D) && $(TARGET_CONFIGURE_OPTS) \
	LANG=en_US.UTF-8 \
	LC_ALL=en_US.UTF-8 \
	ERL_CFLAGS="-I$(STAGING_DIR)/lib/erlang/usr/include -I$(STAGING_DIR)/usr/include/libmnl" \
	ERL_LDFLAGS="-L$(STAGING_DIR)/usr/lib -lmnl -L$(STAGING_DIR)/lib/erlang/usr/lib -lei" \
	ERL_LIBDIR="$(STAGING_DIR)/lib/erlang/lib" \
	ERL_EI_LIBDIR="$(STAGING_DIR)/lib/erlang/usr/lib" \
	ERL_EI_INCLUDE_DIR="$(STAGING_DIR)/lib/erlang/usr/include" \
	MIX_TARGET_INCLUDE_ERTS=$(PERIDIOD_ERTS_DIR) \
	MIX_ENV=prod \
	MIX_TARGET=target \
	$(PERIDIOD_MIX) release
endef

define PERIDIOD_INSTALL_TARGET_CMDS
    ln -sf /usr/lib/peridiod/bin/peridiod $(TARGET_DIR)/usr/sbin/peridiod
    cp -r $(@D)/_build/target_prod/rel/peridiod $(TARGET_DIR)/usr/lib
    mkdir -p $(TARGET_DIR)/etc/systemd/system
		mkdir -p $(TARGET_DIR)/etc/systemd/system.conf.d
    cp $(PERIDIOD_PKGDIR)peridiod.service $(TARGET_DIR)/etc/systemd/system/peridiod.service
		cp $(PERIDIOD_PKGDIR)peridiod.conf $(TARGET_DIR)/etc/systemd/system.conf.d/peridiod.conf
endef

$(eval $(generic-package))
