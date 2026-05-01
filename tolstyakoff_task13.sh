# ============================================================
# Практика к уроку 13 — адаптация эталона под понятный стиль
# ============================================================

# 1. pgrep2 — аналог pgrep -l (PID + имя)
cat << 'EOF' > pgrep2
#!/bin/bash
ps -e | tr -s ' ' | cut -d ' ' -f 2,5 | grep "$@"
EOF
chmod +x pgrep2

# 2. runlimit — ограничение времени выполнения команды
cat << 'EOF' > runlimit
#!/bin/bash
seconds="$1"
shift
"$@" &
sleep "$seconds"
kill %1
echo "Execution finished"
EOF
chmod +x runlimit

# 3. spamer — многократный запуск с задержкой
cat << 'EOF' > spamer
#!/bin/bash
instances=1
delay=1
while [[ $1 ]]; do
    case $1 in
        -i|--instances) shift; instances="$1" ;;
        -d|--delay)     shift; delay="$1" ;;
        *) break ;;
    esac
    shift
done
shift $((OPTIND-1))
for ((i=0; i<instances; i++)); do
    "$@" &
    sleep "$delay"
done
wait
EOF
chmod +x spamer

# 4. temptouch — создать временный файл, удалить через N секунд
cat << 'EOF' > temptouch
#!/bin/bash
touch "$1"
(sleep "$2"; rm -f "$1") &
EOF
chmod +x temptouch

# 5. killboss — убить самый прожорливый процесс (по CPU или MEM)
cat << 'EOF' > killboss
#!/bin/bash
if [[ " $@ " =~ ( --cpu ) ]]; then
    sort_col=2
elif [[ " $@ " =~ ( --mem ) ]]; then
    sort_col=3
else
    echo "Please specify sorting argument: --cpu or --mem"
    exit 1
fi
entry=$(top -b -n 1 | tr -s ' ' | tail -n +8 | cut -d ' ' -f 2,10,11,13 | sort -rnk $sort_col | head -n 1 | cut -d ' ' -f 1,4)
echo "$entry"
kill $(echo "$entry" | cut -d ' ' -f 1)
EOF
chmod +x killboss