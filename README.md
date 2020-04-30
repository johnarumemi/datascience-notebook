# Datascience Docker Image

This contans the Dockerfile that I use for my general datascience container. <br>
It launches a jupyter lab server on port 8888. <br>
A docker-compose file is also included that spawns a full setup. <br>
<br>
The compose files uses the following environment variable(s),
<br>

+ JLAB_HOST_PORT : Host port to access the jupyter lab notebook. Default is 8889.

+ NOTEBOOKS_DATA : This is the path to the local machines directory that stores our jupyter notebooks. <br>
		               This will be mounted to /home/jovyan/work within the containera

+ PG_PASSWORD    : This is the password for postgres database user that is created on initial creation of the container. <br>
                   This must be defined in your environment variables or passed to docker compose.

+ IEX_TOKEN	: This is the API key I use for access market ticker data from the IEX platform

+ ALPHA_VANTAGE_API : API key for accessing market tocker data from the Alpha Vantage platform.
<br>
The compose files also creates a volume that is managed by docker-compose that is mounted to
the home directory of the jupyter-lab container, /home/jovyan .
<br>

see the .env file for other environment variables required

