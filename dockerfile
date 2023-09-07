FROM ubuntu:18.04

# Instalación de paquetes necesarios
RUN apt-get update && \
    apt-get install -y python sudo vim net-tools openssh-server vlc bc chromium-browser xvfb curl openvpn supervisor

# Modificamos ssh para que podamos hacer login con contraseña
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

RUN service ssh start

# Creamos el nuevo usuario con su contraseña 
RUN useradd -m cognet && echo "cognet:supercognet" | chpasswd

#Instalación de DropBox
RUN cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /home/cognet

# Copia los archivos del directorio /app al directorio de trabajo del contenedor
COPY /app .


# Agrega configuración para supervisord
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# Inicia supervisord
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]


# Permite que el contenedor se quede en ejecución
#CMD [ "tail", "-f", "/dev/null" ]
