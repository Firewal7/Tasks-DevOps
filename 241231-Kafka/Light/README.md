# Уровень Light:

1. Развернуть виртуальные машины с linux: kafka01, db01, web01. (Можно использовать любые способы, яндекс облако или Vagrant).
2. Установите Apache Kafka на kafka01.
3. Установите Kafka UI на web01, убедитесь что web-интерфейс доступен из браузера.
4. Подключите Kafka UI к Kafka.
5. Установите ClickHouse на db01.
6. Настройте базу данных ClickHouse для хранения данных из Kafka.
7. Через UI запишите сообщение в Kafka и проверьте, что оно появилось в ClickHouse.


# Решение:

1. ВМ развернул руками на Yandex Cloud

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/Light/images/1.jpg)

2. Установите Apache Kafka на kafka01.

#### Установим java:

```
sudo apt update
sudo apt install openjdk-11-jdk -y
```

#### Скачиваем и распаковываем Kafka:

```
wget "https://downloads.apache.org/kafka/3.9.2/kafka_2.13-3.9.2.tgz"
tar -xzf kafka_2.13-3.9.2.tgz
sudo mv kafka_2.13-3.9.2 /opt/kafka
```

#### Создаём системного пользователя kafka:

- Kafka запускалась не от root, а с ограниченными правами,
- Безопасно владела файлами /opt/kafka и /var/lib/kafka,
- Проще управлять службой и логами в systemd.

```
sudo useradd --system --home /opt/kafka --shell /usr/sbin/nologin --user-group kafka
sudo chown -R kafka:kafka /opt/kafka
sudo mkdir -p /var/lib/kafka
sudo chown -R kafka:kafka /var/lib/kafka
sudo chmod 750 /var/lib/kafka
```

#### Конфиг удобно собрать от заготовки в дистрибутиве:

```
sudo cp /opt/kafka/config/kraft/server.properties /opt/kafka/config/kraft/server-kraft.properties
sudo nano /opt/kafka/config/kraft/server-kraft.properties
```

#### Здесь Kafka слушает порт 9092 на всех интерфейсах, а клиентам «рекламирует» себя как KAFKA_IP:9092 (внешний адрес узла).

```
process.roles=broker,controller
node.id=1
controller.quorum.voters=1@127.0.0.1:9093
controller.listener.names=CONTROLLER

listeners=PLAINTEXT://0.0.0.0:9092,CONTROLLER://127.0.0.1:9093
inter.broker.listener.name=PLAINTEXT
advertised.listeners=PLAINTEXT://KAFKA_IP:9092
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT

log.dirs=/var/lib/kafka

num.partitions=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
```

#### Первый раз перед запуском Kafka в режиме KRaft нужно отформатировать хранилище с помощью kafka-storage.sh format. Каталог из log.dirs должен быть пустым либо предварительно очищенным, чтобы не затереть случайно старые данные:

```
sudo mkdir -p /var/lib/kafka
CLUSTER_UUID=$(/opt/kafka/bin/kafka-storage.sh random-uuid)
sudo -u kafka /opt/kafka/bin/kafka-storage.sh format -t "$CLUSTER_UUID" -c /opt/kafka/config/kraft/server-kraft.properties
```

#### Запуск Kafka в фоновом режиме:

```
sudo -u kafka /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server-kraft.properties &
```

#### Если нужно, чтобы после перезагрузки ВМ всё поднималось автоматически, настроил `systemd`:

##### Сначала останавливаю, что могло остаться от ручного запуска:

```
sudo /opt/kafka/bin/kafka-server-stop.sh || true
sudo pkill -f 'kafka.Kafka' || true
```

#### Создаём systemd‑инит‑файл для Kafka:

```
sudo tee /etc/systemd/system/kafka.service << 'EOF'
[Unit]
Description=Apache Kafka (KRaft)
After=network-online.target
Wants=network-online.target
[Service]
Type=simple
User=kafka
Group=kafka
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server-kraft.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-failure
RestartSec=10
LimitNOFILE=1048576
[Install]
WantedBy=multi-user.target
EOF
```

#### Включаем:

```
sudo systemctl daemon-reload
sudo systemctl enable kafka
sudo systemctl start kafka
sudo systemctl status kafka
```

#### Создадим топик:

```
/opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic test-topic --partitions 1 --replication-factor 1
```

#### Быстрая проверка, ответа брокера:

```
/opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092
```

3. Установите Kafka UI на web01, убедитесь что web-интерфейс доступен из браузера.

#### Устанавливаем Docker:

```
sudo curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
```

#### Для просмотра и управления Kafka‑кластером был развёрнут веб‑интерфейс Kafka‑UI в Docker‑контейнере (указываем KAFKA_IP нашего брокера):

```
sudo docker run -d \
  --name kafka-ui \
  --restart unless-stopped \
  -p 8080:8080 \
  -e KAFKA_CLUSTERS_0_NAME=local \
  -e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=KAFKA_IP:9092 \
  provectuslabs/kafka-ui:v0.7.2
```

4. Проверяем подключение Kafka UI к Kafka.

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/Light/images/2.jpg)

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/Light/images/3.jpg)

5. Устанавливаем ClickHouse на db01:

```
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | sudo gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb stable main" | sudo tee \
    /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update

sudo apt-get install -y clickhouse-server=26.3.9.8 clickhouse-client=26.3.9.8

sudo service clickhouse-server start
sudo service clickhouse-server status
```

6. Настраиваем базу данных ClickHouse для хранения данных из Kafka.

#### Создаём БД:

#### Заходим в БД

```
clickhouse-client
```

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

#### Создаём таблицу для чтения данных из Kafka (указываем KAFKA_IP нашего брокера):

```
CREATE TABLE kafka_data.kafka_raw (
    key String,
    value String,
    timestamp DateTime
) ENGINE = Kafka
SETTINGS kafka_broker_list = 'KAFKA_IP:9092',
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

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/Light/images/4.jpg)

#### Проверяем Clickhouse:
```
SELECT 
    database,
    table,
    sum(bytes_on_disk) / 1024 / 1024 AS size_mb
FROM system.parts
WHERE active
GROUP BY database, table
ORDER BY size_mb DESC;
```
![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/241231-Kafka/Light/images/5.jpg)