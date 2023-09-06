**Docker commands:**

1. docker compose up --build -d
2. Stop all containers with: docker stop $(docker ps -q)


**Next goals:**

- Enable ssh conexion (done)
- Dedicated container exclusively for dropbox service (done)
- Generate traffic

**Problemas:**

CGDropbox - El cliente de dropbox no es compatible de manera directa con alpine. Se puede solucionar utilizando un contenedor exclusivo para correr el servicio de Dropbox en Ubuntu y el resto de servicios en Alpine.

CGOwncloud.sh - error linea 104 (no está conectado al servidor interno)

CGYoutubeRequest.sh - index fail tanto en mv como cointainer

CGWebVideo_x.sh - errores varios

CGApacherequets.sh - index fail tanto en mv como cointainer

CGTest17.sh - linea 101 owncloud (comando)

CGTest18.sh - eror linea owncloud (comando) y usleep

