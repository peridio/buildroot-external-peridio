################################################################################
#
# peridio erlang
#
################################################################################

# See note below when updating Peridio Erlang
PERIDIO_ERLANG_VERSION = 25.0.3
PERIDIO_ERLANG_SITE = \
	https://github.com/erlang/otp/releases/download/OTP-$(PERIDIO_ERLANG_VERSION)
PERIDIO_ERLANG_SOURCE = otp_src_$(PERIDIO_ERLANG_VERSION).tar.gz
PERIDIO_ERLANG_DEPENDENCIES = host-peridio-erlang

PERIDIO_ERLANG_LICENSE = Apache-2.0
PERIDIO_ERLANG_LICENSE_FILES = LICENSE.txt
PERIDIO_ERLANG_CPE_ID_VENDOR = erlang
PERIDIO_ERLANG_CPE_ID_PRODUCT = erlang\/otp
PERIDIO_ERLANG_INSTALL_STAGING = YES
PERIDIO_ERLANG_INSTALL_TARGET = NO

# windows specific issue: https://nvd.nist.gov/vuln/detail/CVE-2021-29221
ERLANG_IGNORE_CVES += CVE-2021-29221

# Remove the leftover deps directory from the ssl app
# See https://bugs.erlang.org/browse/ERL-1168
define PERIDIO_ERLANG_REMOVE_SSL_DEPS
	rm -rf $(@D)/lib/ssl/src/deps
endef
PERIDIO_ERLANG_POST_PATCH_HOOKS += PERIDIO_ERLANG_REMOVE_SSL_DEPS

# Patched erts/aclocal.m4
define PERIDIO_ERLANG_RUN_AUTOCONF
	cd $(@D) && PATH=$(BR_PATH) ./otp_build autoconf
endef
PERIDIO_ERLANG_DEPENDENCIES += host-autoconf
PERIDIO_ERLANG_PRE_CONFIGURE_HOOKS += PERIDIO_ERLANG_RUN_AUTOCONF
HOST_PERIDIO_ERLANG_DEPENDENCIES += host-autoconf
HOST_PERIDIO_ERLANG_PRE_CONFIGURE_HOOKS += PERIDIO_ERLANG_RUN_AUTOCONF

# Whenever updating Erlang, this value should be updated as well, to the
# value of EI_VSN in the file lib/erl_interface/vsn.mk
PERIDIO_ERLANG_EI_VSN = 5.3

# The configure checks for these functions fail incorrectly
PERIDIO_ERLANG_CONF_ENV = ac_cv_func_isnan=yes ac_cv_func_isinf=yes \
		  i_cv_posix_fallocate_works=yes

# Set erl_xcomp variables. See xcomp/erl-xcomp.conf.template
# for documentation.
PERIDIO_ERLANG_CONF_ENV += erl_xcomp_sysroot=$(STAGING_DIR)

# Support for CLOCK_THREAD_CPUTIME_ID cannot be autodetected for
# crosscompiling. The man page for clock_gettime(3) indicates that
# Linux 2.6.12 and later support this.
PERIDIO_ERLANG_CONF_ENV += erl_xcomp_clock_gettime_cpu_time=yes

PERIDIO_ERLANG_CONF_OPTS = --without-javac

# Force ERL_TOP to the downloaded source directory. This prevents
# Erlang's configure script from inadvertantly using files from
# a version of Erlang installed on the host.
PERIDIO_ERLANG_CONF_ENV += ERL_TOP=$(@D)
HOST_PERIDIO_ERLANG_CONF_ENV += ERL_TOP=$(@D)

# erlang uses openssl for all things crypto. Since the host tools (such as
# rebar) uses crypto, we need to build host-erlang with support for openssl.
HOST_PERIDIO_ERLANG_DEPENDENCIES += host-openssl
HOST_PERIDIO_ERLANG_CONF_OPTS = --without-javac --with-ssl=$(HOST_DIR)

HOST_PERIDIO_ERLANG_CONF_OPTS += --without-termcap

ifeq ($(BR2_PACKAGE_NCURSES),y)
PERIDIO_ERLANG_CONF_OPTS += --with-termcap
PERIDIO_ERLANG_DEPENDENCIES += ncurses
else
PERIDIO_ERLANG_CONF_OPTS += --without-termcap
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
PERIDIO_ERLANG_CONF_OPTS += --with-ssl
PERIDIO_ERLANG_DEPENDENCIES += openssl
else
PERIDIO_ERLANG_CONF_OPTS += --without-ssl
endif

ifeq ($(BR2_PACKAGE_UNIXODBC),y)
PERIDIO_ERLANG_DEPENDENCIES += unixodbc
PERIDIO_ERLANG_CONF_OPTS += --with-odbc
else
PERIDIO_ERLANG_CONF_OPTS += --without-odbc
endif

# Always use Buildroot's zlib
PERIDIO_ERLANG_CONF_OPTS += --disable-builtin-zlib
PERIDIO_ERLANG_DEPENDENCIES += zlib

# Remove source, example, gs and wx files from staging and target.
PERIDIO_ERLANG_REMOVE_PACKAGES = gs wx

ifneq ($(BR2_PACKAGE_PERIDIO_ERLANG_MEGACO),y)
PERIDIO_ERLANG_REMOVE_PACKAGES += megaco
endif

define PERIDIO_ERLANG_REMOVE_STAGING_UNUSED
	for package in $(PERIDIO_ERLANG_REMOVE_PACKAGES); do \
		rm -rf $(STAGING_DIR)/usr/lib/erlang/lib/$${package}-*; \
	done
endef

define PERIDIO_ERLANG_REMOVE_TARGET_UNUSED
	find $(TARGET_DIR)/usr/lib/erlang -type d -name src -prune -exec rm -rf {} \;
	find $(TARGET_DIR)/usr/lib/erlang -type d -name examples -prune -exec rm -rf {} \;
	for package in $(PERIDIO_ERLANG_REMOVE_PACKAGES); do \
		rm -rf $(TARGET_DIR)/usr/lib/erlang/lib/$${package}-*; \
	done
endef

PERIDIO_ERLANG_POST_INSTALL_STAGING_HOOKS += PERIDIO_ERLANG_REMOVE_STAGING_UNUSED
PERIDIO_ERLANG_POST_INSTALL_TARGET_HOOKS += PERIDIO_ERLANG_REMOVE_TARGET_UNUSED

$(eval $(autotools-package))
$(eval $(host-autotools-package))
