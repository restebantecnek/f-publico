# Creación de registro de contenedores privado en Docker con certificado privado y autenticación

1. bajar el archivo `install_registry.sh` en una carpeta en el servidor de registry privado
2. cambiar las propriedades del script para ejecutable con 'chmod +x install_registry.sh`
3. correr el script con las variables de **nombre de certificado**, **usuario del registry** y **clave**, por ejemplo:
  - `./install_registry fe1 admin portainer1234`
4. copiar el certificado generado en `~/registry/certs/fe1.crt` para el nodo manager del cluster docker swarm
5. mover el archivo `fe1.crt` en el nodo manager de docker swarm para la carpeta `/usr/local/share/ca-certificates`
6. correr el comand `update-ca-certificates`
7. reiniciar docker swarm