FROM alpine:latest
LABEL maintainer Caoimhe Chaos <caoimhechaos@protonmail.com>

RUN apk --update add borgbackup openssh-client postgresql-client
RUN adduser -h /home/pg_borgbackup -g "borg backup of PostgreSQL" -s /sbin/nologin -S -D pg_borgbackup

COPY backup.sh /usr/local/bin/backup.sh
VOLUME ["/backup", "/pgpass", "/ssh"]
USER pg_borgbackup
ENTRYPOINT sh -x /usr/local/bin/backup.sh
