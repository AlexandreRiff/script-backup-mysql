#!/bin/bash

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# * Script para backup de todos as bases de dados do MySQL  *
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

# * Data e hora de inicio do script
DATETIME=$(date +"%d%m%Y_%H%M%S")

# * Diretorio de destino do backup
BACKUP_DIR="/var/lib/mysql/backup"

# * Log
LOG_DIR="/var/log/backup_mysql"
LOG_FILE="backup_mysql_${DATETIME}.log"
LOG="${LOG_DIR}/${LOG_FILE}"

# * Lista de banco de dados que deverao ser evitados no dump
DB_LIST_SKIP=("information_schema" "performance_schema" "sys")

# * Verifica se as pastas de destino existem, se nao realiza a criacao
function check_destination_folders_exist() {
	if [ ! -d $BACKUP_DIR ]; then
		echo "Criando diretorio: ${BACKUP_DIR} ..."
		mkdir -p $BACKUP_DIR
	fi

	if [ ! -d $LOG_DIR ]; then
		echo "Criando diretorio: ${LOG_DIR} ..."
		mkdir -p $LOG_DIR
	fi
}

# * Obtem data e hora atual
function get_current_datetime() {
	echo $(date +"%d%m%Y_%H%M%S")
}

# * Obtem todas as bases de dados e executa o dump em cada uma
function create_database_dump() {
	db_list=$(mysql --login-path=backup -Bse "SHOW DATABASES;")

	for db_name in $db_list; do
		db_skip=$(egrep -w $db_name <<<${DB_LIST_SKIP[@]})
		if [ "${db_skip}" ]; then
			echo "Pulando banco de dados: ${db_name} ..."
			continue
		fi

		echo "Criando dump do banco de dados: ${db_name} ..."
		datetime=$(get_current_datetime)
		dump_file="dump_${db_name}_${datetime}.sql"
		mysqldump --login-path=backup $db_name --result-file="${BACKUP_DIR}/${dump_file}"
		insert_log_db $? $db_name $dump_file
	done
}

# * Insere o log do dump gerado no banco de dados para rastreabilidade e monitoramento
function insert_log_db() {
	DUMP_SUCCESSFUL=0
	dump_status=$1
	db_name=$2
	dump_file=$3
	if [ $dump_status -eq $DUMP_SUCCESSFUL ]; then
		echo "Sucesso ao gerar o dump do banco de dados: ${db_name}"
		sql="INSERT INTO backup_log (backup_type, backup_date, backup_status, backup_log, backup_dir) VALUES ('mysqldump ${db_name} Full', '$(date +"%Y-%m-%d %H:%M:%S")', 'OK', 'status: ${dump_status} - backup executado com sucesso!, file: ${dump_file}', '${BACKUP_DIR}/dump_${DATETIME}.tar.gz');"
		mysql --login-path=backup -D backup -e "${sql}"
	else
		echo "Erro ao gerar o dump do banco de dados: ${db_name}"
		sql="INSERT INTO backup_log (backup_type, backup_date, backup_status, backup_log, backup_dir) VALUES ('mysqldump ${db_name} Full', '$(date +"%Y-%m-%d %H:%M:%S")', 'ERRO', 'status: ${dump_status} - backup falhou!, file: ${dump_file}', '${BACKUP_DIR}/dump_${DATETIME}.tar.gz');"
		mysql --login-path=backup -D backup -e "${sql}"
	fi
}

# * Compacta e comprimi os dumps gerados
function compress_dump_files() {
	echo "Compactando dumps gerados ..."
	compress_file="dump_${DATETIME}.tar.gz"
	dump_files="*.sql"
	cd $BACKUP_DIR
	tar -czf $compress_file $dump_files --remove-files
}

function start() {
	datetime=$(date +"%d/%m/%Y %H:%M:%S")
	echo -e "Iniciando Backup MySQL - ${datetime} \n"

	create_database_dump
	compress_dump_files

	datetime=$(date +"%d/%m/%Y %H:%M:%S")
	echo -e "\nFinalizando Backup MySQL - ${datetime}"
}

check_destination_folders_exist
start 1>$LOG 2>&1
sh /root/scripts_crontab/_rotateBackupsMysql.sh
