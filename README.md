   Monitoring. sh предназначен для инициализации и запуска базовых процессов в проекте. Он полностью функционален и протестирован на различных окружениях, включая Linux и macOS.
   Репрозиторий уже содержит работающий init (monitoring.service), этот вариант можно интегрировать как альтернативу или расширение.


<Установка и запуск>


Клонируйте репозиторий: git clone <repo-url>.

Перейдите в директорию: cd <name_repo>.

Сделайте скрипт исполняемым: chmod +x monitoring.sh.

Добавьте  файл monitoring.service  в путь /etc/systemd/system (для автоматического запуска с вашей ОС)

Запустите вручную (работает если вы в той же директории,  что и bash-cкрипт): ./monitoringt.sh (опционально с флагами, см. ниже).

Или же запустите, как sudo systemctl start monitoring.service

<P.S. Важно! Если вы запускаете через systemctl, то перед стартом выполните следующие действия:

sudo systemctl daemon-reload
sudo  systemctl start monitoring.service

И только после запуска через systemctl введите:

sudo systemctl status monitoring.service (проверка статуса).

Корректный вывод будет примерно таким:

 monitoring.service - Мониторинг API test при запущенном процессе test
     Loaded: loaded (/etc/systemd/system/monitoring.service; enabled; preset: disabled)
     Active: active (running) since Fri 2025-10-24 14:26:47 MSK; 7s ago
 Invocation: b66b0a1cb2614040ad35f7f36218be03
   Main PID: 3947 (monitoring.sh)
      Tasks: 2 (limit: 3825)
     Memory: 640K (peak: 1.3M)
        CPU: 36ms
     CGroup: /system.slice/monitoring.service
             ├─3947 /bin/bash /home/limbles/test/monitoring.sh # Путь к скрипту
             └─3953 sleep 60

окт 24 14:26:47 limbless systemd[1]: Started monitoring.service - Мониторинг API test при запущенном процессе test.>

<Основные функции>

1. Запускается при запуске системы (через init);
2. Отрабатывает каждую минуту;
3. Если процесс запущен, то стучится (по https) на
https://test.com/monitoring/test/api;
4. Если процесс был перезапущен, пишет в лог /var/log/monitoring.log
(если процесс не запущен, то ничего не делает);
5. Если сервер мониторинга не доступен, так же делает запись в лог.

<Требования и совместимость>

Требуется Bash 4+. Совместим с проектами на JavaScript/TypeScript. Для Windows используйте Git Bash или WSL.


<Устранение неисправностей>

Если скрипт падает, проверьте права доступа и обновите зависимости. Для кастомизации редактируйте config.ini. (monitoring.service) В случае ошибок обращайтесь в issues на GitHub.

