$(call PKG_INIT_BIN, 3.9p1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=afc34175f38d08867c1403d9008600b3
$(PKG)_SITE:=ftp://ftp.openbsd.org/pub/OpenBSD/OpenNTPD/
$(PKG)_BINARY:=$($(PKG)_DIR)/ntpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ntpd

$(PKG)_STARTLEVEL=60 # before aiccu

$(PKG)_CONFIGURE_OPTIONS += --with-builtin-arc4random
$(PKG)_CONFIGURE_OPTIONS += --with-privsep-user=ntp
$(PKG)_CONFIGURE_OPTIONS += --with-adjtimex

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENNTPD_DIR) \
		$(TARGET_CONFIGURE_ENV) \
		CFLAGS="$(TARGET_CFLAGS) -DUSE_ADJTIMEX" \
		LDFLAGS=""

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENNTPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(OPENNTPD_TARGET_BINARY)

$(PKG_FINISH)
