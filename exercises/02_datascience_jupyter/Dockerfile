FROM python:3.11-slim

WORKDIR /notebooks

# Instalar Jupyter y librerías de Data Science / IA
RUN pip install --no-cache-dir \
    jupyter \
    numpy \
    pandas \
    matplotlib \
    scikit-learn \
    seaborn \
    scipy

# TensorFlow es opcional: descomenta si tienes suficiente RAM/disco (~500 MB)
# RUN pip install --no-cache-dir tensorflow

EXPOSE 8888

CMD ["jupyter", "notebook", \
     "--ip=0.0.0.0", \
     "--port=8888", \
     "--no-browser", \
     "--allow-root", \
     "--NotebookApp.token=''", \
     "--NotebookApp.password=''"]
