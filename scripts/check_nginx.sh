#!/usr/bin/env bash

set -u
set -o pipefail

SVC="nginx"
URL="http://127.0.0.1"
OK=1

echo "== $(date) =="
echo "(1) systemd status ($SVC)"
if systemctl status "$SVC" --no-pager | grep -E 'Active: active'; then
	echo "nginx is active"
else
	echo "nginx is NOT active"
	OK=0
fi

echo
echo "(2) listener on :80"
if ss -lntp | grep -E ':(80)\b'; then 
	echo "Port 80: LISTEN"
else
	echo "No :80 listener"
	OK=0
fi

echo
echo "(3) HTTP check ($URL)"
curl_code=$(curl -sS -o /dev/null -w "%{http_code}" "$URL")
if [[ "$curl_code" == "200" ]]; then
	echo "curl ok"
else
	echo "curl failed"
	OK=0
fi

echo
echo "(4) last logs ($SVC)"
journalctl -u "$SVC" -n 20 --no-pager || true

echo
if [[ "$OK" == "1" ]]; then
	echo "RESULT: OK"
	exit 0
else
	echo "RESULT: FAIL"
	exit 1
fi
