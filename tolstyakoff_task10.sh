#!/bin/bash
# Практика к уроку 10 — компактные решения

# 1. Консервация банки (conservation_toggle)
cat << 'EOF' > conservation_toggle
#!/bin/bash
# Путь к файлу консервации для Lenovo IdeaPad (измените под своё устройство)
CONSERVATION_PATH="/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
if [ -f "$CONSERVATION_PATH" ]; then
    current=$(cat "$CONSERVATION_PATH")
    if [ "$current" -eq 1 ]; then
        echo 0 | sudo tee "$CONSERVATION_PATH" > /dev/null
        echo "battery conservation mode DISABLED"
    else
        echo 1 | sudo tee "$CONSERVATION_PATH" > /dev/null
        echo "battery conservation mode ENABLED"
    fi
else
    echo "Conservation mode file not found"
    exit 1
fi
EOF
chmod +x conservation_toggle

# 2. Гугл хром v0.0.0.0.0.1 (сортировка файлов по количеству вхождений слова)
cat << 'EOF' > countword
#!/bin/bash
# Использование: ./countword <слово или regexp>
pattern="$1"
find . -type f \
    -not -path '*/.venv/*' \
    -not -path '*/__pycache__/*' \
    -not -path '*/.git/*' \
    -exec grep -ow "$pattern" {} \; | sort | uniq -c | sort -rn
EOF
chmod +x countword

# 3. Таблицы как они есть (showtables — извлечь CREATE TABLE из дампа SQL)
cat << 'EOF' > showtables
#!/bin/bash
# Использование: ./showtables dump.sql
sed -n '/^CREATE TABLE /,/^$/p' "$1" | sed '/^$/d'
EOF
chmod +x showtables

# 4. Скрипт для Docker томов (containervolumes)
cat << 'EOF' > containervolumes
#!/bin/bash
# Требует установленных docker и jq
for container in $(docker ps -aq); do
    name=$(docker inspect -f '{{.Name}}' "$container" | sed 's/\///')
    echo "[$name]"
    docker inspect -f '{{json .Mounts}}' "$container" | jq -r '.[] | select(.Type=="volume") | .Source + " " + .Name' 2>/dev/null | while read source name; do
        size=$(sudo du -sh "$source" 2>/dev/null | cut -f1)
        echo "$name $size"
    done
    echo
done
EOF
chmod +x containervolumes