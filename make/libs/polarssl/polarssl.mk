$(call PKG_INIT_LIB, 1.1.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-gpl.tgz
$(PKG)_SOURCE_MD5:=fdd367e3b5ab43ed2af8ffbdfaf0fb81
$(PKG)_SITE:=http://$(pkg).org/code/releases

$(PKG)_LIBNAME:=lib$(pkg).so.$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/library/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(POLARSSL_DIR)/library \
		VERSION="$(POLARSSL_VERSION)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(FPIC) -I../include" \
		OFLAGS="" \
		AR="$(TARGET_AR)" \
		shared static

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include
	cp -a $(POLARSSL_DIR)/include/polarssl $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/
	cp -a $(POLARSSL_DIR)/library/libpolarssl.a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	$(INSTALL_LIBRARY)

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(POLARSSL_DIR)/library clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpolarssl* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/polarssl/

$(pkg)-uninstall:
	$(RM) $(POLARSSL_TARGET_DIR)/libpolarssl.so*

$(PKG_FINISH)
