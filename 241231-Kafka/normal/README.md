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

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/nornal/images/.jpg)

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/normal/images/.jpg)

1. Создал Ansible-роль для установки Kafka UI и настроил подключение к серверу Kafka.

- [Ansible-роль Kafka UI](https://github.com/Firewal7/Tasks-DevOps/tree/main/241231-Kafka/normal)

2. Создал Ansible-роль для установки Apache Kafka.

- [Ansible-роль Apache Kafka](https://github.com/Firewal7/Tasks-DevOps/tree/main/241231-Kafka/normal)

3. Создал Ansible-роль для установки и настройки ClickHouse. Учёл возможность кастомизации конфигурации базы данных через group_vars.

- [Ansible-роль ClickHouse](https://github.com/Firewal7/Tasks-DevOps/tree/main/241231-Kafka/normal)

4. Написал плейбук, объединяющий роли, для автомаической настройки всех компонентов.

- [Playbook](https://github.com/Firewal7/Tasks-DevOps/tree/main/241231-Kafka/normal)

5. Доработайте роль Kafka, либо напишите новую, для настройки кластера Kafka (например для 3 брокеров)











clickhouse-client --host 127.0.0.1 --port 9000 --user default --password '' --database default

SELECT database, table, SUM(bytes_on_disk) / 1024 / 1024 AS size_mb
FROM system.parts
WHERE active
GROUP BY database, table
ORDER BY size_mb DESC;


bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic test-topic --partitions 1 --replication-factor 1
echo '{"key": "value", "another_key": 123}' | /opt/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test-topic

export ANSIBLE_CONFIG=/home/msi/devops/241231-Kafka/normal/ansible.cfg
ansible-playbook /home/msi/devops/241231-Kafka/normal/playbooks/site.yml

    env:
      KAFKA_CLUSTERS_0_NAME: "local"
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: "{{ hostvars['kafka01'].ansible_host }}:9092"
      KAFKA_CLUSTERS_0_ZOOKEEPER: "{{ hostvars['kafka01'].ansible_host }}:2181"