````md
# Práctica Contenedores Docker (Vagrant + Ubuntu 22.04 + Docker CE)

Repositorio para ejecutar la práctica de Docker con **2 máquinas Ubuntu 22.04 en Vagrant** (cliente/servidor) y **Docker preinstalado vía aprovisionamiento**.

> Importante: **NO incluye ni desarrolla los “Desafíos” (puntos 5–7).**

---

## 0. Requisitos (host)

- VirtualBox
- Vagrant
- CPU con virtualización activa (VT-x/AMD-V)
- Espacio en disco: 10+ GB libres (recomendado)

---

## 1. Topología y VMs

Se levantan 2 VMs Ubuntu 22.04:

- **clienteUbuntu**: `192.168.100.4`
- **servidorUbuntu**: `192.168.100.5`

Ambas quedan con Docker instalado automáticamente al hacer `vagrant up --provision`.

---

## 2. Estructura del repo

- `Vagrantfile` → define las 2 VMs
- `provision/`
  - `install_docker.sh` → instala Docker CE + compose plugin en Ubuntu 22.04
  - `common.sh` → helpers (si aplica)
- `scripts/` (atajos opcionales)
  - `up.sh`, `ssh_server.sh`, `ssh_client.sh`, `status.sh`
- `parts/`
  - `part4_custom_image/` → ejemplo para construir imagen propia (apache + html)
  - `part6_copy_files/` → ejemplo para copiar carpeta local al contenedor (COPY)
- `exercises/`
  - `01_dockerhub_image/`
  - `02_datascience_jupyter/`
  - `03_volumes/`
  - `04_ml_jupyter_python3/`
- `docs/` → documento original + notas

---

## 3. Quickstart

### 3.1 Levantar las VMs (con aprovisionamiento)
Desde la raíz del repo:

```bash
vagrant up --provision
vagrant status
````

### 3.2 Entrar por SSH

```bash
vagrant ssh servidorUbuntu
# o
vagrant ssh clienteUbuntu
```

### 3.3 Verificar Docker

En cada VM:

```bash
docker --version || sudo docker --version
sudo systemctl status docker --no-pager
sudo docker run hello-world
```

> Si quieres ejecutar `docker` sin `sudo`:

```bash
sudo usermod -aG docker $USER
exit
# vuelve a entrar con vagrant ssh
```

---

## PARTE 1 — Configuración de Vagrant

El `Vagrantfile` ya viene configurado con las dos VMs y la red privada.

Comandos:

```bash
vagrant up --provision
vagrant status
vagrant ssh servidorUbuntu
vagrant ssh clienteUbuntu
```

---

## PARTE 2 — Instalación de Docker en Ubuntu 22.04 (ya automatizada)

Esta parte queda hecha por `provision/install_docker.sh`.

Validación:

```bash
sudo docker info | more
sudo systemctl status docker --no-pager
```

---

## PARTE 3 — Descargar imagen existente y correr servicio (httpd)

> Se hace en **servidorUbuntu**.

1. Entrar a servidor:

```bash
vagrant ssh servidorUbuntu
```

2. Buscar imágenes:

```bash
sudo docker search apache
```

3. Descargar httpd:

```bash
sudo docker pull httpd
sudo docker images
```

4. Ejecutar contenedor:

```bash
sudo docker run -d --name web1 -p 8800:80 httpd
sudo docker ps
```

5. Probar el servicio:

* Desde el **host**: abre `http://192.168.100.5:8800`
* O desde la VM:

```bash
curl -I http://127.0.0.1:8800
curl -s http://127.0.0.1:8800 | head
```

6. Detener y borrar contenedor:

```bash
sudo docker container stop web1
sudo docker container rm web1
sudo docker container ls -a
```

---

## PARTE 4 — Imagen Docker propia (Ubuntu + Apache + HTML)

> Usar carpeta: `parts/part4_custom_image/` en **servidorUbuntu**.

1. Entrar a servidor:

```bash
vagrant ssh servidorUbuntu
cd /vagrant/parts/part4_custom_image
ls
```

2. Construir la imagen:

```bash
sudo docker build -t TUUSUARIO/ubuntuweb:local .
sudo docker images
```

3. Correr contenedor:

```bash
sudo docker run --name webprueba -d -p 9000:80 TUUSUARIO/ubuntuweb:local
sudo docker ps
```

4. Probar:

* Host: `http://192.168.100.5:9000`
* VM:

```bash
curl -s http://127.0.0.1:9000
```

5. Limpiar:

```bash
sudo docker container stop webprueba
sudo docker container rm webprueba
```

---

