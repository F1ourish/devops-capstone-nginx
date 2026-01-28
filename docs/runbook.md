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
Active: inactive (dead)
```bash
ss -lntp | grep -E ':(80)\b' || echo "No :80 listener"
```
No :80 listener

```bash
journalctl -u nginx -n 20 --no-pager
```
systemd[1]: Stopped nginx.service - A high performance web server and a reverse proxy server.

root cause:
nginx остановлен (systemd unit inactive), порт 80 не слушается, поэтому curl не может подключиться.

fix: 
```bash
sudo systemctl start nginx
curl -I http://127.0.0.1
```
HTTP/1.1 200 OK

Drill 2: битый конфиг

reproduce:
Бэкап файла:
```bash
sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.bak
```
Добавляем заведомо неверную строку в конец:
```bash
echo 'BROKEN' | sudo tee -a /etc/nginx/sites-enabled/default >/dev/null
```
Проверяем конфигурацию:
```bash
sudo nginx -t
```
Пробуем рестарт (ожидаем, что он не поднимется нормально):
```bash
sudo systemctl restart nginx
```

diagnose: 
Проверка конфига:
```bash
sudo nginx -t
```
2026/01/28 13:53:35 [emerg] 21289#21289: unexpected end of file, expecting ";" or "}" in /etc/nginx/sites-enabled/default:97
nginx: configuration file /etc/nginx/nginx.conf test failed

Статус сервиса:
```bash
systemctl status nginx --no-pager
```
Active: failed (Result: exit-code)

Логи:
```bash
journalctl -u nginx -n 10 --no-pager
```
nginx[21261]: 2026/01/28 13:53:01 [emerg] 21261#21261: unexpected end of file, expecting ";" or "}" in /etc/nginx/sites-enabled/default:97
nginx[21261]: nginx: configuration file /etc/nginx/nginx.conf test failed
systemd[1]: nginx.service: Control process exited, code=exited, status=1/FAILURE
systemd[1]: nginx.service: Failed with result 'exit-code'.
systemd[1]: Failed to start nginx.service - A high performance web server and a reverse proxy server.

Порт 80:
```bash
ss -lntp | grep -E ':(80)\b' || echo "No :80 listener"
```
No :80 listener

root cause:
после изменения файла конфигурации сайтa nginx конфиг не проходит nginx -t, поэтому сервис не стартует/не слушает порт 80.

fix: 
```bash
sudo mv /etc/nginx/sites-enabled/default.bak /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
curl -I http://127.0.0.1
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

curl 200 OK

Drill 3: порт 80 занят

reproduce: ...

diagnose: ...

fix: ...

Case notes

YYYY-MM-DD: ...

