# Instructions

1. Please be sure you have installed docker and docker compose.
2. Please take in consideration this tutorial only works using the business image from portainer.io (You will require a valid license key)
3. Execute the command, this execution will create a directory "certs" with one certificate (Includes the SAS Recommendation) and key for each service.
```sh
chmod +x setup.sh
```
4. Execute the next command to create the required certificates.
```sh
./setup.sh
```
5. Execute the next command to start the Seven (7) Container:
    - portainer (Container running the tool)
    - registry-1 (Container running a service registry)
    - registry-2 (Container running a service registry)
    - registry-3 (Container running a service registry)
    - docker-staging (Container running a Docker in Docker service, the objective its to serve the containers of stating environment)
    - docker-prod (Container running a Docker in Docker service, the objective its to serve the containers of stating environment)
```docker
docker compose up
```
### Please look at the directory "instructions-images" for the next steps
6. Go to (https://localhost:9444) and setup the initial user and password
7. Go to Registries option in **Portainer.io (localhost:9444)** and add each Registry
    - registry-1
    - registry-2
    - registry-3
    Using the web interface remember the port should be 5000. (Please check the attached images for details) 
    - After you added the registry click on **Browse** you will see and error **Registry management configuration required** Click in the option **"Configure this registry"** -> Enable TLS and use the registry-1.cert and registry-1.key created at step 3, each container will have their own certificate and key. **TLS CA Certificate always use rootCA.pem**

8. Go to Environments option in **Portainer.io (localhost:9444)** and add the two containers (docker-staging, docker-prod) use the option **Docker Standalone** -> **API** you will need to active TLS verification and use the certificates created at step 3.**TLS CA Certificate always use rootCA.pem**

9. After following the previous steps your will have:
    - Portainer service managing:
        - 3 Registries (Secure Traffic SSL)
        - 2 Environments (Secure Traffic SSL)

## Notes:
Please remember to select one environment in portainer (Do not use local).