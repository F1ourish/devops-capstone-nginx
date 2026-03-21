# devops-capstone-nginx

Учебный production-like capstone проект с Nginx, Docker Compose, health checks, CI-проверками и операционной документацией.

Цель проекта — не просто запустить Nginx в контейнере, а отработать базовые практики, близкие к реальной эксплуатации: проверку конфигурации, health endpoints, наблюдаемость, runbook-подход и воспроизводимые проверки состояния сервиса.

# Current status

На текущий момент в проекте реализованы:

* контейнеризированный сервис Nginx
* запуск через Docker Compose
* основной HTTP endpoint `/`
* health endpoint `/healthz`
* проверки конфигурации Nginx и Compose
* CI workflow для базовой валидации
* внешний health check через `systemd` timer/service
* operational documentation в виде runbook и observability guide

Текущий релиз: `v0.5.0 — Observability minimum + README alignment`

# Implemented features
* кастомный образ Nginx на базе Dockerfile
* запуск и управление сервисом через Docker Compose
* публикация HTTP-сервиса на локальном порту
* отдельный health endpoint для технических проверок
* базовая валидация конфигурации через `nginx -t`
* проверка итоговой Compose-конфигурации через `docker compose config`
* CI-проверки для проекта
* внешний health check через `systemd`
* документация по запуску, проверкам и диагностике

# Project structure
* `compose.yaml` — основной Compose-файл проекта
* `docker/` — Dockerfile и конфигурация Nginx
* `scripts/` — вспомогательные скрипты проверок
* `systemd/` — unit/timer для внешнего health check
* `.github/workflows/` — CI workflow
* `docs/` — документация проекта

# Documentation
* `docs/runbook.md` — базовые операционные действия и runbook-подход
* `docs/observability.md` — быстрые проверки, expected healthy state и сценарии типичных поломок
* `docs/docker.md` — заметки по Docker-части проекта
* `docs/systemd-healthcheck.md` — внешний health check через `systemd`
* `docs/architecture.md` — краткое описание структуры и логики проекта

Если какой-то файл документации был переименован или удалён, этот список стоит синхронизировать с фактическим состоянием репозитория.

# Quick start

Сборка и запуск проекта:

`docker compose up -d --build`

Проверка состояния контейнера:

`docker compose ps`

Проверка основного endpoint:

`curl -i http://127.0.0.1:8080/`

Проверка health endpoint:

`curl -i http://127.0.0.1:8080/healthz`

Просмотр логов:

`docker compose logs nginx`

Проверка конфигурации Nginx:

`docker compose exec nginx nginx -t`

Проверка итоговой конфигурации Compose:

`docker compose config`

# Operational checks

Базовая модель проверок в проекте строится по принципу "снаружи внутрь":

1. Проверить основной HTTP endpoint `/`
2. Проверить health endpoint `/healthz`
3. Проверить состояние контейнера
4. Проверить логи контейнера
5. Проверить конфигурацию Nginx

Подробности и типовые сценарии диагностики описаны в `docs/observability.md`.

# CI

В проекте используется базовый CI workflow для проверки конфигурации и состояния сервиса.

CI-слой предназначен для того, чтобы:

* валидировать Compose-конфигурацию
* проверять конфигурацию Nginx
* запускать базовые автоматические проверки сервиса

Конкретная реализация и набор шагов находятся в `.github/workflows/`.

# Learning goals

Проект используется как учебный capstone для отработки следующих практик:

* Docker / Docker Compose
* базовая эксплуатация HTTP-сервиса
* проверка конфигурации и health checks
* CI basics
* observability minimum
* runbook-thinking и первичная диагностика
* production-like подход к небольшому сервису

# Next steps

Планируемые следующие улучшения проекта:

* дальнейшее усиление automation checks
* расширение observability-подхода
* улучшение release/documentation alignment
* постепенное усиление production-like практик

# Notes

Проект учебный, но оформляется в production-like стиле, чтобы тренировать не только запуск сервиса, но и инженерный подход к эксплуатации, проверкам и документации.
