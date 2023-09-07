FROM ubuntu:18.04

# Instalación de paquetes necesarios
RUN apt-get update && \
    apt-get install -y python sudo vim net-tools openssh-server vlc bc chromium-browser xvfb curl openvpn supervisor


# Creamos el nuevo usuario con su contraseña y lanzamos el servicio ssh
RUN useradd -m -s /bin/bash -g root -G sudo -u 1000 cognet  && \
echo "cognet:supercognet" | chpasswd 
#Iniciamos el servicio ssh
RUN service ssh start


# Establece el directorio de trabajo dentro del contenedor
WORKDIR /home/cognet
# Copia los archivos del directorio /app al directorio de trabajo del contenedor
COPY /app .


#Instalación de DropBox --> https://www.dropbox.com/es_ES/install?os=lnx
RUN cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -


# Agrega configuración para supervisord
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# Inicia supervisord en primer plano para evitar cierre de contenedor
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]


# Permite que el contenedor se quede en ejecución
#CMD [ "tail", "-f", "/dev/null" ]
