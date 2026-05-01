#!/bin/bash
# Практика к уроку 9 — компактные решения

# 1. Решатель кроссвордов (wordhint)
cat << 'EOF' > wordhint
#!/bin/bash
grep -x "$1" /usr/share/dict/words
EOF
chmod +x wordhint

# 2. Электронные почты (команда для поиска в emails.txt)
# Формат: имя(6+ лат/цифр)@домен(3-12 лат).зона(3-6 лат)
grep -E '^[a-zA-Z0-9]{6,}@[a-z]{3,12}\.[a-z]{3,6}$' emails.txt

# 3. Номера ТС РФ (извлечь из plates.txt)
# Формат: буква, 3 цифры, 2 буквы, вертикальная черта, 2 цифры
grep -oE '[АВЕКМНОРСТУХ]\d{3}[АВЕКМНОРСТУХ]{2}\|\d{2}' plates.txt

# 4. Русификация интернетов (замена доменной зоны на ru через stdin)
sed -E 's|://[^/]+\.([a-z]{2,})(/|$)|://\1.ru\2|g; s|\.([a-z]{2,})\.ru|.\1.ru|g'

# 5. Исправление очепятки (fiboncaci -> fibonacci, не в комментариях)
sed -i '/^[[:space:]]*#/! s/fiboncaci/fibonacci/g' fib.py fib_test.py

# 6. Логирование конвейера (teepipes)
cat << 'EOF' > teepipes
#!/bin/bash
# Использование: teepipes 'cmd1 | cmd2 | cmd3'
log="teepipes.log"
> "$log"
IFS='|' read -ra cmds <<< "$1"
for ((i=0; i<${#cmds[@]}; i++)); do
    if [ $i -eq 0 ]; then
        eval "${cmds[$i]}" >> "$log" 2>&1
    else
        eval "tail -n +1 \"$log\" | ${cmds[$i]}" >> "$log" 2>&1
    fi
done
cat "$log"
EOF
chmod +x teepipes

# 7. Занятые порты (busyports)
cat << 'EOF' > busyports
#!/bin/bash
find . -type f ! -path '*/.venv/*' ! -path '*/__pycache__/*' ! -name '*.csv' \
    -exec grep -HnE '\bPORT\s*=\s*[0-9]+' {} \; \
    -exec grep -HnE '\b[A-Z_]*PORT\s*=\s*[0-9]+' {} \;
EOF
chmod +x busyports

# 8. Последние изменения (recentpys)
cat << 'EOF' > recentpys
#!/bin/bash
find . -name '*.py' -type f -mtime -30 -printf '%T@ %p\n' | sort -rn | cut -d' ' -f2- | xargs -I {} stat -c "%y %n" {}
EOF
chmod +x recentpys

# 9. Вынос здоровяков (mvbigfiles)
cat << 'EOF' > mvbigfiles
#!/bin/bash
mkdir -p archive
find . -maxdepth 1 -type f \( -name '*.bak' -o -name 'old_*' \) -size +4M -exec mv {} archive/ \;
EOF
chmod +x mvbigfiles