# AddSiter - скрипт добавления нового сайта на Apache сервер
Скрипт создает сайт и файлы конфигурации для него, затем включает сайт и перезапускает Apache сервер. Скрипт позволяет очень быстро настроить сайт. Запускать необходимо как `root` или использовать команду `sudo`.

## Что делает скрипт
1. Проверяет наличие `root` привилегий и необходимых аргументов, затем происходит создание сайтов
2. Проверяет наличие конфигурации в директории `/etc/apache2/sites-available/` *(данный параметр изменяется в начале файла скрипта)* а также, если каталог текущего веб-сайта пуст или нет. 
    - Если директория не существует, она будет создана; 
    - Если директория не пустая или файл конфигурации Apache существует, создание текущего веб-сайта будет пропущено.
3. Создается директория сайта, используя имя сайта. В директории сайта скрипт создает `index.php` с функцией `phpinfo()` *(можно изменить в начале скрипта)*.
4. Добавляет соответствующий конфиг в Apache *(по умолчанию к имени сайта добавляется `.loc`, например `namesite.loc`, именно по такому адресу затем будут доступны сайты)*.
5. После генерации всех конфигов скрипт перезапускает Apache.

## Установка
1. Скачайте скрипт с Github или клонируйте его:
```bash
git clone https://github.com/alexsoin/addsiter.git
```

2. Можно начать использовать его из папки, но было бы полезно переместить его куда-нибудь:
```bash
mv addsiter/addsiter.sh ~/bashscripts/addsiter.sh
```
Убедитесь, что скрипт можно выполнить:
```bash
chmod +x ~/bashscripts/addsiter.sh
```

3. Создайте псевдоним для скрипта. Например `addsite`:
```bash
echo 'alias addsite="~/bashscripts/addsiter.sh"' >> ~/.bashrc
```

ИЛИ создаем символическую ссылку на файл:
```bash
sudo ln -s /home/user/bashscripts/addsiter.sh /usr/bin/addsite
```

## Использование
**Не обязательные аргументы:**<br />
**-d** root директория для сайта. По умолчанию будет использоваться `/var/www/html/`<br />
<br />
**Примеры:**
```bash
./addsiter testsite 
```
↑ эта команда добавит сайт `testsite`, который затем будет доступен по ссылке `testsite.loc`

```bash
./addsiter testsite -d mydir
```
↑ эта команда создаст каталог ./mydir и создаст сайт `testsite` в текущем каталоге: