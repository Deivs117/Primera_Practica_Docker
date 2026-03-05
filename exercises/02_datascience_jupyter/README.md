# Ejercicio 2 — Contenedor Data Science + Jupyter

## Objetivo

Levantar un contenedor con Jupyter Notebook y las principales librerías de
Data Science / IA preinstaladas.

## Librerías incluidas

| Librería | Uso |
|---|---|
| `numpy` | Cómputo numérico |
| `pandas` | Manipulación de datos |
| `matplotlib` | Visualización |
| `scikit-learn` | Machine Learning |
| `seaborn` | Visualización estadística |
| `scipy` | Cómputo científico |
| `tensorflow` *(opcional)* | Deep Learning |

> TensorFlow está comentado en el Dockerfile porque puede tardar mucho en
> construir y pesa ~500 MB. Descomenta la línea si lo necesitas.

## Comandos (en servidorUbuntu)

```bash
# 1. Entrar a la VM y navegar a la carpeta
vagrant ssh servidorUbuntu
cd /vagrant/exercises/02_datascience_jupyter

# 2. Construir la imagen
sudo docker build -t ds-jupyter:local .

# 3. Levantar el contenedor
sudo docker run --name ds -it -p 8888:8888 ds-jupyter:local
# Abre en el host: http://192.168.100.5:8888

# 4. Para correr en background:
sudo docker run --name ds -d -p 8888:8888 ds-jupyter:local
sudo docker logs ds   # ver el link con token si aplica

# 5. Limpiar
sudo docker rm -f ds
```

## Nota sobre TensorFlow

Si quieres incluir TensorFlow, edita el Dockerfile y descomenta la línea:

```dockerfile
RUN pip install --no-cache-dir tensorflow
```

También puedes usar la imagen oficial:

```bash
sudo docker run --name tf -it -p 8888:8888 \
  tensorflow/tensorflow:latest-jupyter
```
