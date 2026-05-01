#!/bin/bash
# ============================================================
# Практика к уроку 6 – средний вариант (минимальные проверки)
# Каждый пункт – отдельный исполняемый скрипт
# ============================================================

# 1. Начало и конец (headtail.sh)
cat << 'EOF' > headtail.sh
#!/bin/bash
[ $# -eq 0 ] && exit 1
[ -f "$1" ] || exit 1
echo -e "HEAD:\n$(head -n 5 "$1")\n================\nTAIL:\n$(tail -n 5 "$1")"
EOF
chmod +x headtail.sh

# 2. Не начало и не конец (exclude.sh)
cat << 'EOF' > exclude.sh
#!/bin/bash
[ $# -eq 0 ] && exit 1
[ -f "$1" ] || exit 1
head -n -5 "$1" | tail -n +6
EOF
chmod +x exclude.sh

# 3. Нужно больше less (showlines.sh)
cat << 'EOF' > showlines.sh
#!/bin/bash
find . -type f -exec wc -l {} + | less
EOF
chmod +x showlines.sh

# 4. Fast diff (fastdiff.sh)
cat << 'EOF' > fastdiff.sh
#!/bin/bash
[ $# -eq 0 ] && exit 1
files=( $(ls *"$1"* 2>/dev/null) )
[ ${#files[@]} -ge 2 ] || exit 1
diff "${files[0]}" "${files[1]}"
EOF
chmod +x fastdiff.sh

# 5. Зайти в nano (опционально) – factorial на Python, редактирование в nano
cat << 'EOF' > factorial_nano.sh
#!/bin/bash
cat > /tmp/fact.py << 'PY'
def factorial(n):
    return 1 if n < 2 else n * factorial(n-1)
print(factorial(int(input("Введите число: "))))
PY
nano /tmp/fact.py
python3 /tmp/fact.py
EOF
chmod +x factorial_nano.sh

# 6. Выйти из vim (опционально) – Фибоначчи
cat << 'EOF' > fibonacci_vim.sh
#!/bin/bash
cat > /tmp/fib.py << 'PY'
def fib(n):
    a, b = 0, 1
    for _ in range(n):
        print(a, end=' ')
        a, b = b, a+b
fib(int(input("Введите n: ")))
PY
vim /tmp/fib.py
python3 /tmp/fib.py
EOF
chmod +x fibonacci_vim.sh