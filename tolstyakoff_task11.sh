#!/bin/bash
# ========== 1. swap ==========
# Меняет местами два файла (атомарно, через mv -T)
cat << 'EOF' > swap
#!/bin/bash
[ $# -ne 2 ] && echo "Usage: swap file1 file2" && exit 1
dest1="$(dirname "$2")/$(basename "$1")"
dest2="$(dirname "$1")/$(basename "$2")"
mv -T "$1" "$dest1".moved
mv -T "$2" "$dest2".moved
mv -T "$dest1".moved "$dest1"
mv -T "$dest2".moved "$dest2"
EOF
chmod +x swap

# ========== 2.1 + 2.2 RGB cat (с поддержкой --custom) ==========
# Основной скрипт rgbcat (использует функцию из my_format_function.sh)
cat << 'EOF' > rgbcat
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Функция раскраски: читает stdin, заменяет ключевые слова на цветные
colorize() {
    local color="$1"
    shift
    local words="$*"
    local content="$(cat)"
    for w in $words; do
        # экранируем спецсимволы в слове (для sed)
        w_escaped=$(printf '%s\n' "$w" | sed 's/[][\.*^$]/\\&/g')
        content=$(echo "$content" | sed "s/$w_escaped/${color}&${NC}/g")
    done
    echo "$content"
}

# Парсинг аргументов
files=()
red_words=()
green_words=()
blue_words=()
custom_words=()

while [ $# -gt 0 ]; do
    case "$1" in
        -r|--red)   shift; red_words+=("$1")   ;;
        -g|--green) shift; green_words+=("$1") ;;
        -b|--blue)  shift; blue_words+=("$1")  ;;
        -c|--custom) shift; custom_words+=("$1");;
        *) files+=("$1") ;;
    esac
    shift
done

# Конвейер: cat файлы -> раскраска для каждого цвета
{
    if [ ${#files[@]} -gt 0 ]; then
        cat "${files[@]}"
    else
        cat
    fi
} | colorize "$RED" "${red_words[@]}" \
  | colorize "$GREEN" "${green_words[@]}" \
  | colorize "$BLUE" "${blue_words[@]}" \
  | (
    if [ ${#custom_words[@]} -gt 0 ] && declare -f custom_format >/dev/null; then
        custom_format "${custom_words[@]}"
    else
        cat
    fi
)
EOF
chmod +x rgbcat

# Внешний файл с функцией custom_format (my_format_function.sh)
cat << 'EOF' > my_format_function.sh
#!/bin/bash
custom_format() {
    local words="$*"
    local content="$(cat)"
    BOLD=$(tput bold)
    NORMAL=$(tput sgr0)
    for w in $words; do
        w_escaped=$(printf '%s\n' "$w" | sed 's/[][\.*^$]/\\&/g')
        content=$(echo "$content" | sed "s/$w_escaped/${BOLD}${w^^}${NORMAL}/g")
    done
    echo "$content"
}
export -f custom_format
EOF
chmod +x my_format_function.sh

# ========== 3. restore.sh (упрощённая версия эталона) ==========
# Использует файл backup-dirs (содержит массивы conffiles, homefiles)
cat << 'EOF' > restore.sh
#!/bin/bash
set -e

DEFAULT_BACKUP_FOLDER="$HOME/backup"
source ./backup-dirs 2>/dev/null || true
backup_folder="${backup_folder:-$DEFAULT_BACKUP_FOLDER}"
need_unarchive=false
need_git_pull=false
extra_root=""
extra_files=()

show_help() {
    cat << HELP
Usage: restore.sh [OPTIONS]
  -h, --help          show this help
  -i, --input DIR     backup source directory (default: $DEFAULT_BACKUP_FOLDER)
  -z, --targz         uncompress .tgz/.tar.gz before restore
  -g, --git-pull      run git pull in backup folder
  -e, --extra DIR     restore extra files (read from stdin, one file per line)
HELP
}

# Восстановление основных файлов
do_restore() {
    for f in "${conffiles[@]}"; do
        rm -rf "$HOME/.config/$(basename "$f")"
        mkdir -p "$HOME/.config/$(dirname "$f")"
        cp -r "$backup_folder/$(basename "$f")" "$HOME/.config/$(dirname "$f")"
    done
    for f in "${homefiles[@]}"; do
        rm -rf "$HOME/$(basename "$f")"
        mkdir -p "$HOME/$(dirname "$f")"
        cp -r "$backup_folder/$(basename "$f")" "$HOME/$(dirname "$f")"
    done
}

# Распаковка архива
uncompress() {
    $need_unarchive || return
    cd "$backup_folder"
    for arch in "$(basename "$backup_folder").tgz" "$(basename "$backup_folder").tar.gz"; do
        if [ -f "$arch" ]; then
            tar -xzf "$arch"
            rm -f "$arch"
            break
        fi
    done
    cd - >/dev/null
}

# Git pull
git_pull() {
    $need_git_pull || return
    (cd "$backup_folder" && git pull) 2>/dev/null || true
}

# Восстановление extra файлов (читает stdin)
read_extra_files() {
    while IFS= read -r line; do
        [ -n "$line" ] && echo "$line"
    done
}

extra_restore() {
    [ -z "$extra_root" ] && return
    local files=("$@")
    for f in "${files[@]}"; do
        rm -rf "$extra_root/$(basename "$f")"
        mkdir -p "$extra_root/$(dirname "$f")"
        cp -r "$backup_folder/$(basename "$f")" "$extra_root/$(dirname "$f")"
    done
}

# Парсинг аргументов
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) show_help; exit 0;;
        -i|--input) shift; backup_folder="$1";;
        -z|--targz) need_unarchive=true;;
        -g|--git-pull) need_git_pull=true;;
        -e|--extra) shift; extra_root="$1";
            extra_files=($(read_extra_files));;
        *) echo "Unknown option $1"; exit 1;;
    esac
    shift
