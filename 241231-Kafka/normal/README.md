# Уровень Normal:

1. Создайте Ansible-роль для установки Kafka UI и настройте подключение к серверу Kafka.
2. Создайте Ansible-роль для установки Apache Kafka
3. Создайте Ansible-роль для установки и настройки ClickHouse. Учтите возможность кастомизации конфигурации базы данных.
4. Напишите плейбук, объединяющий роли, для автомаической настройки всех компонентов.
5. Доработайте роль Kafka, либо напишите новую, для настройки кластера Kafka (например для 3 брокеров)


clickhouse-client --host 127.0.0.1 --port 9000 --user default --password '' --database default

SELECT 
    round(sum(p.bytes) / 1024 / 1024, 2) AS total_mb,
    count(pr.query_id) AS active_queries
FROM system.parts p
LEFT JOIN system.processes pr ON pr.database = 'kafka_data'
WHERE p.database = 'kafka_data';


bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic test-topic --partitions 1 --replication-factor 1
