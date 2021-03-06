$(call PKG_INIT_BIN, 3.12.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=a063f76aa47edab55a3f31ff2558df07
$(PKG)_SITE:=@SF/hplip
$(PKG)_LIB_IP_VERSION=0.0.1
$(PKG)_LIB_IP_BINARY:=$($(PKG)_DIR)/.libs/libhpip.so.$($(PKG)_LIB_IP_VERSION)
$(PKG)_LIB_IP_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpip.so.$($(PKG)_LIB_IP_VERSION)
$(PKG)_LIB_IP_TARGET_BINARY:=$($(PKG)_DEST_LIBDIR)/libhpip.so.$($(PKG)_LIB_IP_VERSION)
$(PKG)_LIB_MUD_VERSION=0.0.6
$(PKG)_LIB_MUD_BINARY:=$($(PKG)_DIR)/.libs/libhpmud.so.$($(PKG)_LIB_MUD_VERSION)
$(PKG)_LIB_MUD_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpmud.so.$($(PKG)_LIB_MUD_VERSION)
$(PKG)_LIB_MUD_TARGET_BINARY:=$($(PKG)_DEST_LIBDIR)/libhpmud.so.$($(PKG)_LIB_MUD_VERSION)
$(PKG)_LIB_HPAIO_VERSION=1.0.0
$(PKG)_LIB_HPAIO_BINARY:=$($(PKG)_DIR)/.libs/libsane-hpaio.so.$($(PKG)_LIB_HPAIO_VERSION)
$(PKG)_LIB_HPAIO_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sane/libsane-hpaio.so.$($(PKG)_LIB_HPAIO_VERSION)
$(PKG)_LIB_HPAIO_TARGET_BINARY:=$($(PKG)_DEST_LIBDIR)/sane/libsane-hpaio.so.$($(PKG)_LIB_HPAIO_VERSION)

$(PKG)_DEPENDS_ON := sane-backends

$(PKG)_CONFIGURE_PRE_CMDS += autoreconf -f -i;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-lite-build
$(PKG)_CONFIGURE_OPTIONS += --disable-doc-build
$(PKG)_CONFIGURE_OPTIONS += --disable-network-build
$(PKG)_CONFIGURE_OPTIONS += --disable-pp-build
$(PKG)_CONFIGURE_OPTIONS += --disable-gui-build
$(PKG)_CONFIGURE_OPTIONS += --disable-fax-build
$(PKG)_CONFIGURE_OPTIONS += --disable-dbus-build
$(PKG)_CONFIGURE_OPTIONS += --disable-cups-drv-install
$(PKG)_CONFIGURE_OPTIONS += --disable-foomatic-drv-install
$(PKG)_CONFIGURE_OPTIONS += --disable-foomatic-rip-hplip-install
$(PKG)_CONFIGURE_OPTIONS += --disable-hpcups-install

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIB_IP_BINARY) \
	$($(PKG)_LIB_MUD_BINARY) \
	$($(PKG)_LIB_HPAIO_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HPLIP_DIR)

$($(PKG)_LIB_IP_STAGING_BINARY) \
	$($(PKG)_LIB_MUD_STAGING_BINARY) \
	$($(PKG)_LIB_HPAIO_STAGING_BINARY): $($(PKG)_LIB_IP_BINARY) \
						$($(PKG)_LIB_MUD_BINARY) \
						$($(PKG)_LIB_HPAIO_BINARY)
	$(SUBMAKE) -C $(HPLIP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpip.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpmud.la
	cp $(HPLIP_DIR)/io/hpmud/hpmud.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include

$($(PKG)_LIB_IP_TARGET_BINARY): $($(PKG)_LIB_IP_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_LIB_MUD_TARGET_BINARY): $($(PKG)_LIB_MUD_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_LIB_HPAIO_TARGET_BINARY): $($(PKG)_LIB_HPAIO_STAGING_BINARY)
	mkdir -p $(HPLIP_DEST_LIBDIR)/sane
	mkdir -p $(HPLIP_DEST_DIR)/etc
	mkdir -p $(HPLIP_DEST_DIR)/usr/share/hplip/data/models
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sane/libsane-hpaio.so* $(HPLIP_DEST_LIBDIR)/sane
	cp -R $(TARGET_TOOLCHAIN_STAGING_DIR)/etc/default.hplip $(HPLIP_DEST_DIR)/etc
	$(TARGET_STRIP) $@

$(PKG)_TARGET_CONF:
	$(call MESSAGE,HPLIP: Strip down models.dat to $(FREETZ_PACKAGE_HPLIP_PRINTER_TYPE))
	@awk 'BEGIN { found=0 } /^\[.*\]/ || /^$$/ { found=0 } /^\['$(FREETZ_PACKAGE_HPLIP_PRINTER_TYPE)'\]/ { found=1 } \
		{ if (found) { print $$0 } }' < $(HPLIP_DIR)/data/models/models.dat \
		> $(HPLIP_DEST_DIR)/usr/share/hplip/data/models/models.dat

.PHONY: $(PKG)_TARGET_CONF

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIB_IP_TARGET_BINARY) \
			$($(PKG)_LIB_MUD_TARGET_BINARY) \
			$($(PKG)_LIB_HPAIO_TARGET_BINARY) \
			$(PKG)_TARGET_CONF

$(pkg)-clean:
	-$(SUBMAKE) -C $(HPLIP_DIR) clean

$(pkg)-config-update:
	$(HPLIP_MAKE_DIR)/hplip-config-update.pl $(HPLIP_VERSION) \
		$(HPLIP_DIR)/data/models/models.dat > $(HPLIP_MAKE_DIR)/Config.in

$(pkg)-uninstall:
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhp* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sane/libsane-hpaio* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/hpmud.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/hplip \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/etc/default.hplip

$(PKG_FINISH)
