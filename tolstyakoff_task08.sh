#!/bin/bash
# Практика к уроку 8 

# 1. Env keys (скрипт vars)
# Вывести имена всех экспортируемых переменных (без значений)
cat << 'EOF' > vars
#!/bin/bash
printenv | cut -d= -f1
EOF
chmod +x vars

# 2. Env файл для тестов (.env)
# Создаём файл .env с необходимыми переменными
cat << 'EOF' > .env
RUNNER=python
testdir=tests1/
USER=student1
EOF

# 2.1 + 2.2 Импорт .env и запуск runtests.sh
# Основной скрипт (например, run.sh) для импорта и запуска
cat << 'EOF' > run.sh
#!/bin/bash
set -a
source .env
set +a
./runtests.sh "$testdir"
EOF
chmod +x run.sh

# 3. Конфликтные имена (showconflicts.sh)
cat << 'EOF' > showconflicts.sh
#!/bin/bash
# Использование: ./showconflicts.sh .env
# Выводит имена переменных из файла, которые уже есть в окружении
export -p | cut -d= -f1 | cut -d' ' -f3 > /tmp/env_names.txt
grep -o '^[A-Za-z_][A-Za-z0-9_]*' "$1" | sort | uniq > /tmp/file_names.txt
comm -12 /tmp/env_names.txt /tmp/file_names.txt
rm -f /tmp/env_names.txt /tmp/file_names.txt
EOF
chmod +x showconflicts.sh

# 4. Сомнительные имена (wtf)
cat << 'EOF' > wtf
#!/bin/bash
ls --quoting-style=shell-escape | grep -E '(["'"'"'\\$`~!@#%&*|;<>? ])'
EOF
chmod +x wtf

# 5. Средняя температура по датацентру (avgsize)
cat << 'EOF' > avgsize
#!/bin/bash
find . -maxdepth 1 -type f -printf "%s\n" | awk '{sum+=$1; c++} END {if(c) print int(sum/c+0.5); else print 0}'
EOF
chmod +x avgsize