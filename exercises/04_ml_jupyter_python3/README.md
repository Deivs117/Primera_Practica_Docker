# Ejercicio 4 — ML Jupyter Python3 (repo externo asashiho/ml-jupyter-python3)

## Objetivo

Construir y ejecutar el contenedor del repositorio
[asashiho/ml-jupyter-python3](https://github.com/asashiho/ml-jupyter-python3),
que proporciona Jupyter Notebook con TensorFlow y Scikit-learn para
Machine Learning.

## Pasos (en servidorUbuntu)

```bash
vagrant ssh servidorUbuntu
cd /vagrant/exercises/04_ml_jupyter_python3

# 1. Clonar el repo y aplicar los parches automáticamente
chmod +x clone_and_patch.sh
bash ./clone_and_patch.sh

# 2. Entrar al directorio clonado
cd ml-jupyter-python3

# 3. Construir la imagen (puede tardar varios minutos)
sudo docker build -t ml-jupyter:local .

# 4. Levantar el contenedor
sudo docker run --name ml -it -p 8890:8888 ml-jupyter:local
# Host: http://192.168.100.5:8890

# Para correr en background:
sudo docker run --name ml -d -p 8890:8888 ml-jupyter:local
sudo docker logs ml   # ver el link con token

# 5. Limpiar
sudo docker rm -f ml
```

## Qué hace `clone_and_patch.sh`

1. Clona `asashiho/ml-jupyter-python3` si no existe en el directorio actual.
2. **Comenta `libav-tools`** en el Dockerfile si existe (paquete descontinuado
   en Ubuntu 22.04+, ya no disponible en los repos oficiales).
3. **Reemplaza `Sklearn` por `scikit-learn`** en el Dockerfile si aparece (nombre
   de paquete pip correcto).

## Troubleshooting

| Problema | Solución |
|---|---|
| `libav-tools` no se encuentra | El patch lo comenta automáticamente |
| `sklearn` / `Sklearn` no se instala | El patch lo reemplaza por `scikit-learn` |
| Build tarda mucho | Normal, TensorFlow + deps son pesados (~2 GB) |
| Puerto 8890 no accesible | Verificar con `sudo docker ps` y `ip a` dentro de la VM |
| Error de memoria | Aumentar RAM de la VM en el Vagrantfile (memory = "4096") |

## Notas

- La primera vez que se construye la imagen puede tardar **10–20 minutos**
  dependiendo de la velocidad de red.
- Si el build falla por otro paquete descontinuado, revisa el Dockerfile en
  `ml-jupyter-python3/Dockerfile` y comenta la línea problemática manualmente.
