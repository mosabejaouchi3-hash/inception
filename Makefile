COMPOSE_FILE = ./srcs/docker-compose.yml
COMPOSE      = docker compose -f $(COMPOSE_FILE)
DATA_WP      = /home/mjaouchi/data/wordpress
DATA_DB      = /home/mjaouchi/data/mariadb

all: up

init_dirs:
	@sudo mkdir -p $(DATA_WP) $(DATA_DB)

up: init_dirs
	@sudo $(COMPOSE) up --build -d

build: init_dirs
	@sudo $(COMPOSE) up --build

down:
	@sudo $(COMPOSE) down

clean: down

fclean:
	@sudo $(COMPOSE) down -v --rmi all
	@sudo rm -rf $(DATA_WP)/* $(DATA_DB)/*

re: fclean up
