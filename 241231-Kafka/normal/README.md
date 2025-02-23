# Уровень Normal:

0. Развернул виртуальные машины с linux: kafka01, db01, web01 с помощью Terraform. 
1. Создайте Ansible-роль для установки Kafka UI и настройте подключение к серверу Kafka.
2. Создайте Ansible-роль для установки Apache Kafka
3. Создайте Ansible-роль для установки и настройки ClickHouse. Учтите возможность кастомизации конфигурации базы данных.
4. Напишите плейбук, объединяющий роли, для автомаической настройки всех компонентов.
5. Доработайте роль Kafka, либо напишите новую, для настройки кластера Kafka (например для 3 брокеров)

# Решение:

0. Развернул виртуальные машины с помощью Terraform.

```
terraform apply
```

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/normal/images/1.jpg)

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/normal/images/2.jpg)

1. Создал Ansible-роль для установки Kafka UI и настроил подключение к серверу Kafka.

- [Ansible-роль Kafka UI](https://github.com/Firewal7/Tasks-DevOps/tree/main/241231-Kafka/normal/roles/kafka_ui)

2. Создал Ansible-роль для установки Apache Kafka.

- [Ansible-роль Apache Kafka](https://github.com/Firewal7/Tasks-DevOps/tree/main/241231-Kafka/normal/roles/kafka)

3. Создал Ansible-роль для установки и настройки ClickHouse. Учёл возможность кастомизации конфигурации базы данных через group_vars.

- [Ansible-роль ClickHouse](https://github.com/Firewal7/Tasks-DevOps/tree/main/241231-Kafka/normal/roles/clickhouse)

4. Написал плейбук, объединяющий роли, для автомаической настройки всех компонентов.

- [Playbook](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/normal/playbook.yml)

5. Доработал роль Kafka, либо напишите новую, для настройки кластера Kafka (например для 3 брокеров)

- [Ansible-роль Apache Kafka](https://github.com/Firewal7/Tasks-DevOps/tree/main/241231-Kafka/normal/roles/kafka)

```
ansible-playbook playbook.yml
```

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/normal/images/3.jpg)

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/normal/images/4.jpg)

#### Отправка сообщения в Kafka:

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/normal/images/5.jpg)

#### Проверяем Clickhouse:

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/normal/images/5.jpg)
