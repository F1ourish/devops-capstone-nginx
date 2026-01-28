# Runbook: Nginx (Release 0.1)

## Быстрая проверка (2 минуты)
1) Сервис жив?
```bash
systemctl status nginx --no-pager
```
2) Порт слушается?
```bash
ss -lntp | grep -E ':(80)\b' || echo "No :80 listener"
```

3) HTTP отвечает?
```bash
curl -I http://127.0.0.1
```

4) Логи (последние 50 строк)
```bash
journalctl -u nginx -n 50 --no-pager
```

Failure drills (заготовка)
Drill 1: nginx остановлен

reproduce: ...

diagnose: ...

fix: ...

Drill 2: битый конфиг

reproduce: ...

diagnose: ...

fix: ...

Drill 3: порт 80 занят

reproduce: ...

diagnose: ...

fix: ...

Case notes

YYYY-MM-DD: ...


2026-01-28: nginx installed, active(running), curl 200 OK