done

uncompress
git_pull
do_restore
extra_restore "${extra_files[@]}"
echo "Restore completed."
EOF
chmod +x restore.sh

# ========== 4.1 + 4.2 Lit (минималистичный git) ==========
# Скрипт lit с поддержкой .litignore
cat << 'EOF' > lit
#!/bin/bash
LITDIR=".lit"
IGNORE_FILE=".litignore"
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Проверка числа аргументов
check_argnum() {
    if [ $1 -lt $2 ]; then
        echo "Error: need at least $2 argument(s)"
        exit 1
    fi
}

# exhibit — показать список изменений
exhibit() {
    if [ ! -d "$LITDIR" ]; then
        echo "No changes yet."
        return
    fi
    # сортировка по времени изменения файла (новые сверху)
    for f in "$LITDIR"/*.tgz; do
        [ -f "$f" ] || continue
        name=$(basename "$f" .tgz)
        date=$(date -r "$f" "+%b %d %H:%M")
        echo "$date | $name"
    done | sort -k1,3M -k2n -r | while read line; do
        # выделить жирным название после "| "
        echo -e "$(echo "$line" | sed -E 's/(.*\| )(.*)/\1'${BOLD}'\2'${NORMAL}'/')"
    done
}

# Построение regexp для игнорирования из .litignore
build_ignore_pattern() {
    local pattern=""
    if [ -f "$IGNORE_FILE" ]; then
        pattern=$(cat "$IGNORE_FILE" | grep -v '^#' | grep -v '^$' | tr '\n' '|' | sed 's/|$//')
    fi
    # всегда игнорируем .lit
    if [ -n "$pattern" ]; then
        pattern="($pattern|$LITDIR)"
    else
        pattern="$LITDIR"
    fi
    echo "$pattern"
}

# feed — сохранить текущее состояние
feed() {
    local name="$1"
    mkdir -p "$LITDIR"
    local ignore_pat="$(build_ignore_pattern)"
    # собираем файлы, исключая игнорируемые
    find . -type f | grep -vE "$ignore_pat" | xargs tar -czf "$LITDIR/$name.tgz" 2>/dev/null
    echo "Saved: $name"
}

# need — восстановить состояние
need() {
    local name="$1"
    local archive="$LITDIR/$name.tgz"
    if [ ! -f "$archive" ]; then
        echo "Error: change '$name' not found"
        exit 1
    fi
    tar -xzf "$archive" --overwrite
    echo "Restored: $name"
}

# Поддержка сокращений
cmd="$1"
case "$cmd" in
    f|fe|fee|feed)
        check_argnum $# 2
        feed "$2"
        ;;
    n|ne|nee|need)
        check_argnum $# 2
        need "$2"
        ;;
    e|ex|exh|exhi|exhib|exhibit)
        exhibit
        ;;
    *)
        echo "Usage: lit {feed|need|exhibit} [name]"
        exit 1
        ;;
esac
EOF
chmod +x lit

# ========== 5. mytree (рекурсивный вывод дерева, как tree) ==========
cat << 'EOF' > mytree
#!/bin/bash
# Рекурсивный вывод дерева директорий (игнорирует скрытые файлы)

build_tree() {
    local prefix="$1"
    local dir="$2"
    local items=("$dir"/*)   # без скрытых файлов (как tree)
    local count=${#items[@]}
    for i in "${!items[@]}"; do
        local item="${items[$i]}"
        if [ -d "$item" ]; then
            if [ $i -eq $((count-1)) ]; then
                echo "${prefix}└── $(basename "$item")"
                build_tree "${prefix}    " "$item"
            else
                echo "${prefix}├── $(basename "$item")"
                build_tree "${prefix}│   " "$item"
            fi
        else
            if [ $i -eq $((count-1)) ]; then
                echo "${prefix}└── $(basename "$item")"
            else
                echo "${prefix}├── $(basename "$item")"
            fi
        fi
    done
}

echo "."
build_tree "" "."
EOF
chmod +x mytree

# ============================================================
# Конец :))
# ============================================================