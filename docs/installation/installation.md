---
layout: default
title: "Installation"
parent: "📥 Installation"
nav_order: 3
---

## 📥 Installation

1. Install docker if you haven't already

2. Make sure UDP/QUIC optimisations are done

3. Now run the docker container and have fun!

You can run the container by running this in your terminal.
```bash
docker run -d \
  --name hytale-server \
  --restart unless-stopped \
  -e EULA="TRUE" \
  -e DEBUG="FALSE" \
  -p 5520:5520/udp \
  -v docker-hytale-server:/home/container \
  freudend/docker-hytale-server:latest
```

Alternatively, you can deploy using Docker Compose. Use the configuration below or explore the [examples](https://github.com/deinfreu/docker-hytale-server/tree/main/examples) folder for more advanced templates.

```bash
services:
  hytale:
    image: freudend/hytale-server:experimental
    container_name: hytale-server
    environment:
      EULA: "TRUE"               
    restart: unless-stopped
    ports:
      - "5520:5520/udp"           #external OS:internal docker
    volumes:
      - ./data:/home/container    #external OS:internal docker
```

> ./data will create a folder called "data" next to the docker-compose.yml file.

That's all you need to know to start! 🎉
