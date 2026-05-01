#!/bin/bash
# ============================================================
# Практика к уроку 12 — адаптация эталона под понятный стиль
# Все скрипты создаются в текущей директории
# ============================================================

# ========== 1.1 Мое ==========
# Сделать файлы принадлежащими только текущему пользователю с правами 700
cat << 'EOF' > мое
#!/bin/bash
sudo chown "$USER:root" "$@" && sudo chmod 700 "$@"
EOF
chmod +x мое

# ========== 1.2 Наше ==========
# Сделать файлы доступными группе пользователя (права 070)
cat << 'EOF' > наше
#!/bin/bash
sudo chown "root:$USER" "$@" && sudo chmod 070 "$@"
EOF
chmod +x наше

# ========== 2. xtouch ==========
# Обновить метку файла, добавить shebang по расширению, сделать исполняемым
cat << 'EOF' > xtouch
#!/bin/bash
[ $# -ne 1 ] && echo "Usage: xtouch file" && exit 1
ext="${1##*.}"
case "$ext" in
    py)  exec_cmd="python3" ;;
    js)  exec_cmd="node" ;;
    sh|bash) exec_cmd="bash" ;;
    *) echo "Unknown extension"; exit 1 ;;
esac
touch "$1"
chmod u+x "$1"
if ! head -n1 "$1" | grep -q "$exec_cmd"; then
    echo -e "#!/usr/bin/env $exec_cmd\n\n$(cat "$1")" > "$1"
fi
EOF
chmod +x xtouch

# ========== 3. modfilter ==========
# Вывести файлы (рекурсивно) в формате ls -l, для которых разрешено действие (read/write/execute)
cat << 'EOF' > modfilter
#!/bin/bash
action="$1"
[[ -z "$action" || ! "$action" =~ ^[rwex]$ ]] && echo "Usage: modfilter {r|w|x}" && exit 1
# Преобразуем e->x для execute (чтобы совпадало с правами)
[[ "$action" == "e" ]] && action="x"
my_groups=$(id -Gn)
find . -type f 2>/dev/null | while read f; do
    attrs=$(ls -l "$f" 2>/dev/null | tr -s ' ')
    [ -z "$attrs" ] && continue
    perm=$(echo "$attrs" | cut -d' ' -f1)
    user=$(echo "$attrs" | cut -d' ' -f3)
    group=$(echo "$attrs" | cut -d' ' -f4)
    # Проверяем права: user, group, other
    if [[ "$user" == "$USER" && "${perm:1:3}" == *"$action"* ]] \
        || [[ " $my_groups " == *" $group "* && "${perm:4:3}" == *"$action"* ]] \
        || [[ "${perm:7:3}" == *"$action"* ]]; then
        echo "$attrs"
    fi
done
EOF
chmod +x modfilter

# ========== 4. shebanger ==========
# Все .sh/.bash файлы рекурсивно сделать исполняемыми и добавить shebang
# с опцией --export (-e) DIR переместить в DIR и убрать расширение
cat << 'EOF' > shebanger
#!/bin/bash
export_dir=""
while [ $# -gt 0 ]; do
    case "$1" in
        -e|--export) shift; export_dir="$1"; shift ;;
        *) shift ;;
    esac
done
find . -type f \( -name "*.sh" -o -name "*.bash" \) 2>/dev/null | while read f; do
    chmod u+x "$f"
    if ! head -n1 "$f" | grep -q "bash"; then
        sed -i '1i #!/usr/bin/env bash\n' "$f"
    fi
    if [ -n "$export_dir" ]; then
        base=$(basename "$f")
        mv "$f" "$export_dir/${base%.*}"
    fi
done
EOF
chmod +x shebanger

# ========== 5. У самурая есть только $PATH ==========
# Переопределение cd: при переходе текущая директория добавляется в PATH
# Добавьте следующий код в ваш ~/.bashrc
cat << 'EOF'
# Добавьте в ~/.bashrc:
cd() {
    builtin cd "$@" || return
    BASEPATH=${BASEPATH:-$PATH}
    PATH="$BASEPATH:$PWD"
}
EOF
echo "Совет: для активации переопределения cd добавьте указанную функцию в ~/.bashrc"