# punktDe/ansible-docker

A Docker role which can be used to deploy Docker containers as SystemD services.

Installs the latest version of Docker from the official repos

Compatible with Ubuntu 20.04 and 22.04

### Usage
Create a template in the role that manages your docker container with the following contents:
```
#jinja2: trim_blocks: False
{%- import (role_path + "/../docker/templates/systemd/container.service")|relpath(playbook_dir) as service with context -%}
{{ service.All(example_container) }}
```

Configure the container parameters using Ansible variables
```yaml
example_container:
  container_name: example
  image: example:latest
  container_stop_timeout: 55
  volumes:
    "/etc/config.cfg": { host_dir: "/var/example/config.cfg", relabel: unshared, read_only: yes }
  ports:
    8080: 80
  environment:
    KEY: "value"
  entrypoint:
    /etc/entrypoint
  command:
    echo "hello world"
```

Finally, provision the service file:
```yaml
- name: Install systemd service for example_container
  template:
    src: example_container.service
    dest: "/etc/systemd/system/example_container.service"
```


### Custom networks
This role can be used to create custom Docker networks in the following format:
```yaml
docker:
  networks:
    - name: example_network
      subnet: 10.22.11.0/24
    - name: example_network_2
      subnet: 172.156.11.0/24
```

The networks will then be created automatically on system boot using SystemD services.

A container can then be connected to a network as follows:
```yaml
example_container:
  network:
    name: example_network
    ip: 10.22.11.21
```

If the appropriate network exists, its SystemD service will be added as a dependency to the container's service.

Alternatively, if you'd like to omit the IP address (for example, with `host` network), the following structure can be used:
```yaml
example_container:
  network: example_network
```
