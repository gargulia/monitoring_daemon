#!/bin/bash

LOG_FILE="/var/log/monitoring.log"
API_URL="https://test.com/monitoring/test/api"
PROCESS_NAME="test" # Имя проверяемого процесса

# Функция для записи в лог
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Функция для проверки доступности API
check_api() {
  curl -s --fail "$API_URL" > /dev/null  # Отправляем запрос и игнорируем вывод
  if [ $? -eq 0 ]; then
    log_message "API доступен"
    return 0 # API доступен
  else
    log_message "API недоступен"
    return 1 # API недоступен
  fi
}

# Функция для проверки запущен ли процесс (с помощью pgrep)
is_process_running() {
    pgrep "$PROCESS_NAME" > /dev/null 2>&1
    return $? # 0 если процесс найден, 1 если нет
}

# Сохраняем PID процесса в файл
save_pid() {
    pid=$(pgrep "$PROCESS_NAME")
    if [ -n "$pid" ]; then
        echo "$pid" > /var/run/"$PROCESS_NAME".pid
    fi
}

# Читаем сохраненный PID процесса
get_saved_pid() {
    if [ -f /var/run/"$PROCESS_NAME".pid ]; then
        cat /var/run/"$PROCESS_NAME".pid
    else
        echo ""
    fi
}


# Функция для проверки, был ли процесс перезапущен
is_process_restarted() {
    saved_pid=$(get_saved_pid)
    current_pid=$(pgrep "$PROCESS_NAME")

    if [ -z "$saved_pid" ]; then
        # Предыдущий PID не был сохранен, т.е. это первый запуск или процесс не был запущен ранее
        return 1 # Считаем, что процесс был перезапущен/запущен заново, так как предыдущего PID нет
    fi

    if [ -z "$current_pid" ]; then
        # Процесс сейчас не запущен, хотя раньше был
        return 1 # Процесс был перезапущен (точнее, он был остановлен)
    fi

    if [ "$saved_pid" -ne "$current_pid" ]; then
        # PID изменился, значит процесс был перезапущен
        return 0
    else
        # PID не изменился, процесс не перезапускался
        return 1
    fi
}



# Основной цикл
while true; do
    # Проверяем, запущен ли процесс
    if is_process_running; then
        # Процесс запущен
        log_message "Процесс $PROCESS_NAME запущен"

        # Проверяем, был ли процесс перезапущен
        if is_process_restarted; then
            log_message "Процесс $PROCESS_NAME был перезапущен"
        fi

        # Сохраняем текущий PID (или обновляем, если он изменился)
        save_pid


        # Если процесс запущен, проверяем API
        check_api
    else
        # Процесс не запущен
        log_message "Процесс $PROCESS_NAME не запущен"
        # Удаляем файл с PID, так как процесс больше не запущен
        rm -f /var/run/"$PROCESS_NAME".pid
    fi

    # Ждем 60 секунд
    sleep 60
done
