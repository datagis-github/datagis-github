
# Dataset Service

## Описание

Этот сервис подключается к базам данных, таким как PostgreSQL и Redis. Использует `docker compose` для сборки и запуска контейнера.

## Инструкция по сборке Docker образа

1. Убедитесь, что у вас установлены Docker и Docker Compose.

2. Перейдите в директорию, где находится `docker-compose.yml` файл.
`bash` `cd /путь/к/сервису/`
3. Соберите Docker образы, используя `docker compose`:
`bash` `docker compose build`
 ## Инструкция по смене конфигурации

Чтобы изменить конфигурацию для подключения к базам данных, следуйте этим шагам:

1. Откройте файл `envs.lua` в вашем любимом текстовом редакторе:
`bash` `nano /путь/к/сервису/envs.lua`
2. Найдите и задайте подключения к БД в блоки конфигурации для PostgreSQL и Redis следующим образом:

 - **Блок конфигурации для PostgreSQL connections:**
      

        ...
        POSTGRES_CONNECTIONS = {
            name = "БД connections",
            str = {
                host = "127.0.0.1",
                port = "5432",
                database = "connections-db",
                user = "user-db",
                password = "P@ssw0rd-DB"
            }
        },
        ...


 - **Блок конфигурации для PostgreSQL dsconfig:**
      

        ...
        CONFIG_DSCONFIG = {
            name = "БД dsconfig",
            str = {
                host = "127.0.0.1",
                port = "5432",
                database = "config-db",
                user = "user-db",
                password = "P@ssw0rd-DB"
            }
        },
        ...

 - **Блок конфигурации для Redis:**


        ...
        REDIS = {
            name = "Redis",
            str = {
                host = "127.0.0.1",
                port = 6379,
                pass = "P@ssw0rd-DB"
            }
        },
        ...

3. Сохраните изменения и закройте файл.

## Инструкция по запуску Docker контейнера

1. Перейдите в директорию с сервисом, где находится `docker-compose.yml` файл:
  ``` bash ``` ```cd /путь/к/сервису```
2. Запустите Docker контейнер:
  ```bash``` ```docker-compose up  -d``` 

## Просмотр логов

Для просмотра логов, используя команду `tail -f`, выполните следующие шаги:

1. Перейдите в директорию, где находится сервис.
`bash` `cd /путь/к/сервису/logs`
2. Введите команду `bash` `tail -f error.log`, указав путь к файлу логов. 
Команда позволит в реальном времени наблюдать за выводом логов сервиса.



:wq


:wq
