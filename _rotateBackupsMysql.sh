#!/bin/bash

# * * * * * * * * * * * * * * * * * * * * * *
# ** Script manutencao de backups MySQL **  *
# * * * * * * * * * * * * * * * * * * * * * *

# * Meses a considerar para exclusao dos backups antigos
DELETE_BACKUPS_LAST_MONTHS=1

# * Verifica backups gerados nos ultimos meses conforme valor setado em "DELETE_BACKUPS_LAST_MONTHS" e realiza a exclusao dos mesmos
function delete_old_backups() {
	sql="SELECT backup_dir FROM backup_log WHERE backup_retained = 'Y' AND backup_date <= DATE_SUB(NOW(), INTERVAL ${DELETE_BACKUPS_LAST_MONTHS} MONTH);"
	old_backups=$(mysql --login-path=backup -D backup -se "${sql}")
	for old_backup in $old_backups; do
		echo "Excluindo backup antigo: ${old_backup} ..."
		rm -f $old_backup
		sql="UPDATE backup_log SET backup_retained = 'N' WHERE backup_dir = '${old_backup}';"
		mysql --login-path=backup -D mydb -e "${sql}"
	done
}

function start() {
	CURRENT_DAY=$(date +"%d")
	# * Realiza a execucao sempre na segunda semana do mes
	if [ $CURRENT_DAY -ge 08 ] && [ $CURRENT_DAY -le 14 ]; then
		delete_old_backups
	fi
}

start 1>/dev/null 2>&1
