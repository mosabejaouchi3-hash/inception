PATH_COMPOSE = ./srcs/docker-compose.yml

build:
	@sudo docker compose -f $(PATH_COMPOSE) up --build 
clean:
	@docker compose -f ./srcs/docker-compose.yml down

fclean:
	@docker compose -f ./srcs/docker-compose.yml down -v --rmi all
	@sudo rm -rf /home/mjaouchi/data/mariadb/*
	@sudo rm -rf /home/mjaouchi/data/wordpress/*

no-build:
	@sudo docker compose -f $(PATH_COMPOSE) up
re: fclean build
