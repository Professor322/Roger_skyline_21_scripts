if [[ $(md5sum /var/spool/cron/root) = $(cat /var/spool/cron/hashsum) ]];
then
		echo "Crontab has not been modified"
	else
			echo "Crontab has been modified" | mail -s "CRON CHANGES" professor3222@gmail.com
		fi
