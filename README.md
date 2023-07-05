# punktDe/ansible-docker

A Docker role which can be used to deploy Docker containers as SystemD services.

Installs the latest version of Docker from the official repos

Compatible with Ubuntu 20.04 and 22.04

### Usage
Create a template in the role that manages your docker container with the following contents:
```
{%- import (role_path + "/../docker/templates/systemd/container.service")|relpath(playbook_dir) as service with context -%}
{{ service.All(example_container) }}
```

Configure the container parameters using Ansible variables
```
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
```
- name: Install systemd service for example_container
  template:
    src: example_container.service
    dest: "/etc/systemd/system/example_container.service"
```
