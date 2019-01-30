DOCKER_IMAGE = cavaliercoder/zabbix

DOCKER_BUILD = docker build \
	--pull \
	--build-arg "http_proxy=$(http_proxy)" \
	--build-arg "https_proxy=$(https_proxy)"

all: \
	zabbix-1.8 \
	zabbix-2.0 \
	zabbix-2.2 \
	zabbix-2.4 \
	zabbix-3.0 \
	zabbix-3.2 \
	zabbix-3.4 \
	zabbix-4.0

zabbix-1.8:
	$(DOCKER_BUILD) \
		-f zabbix-1.8.Dockerfile \
		-t $(DOCKER_IMAGE):1.8 \
		.

zabbix-2.0:
	$(DOCKER_BUILD) \
		-f zabbix-2.0.Dockerfile \
		-t $(DOCKER_IMAGE):2.0 \
		.

zabbix-2.2:
	$(DOCKER_BUILD) \
		-f zabbix-2.2.Dockerfile \
		-t $(DOCKER_IMAGE):2.2 \
		.

zabbix-2.4:
	$(DOCKER_BUILD) \
		-f zabbix-2.4.Dockerfile \
		-t $(DOCKER_IMAGE):2.4 \
		.

zabbix-3.0:
	$(DOCKER_BUILD) \
		-f zabbix-3.0.Dockerfile \
		-t $(DOCKER_IMAGE):3.0 \
		.

zabbix-3.2:
	$(DOCKER_BUILD) \
		-f zabbix-3.2.Dockerfile \
		-t $(DOCKER_IMAGE):3.2 \
		.

zabbix-3.4:
	$(DOCKER_BUILD) \
		-f zabbix-3.4.Dockerfile \
		-t $(DOCKER_IMAGE):3.4 \
		.

zabbix-4.0:
	$(DOCKER_BUILD) \
		-f zabbix-4.0.Dockerfile \
		-t $(DOCKER_IMAGE):4.0 \
		-t $(DOCKER_IMAGE):latest \
		.
