################################################################################
#
# peridiod
#
################################################################################

PERIDIOD_VERSION = 1.0.0
PERIDIOD_SITE = $(call github,peridio,peridiod,v$(PERIDIOD_VERSION))
PERIDIOD_DEPENDENCIES = host-peridio-elixir peridio-erlang

define PERIDIOD_BUILD_CMDS
    $(TARGET_MAKE_ENV) \
      PERIDIOD_INCLUDE_ERTS_DIR=$(STAGING_DIR)/usr/lib/erlang/erts-13.0.3 \
      ERL_CFLAGS="-I$(STAGING_DIR)/lib/erlang/usr/include -I$(STAGING_DIR)/usr/include/libmnl" \
      ERL_LDFLAGS="-L$(STAGING_DIR)/usr/lib -lmnl -L$(STAGING_DIR)/lib/erlang/usr/lib -lei" \
      MIX_ENV=prod \
      MIX_TARGET=not_host \
      $(MAKE) \
      $(TARGET_CONFIGURE_OPTS) \
      -C $(@D) release
endef

define PERIDIOD_INSTALL_TARGET_CMDS
    ln -sf /usr/lib/peridiod/bin/peridiod $(TARGET_DIR)/usr/sbin/peridiod
    cp -r $(@D)/_build/not_host_prod/rel/peridiod $(TARGET_DIR)/usr/lib
    cp $(PERIDIOD_PKGDIR)/peridiod.service $(TARGET_DIR)/etc/systemd/system/peridiod.service
endef

$(eval $(generic-package))
