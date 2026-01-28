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
### Drill 1: nginx остановлен

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

### Drill 2: битый конфиг

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

### Drill 3: порт 80 занят

reproduce: 
```bash
sudo apt -y install apache2
sudo systemctl enable --now apache2
```

diagnose: 
```bash
systemctl status apache2 --no-pager
journalctl -u apache2 -n 20 --no-pager
```
Ключевой симптом в логах: Address already in use ... could not bind to ...:80

Проверяем, кто слушает 80 
```bash
sudo ss -lntp | grep -E ':(80)\b' || echo "No :80 listener"
```
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=23808,fd=5),("nginx",pid=23807,fd=5),("nginx",pid=23806,fd=5),("nginx",pid=23805,fd=5),("nginx",pid=23804,fd=5),("nginx",pid=23803,fd=5),("nginx",pid=23802,fd=5),("nginx",pid=23801,fd=5),("nginx",pid=23800,fd=5))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=23808,fd=6),("nginx",pid=23807,fd=6),("nginx",pid=23806,fd=6),("nginx",pid=23805,fd=6),("nginx",pid=23804,fd=6),("nginx",pid=23803,fd=6),("nginx",pid=23802,fd=6),("nginx",pid=23801,fd=6),("nginx",pid=23800,fd=6))

root cause:
порт 80 уже занят nginx (LISTEN на 0.0.0.0:80 и/или [::]:80), поэтому apache2 не может забиндиться и падает с ошибкой Address already in use (98)

fix:
```bash
sudo systemctl stop nginx
sudo systemctl start apache2
curl -I http://127.0.0.1

sudo systemctl stop apache2
sudo systemctl disable apache2
sudo systemctl start nginx
curl -I http://127.0.0.1
```
curl 200 OK

### Drill 4: альтернативное решение конфликта портов — apache2 на 8081 (nginx остаётся на 80)

reproduce:
```bash
sudo systemctl enable --now apache2
```
# ожидаемо: упадёт из-за занятого :80

diagnose:
Ключевой симптом в логах apache2: Address already in use ... could not bind to ...:80
Проверяем, кто занял :80:
```bash
sudo ss -tlnp | grep -E ':(80)\b'
```

root cause:
порт 80 занят nginx, поэтому apache2 не может забиндиться на :80 и не стартует.

fix:
Меняем порт apache2 на 8081:
```bash
sudo cp /etc/apache2/ports.conf /etc/apache2/ports.conf.bak
sudo vim /etc/apache2/ports.conf
# Listen 80 -> Listen 8081
```
Меняем VirtualHost на 8081:
```bash
sudo vim /etc/apache2/sites-enabled/000-default.conf
# <VirtualHost *:80> -> <VirtualHost *:8081>
```
Перезапускаем apache2 и проверяем:
```bash
sudo systemctl restart apache2
systemctl status apache2 --no-pager
curl -I http://127.0.0.1:8081
```
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=23808,fd=5),("nginx",pid=23807,fd=5),("nginx",pid=23806,fd=5),("nginx",pid=23805,fd=5),("nginx",pid=23804,fd=5),("nginx",pid=23803,fd=5),("nginx",pid=23802,fd=5),("nginx",pid=23801,fd=5),("nginx",pid=23800,fd=5))
LISTEN 0      511                *:8081            *:*    users:(("apache2",pid=24242,fd=4),("apache2",pid=24241,fd=4),("apache2",pid=24239,fd=4))                                                                                                                                                
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=23808,fd=6),("nginx",pid=23807,fd=6),("nginx",pid=23806,fd=6),("nginx",pid=23805,fd=6),("nginx",pid=23804,fd=6),("nginx",pid=23803,fd=6),("nginx",pid=23802,fd=6),("nginx",pid=23801,fd=6),("nginx",pid=23800,fd=6))

Убеждаемся, что nginx всё ещё на 80:
```bash
curl -I http://127.0.0.1
sudo ss -lntp | grep -E ':(80|8081)\b'
```

Case notes

2026-01-28: nginx installed, active(running), curl 200 OK
