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

2026-01-28: nginx installed, active(running), curl 200 OK

Failure drills (заготовка)
Drill 1: nginx остановлен

reproduce: 
```bash
sudo systemctl stop nginx
curl -I http://127.0.0.1
```
curl: (7) Failed to connect to 127.0.0.1 port 80 after 0 ms: Couldn't connect to server 

diagnose: 
```bash
systemctl status nginx --no-pager
```
Status: inactive

```bash
ss -lntp | grep -E ':(80)\b' || echo "No :80 listener"
```
No :80 listener

```bash
journalctl -u nginx -n 20 --no-pager
```
systemd[1]: Stopped nginx.service - A high performance web server and a reverse proxy server.

fix: 
```bash
sudo systemctl start nginx
curl -I http://127.0.0.1
```
HTTP/1.1 200 OK

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

