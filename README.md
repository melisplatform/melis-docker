# melis-docker
Dockerized Melisplatfrom

# build components :
## config
Change php version in **app/latest/.env** default tag **dev-apache-7.3**
available tag: [here](https://hub.docker.com/repository/docker/melisplatform/melis-docker)
* dev-apache-7.3
* dev-apache-7.1
* dev-apache-7.0
* dev-apache-5.6
* dev-apache-5.5
#
ps: make sure that the port 8080 is not used in you host/or you can change it in the *.env* with any port

```bash
docker-compose up build --pull
```
# start stack
```bash
docker-compose up -d
```
# shutdown stack:
```bash
docker-compose down -v
```

