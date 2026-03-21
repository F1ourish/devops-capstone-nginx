# Architecture

## Назначение

Этот документ кратко описывает текущую архитектуру проекта, основные компоненты, поток запросов и базовые сигналы состояния сервиса.

## Компоненты

* Ubuntu 24.04 VM
* Docker Engine
* Docker Compose
* контейнер `nginx`
* конфигурация Nginx из каталога `docker/nginx/conf.d`
* `compose.yaml` как основной файл запуска сервиса
* CI workflow для базовой валидации проекта
* внешний health check через `systemd` service/timer

## Поток запросов

`Client -> VM:8080 -> Docker Compose -> nginx container -> Nginx endpoint`

Для базовой проверки сервиса используются два endpoint:

* `/` — основной HTTP endpoint
* `/healthz` — технический health endpoint

## Конфигурационный слой

Основные конфигурационные элементы проекта:

* `compose.yaml` — описание сервиса и параметров запуска
* `docker/Dockerfile.nginx` — сборка кастомного образа Nginx
* `docker/nginx/conf.d/` — конфигурация endpoint и HTTP-поведения
* `scripts/` — вспомогательные скрипты проверок
* `systemd/` — внешний health check через `service` и `timer`
* `.github/workflows/` — CI-проверки проекта

## Проверки и observability

Базовые сигналы состояния сервиса в проекте:

* HTTP-проверка основного endpoint `/`
* HTTP-проверка health endpoint `/healthz`
* проверка состояния контейнера через `docker compose ps`
* просмотр логов контейнера через `docker compose logs nginx`
* проверка конфигурации Nginx через `nginx -t`
* внешний health check через `systemd`

Подробности по диагностике и quick checks описаны в docs/observability.md.

## CI и валидация

В проекте используется базовый CI workflow для автоматических проверок.

Он покрывает следующие задачи:

* валидация Compose-конфигурации
* проверка конфигурации Nginx
* базовые проверки доступности и health state сервиса

## Логика проекта

Проект построен как небольшой production-like сервис, в котором акцент сделан не только на запуск Nginx, но и на:

* воспроизводимый запуск через Compose
* health checks
* базовую наблюдаемость
* CI-проверки
* operational documentation
* runbook-thinking

## Текущие ограничения

На текущем этапе проект остаётся учебным и intentionally small-scale.

Пока в нём нет:

* полноценного reverse proxy layer перед сервисом
* отдельной системы метрик
* централизованного логирования
* полноценного CD/deploy automation

## Следующие шаги

Следующие улучшения проекта могут включать:

* дальнейшее усиление automation checks
* расширение observability-подхода
* улучшение документации и release alignment
* постепенное усиление production-like практик
