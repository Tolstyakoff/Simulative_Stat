#!/bin/bash
# ============================================================
# prepare-host.sh
# Скрипт для автоматической установки инструментов и утилит
# на удалённом хосте Linux (Ubuntu/Debian).
# Запускать с sudo: sudo bash prepare-host.sh
# ============================================================

set -e  # остановка при любой ошибке

# ------------------------------------------------------------
# 1. Автоматическая установка пакетов
# ------------------------------------------------------------

# Проверка прав суперпользователя
if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: пожалуйста, запустите скрипт с sudo"
    exit 1
fi

echo "Обновление списка пакетов..."
apt update

echo "Установка базовых утилит (fzf, tmux, tree, htop, vim, nano, build-essential, make, git, wget, curl)..."
apt install -y fzf tmux tree htop vim nano build-essential make git wget curl

echo "Установка Python, pip и virtualenv..."
apt install -y python3 python3-pip
pip3 install virtualenv

echo "Установка Node.js (версия 20.x) через официальный репозиторий NodeSource..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

echo "Установка PostgreSQL и Nginx..."
apt install -y postgresql postgresql-contrib nginx

# ------------------------------------------------------------
# 2. Быстрейшее Обновление – алиас autoupgrade
# ------------------------------------------------------------
# 3. Полнейшее удаление – алиас fullremove
# ------------------------------------------------------------

# Добавляем алиасы в .bashrc реального пользователя (не root)
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

BASHRC="$USER_HOME/.bashrc"
touch "$BASHRC"

# Функция для безопасного добавления алиаса (если ещё не существует)
add_alias() {
    local alias_name="$1"
    local alias_cmd="$2"
    if ! grep -q "alias $alias_name=" "$BASHRC"; then
        echo "alias $alias_name='$alias_cmd'" >> "$BASHRC"
        echo "✅ Алиас $alias_name добавлен в $BASHRC"
    else
        echo "ℹ️ Алиас $alias_name уже присутствует в $BASHRC"
    fi
}

add_alias "autoupgrade" "sudo apt update && sudo apt upgrade -y"
add_alias "fullremove"  "sudo apt remove -y \"\$@\" ; sudo apt purge -y \"\$@\" ; sudo apt autoremove -y ; sudo apt clean"

echo "------------------------------------------------------------"
echo "✅ Все пакеты установлены, алиасы добавлены."
echo "👉 Чтобы алиасы стали доступны, выполните: source $BASHRC"
echo "   или откройте новый терминал."
echo "------------------------------------------------------------"
