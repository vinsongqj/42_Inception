DATA_DIR=/home/$(USER)/data
export DATA_DIR

COMPOSE = docker compose -f srcs/docker-compose.yml

all: up

up:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean: down
	docker image prune -f

fclean:
	$(COMPOSE) down -v --rmi local
	sudo rm -rf $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

re: fclean all

.PHONY: all up down clean fclean re
 
