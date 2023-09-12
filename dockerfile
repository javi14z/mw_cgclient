FROM ubuntu:18.04 AS build

# Instalación de paquetes necesarios, limpieza de cache y archivos temporales
RUN apt-get update && \
    apt-get install -y  wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

#Instalación de DropBox --> https://www.dropbox.com/es_ES/install?os=lnx y de geckodriver
RUN cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf - && \
cd ~ && wget -O - "https://github.com/mozilla/geckodriver/releases/download/v0.30.0/geckodriver-v0.30.0-linux64.tar.gz" | tar xzf -


FROM ubuntu:18.04

# Instalación de paquetes necesarios, limpieza de cache y archivos temporales
RUN apt-get update && \
    apt-get install -y python3 sudo vim net-tools openssh-server vlc bc firefox \
    curl openvpn supervisor python3-pip && \
    pip3 install selenium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Creamos el nuevo usuario con su contraseña y lanzamos el servicio ssh
RUN useradd -m -s /bin/bash -g root -G sudo -u 1000 cognet  && \
echo "cognet:supercognet" | chpasswd && \
service ssh start

#Configurar pantalla
ENV DISPLAY=host.docker.internal:0.0


# Establece el directorio de trabajo dentro del contenedor
WORKDIR /home/cognet
# Copia los archivos del directorio /app al directorio de trabajo del contenedor
COPY /app .
# Copia los archivos necesarios desde la etapa de construcción
COPY --from=build /root /root
# Agrega configuración para supervisord
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Inicia supervisord en primer plano para evitar cierre de contenedor
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]


# Permite que el contenedor se quede en ejecución
#CMD [ "tail", "-f", "/dev/null" ]
