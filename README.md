# Práctica Contenedores Docker (Vagrant + Ubuntu 22.04 + Docker CE)

Repositorio para ejecutar la práctica de Docker con **2 máquinas Ubuntu 22.04 en Vagrant** (cliente/servidor) y **Docker CE preinstalado vía aprovisionamiento automático**.

> ⚠️ **Importante:** Este repositorio **NO incluye ni desarrolla los "Desafíos" (puntos 5–7).**
> Ver sección al final.

---

## 0. Requisitos (host)

- [VirtualBox](https://www.virtualbox.org/) (≥ 6.1)
- [Vagrant](https://www.vagrantup.com/) (≥ 2.3)
- CPU con virtualización activa (VT-x/AMD-V habilitada en BIOS/UEFI)
- Espacio en disco: **10+ GB libres** (recomendado)
- Conexión a internet (para descargar la box y la imagen Docker)

---

## 1. Topología de VMs

| VM | Hostname | IP | RAM |
|---|---|---|---|
| Servidor | `servidorUbuntu` | `192.168.100.5` | 2 GB |
| Cliente | `clienteUbuntu` | `192.168.100.4` | 2 GB |

Ambas VMs usan la box `bento/ubuntu-22.04` y quedan con Docker CE instalado
automáticamente al ejecutar `vagrant up --provision`.

---

## 2. Estructura del repositorio

```
/
├── Vagrantfile                        ← define las 2 VMs
├── README.md                          ← este archivo
├── provision/
│   ├── install_docker.sh              ← instala Docker CE en Ubuntu 22.04
│   └── common.sh                      ← helpers opcionales
├── scripts/
│   ├── up.sh                          ← atajo para vagrant up --provision
│   ├── ssh_server.sh                  ← atajo para vagrant ssh servidorUbuntu
│   ├── ssh_client.sh                  ← atajo para vagrant ssh clienteUbuntu
│   └── status.sh                      ← atajo para vagrant status
├── parts/
│   ├── part4_custom_image/
│   │   ├── Dockerfile                 ← imagen Ubuntu + Apache2 + HTML
│   │   └── html1/index.html
│   └── part6_copy_files/
│       ├── Dockerfile                 ← imagen con COPY de directorio
│       └── voldocker/
│           ├── index.html
│           └── pagina1.html
├── exercises/
│   ├── 01_dockerhub_image/            ← Ej 1: imagen propia + DockerHub
│   ├── 02_datascience_jupyter/        ← Ej 2: Jupyter + libs Data Science
│   ├── 03_volumes/                    ← Ej 3: volúmenes Docker
│   └── 04_ml_jupyter_python3/        ← Ej 4: ML Jupyter desde repo externo
└── docs/                              ← documento guía (placeholder)
```

---

## 3. Quickstart

### 3.1 Levantar las VMs (con aprovisionamiento)

Desde la raíz del repositorio:

```bash
vagrant up --provision
vagrant status
```

### 3.2 Entrar por SSH

```bash
vagrant ssh servidorUbuntu
# o
vagrant ssh clienteUbuntu
```

### 3.3 Verificar Docker

En cada VM:

```bash
sudo docker run hello-world
sudo systemctl status docker --no-pager
sudo docker info | more
```

> **Nota sobre sudo:** El usuario `vagrant` ya fue agregado al grupo `docker`
> durante el aprovisionamiento. Para usar `docker` sin `sudo`, cierra y vuelve
> a abrir la sesión SSH:
>
> ```bash
> exit
> vagrant ssh servidorUbuntu
> ```

---

## PARTE 1 — Configuración de Vagrant

El `Vagrantfile` ya viene configurado con las dos VMs y la red privada.

```bash
vagrant up --provision
vagrant status
vagrant ssh servidorUbuntu
vagrant ssh clienteUbuntu
```

---

## PARTE 2 — Instalación de Docker en Ubuntu 22.04 (automatizada)

Esta parte queda completada por `provision/install_docker.sh` durante el
`vagrant up --provision`. El script:

1. Remueve versiones antiguas de Docker si existen.
2. Instala `ca-certificates` y `curl`.
3. Agrega la llave GPG oficial de Docker.
4. Agrega el repositorio oficial de Docker para Ubuntu.
5. Instala `docker-ce`, `docker-ce-cli`, `containerd.io`,
   `docker-buildx-plugin`, `docker-compose-plugin`.
6. Habilita el servicio: `systemctl enable --now docker`.
7. Agrega el usuario `vagrant` al grupo `docker`.

Validación manual (dentro de cualquier VM):

```bash
sudo docker info | more
sudo systemctl status docker --no-pager
```

---

## PARTE 3 — Descargar imagen existente y correr servicio (httpd)

> Se ejecuta en **servidorUbuntu**.

```bash
# 1. Entrar al servidor
vagrant ssh servidorUbuntu

# 2. Buscar imágenes de Apache en DockerHub
sudo docker search apache

# 3. Descargar la imagen httpd
sudo docker pull httpd
sudo docker images

# 4. Ejecutar el contenedor
sudo docker run -d --name web1 -p 8800:80 httpd
sudo docker ps

# 5. Probar el servicio
curl -I http://127.0.0.1:8800
curl -s http://127.0.0.1:8800 | head
# Desde el host: http://192.168.100.5:8800

# 6. Detener y borrar el contenedor
sudo docker container stop web1
sudo docker container rm web1
sudo docker container ls -a
```

---

## PARTE 4 — Imagen Docker propia (Ubuntu + Apache + HTML)

> Usar carpeta: `parts/part4_custom_image/` en **servidorUbuntu**.

### Dockerfile

```dockerfile
FROM ubuntu
RUN apt update
RUN apt install -y apache2
RUN apt install -y apache2-utils
RUN apt clean
COPY html1/ /var/www/html/
EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]
```

### Comandos

```bash
# 1. Entrar al servidor
vagrant ssh servidorUbuntu
cd /vagrant/parts/part4_custom_image
ls

# 2. Construir la imagen
sudo docker build -t TUUSUARIO/ubuntuweb:local .
sudo docker images

# 3. Correr el contenedor
sudo docker run --name webprueba -d -p 9000:80 TUUSUARIO/ubuntuweb:local
sudo docker ps

# 4. Probar
curl -s http://127.0.0.1:9000
# Host: http://192.168.100.5:9000

# 5. Limpiar
sudo docker container stop webprueba
sudo docker container rm webprueba
```

> Reemplaza `TUUSUARIO` con tu nombre de usuario de DockerHub.

---

## PARTE 5 — Subir imagen al Registry (DockerHub)

> Requiere cuenta en [hub.docker.com](https://hub.docker.com).
> El `docker login` se hace **manualmente** (no se automatiza).

```bash
# En servidorUbuntu:

# 1. Login (interactivo — ingresa usuario y contraseña/token)
sudo docker login

# 2. Etiquetar la imagen como versión v1
sudo docker tag TUUSUARIO/ubuntuweb:local TUUSUARIO/ubuntuweb:v1
sudo docker images

# 3. Push a DockerHub
sudo docker push TUUSUARIO/ubuntuweb:v1

# 4. Probar desde clienteUbuntu
vagrant ssh clienteUbuntu
sudo docker pull TUUSUARIO/ubuntuweb:v1
sudo docker run --name webcliente -d -p 9900:80 TUUSUARIO/ubuntuweb:v1
sudo docker ps
curl -s http://127.0.0.1:9900
# Host: http://192.168.100.4:9900

# 5. Limpiar
sudo docker container stop webcliente
sudo docker container rm webcliente
```

---

## PARTE 6 — Copiar archivos desde directorio del host (COPY en build)

> Usar carpeta: `parts/part6_copy_files/` en **servidorUbuntu**.

La instrucción `COPY voldocker/ /var/www/html/` en el Dockerfile copia la
carpeta local `voldocker/` al directorio raíz de Apache dentro del contenedor.

```bash
# 1. Entrar al servidor
vagrant ssh servidorUbuntu
cd /vagrant/parts/part6_copy_files
ls

# 2. Build
sudo docker build -t TUUSUARIO/testdir:local .

# 3. Run
sudo docker run -d --name webcontainer -p 9910:80 TUUSUARIO/testdir:local
sudo docker ps

# 4. Probar
curl -s http://127.0.0.1:9910
# Host: http://192.168.100.5:9910

# 5. Ver logs y entrar al contenedor
sudo docker logs webcontainer
sudo docker exec -it webcontainer /bin/bash

# 6. Limpiar
sudo docker container stop webcontainer
sudo docker container rm webcontainer
```

---

## EJERCICIOS (INCLUIDOS)

### Ejercicio 1 — Imagen propia + DockerHub

> Carpeta: `exercises/01_dockerhub_image/`
> Ver también: [exercises/01_dockerhub_image/README.md](exercises/01_dockerhub_image/README.md)

```bash
vagrant ssh servidorUbuntu
cd /vagrant/exercises/01_dockerhub_image

sudo docker build -t TUUSUARIO/miweb:local .
sudo docker tag TUUSUARIO/miweb:local TUUSUARIO/miweb:v1
sudo docker login
sudo docker push TUUSUARIO/miweb:v1
```

---

### Ejercicio 2 — Contenedor Data Science + Jupyter

> Carpeta: `exercises/02_datascience_jupyter/`
> Ver también: [exercises/02_datascience_jupyter/README.md](exercises/02_datascience_jupyter/README.md)

```bash
vagrant ssh servidorUbuntu
cd /vagrant/exercises/02_datascience_jupyter

sudo docker build -t ds-jupyter:local .
sudo docker run --name ds -it -p 8888:8888 ds-jupyter:local
# Abre en el host: http://192.168.100.5:8888
```

> TensorFlow está comentado en el Dockerfile por su tamaño (~500 MB).
> Descomenta la línea si lo necesitas.

---

### Ejercicio 3 — Volúmenes Docker

> Carpeta: `exercises/03_volumes/`
> Ver también: [exercises/03_volumes/README.md](exercises/03_volumes/README.md)

```bash
vagrant ssh servidorUbuntu
cd /vagrant/exercises/03_volumes

mkdir -p site
echo "<h1>Hola volumen</h1>" > site/index.html

sudo docker run --name volweb -d -p 9920:80 \
  -v "$(pwd)/site:/usr/share/nginx/html:ro" nginx:alpine

curl -s http://127.0.0.1:9920
# Host: http://192.168.100.5:9920

sudo docker rm -f volweb
```

---

### Ejercicio 4 — ML Jupyter Python3 (repo externo asashiho)

> Carpeta: `exercises/04_ml_jupyter_python3/`
> Ver también: [exercises/04_ml_jupyter_python3/README.md](exercises/04_ml_jupyter_python3/README.md)

```bash
vagrant ssh servidorUbuntu
cd /vagrant/exercises/04_ml_jupyter_python3

chmod +x clone_and_patch.sh
./clone_and_patch.sh

cd ml-jupyter-python3
sudo docker build -t ml-jupyter:local .
sudo docker run --name ml -it -p 8890:8888 ml-jupyter:local
# Host: http://192.168.100.5:8890
```

> El script `clone_and_patch.sh` aplica automáticamente:
> - Comentar `libav-tools` (no disponible en Ubuntu 22.04)
> - Reemplazar `Sklearn` → `scikit-learn`

---

## Troubleshooting

### "docker: permission denied"

```bash
sudo usermod -aG docker $USER
exit
vagrant ssh servidorUbuntu
```

### No se puede acceder desde el navegador del host

```bash
# Verifica que el contenedor está corriendo
sudo docker ps

# Verifica la IP de la VM
ip a

# Prueba con curl dentro de la VM
curl -s http://127.0.0.1:PUERTO

# Verifica que la red host-only de VirtualBox esté activa
```

### `vagrant up` falla con error de red

Revisa que VirtualBox pueda crear redes host-only. En algunas versiones puede
requerir configuración adicional en `/etc/vbox/networks.conf`.

---

## ⛔ NO INCLUIDO: DESAFÍOS (NO HACER)

Los siguientes puntos del documento guía original **no están implementados**
en este repositorio:

- **Desafío 1**: CUDA + Python + Docker (requiere GPU NVIDIA)
- **Desafío 2**: Docker dentro de LXD (contenedores anidados)
- **Desafío 3**: Docker + Flask (`omondragon/docker-flask-example`)
