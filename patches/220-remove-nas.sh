[ "$FREETZ_REMOVE_NAS" == "y" ] || return 0

echo1 "removing nas"
rm -rf "${FILESYSTEM_MOD_DIR}/bin/showfritznasdbstat"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www.nas"
ln -sf www "${FILESYSTEM_MOD_DIR}/usr/www.nas"

modsed "s/CONFIG_NAS.*/CONFIG_NAS=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

echo2 "removing internal memory"
rm -rf ${FILESYSTEM_MOD_DIR}/etc/internal_memory_default*.tar
