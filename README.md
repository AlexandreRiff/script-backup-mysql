# Script de Backup de Banco de Dados MySQL

Este script realiza o backup automatizado de todos os bancos de dados MySQL, exceto por aqueles especificados na lista de bancos de dados a serem ignorados. Ele cria dumps individuais para cada banco de dados e os compacta em um arquivo _tar.gz_. Além disso, registra informações sobre o backup em um banco de dados para rastreabilidade e monitoramento.

## 💻 Requisitos

- Acesso ao servidor MySQL com privilégios suficientes para executar comandos de backup e inserir registros no banco de dados de log.
- Acesso ao sistema de arquivos do servidor para criar e gerenciar diretórios de backup e log.

## ⚙️ Configuração

Antes de executar o script, é necessário fazer algumas configurações.

1. Editar permissões do script:

Certifique-se de que o script tenha permissão de execução.

```shell
chmod +x _backupMysql.sh
```

2. Modificar variáveis:

- `$BACKUP_DIR`: Diretório onde os arquivos de backup serão armazenados (por padrão: _/var/lib/mysql/backup_).
- `$LOG_DIR`: Diretório onde os arquivos de log serão armazenados (por padrão: _/var/log/backup_mysql_).
- `$DB_LIST_SKIP`: Lista de bancos de dados que não devem ser incluídos no backup (por padrão: _information_schema, performance_schema e sys_).

## 🔑 Credenciais de Acesso ao MySQL

O script usa o conceito de _login path_ para autenticação com o MySQL. O login path é um recurso utilizado para autenticação com o banco de dados MySQL. Ele permite armazenar e gerenciar de forma segura as opções de conexão do cliente MySQL em um arquivo de login criptografado, em vez de especificá-las na linha de comando.

A configuração de um login path é feita da seguinte maneira:

```shell
mysql_config_editor set --login-path=backup --host=nome_do_host --user=nome_do_usuário --password
```

Neste comando, substitua _"backup"_ pelo nome desejado para o login path. O _"nome_do_host"_ deve ser substituído pelo nome do host do MySQL ao qual você deseja se conectar. _"nome_do_usuário"_ deve ser substituído pelo nome de usuário do MySQL e _"--password"_ indica que você será solicitado a inserir a senha do MySQL.

Digite a senha do MySQL quando solicitado. O login path será então armazenado de forma segura no arquivo de login.

## 🔄 Script de Rotação de Backups

O script finaliza executando um script externo (`_rotateBackupsMysql.sh`).
Este script externo é responsável pela rotação dos backups, removendo backups antigos de um determinado período, na qual é determinado pela variável `$DELETE_BACKUPS_LAST_MONTHS` (por padrão: 1 mês).

## ☕️ Uso

### Execução Manual

Para executar o script manualmente, navegue até o diretório onde o script está localizado e execute:

```shell
sh _backupMysql.sh
```

### Agendamento com Cron

Para agendar o script para execução automática, adicione uma entrada no crontab. Por exemplo, para executar o script todos os dias à meia-noite, adicione a seguinte linha ao crontab:

```shell
0 0 * * * sh _backupMysql.sh
```

## 📝 Logs

O script gera logs detalhados de cada execução, incluindo informações sobre o sucesso ou falha de cada backup de banco de dados. Os logs são armazenados no diretório especificado por `$LOG_DIR`.

## ℹ️ Limitações

O script não verifica se há espaço suficiente no diretório de backup antes de iniciar o backup. Certifique-se de que haja espaço suficiente para acomodar os arquivos de backup.
