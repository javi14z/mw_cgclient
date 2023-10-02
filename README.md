# Docker COMMANDS:

**Lift the container with:**
```
docker compose up --build -d
```
**Stop all containers with:**
```
docker stop $(docker ps -q)
```


## SSH CONEXION:

**cgclient:**

Port 2222 of the host mapped to 22 of the container:
```
ssh -p 2222 cognet@localhost
```

**cgserver:**

Port 2224 of the host mapped to 22 of the container:
```
ssh -p 2224 cognet@localhost
```

**ddosserver:**

Port 2226 of the host mapped to 22 of the container:
```
ssh -p 2226 cognet@localhost
```

**ddosserver:**

Port 2228 of the host mapped to 22 of the container:
```
ssh -p 2228 cognet@localhost
```


## Supervisor:
In the supervisord folder you can configure services to run automatically (most of them are currently commented)


## Xming (Dsiplay X11):
For correct operation, install Xming (Windows)


## Problemas:

CGOwncloud.sh - error linea 104 (no está conectado al servidor interno)

CGYoutubeRequest.sh - index fail tanto en mv como cointainer

CGWebVideo_x.sh - errores varios

CGApacherequets.sh - index fail tanto en mv como cointainer

CGTest17.sh - linea 101 owncloud (comando)

CGTest18.sh - eror linea owncloud (comando) y usleep



## Dudas:


