#!/bin/bash
# Практика к уроку 7 – максимально компактные решения

# 1.1 Подавляющая обертка (suppress) – подавление stderr
alias suppress='2>/dev/null'

# 1.2 Использование suppress для очистки вывода описаний утилит
suppress whatis * 2>/dev/null   # или: whatis * 2>/dev/null

# 2.1 Обертка логирующая (outlog) – stderr -> stdout, весь вывод дублируется в out.log
alias outlog='2>&1 | tee out.log'

# 2.2 Использование outlog для cat с существующим и несуществующим файлом
cat exists.txt missing.txt 2>&1 | tee out.log

# 3. Обертка обрезки (cuterr) – только 20 последних строк ошибки
alias cuterr='2>&1 >/dev/null | tail -n 20'

# 4. Свежие файлы – удалить всё кроме 30 самых новых, с подавлением ошибок
suppress ls -t | tail -n +31 | xargs rm -f

# 5. Свой Tee (mytee) – читает stdin, пишет в stdout и в файл $1
alias mytee='tee "$1"'

# 6. Амплитудный diff – разница между самым большим и маленьким файлом по символам
# Вспомогательный heil: первая и последняя строка из конвейера
alias heil='{ head -n1; tail -n1; }'
# Сам diff
wc -c * 2>/dev/null | grep -v total | sort -n | cut -d' ' -f1 | heil | xargs | { read a b; echo $((b - a)); }

# 7. Буфер копи-пастинга (toclip) – копирует вывод команды в буфер обмена
alias toclip='xclip -selection clipboard'

# 8. Обновление всех пакетов pip (скрипт)
alias pipup='pip list --outdated --disable-pip-version-check | cut -d" " -f1 | tail -n +3 | xargs -n1 pip install --upgrade'