## PARTE 5 — Subir imagen al Registry (DockerHub)

> Requiere cuenta de DockerHub. Se hace login manualmente.

1. Login:

```bash
sudo docker login
```

2. Tag versión v1:

```bash
sudo docker tag TUUSUARIO/ubuntuweb:local TUUSUARIO/ubuntuweb:v1
sudo docker images
```

3. Push:

```bash
sudo docker push TUUSUARIO/ubuntuweb:v1
```

4. Probar desde **clienteUbuntu**:

```bash
vagrant ssh clienteUbuntu
sudo docker pull TUUSUARIO/ubuntuweb:v1
sudo docker run --name webcliente -d -p 9900:80 TUUSUARIO/ubuntuweb:v1
sudo docker ps
```

5. Verificar:

* Host: `http://192.168.100.4:9900`
* VM:

```bash
curl -s http://127.0.0.1:9900
```

6. Limpiar:

```bash
sudo docker container stop webcliente
sudo docker container rm webcliente
```

---

## PARTE 6 — Copiar archivos desde directorio del host (COPY en build)

> Usar carpeta: `parts/part6_copy_files/` en **servidorUbuntu**.

1. Entrar a servidor:

```bash
vagrant ssh servidorUbuntu
cd /vagrant/parts/part6_copy_files
ls
```

2. Build:

```bash
sudo docker build -t TUUSUARIO/testdir:local .
```

3. Run:

```bash
sudo docker run -d --name webcontainer -p 9910:80 TUUSUARIO/testdir:local
sudo docker ps
```

4. Probar:

* Host: `http://192.168.100.5:9910`
* VM:

```bash
curl -s http://127.0.0.1:9910
```

5. Logs y exec:

```bash
sudo docker logs webcontainer
sudo docker exec -it webcontainer /bin/bash
```

6. Limpiar:

```bash
sudo docker container stop webcontainer
sudo docker container rm webcontainer
```

---

# 4. EJERCICIOS (INCLUIDOS)

## Ejercicio 1 — Imagen propia + DockerHub

Carpeta: `exercises/01_dockerhub_image/`

Objetivo: construir una imagen con sitio web personalizado y subirla a DockerHub.

Comandos (en servidorUbuntu):

```bash
cd /vagrant/exercises/01_dockerhub_image
sudo docker build -t TUUSUARIO/miweb:local .
sudo docker tag TUUSUARIO/miweb:local TUUSUARIO/miweb:v1
sudo docker login
sudo docker push TUUSUARIO/miweb:v1
```

---

## Ejercicio 2 — Contenedor Data Science e IA (Jupyter + libs)

Carpeta: `exercises/02_datascience_jupyter/`

```bash
cd /vagrant/exercises/02_datascience_jupyter
sudo docker build -t ds-jupyter:local .
sudo docker run --name ds -it -p 8888:8888 ds-jupyter:local
# abre el link/token que imprime Jupyter
```

---

## Ejercicio 3 — Volúmenes Docker

Carpeta: `exercises/03_volumes/`

```bash
cd /vagrant/exercises/03_volumes
mkdir -p site
echo "<h1>Hola volumen</h1>" > site/index.html

sudo docker run --name volweb -d -p 9920:80 \
  -v "$(pwd)/site:/usr/share/nginx/html:ro" nginx:alpine

curl -s http://127.0.0.1:9920
```

Limpiar:

```bash
sudo docker rm -f volweb
```

---

## Ejercicio 4 — Contenedor IA (TensorFlow + Scikit-learn) desde repo externo

Carpeta: `exercises/04_ml_jupyter_python3/`

```bash
cd /vagrant/exercises/04_ml_jupyter_python3
./clone_and_patch.sh
cd ml-jupyter-python3
sudo docker build -t ml-jupyter:local .
sudo docker run --name ml -it -p 8890:8888 ml-jupyter:local
```

Notas:

* Si falla `libav-tools`: comentar esa línea en Dockerfile.
* Cambiar `Sklearn` por `scikit-learn` donde aplique.

---

# NO INCLUIDO: DESAFÍOS (NO HACER)

* CUDA + Python + Docker (GPU)
* Docker dentro de LXD
* Docker + Flask (repo omondragon/docker-flask-example)

---

## Troubleshooting rápido

* “docker: permission denied” → agrega usuario al grupo docker y reingresa:

```bash
sudo usermod -aG docker $USER
exit
vagrant ssh servidorUbuntu
```

* Si no abre en navegador del host:

  * prueba `curl` dentro de la VM
  * revisa IPs con `ip a`
  * revisa que la red host-only de VirtualBox esté activa

````



