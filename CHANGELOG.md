## Recent Changes

### 2026-07-19
* Updated stack:
  * PostgreSQL client: 18.4
  * Elixir 1.20.1
  * Erlang/OTOP 29
  * Phoenix Framework 1.8.9
  * Alpine Linux 3.23.5

### 2026-05-07
* Updated image to Phoenix Framework 1.8.7

### 2026-04-17
* Updated stack:
  * PostgreSQL client: 18.3
  * Alpine Liinux: 3.23.4

### 2026-03-07
* Updated Phoenix Framework 1.8.5

### 2026-02-16
* Updated stack:
  * PostgreSQL client 18.2
  * Elixir 1.19.5
  * Erlang/OTOP 28
  * Phoenix Framework 1.8.3
  * Alpine Linux 3.23.2

### 2025-11-25
* Update to Elixir 1.19.3 and Phoenix Framework 1.8.2

### 2025-08-30
* Update latest image to Phoenix Framework 1.8.1.  
* Fix run commands.  

### 2025-08-06
* Updated to Phoenix Framework 1.8.0.  

### 2025-05-20
* Igniter and Tidewave are now part of the base image.   

See [MCP docs](https://hexdocs.pm/tidewave/mcp.html) for editor support.  


### 2025-04-19
* New base image elixir:1.18-alpine.


### 2025-03-02
Added __phoenix__ system account and set /opt/phoenix as the default 
container directory. 

The prepare script has been internalized and the functionality moved 
to the docker-entrypoint.sh file. 

Running the container now depends on a couple of environment variables 
to be passed to the container.

* APP_NAME - the name of the Phoenix application to be setup or run.  
* ECTO - a y/n flag (defaults to n) to include database support in the 
    Phoenix application  

Ecto support in the docker-entrypoint script is designed to work with the docker 
phoenix-compose project (see Companion Project below).

Mix and hex are now installed under the /opt/phoenix directory.