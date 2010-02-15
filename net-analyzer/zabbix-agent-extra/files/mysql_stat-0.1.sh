#!/bin/bash

### PARAM

MYSA="/usr/bin/mysqladmin"
#MYSA=`which mysqladmin`
USER="root"
PASSWD="JIDBOBDgfd"

CACHE="/tmp/mysqlstat.cache"
CACHEVALID="50"

### RUN

# $1 - обязательный параметр, указывает измеряемую мертику
if [ -z $1 ]; then
	exit 1
fi

# Проверка работы mysql не кешируется
if [ "$1" = "ping" ]; then
	$MYSA -u$USER -p$PASSWD ping|grep alive|wc -l
	exit
fi

## Проверка кеша

# текущее время
TIMENOW=`date '+%s'`
# время создание кеша (или 0 есть файл кеша отсутствует)
if [ -e "$CACHE" ]; then
	TIMECACHE=`stat -c"%Z" "$CACHE"`
else
	TIMECACHE=0
fi

# Если кеш неактуален, то обновить его
if [ "$(($TIMENOW - $TIMECACHE))" -gt "$CACHEVALID" ]; then
	$MYSA -u$USER -p$PASSWD extended-status > "$CACHE"
fi

# Получение значения указанной метрики
cat $CACHE | grep -iw $1 | cut -d'|' -f3
