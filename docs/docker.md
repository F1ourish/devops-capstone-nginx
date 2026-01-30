## 1. Сервис Nginx теперь запущен в Docker Compose на `127.0.0.1:8080`

## 2. Для проверки можно воспользоваться командой:
```bash
curl -I http://127.0.0.1:8080
```

## 3. Для просмотра логов:
```bash
docker compose logs --tail 20 nginx
```

## 4. Таймзона настроена на Europe/Moscow
для проверки можно использовать команду:
```bash
docker compose exec nginx date
```
