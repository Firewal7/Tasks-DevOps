# Уровень Light:

1. Развернуть виртуальные машины с linux: kafka01, db01, web01. (Можно использовать любые способы, яндекс облако или Vagrant).
2. Установите Apache Kafka на kafka01.
3. Установите Kafka UI на web01, убедитесь что web-интерфейс доступен из браузера.
4. Подключите Kafka UI к Kafka.
5. Установите ClickHouse на db01.
6. Настройте базу данных ClickHouse для хранения данных из Kafka.
7. Через UI запишите сообщение в Kafka и проверьте, что оно появилось в ClickHouse.


# Решение:

1. ВМ развернул на Yandex Cloud

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/light/images/1.jpg)

2. Установите Apache Kafka на kafka01.

#### Установим java
```
sudo apt update
sudo apt install openjdk-11-jdk -y
```
#### Скачиваем и устанавливаем Kafka:
```
wget https://dlcdn.apache.org/kafka/3.9.0/kafka_2.13-3.9.0.tgz
tar -xzf kafka_2.13-3.9.0.tgz
sudo mv kafka_2.13-3.9.0 /opt/kafka
```
#### Отредактируем файл: nano /opt/kafka/config/server.properties

```
broker.id=1
log.dirs=/tmp/kafka-logs
zookeeper.connect=localhost:2181
listeners=PLAINTEXT://:9092
```
#### Запустим ZooKeeper: 
```
/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties &
```
#### Запустим Kafka: 
```
/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties &
```
#### Создадим топик:
```
/opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic test-topic --partitions 1 --replication-factor 1
```

3. Установите Kafka UI на web01, убедитесь что web-интерфейс доступен из браузера.

#### Устанавливаем Docker: 
```
sudo curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
```
#### Запускаем Kafka UI:

```
docker run -d \
--name kafka-ui \
-p 8080:8080 \
-e KAFKA_CLUSTERS_0_NAME=local \
-e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=158.160.69.2:9092 \
provectuslabs/kafka-ui:latest
```

4. Проверяем подключение Kafka UI к Kafka.

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/light/images/4.jpg)

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/light/images/4.1.jpg)

5. Установливаем ClickHouse на db01.

```
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | sudo gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb stable main" | sudo tee \
    /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update

sudo apt-get install -y clickhouse-server=24.12.2.29 clickhouse-client=24.12.2.29


sudo service clickhouse-server start
sudo service clickhouse-server status
clickhouse-client
```

6. Настраиваем базу данных ClickHouse для хранения данных из Kafka.

#### Создаём БД:
```
CREATE DATABASE kafka_data;
```

#### Создаём таблицу для данных из Kafka:
```
CREATE TABLE kafka_data.kafka_messages (
    key String,
    value String,
    timestamp DateTime
) ENGINE = MergeTree()
ORDER BY timestamp;
```

#### Создаём таблицу для чтения данных из Kafka:
```
CREATE TABLE kafka_data.kafka_raw (
    key String,
    value String,
    timestamp DateTime
) ENGINE = Kafka
SETTINGS kafka_broker_list = '158.160.3.109:9092',
         kafka_topic_list = 'test-topic',
         kafka_group_name = 'clickhouse_group',
         kafka_format = 'JSONEachRow',
         kafka_row_delimiter = '\n',
         kafka_num_consumers = 1;
```

#### Приведём в материализованный вид для вставки данных из Kafka в основную таблицу:
```
CREATE MATERIALIZED VIEW kafka_data.kafka_to_table
TO kafka_data.kafka_messages
AS SELECT
    key,
    value,
    now() AS timestamp
FROM kafka_data.kafka_raw;
```

7. Отправка сообщения в Kafka через консоль на ВМ kafka01:

```
echo '{"key": "value", "another_key": 123}' | /opt/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test-topic
```

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/light/images/7.jpg)

#### Проверяем Clickhouse:

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/light/images/8.jpg)


