# Уровень Light:

1. Разверните три виртуальные машины с linux: nexus01, runner01 и app01. Можно использовать любые способы создания, например в Яндекс Облаке или локально в Vagrant.
2. Установите Docker на виртуальную машину "nexus01". Запустить в нём Sonartype Nexus. настроить volume для сохранения данных.
3. Создать учётную запись, создать Docker hosted репозиторий в Nexus для хранения Docker-образов. Создать Docker proxy репозиторий для dockerhub и Docker group для публикаций объединённого репозитория.
4. Написать docker-compouse.yml, поднимающий настроенный и готовый к работе Nexus. В качестве БД использовать postgresql. Предусмотреть healtchech'и для контейнера БД и очередность запуска.
5. Установить docker на app01, написать Dockerfile для приложения.
6. Собрать и запушить образ в Nexus. Запустить приложение на app01 с образом из Nexus.

# Решение:

1. ВМ развернул на Yandex Cloud

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/250505-CICD/Light/images/1.jpg)

2. Устанавливаем Docker и docker-compose на nexus01, запускаем Sonartype Nexus, создаём volume для сохранения данных.

```
sudo curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
docker volume create nexus-data
```
```
docker run -d --name nexus \
  -p 8081:8081 \
  -p 5000:5000 \
  --restart=unless-stopped \
  -v nexus-data:/nexus-data \
  sonatype/nexus3
```
```
user@nexus01:~$ docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED          STATUS          PORTS                                                                                      NAMES
da56ea9d5885   sonatype/nexus3   "/opt/sonatype/nexus…"   51 seconds ago   Up 49 seconds   0.0.0.0:5000->5000/tcp, [::]:5000->5000/tcp, 0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp   nexus
```

Зайдём в контейнер узнать пароль от учётки.
```
docker exec nexus cat /nexus-data/admin.password

d225d576-10a7-48a3-a84f-5f67d8a9bbf9
```

3. Создаём Учётку и репозитории. (Docker hosted репозиторий для хранения Docker-образов, Docker proxy для dockerhub и Docker group для публикаций объединённого репозитория).

В docker-hosted открываем порт http:5000
В docker-proxy storage https://registry-1.docker.io (Use Docker Hub)

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/250505-CICD/Light/images/2.jpg)

4. docker-compose.yml поднимающий Nexus и postgresql c healtchech'ками.

```
version: "3.9"

services:
  nexus:
    image: sonatype/nexus3
    container_name: nexus
    ports:
      - "8081:8081"
      - "5000:5000"
    volumes:
      - nexus-data:/nexus-data
    restart: unless-stopped
    depends_on:
      postgresql:
        condition: service_healthy  # Дождаться, пока postgresql станет здоровым
    environment:
      - NEXUS_DB_CONNECTION_STRING=jdbc:postgresql://postgresql:5432/nexus
      - NEXUS_DB_USERNAME=nexus
      - NEXUS_DB_PASSWORD=nexus
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8081/ || exit 1"]  # Проверка доступности веб-интерфейса
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s  # Дать время Nexus на запуск
    networks:
      - nexus-network

  postgresql:
    image: postgres:15-alpine
    container_name: postgresql
    volumes:
      - postgresql-data:/var/lib/postgresql/data
    restart: unless-stopped
    environment:
      - POSTGRES_USER=nexus
      - POSTGRES_PASSWORD=nexus
      - POSTGRES_DB=nexus
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U nexus -d nexus"]  # Проверка готовности postgresql
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - nexus-network

volumes:
  nexus-data:
    external: true
  postgresql-data:

networks:
  nexus-network:
    driver: bridge
```
Остановите и удалите существующий контейнер Nexus:
```
docker stop nexus 

docker rm nexus
```
```
user@nexus01:~$ docker compose up -d

[+] Running 12/12
 ✔ postgresql Pulled                                                       8.1s
   ✔ fe07684b16b8 Pull complete                                            0.8s
   ✔ 2777460b63f4 Pull complete                                            0.9s
   ✔ 642e176e7683 Pull complete                                            1.0s
   ✔ b4dcca6808e5 Pull complete                                            1.1s
   ✔ 77b69ff8bb36 Pull complete                                            1.2s
   ✔ 45886f8a09ca Pull complete                                            5.5s
   ✔ 331cba96f288 Pull complete                                            5.5s
   ✔ 6380a3c9c68c Pull complete                                            5.6s
   ✔ f2ee91c57ab1 Pull complete                                            5.7s
   ✔ 8e7dfe758b13 Pull complete                                            5.8s
   ✔ 639ffb3d4c66 Pull complete                                            5.8s
[+] Running 4/4
 ✔ Network user_nexus-network     Created                                  0.1s
 ✔ Volume "user_postgresql-data"  Creat...                                 0.0s
 ✔ Container postgresql           Healthy                                 27.6s
 ✔ Container nexus                Started                                 11.4s
```

5. Установил Docker на app01 и написал Dockerfile для приложения.

```
sudo curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
```

Dockerfile:

```
FROM python:3.9-slim-buster
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["python", "app.py"]
```

requirements.txt
```
flask
```

Приложение которое возвращает (Hello from app01!): app.py
```
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello from app01!"

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=8000)
```

6. Собрали и запушили образ в Nexus.

Соберали Docker-образ (на app01):
```
docker build -t app01:latest .
```

Укажите Docker, что registry использует HTTP /etc/docker/daemon.json
```
{
       "insecure-registries": ["84.201.140.155:5000"]
     }

sudo systemctl restart docker
```

Авторизуйтесь в Nexus (на app01):
```
user@app01:~$ docker login -u admin -p admin 84.201.140.155:5000
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
Login Succeeded
```

Затегируйте образ (на app01):
```
docker tag app01:latest 84.201.140.155:5000/app01:latest
```

Опубликуйте образ в Nexus (на app01):
```
docker push 84.201.140.155:5000/app01:latest
```
Запустите приложение из Nexus (на app01):
```
docker run -d -p 8000:8000 --name app01 84.201.140.155:5000/app01:latest
```
```
user@app01:~$ curl http://89.169.189.47:8000
Hello from app01!
```

![alt](https://github.com/Firewal7/Tasks-DevOps/blob/main/250505-CICD/Light/images/3.jpg)