# Ejercicio 3 — Volúmenes Docker

## Objetivo

Aprender a usar **bind-mounts** (volúmenes de host) para persistir y compartir
datos entre el host y los contenedores.

## Conceptos clave

- **Bind-mount**: monta una carpeta del host directamente en el contenedor.
- **Named volume**: Docker gestiona el almacenamiento. Útil para datos que deben
  persistir entre reinicios del contenedor.

## Ejemplo: nginx con bind-mount (en servidorUbuntu)

```bash
vagrant ssh servidorUbuntu
cd /vagrant/exercises/03_volumes

# 1. Crear la carpeta de contenido en el host
mkdir -p site
echo "<h1>Hola desde el volumen</h1>" > site/index.html

# 2. Levantar nginx con bind-mount
sudo docker run --name volweb -d -p 9920:80 \
  -v "$(pwd)/site:/usr/share/nginx/html:ro" \
  nginx:alpine

# 3. Probar
curl -s http://127.0.0.1:9920
# Host: http://192.168.100.5:9920

# 4. Editar el archivo en el host y ver el cambio en caliente
echo "<h1>Contenido actualizado</h1>" > site/index.html
curl -s http://127.0.0.1:9920

# 5. Limpiar
sudo docker rm -f volweb
```

## Ejemplo: volumen nombrado

```bash
# Crear un volumen nombrado
sudo docker volume create mivol

# Usar el volumen en un contenedor
sudo docker run --name test -d \
  -v mivol:/data \
  ubuntu sleep 3600

# Ver punto de montaje en el host
sudo docker volume inspect mivol

# Listar volúmenes
sudo docker volume ls

# Limpiar
sudo docker rm -f test
sudo docker volume rm mivol
```

## Comandos útiles de volúmenes

```bash
sudo docker volume ls           # listar volúmenes
sudo docker volume inspect VOL  # detalles de un volumen
sudo docker volume rm VOL       # eliminar volumen
sudo docker volume prune        # eliminar volúmenes no usados
```
