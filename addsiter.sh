#!/bin/bash

# Проверка, что root может запускать этот скрипт
if [[ $EUID -ne 0 ]]; then
   echo "[ОШИБКА] - Этот скрипт должен быть запущен от имени пользователя root" 1>&2
   exit 1
fi

# корневая директория по умолчанию для сайтов в linux
SITEDIR="/var/www/html/"
# корневая директория по умолчанию для сайтов в windows
# SITEDIR="/mnt/c/projects/"

# apache папка с конфигами
apacheConfigs='/etc/apache2/sites-available/'

# выходные данные для index.php
indexPHP='<?php phpinfo(); ?>';

# путь к файлу hosts в linux
HOSTPATH='/etc/hosts'
# путь к файлу hosts в windows
# HOSTPATH='/mnt/c/Windows/System32/drivers/etc/hosts'

#получаемые аргументы
while getopts d: option
do
	case "${option}"
		in
		d) SITEDIR=$OPTARG;;
	esac
done

# проверка, что переменная с именем сайта была введена
if [[ -z $1 ]]
	then
	echo "[ОШИБКА] - значение с именем сайта небыла получена
-----------------------------------------------------------
Пример команды для добавления сайта:
addsite sitename
    
Пример команды для добавления сайта в стороннюю директорию:
addsite sitename -d myDir
-----------------------------------------------------------"
    exit 1
fi

# получаем имя сайта
SITENAME=$1

#проверка первого символа для "/"
firstchar=${SITEDIR:0:1}
if [ $firstchar != "/" ]
	then
	SITEDIR=$(readlink -f $SITEDIR)
fi

#проверка последнего символа для  "/"
lastchar=${SITEDIR:(-1)}
if [ $lastchar != "/" ]
	then
	SITEDIR=$SITEDIR/
fi

#Переменная «site» - это счетчик цикла и имени сайта
echo adding website $SITENAME;
apacheConfig=$apacheConfigs$SITENAME.conf
websiteDir=$SITEDIR$SITENAME

#Проверяет наличия файла конфигурации
if [ -f $apacheConfig ]; then
    echo "Конфигурационный файл $apacheConfig существует! Сайт $SITENAME; небыл создан!"
    exit 1
fi

#Проверяет, пустая ли папка или нет
if [ -d $websiteDir ]; then
    if [ "$(ls -A $websiteDir)" ]; then
    echo "Файл каталога сайта $websiteDir не пуст! Сайт $SITENAME; небыл создан!"
    exit 1
    fi
fi

echo "<VirtualHost *:80>

ServerName $SITENAME.loc
DocumentRoot \"$SITEDIR$SITENAME\"

ErrorLog "'${APACHE_LOG_DIR}'"/$SITENAME/error.log
CustomLog "'${APACHE_LOG_DIR}'"/$SITENAME/access.log combined

<Directory \"$SITEDIR$SITENAME\">

# use mod_rewrite for pretty URL support
RewriteEngine on
# If a directory or a file exists, use the request directly
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
# Otherwise forward the request to index.php
RewriteRule . index.php

# allow access to the directory
Require all granted

# ...other settings...
</Directory>

</VirtualHost>
" > $apacheConfig

echo "127.0.0.1	$SITENAME.loc" >> $HOSTPATH

mkdir /var/log/apache2/$SITENAME/
echo $SITEDIR$SITENAME
mkdir -p $SITEDIR$SITENAME
echo $indexPHP > $SITEDIR$SITENAME/index.php

# включение сайта с подавлением вывода
a2ensite $SITENAME.conf > /dev/null

service apache2 restart
