# Git Cheatsheet (Quick)

## Оглавление

[Быстрый старт](#0-быстрый-старт-90-секунд)

[Ежедневные команды](#1-ежедневные-команды)

[Статус и история](#10-статус-и-история)

[Добавление и коммит](#11-добавление-и-коммит)

[Ветки](#12-ветки)

[Обновить из origin](#13-обновить-из-origin)

[Push в origin](#14-push-в-origin)

[Доступ к GitHub](#15-доступ-к-github-https-vs-ssh)

[Частые "затыки"](#2-частые-затыки-самое-короткое)

[Откат/Undo](#21-откатundo-частые-сценарии)

[Конфликт при rebase/merge](#22-конфликт-при-rebasemerge-как-проходить)

[Stash](#23-stash-временно-спрятать-изменения)

[Remote](#24-remote-проверитьисправить-origin)

[Мини-памятка по формату коммитов](#3-мини-памятка-по-формату-коммитов)

## 0) Быстрый старт (90 секунд)
```bash
git status
git add -A
git commit -m "..."
git push
```

## 1) Ежедневные команды
### 1.0) Статус и история
```bash
git status
git log --oneline --decorate --graph -n 15
```

### 1.1) Добавление и коммит
```bash
git add <file>
git add -A
git commit -m "message"
```

### 1.2) Ветки
```bash
git branch
git switch -c <new-branch>
git switch <branch>
```

### 1.3) Обновить из origin
```bash
git fetch origin
git pull --rebase origin main
```

### 1.4) Push в origin
Команды: `git push, git push -u origin main`

Пояснение:

- `git push` отправляет текущую ветку в origin (если upstream уже настроен).

- `git push -u origin main` один раз “привязывает” локальную main к origin/main, чтобы потом можно было просто git push.

### 1.5) Доступ к GitHub (HTTPS vs SSH)
### Важно про пароли

GitHub НЕ принимает пароль аккаунта для git операций по HTTPS.
Нужны варианты:

* SSH ключи (рекомендовано)

* Personal Access Token (PAT) вместо пароля (если используешь HTTPS)

### Проверка, чем подключён remote

Смотри git remote -v:

* если https://github.com/... — это HTTPS (нужен токен)

* если git@github.com:... — это SSH (нужен ключ)

### Быстрый SSH-чек

Если всё ок, команда ssh -T git@github.com отвечает примерно так:
“Hi <user>! You've successfully authenticated…”

### Типовые ошибки и что они значат

1. “Password authentication is not supported”

* ты пушишь по HTTPS и вводишь пароль → так больше нельзя → переходи на SSH или PAT.

2. “Repository not found”

* чаще всего неверно указан remote URL (репо/ник/название)

* либо нет прав на репозиторий (приватный/не твой)

3. “Permission denied (publickey)”

* SSH ключ не добавлен в GitHub или не тот ключ подхватывается

### Мини-набор команд для диагностики (коротко)

* посмотреть remote

* проверить текущую ветку и upstream

* проверить, какой ключ использует ssh (при необходимости через ssh -v)

* обновить remote на SSH-адрес (git remote set-url)

## 2) Частые “затыки” (самое короткое)

* `rejected (fetch first)` → сначала `git pull --rebase`

* “не тот remote” → `git remote -v`

* “забыл add” → `git status`

* “конфликт” → правим файлы → `git add` → продолжаем (merge/rebase)

* “не авторизуется GitHub” → HTTPS паролем нельзя, нужен SSH или токен

* “Repository not found” → проверь `git remote -v (URL)` и права доступа

* “Permission denied (publickey)” → ключ не добавлен в GitHub или ssh не видит ключ

## 2.1) Откат / Undo (частые сценарии)
### Отменить изменения в файле (вернуть как было в последнем коммите)
```bash
git restore <file>
```

### Убрать файл из stage (после git add), но оставить изменения в рабочей папке
```bash
git restore --staged <file>
```

### Исправить последний коммит (добавить файлы / поменять сообщение)
```bash
git add <file>
git commit --amend
```

### Откатить коммит, но оставить изменения в рабочей папке
```bash
git reset --soft HEAD~1
```

### Откатить коммит и выкинуть изменения (осторожно)
```bash
git reset --hard HEAD~1
```

## 2.2) Конфликт при rebase/merge (как проходить) 
Если ты в rebase и получил конфликт:

1. Открываешь конфликтный файл и убираешь маркеры:

* <<<<<<<

* =======

* >>>>>>>

2. Сохраняешь файл

3. Помечаешь как решённый и продолжаешь rebase:
```bash
git add <conflicted_file>
git rebase --continue
```
Если передумал и хочешь отменить rebase:
```bash
git rebase --abort
```

## 2.3) Stash (временно спрятать изменения)

Команды: `git stash, git stash pop, git stash list`

Пояснение:

* git stash убирает незакоммиченные изменения, чтобы можно было сделать pull или переключить ветку.

* git stash pop возвращает изменения обратно.

* git stash list показывает список сохранённых “стэшей”.

## 2.4) Remote (проверить/исправить origin)

Команды: `git remote -v, git remote set-url origin git@github.com:<USER>/<REPO>.git`

Пояснение:

* `git remote -v` — проверка, куда настроен push/fetch.

* `set-url` — заменить URL origin, если привязал “не тот репо”.

## 3) Мини-памятка по формату коммитов

- один коммит = одна логическая задача

- сообщение: глагол + объект (Add / Fix / Update)
