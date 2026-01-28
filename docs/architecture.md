# Architecture (Release 0.1)

## Компоненты
- Ubuntu 24.04 VM
- nginx (systemd unit)

## Поток запросов
Client -> VM:80 -> nginx -> default page

## Наблюдаемость (пока)
- systemd status
- journalctl
- ручные проверки curl/ss

## План следующих релизов
- Docker/compose
- CI/CD
- мониторинг/алерты

