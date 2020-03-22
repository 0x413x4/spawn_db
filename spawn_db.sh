#!/bin/bash

# spawn_db.sh - Script to pull various databases from online
#               docker images, and spawn a local instance ready
#					 to use.
#
# alexa (@0x413x4) - 2020 


##### Docker images
MSSQL_IMAGE="mcr.microsoft.com/mssql/server:2017-latest"
MYSQL_IMAGE="mysql/mysql-server:latest"
POSTGRES_IMAGE="postgres:latest"
ORACLEDB_IMAGE="softwareplant/oracle:latest"


##### Functions
usage()
{
	echo "Usage: "
	echo "$ spawn_db.sh [mssql | mysql | oracle | postgres]"
}


wait_for() {
	local duration=${1}
	local bar_size=20

	already_done() 
	{ 
		let s="($elapsed * $bar_size) / $duration"
		for ((done=0; done<$s; done++)); do 
			printf "▇"; 
		done 
	}

	remaining() 
	{ 
		let r="$bar_size - (($elapsed * $bar_size) / $duration)"
		for ((done=0; done<$r; done++)); do 
			printf " "; 
		done 
	}

	percentage() { 
		printf "| %s%%" $(( (($elapsed)*100) / ($duration)*100 / 100 )); 
	}

	clean_line() { 
		printf "\r"; 
	}

	for (( elapsed=1; elapsed<=$duration; elapsed++ )); do
		already_done; remaining; percentage
		sleep 1
		clean_line
	done

	clean_line
}


start_mssql()
{
	echo "[i] Generating a random password..."
	DB_PASSWORD=$(openssl rand -base64 25)

	echo "[i] Creating a new container for Microsoft SQL..."
	docker run --rm --name mssql -d -e 'ACCEPT_EULA=Y' \
				  -e 'SA_PASSWORD='$DB_PASSWORD $MSSQL_IMAGE &> /dev/null

	wait_for 15

	echo "[i] Starting sqlcmd..."
	echo "--------------------"
	echo
	docker exec -it mssql /opt/mssql-tools/bin/sqlcmd \
			      -S 127.0.0.1 -U sa -P $DB_PASSWORD
	
	echo "[i] Cleaning up..."
	docker stop mssql
	
	echo "[i] Done."
}


start_mysql()
{
	echo "[i] Generating a random password..."
	DB_PASSWORD=$(openssl rand -base64 25)
	
	echo "[i] Creating a new container for MySQL..."
	docker run --rm --name mysql -d $MYSQL_IMAGE &> /dev/null 

	wait_for 15

	echo "[i] Greping temp password from install log and setting new password"
	TMP_PASSWORD=$(docker logs mysql 2>&1 | grep GENERATED | awk '{print $5}')
	docker exec -it mysql mysql --connect-expired-password -uroot \
			-p$TMP_PASSWORD \
			-e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_PASSWORD';" &> /dev/null

	echo "[i] Starting mysql..."
	echo "--------------------"
	echo
	docker exec -it mysql mysql --silent -uroot -p$DB_PASSWORD

	echo "[i] Cleaning up..."
	docker stop mysql

	echo "[i] Done."
}


start_postgres()
{
	echo "[i] Generating a random password..."
	DB_PASSWORD=$(openssl rand -base64 25)
	
	echo "[i] Creating a new container for PostgresSQL..."
	docker run --rm --name postgres -e POSTGRES_PASSWORD=$DB_PASSWORD -d $POSTGRES_IMAGE &>/dev/null

	wait_for 15

	echo "[i] Starting psql..."
	echo "--------------------"
	echo
	docker exec -it postgres psql -h 127.0.0.1 -U postgres

	echo "[i] Cleaning up..."
	docker stop postgres

	echo "[i] Done."
}


start_oracle()
{
	echo "[i] Creating a new container for Oracle. This will take about 10 minutes (thanks oracle..) go grab a coffee!"
	docker run --rm --name oracle -d $ORACLEDB_IMAGE &> /dev/null

	wait_for 600

	echo "[i] Starting sqlplus..."
	echo "--------------------"
	echo
	docker exec -it oracle sqlplus system/Oradoc_db1@ORCLCDB

	echo "[i] Cleaning up..."
	docker stop oracle

	echo "[i] Done."
}


##### Main
echo "===================="
echo "==    spawn_db    =="
echo "===================="
echo

if [ "$1" = "" ]; then 
	usage
	exit
fi

case $1 in
	mssql )
		start_mssql
		;;
	mysql )
		start_mysql
		;;
	postgres )
		start_postgres
		;;
	oracle )
		start_oracle
		;;
	-h | --help ) 
		usage
		exit
		;;
	* )
		usage
		exit -1
		;;
esac
exit

