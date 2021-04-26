REMOTE_DIR="/mnt/hdd/downloads"
LOG_FILE="/tmp/transmission.log"

ssh -i ~/.ssh/id_rsa pi@${storage_host} -p ${storage_port} "echo '\$TR_TORRENT_DIR transfer started' >> \$LOG_FILE"
scp -P ${storage_port} -i ~/.ssh/id_rsa -r \$TR_TORRENT_DIR pi@${storage_host}:\$REMOTE_DIR 1>>\$LOG_FILE 2>>\$LOG_FILE && echo "\$TR_TORRENT_DIR successfully copied" >>\$LOG_FILE 2>&1 && rm -rf \$TR_TORRENT_DIR
ssh -i ~/.ssh/id_rsa pi@${storage_host} -p ${storage_port} "echo '\$TR_TORRENT_DIR transfer finished' >> \$LOG_FILE"

ssh -i ~/.ssh/id_rsa pi@${storage_host} -p ${storage_port} "bash /home/pi/script.sh"
