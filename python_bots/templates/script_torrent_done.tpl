scp -P ${storage_port} -i ~/.ssh/id_rsa -r \$TR_TORRENT_DIR pi@${storage_host}:/mnt/hdd/downloads 1>> /tmp/transmission.log 2>> /tmp/transmission.log && echo "\$TR_TORRENT_DIR successfully copied" >> /tmp/transmission.log 2>&1 && rm -rf \$TR_TORRENT_DIR