# Уровень Normal:

1. Создайте свой собственный Gitlab Runner с Docker executor на виртуальной машине runner01 и зарегистрируйте его в Gitlab для проекта с приложением. Разработайте Gitlab CI пайплайн с использованием файла '.gitlab-ci.yml' с этапом сборки docker образа.
2. Доработайте пайплайн, добавив шаги загрузки docker-образа в gitlabdocker registry и последующей перепубликацией образа в nexus.
3. Добавить в пайплайн джобу деплоя приложения на app01. Доработать её с учётом функционала Gitlab Enviroment.
4. Добавить в пайплайн джобу для удаления docker-образа из nexus, которая должна запускаться при остановке Gitlab environment.
5. Настроить в Nexus задачи по расписанию для удаления неиспользуемых слоёв и блобов.
6. Настроить https прокси для проксирования на nexus. В качестве прокси можно использовать любой прокси сервер и самописные УЦ.

# Решение:

1. Настроим/установим/зарегистрируем Runner на базе deb-пакетов (Debian / Ubuntu):
```
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
apt install gitlab-runner
gitlab-runner register
sudo usermod -aG docker gitlab-runner
sudo systemctl restart gitlab-runner
```
Gitlab CI пайплайн с использованием файла '.gitlab-ci.yml':
```

```