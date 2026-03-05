# Ejercicio 1 — Imagen propia + DockerHub

## Objetivo

Construir una imagen Docker con un sitio web personalizado y subirla a DockerHub.

## Archivos

- `Dockerfile` — define la imagen (Ubuntu + Apache2 + contenido HTML)
- `site/index.html` — página de ejemplo

## Comandos (en servidorUbuntu)

```bash
# 1. Entrar a la VM y navegar a la carpeta
vagrant ssh servidorUbuntu
cd /vagrant/exercises/01_dockerhub_image

# 2. Construir la imagen
sudo docker build -t TUUSUARIO/miweb:local .
sudo docker images

# 3. Probar en local
sudo docker run --name miweb -d -p 9100:80 TUUSUARIO/miweb:local
curl -s http://127.0.0.1:9100
# Host: http://192.168.100.5:9100

# 4. Etiquetar para DockerHub
sudo docker tag TUUSUARIO/miweb:local TUUSUARIO/miweb:v1

# 5. Login y push (requiere cuenta en hub.docker.com)
sudo docker login
sudo docker push TUUSUARIO/miweb:v1

# 6. Limpiar
sudo docker container stop miweb
sudo docker container rm miweb
```

> Reemplaza `TUUSUARIO` con tu nombre de usuario de DockerHub.
