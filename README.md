# API-mock

## Installation:

```bash
# For first time run following commands
$ git clone https://github.com/imskr/API-mock.git
$ cd API-mock
$ docker-compose up --build # run `docker-compose up` for subsequent runs
# in new shell run following to create db
$ docker-compose exec web rake db:create
$ docker-compose exec web rake db:migrate
```

> Server is up and running at `localhost:3000`
