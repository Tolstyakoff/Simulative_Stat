#!/bin/bash
# ============================================================
# Практика к уроку 14 
# ============================================================

# 1. dfalarm — мониторинг диска (каждые 5 минут, при >90% выводит предупреждение)
cat << 'EOF' > dfalarm
#!/bin/bash
disk="${1:-/}"
while true; do
    usage=$(df "$disk" | tail -1 | tr -s ' ' | cut -d' ' -f5 | tr -d '%')
    if [ "$usage" -gt 90 ]; then
        echo "WARNING: Disk $disk usage is ${usage}%"
    fi
    sleep 300
done
EOF
chmod +x dfalarm

# 2. wgetalarm — мониторинг времени на сайте (ищет "00")
cat << 'EOF' > wgetalarm
#!/bin/bash
wget -qO- https://true-time.com/moscow/ | grep -q "00" && echo "Alarm!"
EOF
chmod +x wgetalarm

# Пример запуска wgetalarm через spamer (5 раз, задержка 1 сек):
# spamer --instances 5 --delay 1 ./wgetalarm

# 3. somecurls — работа с API jsonplaceholder
cat << 'EOF' > somecurls
#!/bin/bash
echo "=== Post #99 ==="
curl -s https://jsonplaceholder.typicode.com/posts/99
echo -e "\n=== Creating posts 1,2,3 ==="
for i in 1 2 3; do
    curl -s -X POST https://jsonplaceholder.typicode.com/posts \
        -H "Content-Type: application/json" \
        -d "{\"title\":\"post $i\",\"body\":\"content\",\"userId\":1}"
    echo
done
EOF
chmod +x somecurls

