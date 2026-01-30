# Systemd healthcheck for nginx
## Что это

Сервис nginx-healthcheck.service запускает скрипт scripts/check_nginx.sh один раз и пишет результат в systemd journal.
Таймер nginx-healthcheck.timer запускает этот сервис каждые 5 минут.

## Файлы в репозитории

1. `systemd/nginx-healthcheck.service`

2. `systemd/nginx-healthcheck.timer`

3. `scripts/check_nginx.sh`

## Установка unit-файлов в systemd

1. Скопировать unit-файлы в /etc/systemd/system/
Команды: `sudo cp systemd/nginx-healthcheck.service /etc/systemd/system/` и `sudo cp systemd/nginx-healthcheck.timer /etc/systemd/system/`

2. Перечитать конфигурацию systemd
Команда: `sudo systemctl daemon-reload`

## Включение и запуск таймера

Команда: `sudo systemctl enable --now nginx-healthcheck.timer`

Проверка статуса:

* Команда: `systemctl status nginx-healthcheck.timer --no-pager`

* Команда: `systemctl list-timers --all | grep nginx-healthcheck`

## Ручной запуск проверки (без ожидания таймера)

Команда: `sudo systemctl start nginx-healthcheck.service`

## Где смотреть результат

Логи healthcheck-сервиса:
Команда: `journalctl -u nginx-healthcheck.service -n 50 --no-pager`

Важно: сейчас скрипт пишет `RESULT: OK` или `RESULT: FAIL`.
Дополнительно скрипт может печатать диагностическую информацию.

## Остановка/отключение

Остановить таймер:
Команда: `sudo systemctl stop nginx-healthcheck.timer`

Отключить автозапуск таймера:
Команда: `sudo systemctl disable nginx-healthcheck.timer`

## Удаление unit-файлов (если нужно полностью убрать)

1. Остановить и отключить таймер

2. Удалить файлы из /etc/systemd/system/

3. Сделать sudo systemctl daemon-reload

## Быстрый troubleshooting

* Таймер не запускается → проверь `systemctl status nginx-healthcheck.timer`

* Логи пустые → запусти сервис вручную и посмотри `journalctl -u nginx-healthcheck.service`

* Скрипт не исполняется → проверь права на `scripts/check_nginx.sh` и путь в `ExecStart`
