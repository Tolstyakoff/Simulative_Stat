#!/bin/bash
# Практика к уроку 5 — упрощённые решения (без циклов и условий)

# 1. Удаление в корзину
alias trm='mv --target-directory="$HOME/.local/share/Trash/files"'

# 2. Просто бекап (mybackup.sh)
cat << 'EOF' > mybackup.sh
#!/bin/bash
mkdir -p "$2"
cp -r "$1"/. "$2"/
EOF
chmod +x mybackup.sh

# 3. Из файла в файловую систему (gendirs.sh)
cat << 'EOF' > gendirs.sh
#!/bin/bash
cat "$1" | xargs mkdir -p
EOF
chmod +x gendirs.sh

# 4. Раскидывание по директориям (extract_by_ext.sh)
cat << 'EOF' > extract_by_ext.sh
#!/bin/bash
cd "$1"
mkdir -p javascript bash python
mv *.js javascript/ 2>/dev/null
mv *.sh bash/ 2>/dev/null
mv *.py python/ 2>/dev/null
EOF
chmod +x extract_by_ext.sh

# 5. Семи символьная символьная ссылка (7ln.sh)
cat << 'EOF' > 7ln.sh
#!/bin/bash
mkdir -p "$1"
ls | grep -E '^.{7}$' | xargs -I {} ln -s "$PWD/{}" "$1"/{}
EOF
chmod +x 7ln.sh

# 6. Git 2.0 (setpy.sh) — требует sudo
cat << 'EOF' > setpy.sh
#!/bin/bash
ln -sf "$(which python$1)" /usr/local/bin/python
EOF
chmod +x setpy.sh