#!/bin/bash

### DESCRIPTION
# $1 - измеряемая метрика
# [$2] - пользователь mysql для подключения (не обязательный параметр, можно задать в скрипте ниже)
# [$3] - пароль пользователя (не обязательный параметр, можно задать в скрипте ниже)

### OPTIONS VERIFICATION
if [ -z $1 ]; then
	exit 1
fi

### PARAMETERS
METRIC="$1"
USER="${2:-root}"	# имя пользователя из 2-го параметра или указать после символов ":-"
PASSWD="${3:-}"		# пароль из 3-го параметра или указать после символов ":-"

MYSA=`which mysqladmin`

CACHE="/tmp/mysqlstat.cache"
CACHETTL="60"	# Время действия кеша в секундах (должно быть равно периоду опроса элементов)

### RUN

# Проверка работы mysql не кешируется
if [ "$1" = "ping" ]; then
	$MYSA -u$USER -p$PASSWD ping|grep alive|wc -l
	exit
fi

# Проверка версии mysql
if [ "$1" = "version" ]; then
	mysql -V
	exit
fi

## Проверка кеша

# время создание кеша (или 0 есть файл кеша отсутствует или имеет нулевой размер)
if [ -s "$CACHE" ]; then
	TIMECACHE=`stat -c"%Z" "$CACHE"`
else
	TIMECACHE=0
fi

# текущее время
TIMENOW=`date '+%s'`
# Если кеш неактуален, то обновить его (выход при ошибке)
if [ "$(($TIMENOW - $TIMECACHE))" -gt "$CACHETTL" ]; then
	$MYSA -u$USER -p$PASSWD extended-status > "$CACHE" || exit 1
fi

# Получение значения указанной метрики
cat $CACHE | grep -iw "$METRIC" | cut -d'|' -f3
