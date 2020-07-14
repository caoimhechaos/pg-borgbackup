#!/bin/sh
#
# Dump PostgreSQL database(s) specified and run borg backup on the result.
#

set -e

if test -z "$PG_USER"
then
	echo "Please set the PG_USER variable to your backup user." 1>&2
	exit 1
fi
if test -z "$PG_DATABASES"
then
	echo "Please set the PG_DATABASES variable to a list of databases to backup." 1>&2
	exit 1
fi
if test -z "$PG_HOSTNAME"
then
	echo "Please set the PG_HOSTNAME variable to the name of the server to backup." 1>&2
	exit 1
fi
if test -z "$BORG_SERVER"
then
	echo "Please set the BORG_SERVER variable to the name of the borg server to backup to." 1>&2
	exit 1
fi
if test -z "$BORG_PREFIX"
then
	echo "Please set the BORG_PREFIX variable to the prefix of the borg archive name." 1>&2
	exit 1
fi
if test -z "$BORG_USER"
then
	export BORG_USER=borg
fi

install -o pg_borgbackup -m 0600 /pgpass/pgpass ~/.pgpass
install -o pg_borgbackup -m 0700 -d ~/.ssh
install -o pg_borgbackup -m 0600 /ssh/id_* ~/.ssh
install -o pg_borgbackup -m 0644 /ssh/known_hosts ~/.ssh

for db in ${PG_DATABASES}
do
	rm -fr /backup/${db}
	pg_dump -h ${PG_HOSTNAME} -U ${PG_USER} -cC --if-exists -f /backup/${db} --format=d $db
done
borg create -s -C lzma,9 ${BORG_USER}@${BORG_SERVER}:${BORG_PREFIX}::$(date +"%Y%m%d-%H%M%S") /backup

