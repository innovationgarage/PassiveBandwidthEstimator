FROM ubuntu:18.04

RUN apt update
RUN apt install -y docker-compose

ADD . /app

CMD ["/app/gridsearch/main.sh"]
